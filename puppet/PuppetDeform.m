% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% PuppetDeform() - recomputes puppet vertices based on current pose using
% Shape Key Deformation (SKD) and Skeletal Subspace Deformation (SSD).
%
% USAGE:
%   [puppet] = PuppetDeform(puppet)
%
% INPUT:
%   [1,1] struct | puppet | puppet structure (see PuppetScan())
%
% OUTPUT:
%   [1,1] double | puppet | deformed puppet (see puppet.meshes(?).vertices)
%
% TODO:
%   + implement 'absolute' SKD

function [puppet] = PuppetDeform(puppet)
    
    % status
    fprintf('Deforming puppet ''%s''...\n', puppet.name);
    
    % evaluate meshes
    for i = 1 : numel(puppet.meshes)
        
        % get mesh
        mesh = puppet.meshes(i);
        
        % test visibility
        if mesh.visible
            
            % status
            time = clock();
            fprintf('  mesh : ''%s'' computing...', puppet.meshes(i).name);
            
            % shape key deformation
            vertices = Skd(puppet, mesh);
            
            % mesh to puppet space
            vertices = AffineXform(mesh.A, vertices);
            
            % skeltal subspace deformation
            vertices = Ssd(puppet, vertices, i);
            
            % puppet to world space
            vertices = AffineXform(puppet.A, vertices);
            
            % assign result
            puppet.meshes(i).vertices = vertices;
            
            % status
            dtime = etime(clock(), time);
            spaces = repmat(' ', [1, max(0, 16 - numel(mesh.name))]);
            str = [Backspace(12), '%s%.2fs\n'];
            fprintf(str, spaces, dtime);
            
        end
        
    end
    
end


% shape key deformation
% CURRENTLY ONLY 'RELATIVE' MODE SHAPE KEYS SUPPORTED!
function [vertices] = Skd(puppet, mesh)
    
    % globals (for driver eval)
    global PLAYBACK %#ok<NUSED>
    
    % initiate weights
    nshapes = numel(mesh.shapes);
    w = zeros(1, nshapes);
    
    % compute non-basis key weights
    for i = 2 : nshapes
        
        % evaluate weight
        weight = mesh.shapes(i).weight;
        
        if isa(weight, 'double')
            
            % constant number
            w(i) = weight;
            
        elseif isa(weight, 'function_handle')
            
            % weight function
            w(i) = weight(puppet);
            
        end
        
    end
    
    % compute basis key weight
    w(1) = 1.0 - sum(w);
    
    % initiate vertices
    vertices = w(1) * mesh.shapes(1).vertices;
    
    % accumalate
    for i = 2 : nshapes
        vertices = vertices + w(i) * mesh.shapes(i).vertices;
    end
    
end


% skeletal subspace deformation
function [x] = Ssd(puppet, vertices, imesh)
    
    % allocate poses
    nbones = numel(puppet.bones);
    A(nbones) = struct('M', eye(3), 'v', zeros(3, 1));
    
    % initiate deformed vertices
    nvertices = size(vertices, 2);
    x = zeros(3, nvertices);
    
    % initiate weight table
    weights = zeros(nbones, nvertices);
    
    % prepare deformation
    for i = 1 : nbones
        
        % get bone
        bone = puppet.bones(i);
        
        % compute pose
        Aa = bone.A;
        Ari = AffineInverse(bone.A_rest);
        A(i) = AffineCompose(Aa, Ari);
        
        % assign to weight table
        indices = bone.indices{imesh};
        weights(i, indices) = bone.weights{imesh};
        
    end
    
    % normalize weights
    w = sum(weights, 1);
    w(w == 0.0) = 1.0;
    weights = weights ./ repmat(w, [size(weights, 1), 1]);
    
    % deform vertices
    for i = 1 : nbones
        indices = puppet.bones(i).indices{imesh};
        w = weights(i, indices);
        w = repmat(w, [3, 1]);
        x(:, indices) = ...
            x(:, indices) + w .* AffineXform(A(i), vertices(:, indices));
    end
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
