% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% TODO:
%   + add faces to simkinect for constructing room efficiently
%   + maybe rewrite evolv ZBuffer()? decouples reweight of sigma for density...

%% Environment =================================================================
clear();
clc();

% path
addpath(genpath('C:\Users\Floor 1 Imager\Documents\code\imager\'));
addpath(genpath('C:\Users\Floor 1 Imager\Documents\code\utility\'));

% initiate memory
ImagerReset();

% clear unused imager structures
clear cal cam register swi xcvr

%% Imager Parameters ===========================================================
% labwork
project = 'imager';
study = 'puppet';
trial = 'male';

% folders
home = 'C:\Users\Floor 1 Imager\Documents\';
folder = Folders(home, project, study, trial);
addpath(folder.study);

% imager study parameters
eval(['Parameters_',study,'()']);

%% Sim Parameters ==============================================================
puppet_path = [folder.trial, 'puppet.txt'];
anim_path   = [folder.trial, 'animation.txt'];
save_path   = [folder.trial, 'recon']; % output image *.mat base path

% puppet
delta_kinect = 0.020; % [m] lowest fidelity
delta_stitch = 0.010; % [m] medium fidelity
delta_sim    = 0.007; % [m] highest fidelety
profile_stitch = [0.02, 0.04]; % [m] stitch cactus profile

% simkinect
point_size = 0.01;

% frames
frame_start = 30;
frame_step = 1;
frame_end = 100;

% gif
gif_base    = [folder.trial, 'out'];
gif_delay   = [0.0333, 2.0];

% vertical kinect
camera(1).device = 'k1';
camera(1).A_ik.M = [...
    +0.127320117, +0.166172290, +0.977842705; ...
    -0.007635183, -0.985672591, +0.168497023; ...
    +0.991832290, -0.028919069, -0.124227194];
camera(1).A_ik.v = [-0.021992248; -0.446040039; +0.141695780];
% horizontal kinect
camera(2).device = 'k1';
camera(2).A_ik.M = [...
    +0.010608515, -0.001881171, +0.999941958; ...
    +0.999943706, -0.000186968, -0.010608885; ...
    +0.000206914, +0.999998213, +0.001879082];
camera(2).A_ik.v = [-0.014288801; +0.062099980; -0.052768100];

% stitch volume
stitch_space = Space('R3');
pitch = [0.01 , 0.01, 0.01]; % [m]
%extent = [-0.15, 0.15; -0.15, 0.15; -0.1, 1.1]; % [m] slinky
extent = [-0.7, 0.7; -0.2, 0.3; -0.15, 1.9]; % [m] male
stitch_space = SpaceSet(stitch_space, 'Extent', extent, 'Pitch', pitch);

clear extent pitch

%% Align Imager ================================================== [DO NOT EDIT]
% scan to creaform
[align.A_cs, align.A_co, align.index, align.scans, align.epsilon] = AlignImager(...
    align.tPath,...
    align.mPath,...
    align.sPath,...
    align.cFile,...
    align.codes,...
    align.radii);

% creaform to imager
align.A_ic = AffineInverse(align.A_co(align.originIndex));

%% Build Imager ================================================== [DO NOT EDIT]
% tx antennas
ant.tx = cell(1, numel(align.txIndex));
% load
for i = 1 : numel(align.txIndex)
    ant.tx{i} = load([align.sPath, align.scans{align.txIndex(i)}]);
end
% pose
ant.tx = AntennaPose(ant.tx, AffineCompose(align.A_ic, align.A_cs(align.txIndex)));

% rx antennas
ant.rx = cell(1, numel(align.rxIndex));
% load
for i = 1 : numel(align.rxIndex)
    ant.rx{i} = load([align.sPath, align.scans{align.rxIndex(i)}]);
end
% pose
ant.rx = AntennaPose(ant.rx, AffineCompose(align.A_ic, align.A_cs(align.rxIndex)));

% sx antennas
ant.sx = cell(1, numel(align.sxIndex));
% load
for i = 1 : numel(align.sxIndex)
    ant.sx{i} = load([align.sPath, align.scans{align.sxIndex(i)}]);
end
% pose
ant.sx = AntennaPose(ant.sx, AffineCompose(align.A_ic, align.A_cs(align.rxIndex)));

clear i

%% Build Operator ================================================ [DO NOT EDIT]
[recon, ant] = OperatorInitiate(recon, select, ant);
recon = OperatorBuild(recon, ant, roi);

%% Save Operator ================================================= [DO NOT EDIT]
% save operator
try
    space = recon.space; %#ok<NASGU>
    operator = recon.operator;
    if strcmp(operator, 'dipoles+H')
        % Dipoles+H
        H = recon.H; %#ok<NASGU>
        save([folder.data, 'operator.mat'], 'select', 'space', 'operator', 'H', '-v7.3');
    else
        % Lookup+APB
        apb = recon.apb; %#ok<NASGU>
        save([folder.data, 'operator.mat'], 'select', 'space', 'operator', 'apb', '-v7.3');
    end
    fprintf('Operator saved\n');
catch
    warning('Operator not saved');
end

clear space operator H apb

%% Load Operator ================================================= [DO NOT EDIT]
% operator, select, space
try
    % load
    data = load([folder.study, 'operator.mat']);
    
    % select
    select = data.select;
    % space
    recon.space = data.space;
    % operator
    recon.operator = data.operator;
    if strcmp(recon.operator, 'dipoles+H')
        % dipoles + H
        recon.H = data.H;
    elseif strcmp(recon.operator, 'lookup+APB')
        % lookup + APB
        recon.apb = data.apb;
    end
    
    % initiate operator
    [recon, ant] = OperatorInitiate(recon, select, ant);
    
    % status
    fprintf('Operator, select, and space loaded\n');
catch
    warning('Failed to load operator');
end

clear data

%% Initiate Sim ================================================================
% scan in puppet data
puppet = PuppetScan(puppet_path);
anim   = PuppetAnimScan(anim_path);

% build kinect puppet (lowest fidelity puppet)
fprintf('Building kinect puppet...\n');
puppet = PuppetVisibility(puppet, [1, 0, 1, 0]); % body and gun
puppet = PuppetRefine(puppet, delta_kinect);
kinect_puppet = puppet;

% build stitch puppet (medium fidelity puppet)
fprintf('Building stitch puppet...\n');
puppet = PuppetRefine(puppet, delta_stitch);
puppet = PuppetVisibility(puppet, [1, 0, 0, 0]); % body only
stitch_puppet = PuppetCactus(puppet, profile_stitch);

% build sim puppet (high fidelity puppet)
fprintf('Building simulation puppet...\n');
puppet = PuppetVisibility(puppet, [1, 0, 1, 0]); % body and gun
sim_puppet = PuppetRefine(puppet, delta_sim);

% get sim puppet reflectivity and faces
sigma = PuppetGet(sim_puppet, '#reflectivity');
faces = PuppetGet(sim_puppet, 'faces');
faces = int32(faces);

% map stitch puppet vertices to stitch indices (does not clip indices!)
Rs = PuppetGet(stitch_puppet, 'vertices');
fprintf('Mapping puppet to stitch space... ');
Rsi = Raster(Rs, stitch_space);
fprintf('[Done]\n');

% global playback structure
global PLAYBACK
nframes = numel(anim.A);
PLAYBACK.nframes = nframes;

%% Run Simulation ================================================ [DO NOT EDIT]
% initate stitch
stitch = zeros(stitch_space.count);
% run
for frame = frame_start : frame_step : frame_end
    
%% Deform Puppet ================================================= [DO NOT EDIT]
    % set playback frame
    PLAYBACK.frame = frame;
    
    % pose and deform simulation puppet
    sim_puppet = PuppetPose(sim_puppet, anim, frame);
    R = PuppetGet(sim_puppet, 'vertices');
    
    % pose and deform kinect puppet
    kinect_puppet = PuppetPose(kinect_puppet, anim, frame);
    Rk = PuppetGet(kinect_puppet, 'vertices');
    
    % pose and deform stitch puppet
    stitch_puppet = PuppetPose(stitch_puppet, anim, frame);
    Rs = PuppetGet(stitch_puppet, 'vertices');
    
%% Simulate Rf =================================================== [DO NOT EDIT]
    % % occlusion
    % fprintf('  Sample Target... ');
    % R2 = OccludePoints(R, recon.space.extent, 0.05, +1);
    % R2 = R(:, R(1,:) < 1.25); % cutoff
    % fprintf('[Done]\n');
    
    % % assign reflectance
    % fprintf('  Balancing Sigma... ');
    % sigma = BalanceSigma(sigma, R2, 0.01);
    
    % occlusion and object sampling
    
    object.vert = R.';
    object.face = faces.';
    object.sigma = sigma.';
    object = ZBuffer(object, 0.005);
    Rz = object.locs.';
    sigmaz = object.sigma;
    
    % simulate rf
    fprintf('  Simulating Rf...\n');
    gv = forward_model(ant.tx, ant.rx, sigma, Rz.');
    
    % convert to metaimager format
    g = cell(numel(ant.tx), numel(ant.rx));
    for i = 1 : numel(ant.tx)
        for j = 1 : numel(ant.rx)
            g{i, j} = squeeze(gv(i, j, :));
        end
    end
    signal.g = g;

    % dummy bg and cal
    signal.b = GZero(numel(g{1}), size(g));
    signal.c = GOne(numel(g{1}), size(g));
    
    clear object gv g i j

%% Simulate Kinect =============================================== [DO NOT EDIT]
    % simulate cameras
    for i = 1 : numel(camera)
    
        % fake kinect metric signal
        fprintf('  Simulating kinect... ');
        metric = SimKinect(camera(i).device, camera(i).A_ik, Rk, point_size);
        camera(i).metric = metric;
    
        % generate kinect mask
        mask = metric(:, :, 1) == 0 & metric(:, :, 2) == 0 & metric(:, :, 3) == 0;
        mask = ~mask;
        % mask = medfilt2(mask, [15, 15]); % todo: simulate bg, fg, and add noise
        camera(i).mask = mask;
    end
    
    clear i metric mask

%% Build Roi ===================================================== [DO NOT EDIT]
    fprintf('  Building Roi (%s)...\n', roi.type);
    if strcmp(roi.type, 'fit')
        % fit
        roi.voxel = RoiFit(recon.space, camera, roi);
    elseif strcmp(roi.type, 'hull')
        % hull
        roi.voxel = RoiFit(recon.space, camera, roi);
        roi.voxel = RoiBox(recon.space, roi.voxel.mhull);
    elseif strcmp(roi.type, 'extent')
        % extent
        roi.voxel = RoiBox(recon.space, roi.space.extent);
    end

%% Reconstruct =================================================== [DO NOT EDIT]
    % recon
    fprintf('  Reconstructing (%s)...\n', recon.algorithm);
    recon = Reconstruct(recon, select, ant, signal, roi);
    
%% Stitch ======================================================== [DO NOT EDIT]
    if ~isempty(recon.image)
        
        % sample points (imaging volume)
        idelta = roi.voxel.ihull(:, 2) - roi.voxel.ihull(:, 1) + 1;
        Xs = linspace(roi.voxel.mhull(1, 1), roi.voxel.mhull(1, 2), idelta(1));
        Ys = linspace(roi.voxel.mhull(2, 1), roi.voxel.mhull(2, 2), idelta(2));
        Zs = linspace(roi.voxel.mhull(3, 1), roi.voxel.mhull(3, 2), idelta(3));
        [Xs, Ys, Zs] = ndgrid(Xs, Ys, Zs);
        
        % query points (stitch puppet)
        Xq = Rs(1, :);
        Yq = Rs(2, :);
        Zq = Rs(3, :);
        
        % interpolate
        Rq = interpn(Xs, Ys, Zs, abs(recon.image), Xq, Yq, Zq);
        
        % blend (max value)
        for i = 1 : numel(Rq)
            if stitch(Rsi(1, i), Rsi(2, i), Rsi(3, i)) < Rq(i)
                stitch(Rsi(1, i), Rsi(2, i), Rsi(3, i)) = Rq(i);
            end
        end
        
    end
    
    clear idelta Xs Ys Zs Xq Yq Zq Rq i

%% Draw Simulation =============================================== [DO NOT EDIT]
    fprintf('  Drawing simulation...\n');
    % figure handles
    if ~exist('fh', 'var')
        fh = gobjects(1, 6);
    end
    
    % stupid figure offset nonsense
    poop = 900;
    poop_extent = [-0.25, +2.00, -1.25, +1.00, -1.25, +1.25];
    
    % scene figure -------------------------------------------------------------
    if ~isgraphics(fh(1))
        fh(1) = MiFigure(1, [], [], [25, 1400-poop, 420, 400]);
    end
    clf(fh(1));
    ah = MiAxes(fh(1));
    colormap('parula');
    % draw simulation puppet
    [ah, ~] = PuppetDraw(ah, kinect_puppet, 'reflectivity', 'f');
    % draw antennas
    DrawAntenna(ant.tx, [0.0, 1.0, 0.0], 0.4, ah);
    DrawAntenna(ant.rx, [0.0, 0.0, 1.0], 0.4, ah);
    % draw camera
    for i = 1 : numel(camera)
        BasisDraw(ah, camera(i).A_ik, 0.1, 2.0);
    end
    % draw origin
    BasisDraw(ah, struct('M', eye(3), 'v', [0; 0; 0]), 0.2, 2.0);
    % format
    grid(ah, 'on');
    axis(ah, 'equal');
    axis(ah, poop_extent);
    view(ah, [45, 45]);
    % notate
    title(ah, sprintf('Simulation Frame %i', frame));
    xlabel(ah, 'x [m]'); ylabel(ah, 'y [m]'); zlabel(ah, 'z [m]');

    % simkinect figure ---------------------------------------------------------
    for i = 1 : numel(camera)
        if ~isgraphics(fh(i + 1))
            fh(i + 1) = MiFigure(i + 1, [], [], [460, 1400-poop, 420, 400]);
        end
        clf(fh(i + 1));
        ah = MiAxes(fh(i + 1));
        % draw metric
        hold(ah, 'on');
        imagesc(ah, flip(camera(i).metric, 2));
        hold(ah, 'off');
        % format
        axis(ah, 'equal');
        axis(ah, 'tight');
        % notate
        title(ah, sprintf('SimKinect %i Frame %i', i, frame));
        xlabel(ah, 'x [m]'); ylabel(ah, 'y [m]'); zlabel(ah, 'z [m]');
    end

    % roi figure ---------------------------------------------------------------
    if ~isgraphics(fh(4))
        fh(4) = MiFigure(4, [], [], [25, 950-poop, 420, 400]);
    end
    clf(fh(4));
    ah = MiAxes(fh(4));
    % colormap
    colormap([0.0, 1.0, 0.0]);
    % draw roi
    overlay = false((roi.voxel.ihull(:,2)-roi.voxel.ihull(:,1)+[1;1;1]).');
    for i = 1 : size(roi.voxel.index, 2)
        overlay( ...
            roi.voxel.index(1, i) - roi.voxel.ihull(1,1) + 1, ...
            roi.voxel.index(2, i) - roi.voxel.ihull(2,1) + 1, ...
            roi.voxel.index(3, i) - roi.voxel.ihull(3,1) + 1 ...
            ) = true();
    end
    DrawOverlay(overlay, roi.voxel.mhull, [0, 1], 1, 1, 0.2, ah);
    % format
    grid(ah, 'on');
    axis(ah, 'equal');
    axis(ah, poop_extent);
    view(ah, [-90, 0]);
    % notate
    title(ah, sprintf('Roi Frame %i', frame));
    xlabel(ah, 'x [m]'); ylabel(ah, 'y [m]'); zlabel(ah, 'z [m]');
    
    % recon figure -------------------------------------------------------------
    if ~isgraphics(fh(5))
        fh(5) = MiFigure(5, [], [], [460, 950-poop, 420, 400]);
    end
    clf(fh(5));
    ah = MiAxes(fh(5));
    % draw target
%     hold(ah, 'on');
%     scatter3(ah, R(1, :), R(2, :), R(3, :), 5, 'Filled');
%     hold(ah, 'off');
    % draw image
    DrawImage(ah, recon.image, roi.voxel.mhull);
    % format
    grid(ah, 'on');
    axis(ah, 'equal');
    axis(ah, poop_extent);
    view(ah, [-90, 0]);
    % notate
    title(ah, sprintf('%s Frame %i', recon.algorithm, frame));
    xlabel(ah, 'x [m]'); ylabel(ah, 'y [m]'); zlabel(ah, 'z [m]');
    
    % stitch figure ------------------------------------------------------------
    if ~isgraphics(fh(6))
        fh(6) = MiFigure(6, [], [], [460, 950-poop, 420, 400]);
    end
    clf(fh(6));
    ah = MiAxes(fh(6));
    % draw image
    DrawImage(ah, stitch, stitch_space.extent);
    % format
    grid(ah, 'on');
    axis(ah, 'equal');
    axis(ah, [stitch_space.extent(1, :),...
        stitch_space.extent(2, :), stitch_space.extent(3, :)]);
    %view(ah, [-90, 0]); % slinky
    view(ah, [-30, 15]);
    % notate
    title(ah, sprintf('Stitch Frame %i', frame));
    xlabel(ah, 'x [m]'); ylabel(ah, 'y [m]'); zlabel(ah, 'z [m]');
    
    % gif output ---------------------------------------------------------------
    gif_path = {...
        [gif_base, '_scene.gif'   ], ...
        [gif_base, '_kinect_a.gif'], ...
        [gif_base, '_kinect_b.gif'], ...
        [gif_base, '_roi.gif'     ], ...
        [gif_base, '_recon.gif'   ], ...
        [gif_base, '_stitch.gif'  ]};
    
    for i = 1 : numel(fh)
        if frame == frame_start
            % first frame
            Gif(fh(i), gif_path{i}, gif_delay(1), inf());
        elseif frame ~= frame_end
            % middle frames
            Gif(fh(i), gif_path{i}, gif_delay(1));
        else
            % last frame
            Gif(fh(i), gif_path{i}, gif_delay(2));
        end
    end
    
    clear ah i overlay
    
%% Save Image ==================================================== [DO NOT EDIT]
    out = sprintf('%s_%0.3i.mat', save_path, frame);
    fprintf('  Saving image (%s)...\n', out);
    img       = recon.image;     %#ok<NASGU>
    space     = recon.space;     %#ok<NASGU>
    voxel     = roi.voxel;       %#ok<NASGU>
    algorithm = recon.algorithm; %#ok<NASGU>
    save(out, 'img', 'space', 'voxel', 'algorithm');
    
    clear out img space voxel algorithm

end
%%
%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
