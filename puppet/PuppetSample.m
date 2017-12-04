% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% PuppetSample() - convert face material custom properties to pervertex data.
%
% USAGE:
%   [puppet] = PuppetSample(puppet)
%
% INPUT:
%   [1,1] struct | puppet | puppet structure (see PuppetScan())
%
% OUTPUT:
%   [1,1] struct | puppet | puppet structure with updated pervertex data

function [puppet] = PuppetSample(puppet)
    
    % status
    fprintf('Sampling puppet ''%s'' materials...\n', puppet.name);
    
    % loop over meshes
    for i = 1 : numel(puppet.meshes)
        
        % get mesh
        mesh = puppet.meshes(i);
        
        if mesh.visible
            
            % status
            time = clock();
            spaces = repmat(' ', [1, max(0, 16 - numel(mesh.name))]);
            fprintf('  mesh : ''%-s''%s ', mesh.name, spaces);
            
            % get custom material property names
            names = fieldnames(mesh.duke);
            
            % sample custom material properties
            for j = 1 : numel(names)
                mesh.duke.(names{j}) = Sample(puppet, mesh, names{j});
            end
            
            % assign mesh
            puppet.meshes(i) = mesh;
            
            % status
            dtime = etime(clock(), time);
            fprintf('%.2fs\n', dtime);
            
        end
        
    end
    
end


function [data] = Sample(puppet, mesh, name)
    
    % count vertices
    nvertices = size(mesh.vertices, 2);
    
    % initiate data average
    tally = zeros(1, nvertices);
    data  = zeros(1, nvertices);
    
    % loop over faces
    for i = 1 : size(mesh.faces, 2)
        
        % get face vertex indices
        face = mesh.faces(:, i);
        
        % get face material
        imaterial = mesh.materials(i);
        material = puppet.materials(imaterial);
        
        % accumulate custom material property
        data(face(1)) = data(face(1)) + material.duke.(name);
        data(face(2)) = data(face(2)) + material.duke.(name);
        data(face(3)) = data(face(3)) + material.duke.(name);
        
        % tally number of contributors
        tally(face(1)) = tally(face(1)) + 1;
        tally(face(2)) = tally(face(2)) + 1;
        tally(face(3)) = tally(face(3)) + 1;
        
    end
    
    % average custom material property
    tally(tally == 0) = 1;
    data = data ./ tally;
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
