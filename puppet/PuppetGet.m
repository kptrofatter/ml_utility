% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% PuppetGet() - get certain structure array variables from a puppet and return
% them as a combined matrix.
%
% USAGE:
%   [data] = PuppetGet(puppet, name)
%
% INPUT:
%   [1,1] struct | puppet | puppet structure (see PuppetScan())
%   [1,?] char   | name   | field name {'vertices', 'faces', or duke data}
%
% OUTPUT:
%   [?,?] double | data   | requested data
%
% NOTES:
%   + to access face material data, prepend property name with '#'

function [data] = PuppetGet(puppet, name)
    
    % status
    fprintf('Getting puppet ''%s'' %s... ', puppet.name, name);
    
    % get mesh visibility
    visibility = [puppet.meshes(:).visible];
    
    % get requested data
    switch name
    case 'vertices'
        
        % get vertex geometry
        data = GetVertices(puppet, visibility);
        
    case 'faces'
        
        % get face geometry
        data = GetFaces(puppet, visibility);
        
    otherwise
        
        % custom material data
        if name(1) == '#'
            
            % get per-face material data
            name(1) = [];
            data = GetDukeFace(puppet, name, visibility);
            
        else
            
            % get per-vertex material data
            data = GetDukeVertex(puppet, name, visibility);
            
        end
    end
    
    % status
    fprintf('[Done]\n');
    
end


function [vertices] = GetVertices(puppet, visibility)
    
    % combine vertex data
    vertices = [puppet.meshes(visibility).vertices];
    
end


function [faces] = GetFaces(puppet, visibility)
    
    % count total number of faces
    nfaces = 0;
    for i = 1 : numel(puppet.meshes)
        if visibility(i)
            nfaces = nfaces + size(puppet.meshes(i).faces, 2);
        end
    end
    
    % allocate faces
    faces = zeros(3, nfaces);
    
    % initiate face remap indices
    foffset = 0;
    voffset = 0;
    
    % combine meshes
    for i = 1 : numel(puppet.meshes)
        
        % get mesh
        mesh = puppet.meshes(i);
        
        % test visibility
        if visibility(i)
            
            % count number of faces and vertices
            nfaces = size(mesh.faces, 2);
            nvertices = size(mesh.shapes(1).vertices, 2);
            
            % remap faces
            faces(:, (1 : nfaces) + foffset) = mesh.faces + voffset;
            
            % increment remap
            foffset = foffset + nfaces;
            voffset = voffset + nvertices;
            
        end
        
    end
    
end


function [data] = GetDukeFace(puppet, name, visibility)
    
    % combine pervertex custom material property data
    imaterial = [puppet.meshes(visibility).materials];
    duke = [puppet.materials(imaterial).duke];
    data = [duke(:).(name)];
    
end


function [data] = GetDukeVertex(puppet, name, visibility)
    
    % combine pervertex custom material property data
    duke = [puppet.meshes(visibility).duke];
    data = [duke(:).(name)];
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
