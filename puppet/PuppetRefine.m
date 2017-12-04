% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% PuppetRefine() - refine meshes so any given face vertices are no more than a
% certain maximum distance apart.
%
% USAGE:
%   [puppet] = PuppetRefine(puppet, resolution=0.01)
%
% INPUT:
%   [1,1] struct | puppet | puppet structure (see PuppetScan())
%   [1,1] double | delta  | [m] maximum distance between face vertices
%
% OUTPUT:
%   [1,1] struct | puppet | puppet structure with refined meshes
%
% NOTE: due to lack of reference mechanism, this program is NOT recursive...

function [puppet] = PuppetRefine(puppet, delta)
    
    % status
    fprintf('Refining puppet ''%s'' to %.3fm...\n', puppet.name, delta);
    
    % default resolution
    if nargin() < 2 || isempty(delta)
        delta = 0.01;
    end
    
    % count meshes
    nmeshes = numel(puppet.meshes);
    
    % refine meshes
    for i = 1 : nmeshes
        
        % get mesh
        mesh = puppet.meshes(i);
        
        % test visibility
        if mesh.visible
            
            % status
            fprintf('  mesh : ''%s''\n', puppet.meshes(i).name);
            
            % initialize maximum face edge length
            dmax = inf();
                
            % refine puppet
            j = 1;
            while dmax > delta
                
                % status
                time = clock();
                fprintf('    [%i] computing...', j);
                
                % refine mesh
                [puppet, dmax] = Refine(puppet, i, delta);
                
                % increment iteration
                j = j + 1;
                
                % status
                dtime = etime(clock(), time);
                str = [Backspace(12), 'dmax = %0.3fm       %.2fs\n'];
                fprintf(str, dmax, dtime);
                
            end
            
        end
        
    end
    
    % sample pervertex material properties
    puppet = PuppetSample(puppet);
    
    % compute deformation
    puppet = PuppetDeform(puppet);
    
end


function [topology] = MapVertexBones(bones, imesh, nvertices, nbones)
    
    % allocate vertices to bones map
    topology = zeros(nbones, nvertices);
    
    % for all vertices
    for i = 1 : nvertices
        
        % for all bones
        for j = 1 : nbones
            
            % get bone
            bone = bones(j);
            
            % test if bone controls vertex
            mask = i == bone.indices{imesh};
            if any(mask)
                
                % map bone to vertex
                topology(j, i) = bone.weights{imesh}(mask);
                
            end
            
        end
        
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


function [refine, divides, dmax] = DivideEdges(refine, faces, vmap, fmap, delta)
    
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
        vertices = refine.vertices;
        v1 = vertices(:, face(1));
        v2 = vertices(:, face(2));
        v3 = vertices(:, face(3));
        
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
                    
                    % refine shapes vertices
                    for k = 1 : numel(refine.shapes)
                        v1 = refine.shapes(k).vertices(:, i1);
                        v2 = refine.shapes(k).vertices(:, i2);
                        refine.shapes(k).vertices(:, index) = (v1 + v2) / 2.0;
                    end
                    
                    % refine vertices
                    v1 = refine.vertices(:, i1);
                    v2 = refine.vertices(:, i2);
                    refine.vertices(:, index) = (v1 + v2) / 2.0;
                    
                    % look up edge vertex bone weights
                    weights1 = vmap(:, i1);
                    weights2 = vmap(:, i2);
                    ibone = find(weights1 | weights2);
                    
                    % refine bones
                    for k = 1 : numel(ibone)
                        
                        % get bone vertex weight index
                        ivertex = refine.bones(ibone(k)).index;
                        refine.bones(ibone(k)).index = ivertex + 1;
                        
                        % assign new index
                        refine.bones(ibone(k)).indices(ivertex) = index;
                        
                        % assign new weight
                        w1 = weights1(ibone(k));
                        w2 = weights2(ibone(k));
                        w = (w1 + w2) / 2.0;
                        refine.bones(ibone(k)).weights(ivertex) = w;
                        
                    end
                    
                end
                
                % assign divide
                divides(j, i) = index;
                
            end
            
        end
        
    end
    
end


