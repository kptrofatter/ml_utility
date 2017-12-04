% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% PuppetCactus() - adds "cactus hair" to meshes at vertices where faces meet.
% Use to prepare a puppet suitable for volumetric stitching of a moving target.
%
% USAGE:
%   [puppet] = PuppetCactus(puppet, profile)
%
% INPUT:
%   [1,1] struct | puppet  | puppet structure (see PuppetScan())
%   [1,?] double | profile | [m] hair vertex profile (-=in, 0=surface, +=out)
%
% OUTPUT:
%   [1,1] struct | puppet  | modified puppet with cactused mesh
%
% NOTES:
%   + evidently 'cactus' is now a verb

function [puppet] = PuppetCactus(puppet, profile)
    
    % status
    fprintf('Cactusing puppet ''%s''...\n', puppet.name);
    
    % count vertices in profile
    nprofile = numel(profile);
    
    % count meshes
    nmeshes = numel(puppet.meshes);
    
    % get bones
    bones = puppet.bones;
    nbones = numel(bones);
    
    % initiate hairy bones
    hairy.bones = puppet.bones;
    
    % for all meshes
    for i = 1 : nmeshes
        
        % get mesh
        mesh = puppet.meshes(i);
        
        % test visibility
        if mesh.visible
            
            % status
            time = clock();
            fprintf('  mesh : ''%s'' computing...', puppet.meshes(i).name);
            
            % get geometry
            shapes = mesh.shapes;
            vertices = mesh.vertices;
            faces = mesh.faces;
            
            % count geometry
            nshapes = numel(shapes);
            nvertices = size(vertices, 2);
            
            % initiate bone indices and weights
            hairy.iweights = zeros(1, nbones);
            for j = 1 : nbones
                
                % compute potential number of new indices and weights
                nweights = numel(hairy.bones(j).weights{i});
                worst = zeros(1, nweights * nprofile);
                
                % initiate bone indices and weights
                hairy.bones(j).indices{i} = [bones(j).indices{i}, worst];
                hairy.bones(j).weights{i} = [bones(j).weights{i}, worst];
                
                % initiate bone weight allocation index
                hairy.iweights(j) = nweights + 1;
                
            end
            
            % map vertices to bones
            vmap = MapVertexBones(bones, i, nvertices, nbones);
            
            % grow hairy shapes
            for j = 1 : nshapes
                verts = mesh.shapes(j).vertices;
                [mesh.shapes(j).vertices, ~] = GrowVertices( ...
                    verts, faces, [], [], [], profile);
            end
            
            % grow hairy vertices
            [mesh.vertices, hairy] = GrowVertices( ...
                vertices, faces, hairy, i, vmap, profile);
            
            % assign hairy mesh
            puppet.meshes(i) = mesh;
            
            % status
            dtime = etime(clock(), time);
            spaces = repmat(' ', [1, max(0, 16 - numel(mesh.name))]);
            str = [Backspace(12), '%s%.2fs\n'];
            fprintf(str, spaces, dtime);
            
        end
        
    end
    
    % assign hairy bones
    puppet.bones = hairy.bones;
    
    % sample pervertex material properties (all hairs get mapped to zero)
    puppet = PuppetSample(puppet);
    
    % compute deformation
    puppet = PuppetDeform(puppet);
    
end


function [vertices, hairy] = GrowVertices( ...
    vertices, faces, hairy, imesh, vmap, profile)
    
    % count things
    nvertices = size(vertices, 2);
    nprofile = numel(profile);
    
    % count bones
    if isempty(hairy)
        nbones = 0;
    else
        nbones = numel(hairy.bones);
    end
    
    % initiate hairy vertices
    vertices = [vertices, zeros(3, nvertices * nprofile)];
    ivertex = nvertices + 1;
    
    % for all original vertices
    for i = 1 : nvertices
        
        % map vertex to adjacent faces
        mask1 = i == faces(1, :);
        mask2 = i == faces(2, :);
        mask3 = i == faces(3, :);
        mask = mask1 | mask2 | mask3;
        iface = find(mask);
        
        % continue if not a vertex of a face (need faces for normal information)
        if isempty(iface)
            continue
        end
        
        % get vertex
        vertex = vertices(:, i);
        
        % compute average normal of faces
        normal = AverageNormal(vertices, faces, iface);
        
        % grow hairy vertices
        for j = 1 : nprofile
            
            % add vertex to vertices
            vertices(:, ivertex) = vertex + profile(j) * normal;
            
            % add vertex index and weight to bones
            for k = 1 : nbones
                
                % test is vertex is controlled by bone
                w = vmap(k, i);
                if w == 0
                    continue
                end
                
                % add bone vertex index and weight
                index = hairy.iweights(k);
                hairy.bones(k).indices{imesh}(index) = ivertex;
                hairy.bones(k).weights{imesh}(index) = w;
                hairy.iweights(k) = index + 1;
                
            end
            
            % increment hairy vertex allocation index
            ivertex = ivertex + 1;
            
        end
        
    end
    
    % clip hairy vertices
    vertices(:, ivertex : end) = [];
    
    % clip hairy bones
    for i = 1 : nbones
        index = hairy.iweights(i);
        hairy.bones(i).indices{imesh}(index : end) = [];
        hairy.bones(i).weights{imesh}(index : end) = [];
    end
    
end

function [map] = MapVertexBones(bones, imesh, nvertices, nbones)
    
    % allocate vertices to bones map
    map = zeros(nbones, nvertices);
    
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
                map(j, i) = bone.weights{imesh}(mask);
                
            end
            
        end
        
    end
    
end


function [normal] = AverageNormal(vertices, faces, iface)
    
    % count adjacent faces
    nfaces = numel(iface);
    
    % allocate normals
    normals = zeros(3, nfaces);
    
    % for all adjacent faces
    for i = 1 : nfaces
        
        % get face
        face = faces(:, iface(i));
        
        % get face vertices
        v1 = vertices(:, face(1));
        v2 = vertices(:, face(2));
        v3 = vertices(:, face(3));
        
        % compute face edges
        e1 = v2 - v1;
        e2 = v3 - v1;
        
        % compute face normal
        n = cross(e1, e2);
        n = n / norm(n);
        
        % assign normal
        normals(:, i) = n;
        
    end
    
    % average normals
    normal = sum(normals, 2);
    normal = normal / norm(normal);
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
