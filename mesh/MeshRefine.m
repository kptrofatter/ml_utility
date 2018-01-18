% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% MeshRefine() - refines a mesh by subdividing faces such that no edge is longer
% than a given value.
%
% USAGE:
%   [refine] = MeshRefine(mesh, delta)
%
% INPUT:
%   [1,1] struct | mesh   | mesh structure
%   [3,v] double | .verts | mesh vertices
%   [3,f] double | .faces | mesh face vertex indices
%   [1,1] double | delta  | max edge length
%
% OUTPUT:
%   [1,1] struct | refine | refined mesh structure
%   [3,?] double | .verts | refined mesh vertices
%   [3,?] double | .faces | refined mesh face vertex indices
%
% NOTES:
%   adapted from, thus possibly integrated with, PuppetRefine()
%
% TODO:
%   add edge support

function [mesh] = MeshRefine(mesh, delta)
    
    % initialize maximum face edge length
    dmax = inf();
    
    % refine puppet
    i = 1;
    while dmax > delta
        
        % status
        time = clock();
        fprintf('    [%i] computing...', i);
        
        % refine mesh
        [mesh, dmax] = Refine(mesh, delta);
        
        % increment iteration
        i = i + 1;
        
        % status
        dtime = etime(clock(), time);
        str = [Backspace(12), 'dmax = %0.3fm       %.2fs\n'];
        fprintf(str, dmax, dtime);
        
    end
    
end


function [edge] = EdgeIndex(pattern)
    
    % map pattern of 2 non-zero face vertices to a local edge index
    if isequal(pattern, [1; 1; 0])
        edge = 1;
    elseif isequal(pattern, [0; 1; 1])
        edge = 2;
    else
        edge = 3;
    end
    
end


function [topology] = MapFaceTopology(faces, nfaces)
    
    % allocate adjacent faces map
    % if any face shares edges with >3 other faces, slots (slowly) added in loop
    map = struct('face', 0, 'interior', 0, 'exterior', 0);
    topology(1 : 3, 1 : nfaces) = map;
    
    % for all faces
    for i = 1 : nfaces
        
        % get face
        face = faces(:, i);
        
        % find adjacent face indices
        mask1 = faces == face(1);
        mask2 = faces == face(2);
        mask3 = faces == face(3);
        mask  = mask1 | mask2 | mask3;
        iface  = find(sum(mask) == 2); % adjacent faces share exactly 2 verts
        
        % map adjacent faces
        for j = 1 : numel(iface)
            
            % get adjacent face vertex indices
            adjacent = faces(:, iface(j));
            
            % assign map face index
            topology(j, i).face = iface(j);
            
            % assign map interior edge index
            mask1 = face == adjacent(1);
            mask2 = face == adjacent(2);
            mask3 = face == adjacent(3);
            pattern = mask1 | mask2 | mask3;
            iedge = EdgeIndex(pattern);
            topology(j, i).interior = iedge;
            
            % assign map exterior edge index
            pattern = mask(:, iface(j));
            iedge = EdgeIndex(pattern);
            topology(j, i).exterior = iedge;
            
        end
        
    end
    
end


function  [index] = Search(iface, iedge, topology, divides)
    
    % initiate index to not found
    index = 0;
    
    % search adjacent faces
    for i = 1 : size(topology, 1)
        
        % break if index found
        if index ~= 0
            break
        end
        
        % get adjacent face index
        iadjacent = topology(i, iface).face;
        
        % break if no more adjacent faces (once you hit zero, the rest are zero)
        if iadjacent == 0
            break
        end
        
        % skip if face hasn't been visited yet (lower index)
        if iface < iadjacent
            continue
        end
        
        % skip if adjacent face doesn't share the right edge
        if iedge ~= topology(i, iface).interior
            continue
        end
        
        % get vertex index
        iedge = topology(i, iface).exterior;
        index = divides(iedge, iadjacent);
        
    end
    
end