function [refine] = DivideFace(refine, face, divide, imaterial)
    
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
        refine.materials(iface + (0 : 3)) = imaterial;
        iface = iface + 4;
    elseif isequal(pattern, [0; 1; 1])
        refine.faces(:, iface + 0) = [f1; f2; d3];
        refine.faces(:, iface + 1) = [f2; d2; d3];
        refine.faces(:, iface + 2) = [f3; d3; d2];
        refine.materials(iface + (0 : 2)) = imaterial;
        iface = iface + 3;
    elseif isequal(pattern, [1; 0; 1])
        refine.faces(:, iface + 0) = [f1; d1; d3];
        refine.faces(:, iface + 1) = [f2; f3; d1];
        refine.faces(:, iface + 2) = [f3; d3; d1];
        refine.materials(iface + (0 : 2)) = imaterial;
        iface = iface + 3;
    elseif isequal(pattern, [1; 1; 0])
        refine.faces(:, iface + 0) = [f1; d1; d2];
        refine.faces(:, iface + 1) = [f2; d2; d1];
        refine.faces(:, iface + 2) = [f3; f1; d2];
        refine.materials(iface + (0 : 2)) = imaterial;
        iface = iface + 3;
    elseif isequal(pattern, [1; 0; 0])
        refine.faces(:, iface + 0) = [f1; d1; f3];
        refine.faces(:, iface + 1) = [f2; f3; d1];
        refine.materials(iface + (0 : 1)) = imaterial;
        iface = iface + 2;
    elseif isequal(pattern, [0; 1; 0])
        refine.faces(:, iface + 0) = [f2; d2; f1];
        refine.faces(:, iface + 1) = [f3; f1; d2];
        refine.materials(iface + (0 : 1)) = imaterial;
        iface = iface + 2;
    elseif isequal(pattern, [0; 0; 1])
        refine.faces(:, iface + 0) = [f3; d3; f2];
        refine.faces(:, iface + 1) = [f1; f2; d3];
        refine.materials(iface + (0 : 1)) = imaterial;
        iface = iface + 2;
    else
        refine.faces(:, iface + 0) = [f1; f2; f3];
        refine.materials(iface + (0 : 0)) = imaterial;
        iface = iface + 1;
    end
    
    % assign refined face index
    refine.iface = iface;
    
end


function [puppet, dmax] = Refine(puppet, imesh, delta)
    
    % get mesh
    mesh = puppet.meshes(imesh);
    
    % get geometry
    shapes = mesh.shapes;
    vertices = mesh.vertices;
    faces = mesh.faces;
    
    % count geometry
    nshapes = numel(shapes);
    nvertices = size(vertices, 2);
    nfaces = size(faces, 2);
    
    % get bones
    bones = puppet.bones;
        
    % count bones
    nbones = numel(puppet.bones);
    
    % initiate worst case refined shapes
    refine.shapes = mesh.shapes;
    for i = 1 : nshapes
        shape = refine.shapes(i);
        refine.shapes(i).vertices = [shape.vertices, zeros(3, nvertices)];
    end
    
    % initiate worst case refined vertices
    refine.vertices = [vertices, zeros(3, nvertices)];
    refine.ivertex = nvertices + 1;
    
    % initiate worst case refined faces
    refine.faces = zeros(3, 4 * nfaces);
    refine.iface = 1;
    
    % initiate worst case refined materials
    refine.materials = zeros(1, 4 * nfaces);
    
    % initiate (hopefully enough...) refined bone indices and weights
    bone = struct('index', 0, 'indices', [], 'weights', []);
    refine.bones(1 : nbones) = bone;
    for i = 1 : nbones
        indices = puppet.bones(i).indices{imesh};
        weights = puppet.bones(i).weights{imesh};
        nindices = size(indices, 2);
        refine.bones(i).index = nindices + 1;
        refine.bones(i).indices = [indices, zeros(1, 2 * nindices)];
        refine.bones(i).weights = [weights, zeros(1, 2 * nindices)];
    end
    
    % map vertices to bones
    vmap = MapVertexBones(bones, imesh, nvertices, nbones);
    
    % map faces to adjacent faces
    fmap = MapFaceTopology(faces, nfaces);
    
    % divide face edges
    [refine, divides, dmax] = DivideEdges(refine, faces, vmap, fmap, delta);
    
    % divide faces
    for i = 1 : nfaces
        
        % get face vertex indices
        face = faces(:, i);
        divide = divides(:, i);
        
        % get face material
        imaterial = mesh.materials(i);
        
        % divide face
        [refine] = DivideFace(refine, face, divide, imaterial);
        
    end
    
    % clip refined geometry
    ivertex = refine.ivertex;
    iface = refine.iface;
    for i = 1 : nshapes
        refine.shapes(i).vertices(:, ivertex : end) = [];
    end
    refine.vertices(:, ivertex : end) = [];
    refine.faces(:, iface : end) = [];
    refine.materials(:, iface : end) = [];
    
    % clip refined bones
    for i = 1 : nbones
        index = refine.bones(i).index;
        refine.bones(i).indices(index : end) = [];
        refine.bones(i).weights(index : end) = [];
    end
    
    % assign refined geometry
    mesh.shapes    = refine.shapes;
    mesh.vertices  = refine.vertices;
    mesh.faces     = refine.faces;
    mesh.materials = refine.materials;
    
    % assign mesh
    puppet.meshes(imesh) = mesh;
    
    % assign refined bone indices and weights
    for i = 1 : nbones
        puppet.bones(i).indices{imesh} = refine.bones(i).indices;
        puppet.bones(i).weights{imesh} = refine.bones(i).weights;
    end
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
