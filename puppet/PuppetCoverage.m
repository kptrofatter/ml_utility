% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% PuppetCoverage() - computes puppet rf coverage from reconstructed image data.
% Results are stored in a custom material variable named 'coverage'.
%
% USAGE:
%   [puppet]        = PuppetCoverage(puppet) % reset coverage
%   [puppet, ratio] = PuppetCoverage(puppet, image, space, limit?)
%
% INPUT:
%   [1,1]   struct  | puppet   | puppet structure (see PuppetScan())
%   [x,y,z] complex | image    | reconstructed image
%   [1,1]   struct  | space    | image space structure (see Space())
%   [1,1]   double  | limit    | threshold coverage magnitude
%
% OUTPUT:
%   [1,1]   struct  | puppet   | puppet with updated coverage map
%   [1,1]   double  | ratio    | area coverage ratio of visible meshes
%
% NOTES:
%   + 'coverage' should not be used as a name for custom material propeties

function [puppet, ratio] = PuppetCoverage(puppet, image, space, limit)
    
    % initiate coverage computation
    if nargin() ~= 1
        
        % process image
        image = abs(image);
        
        % build grid
        space = SpaceGrid(space);
            
        % default limit
        if nargin() < 4
            limit = max(image(:)) / 8.0;
        end
        
    end
    
    % initate coverage ratio
    area_cover = 0.0;
    area_total = 0.0;
    
    % mesh loop
    nmeshes = numel(puppet.meshes);
    for i = 1 : nmeshes
        
        % get mesh
        mesh = puppet.meshes(i);
        
        % initate or reset coverage
        if ~isfield(mesh.duke, 'coverage') || nargin() == 1
            nverts = size(mesh.vertices, 2);
            mesh.duke.coverage = false(1, nverts);
        end
        
        % visibility test
        if mesh.visible && nargin() ~= 1
            
            % compute coverage
            [mesh, cover, total] = MeshCoverage(mesh, image, space, limit);
            
            % accumulate results
            area_cover = area_cover + cover;
            area_total = area_total + total;
            
        end
        
        % assign mesh
        puppet.meshes(i) = mesh;
        
    end
    
    % compute coverage ratio
    if area_total == 0.0
        ratio = 0.0;
    else
        ratio = area_cover / area_total;
    end
    
end


function [mesh, cover, total] = MeshCoverage(mesh, image, space, limit)
    
    % get geometry
    verts = mesh.vertices;
    faces = mesh.faces;
    
    % sample image data
    samples = interpn(space.X, space.Y, space.Z, image, ...
        verts(1, :), verts(2, :), verts(3, :));
    samples(isnan(samples)) = 0.0;
    
    % set coverage
    coverage = mesh.duke.coverage;
    coverage = coverage | samples > limit;
    
    % compute area coverage
    cover = 0;
    total = 0;
    nfaces = size(faces, 2);
    for i = 1 : nfaces
        
        % get face vertex indices
        i1 = faces(1, i);
        i2 = faces(2, i);
        i3 = faces(3, i);
        
        % get face vertices
        v1 = verts(:, i1);
        v2 = verts(:, i2);
        v3 = verts(:, i3);
        
        % compute face area
        e1 = v2 - v1;
        e2 = v3 - v1;
        area = 0.5 * norm(cross(e1, e2));
        
        % accumulate total area
        total = total + area;
        
        % test coverage
        if coverage(i1) || coverage(i2) || coverage(i3)
            cover = cover + area;
        end
        
    end
    
    % assign coverage
    mesh.duke.coverage = coverage;
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