function [refine, divides, dmax] = DivideEdges(refine, faces, fmap, delta)
    
    % helper constant
    itable = [2, 3, 1];
    
    % count unrefined faces
    nfaces = size(faces, 2);
        
    % initiate divide indices
    divides = zeros(3, nfaces);
    
    % initiate maximum distance on mesh
    dmax = 0;
    
    % loop over unrefined faces    
    for i = 1 : nfaces
        
        % get face
        face = faces(:, i);
        
        % get face vertices
        verts = refine.verts;
        v1 = verts(:, face(1));
        v2 = verts(:, face(2));
        v3 = verts(:, face(3));
        
        % compute distances between face vertices
        d = [norm(v1 - v2), norm(v2 - v3), norm(v3 - v1)];
        
        % divide face edges
        for j = 1 : 3
            
            % test resolution
            if d(j) < delta
                
                % track longest face edge
                if d(j) > dmax
                    dmax = d(j);
                end
                
            else
                
                % track longest face edge
                if d(j) / 2.0 > dmax % we are about to divide this edge in half
                    dmax = d(j) / 2.0;
                end
                
                % search for already divided edge
                index = Search(i, j, fmap, divides);
                
                % test search result
                if index == 0
                    
                    % get edge vertex indices
                    i1 = face(j);
                    i2 = face(itable(j));
                    
                    % add a new vertex
                    index = refine.ivertex;
                    refine.ivertex = refine.ivertex + 1;
                    
                    % refine vertices
                    v1 = refine.verts(:, i1);
                    v2 = refine.verts(:, i2);
                    refine.verts(:, index) = (v1 + v2) / 2.0;
                    
                end
                
                % assign divide
                divides(j, i) = index;
                
            end
            
        end
        
    end
    
end


function [refine] = DivideFace(refine, face, divide)
    
    % get vertex indices
    f1 = face(1);
    f2 = face(2);
    f3 = face(3);
    
    % get divide vertex indices
    d1 = divide(1);
    d2 = divide(2);
    d3 = divide(3);
    
    % get refined face index
    iface = refine.iface;
    
    % get divided edge pattern
    pattern = divide ~= 0;
    
    % divide face
    if isequal(pattern, [1; 1; 1])
        refine.faces(:, iface + 0) = [f1; d1; d3];
        refine.faces(:, iface + 1) = [f2; d2; d1];
        refine.faces(:, iface + 2) = [f3; d3; d2];
        refine.faces(:, iface + 3) = [d1; d2; d3];
        iface = iface + 4;
    elseif isequal(pattern, [0; 1; 1])
        refine.faces(:, iface + 0) = [f1; f2; d3];
        refine.faces(:, iface + 1) = [f2; d2; d3];
        refine.faces(:, iface + 2) = [f3; d3; d2];
        iface = iface + 3;
    elseif isequal(pattern, [1; 0; 1])
        refine.faces(:, iface + 0) = [f1; d1; d3];
        refine.faces(:, iface + 1) = [f2; f3; d1];
        refine.faces(:, iface + 2) = [f3; d3; d1];
        iface = iface + 3;
    elseif isequal(pattern, [1; 1; 0])
        refine.faces(:, iface + 0) = [f1; d1; d2];
        refine.faces(:, iface + 1) = [f2; d2; d1];
        refine.faces(:, iface + 2) = [f3; f1; d2];
        iface = iface + 3;
    elseif isequal(pattern, [1; 0; 0])
        refine.faces(:, iface + 0) = [f1; d1; f3];
        refine.faces(:, iface + 1) = [f2; f3; d1];
        iface = iface + 2;
    elseif isequal(pattern, [0; 1; 0])
        refine.faces(:, iface + 0) = [f2; d2; f1];
        refine.faces(:, iface + 1) = [f3; f1; d2];
        iface = iface + 2;
    elseif isequal(pattern, [0; 0; 1])
        refine.faces(:, iface + 0) = [f3; d3; f2];
        refine.faces(:, iface + 1) = [f1; f2; d3];
        iface = iface + 2;
    else
        refine.faces(:, iface + 0) = [f1; f2; f3];
        iface = iface + 1;
    end
    
    % assign refined face index
    refine.iface = iface;
    
end


function [refine, dmax] = Refine(mesh, delta)
    
    % get geometry
    verts = mesh.verts;
    faces = mesh.faces;
    
    % count geometry
    nverts = size(verts, 2);
    nfaces = size(faces, 2);
    
    % initiate worst case refined vertices
    refine.verts = [verts, zeros(3, nverts)];
    refine.ivertex = nverts + 1;
    
    % initiate worst case refined faces
    refine.faces = zeros(3, 4 * nfaces);
    refine.iface = 1;
    
    % map faces to adjacent faces
    fmap = MapFaceTopology(faces, nfaces);
    
    % divide face edges
    [refine, divides, dmax] = DivideEdges(refine, faces, fmap, delta);
    
    % divide faces
    for i = 1 : nfaces
        
        % get face vertex indices
        face = faces(:, i);
        divide = divides(:, i);
        
        % divide face
        [refine] = DivideFace(refine, face, divide);
        
    end
    
    % clip refined geometry
    ivertex = refine.ivertex;
    iface = refine.iface;
    refine.verts(:, ivertex : end) = [];
    refine.faces(:, iface : end) = [];
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
