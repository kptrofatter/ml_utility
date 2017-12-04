% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% PuppetAnimScan() - scans animation data exported by custom blender add-on.
%
% USAGE:
%   [animation] = PuppetAnimScan(path)
%
% INPUT:
%   [1,1] char   | path      | blender exported duke animation text file
%
% OUTPUT:
%   [1,1] struct | animation | puppet animation structure
%   [1,?] char   | .name     | animation name
%   [1,?] char   | .puppet   | puppet name
%   [1,f] struct | .A        | puppet pose (w.r.t world)
%   [3,3] double |  .M       | puppet pose transformation matrix
%   [3,1] double |  .v       | puppet pose translation vector
%   [1,m] struct | .meshes   | puppet meshes' poses
%   [1,?] char   |  .name    | mesh name
%   [1,f] struct |  .A       | mesh poses (w.r.t. puppet)
%   [1,b] struct | .bones    | puppet bones' poses
%   [1,?] char   |  .name    | bone name
%   [1,f] struct |  .A       | bone poses (w.r.t. puppet)

function [animation] = PuppetAnimScan(path)
    
    % status
    fprintf('Scanning puppet animation ''%s''... ', path);
    
    % open file
    fid = fopen(path);
    if fid == -1
        error('File ''%s'' not found!', path);
    end
    
    % scan puppet animation
    try
        
        % allocate animation
        A = Affine();
        animation = struct('name', '', 'puppet', '', 'A', A, ...
            'meshes', [], 'bones', []);
        
        % scan animation type
        data = textscan(fid, 'type : %s', 1);
        if ~strcmp(data{1}{1}, 'animation')
            error('format');
        end
        
        % scan animation name
        data = textscan(fid, 'name : %s', 1);
        animation.name = data{1}{1};
        
        % scan puppet name
        data = textscan(fid, 'puppet : %s', 1);
        animation.puppet = data{1}{1};
        
        % scan puppet number of meshes
        data = textscan(fid, 'meshes : %n', 1);
        nmeshes = data{1};
        
        % scan puppet number of bones
        data = textscan(fid, 'bones : %n', 1);
        nbones = data{1};
        
        % scan puppet number of frames
        data = textscan(fid, 'frames : %n', 1);
        nframes = data{1};
        
        % scan puppet poses
        track = ScanTrack(fid, 'puppet', 1, nframes);
        animation.A = track.A;
        
        % scan meshes' poses
        animation.meshes = ScanTrack(fid, 'mesh', nmeshes, nframes);
        
        % scan bones' poses
        animation.bones = ScanTrack(fid, 'bone', nbones, nframes);
        
        % test for end of file
        data = textscan(fid, '%s', 1);
        if ~isempty(data{1})
            error('format');
        end
        
    catch
        
        % close file
        fclose(fid);
        
        % throw error
        error('File ''%s'' incorrect format!', path);
        
    end
    
    % close file
    fclose(fid);
    
    % status
    fprintf('[Done]\n');
    
end


function [poses] = ScanPose(fid, nframes)
    
    % scan poses
    data = textscan(fid, '%f %f %f %f %f %f %f %f %f %f %f %f', nframes);
    func = @(x) nnz(isnan(x));
    if any(cellfun(func, data))
        error('format');
    end
    
    % allocate poses
    poses = Affine(nframes);
    
    % assign poses
    for i = 1 : nframes
        poses(i).M = [ ...
            data{1}(i), data{4}(i), data{7}(i); ...
            data{2}(i), data{5}(i), data{8}(i); ...
            data{3}(i), data{6}(i), data{9}(i)];
        poses(i).v = [data{10}(i);  data{11}(i);  data{12}(i)];
    end
    
end


function [tracks] = ScanTrack(fid, type, ntracks, nframes)
    
    % allocate tracks
    A = Affine();
    track = struct('name', '', 'A', A);
    track.A(1 : nframes) = A;
    tracks(1 : ntracks) = track;
    
    % scan meshes
    for i = 1 : ntracks
        
        % scan track type
        data = textscan(fid, 'type : %s', 1);
        if ~strcmp(data{1}{1}, type)
            error('format');
        end
        
        % scan track name
        data = textscan(fid, 'name : %s', 1);
        track.name = data{1}{1};
        
        % scan poses
        track.A = ScanPose(fid, nframes);
        
        % assign track
        tracks(i) = track;
        
    end
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
