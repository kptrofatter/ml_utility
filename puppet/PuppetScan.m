% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% PuppetScan() - scans in duke puppet data exported by a custom blender add-on.
%
% USAGE:
%   [puppet] = PuppetScan(path)
%
% INPUT:
%   [1,?] char    | path        | blender exported duke puppet text file
%
% OUTPUT:
%   [1,1] struct  | puppet      | puppet structure
%   [1,?] char    | .name       | puppet name
%   [1,1] struct  | .A          | puppet pose (w.r.t world)
%   [3,3] double  |  .M         | puppet pose transformation matrix
%   [3,1] double  |  .v         | puppet pose translation vector
%   [1,n] struct  | .materials  | puppet materials
%   [1,?] char    |  .name      | material name
%   [1,1] struct  |  .duke      | material custom properties
%   [?,?] ???     |   .???      | material custom property
%   [1,m] struct  | .meshes     | puppet meshes
%   [1,?] char    |  .name      | mesh name
%   [1,1] logical |  .visible   | mesh visibility flag
%   [1,1] struct  |  .A_rest    | mesh rest pose (w.r.t. puppet)
%   [1,1] struct  |  .A         | mesh pose (w.r.t. puppet)
%   [1,s] struct  |  .shapes    | mesh shape keys
%   [1,?] char    |   .name     | shape key name
%   [3,v] double  |   .vertices | shape key vertex data (w.r.t. puppet)
%   [1,?] ???     |   .weight   | shape key weight (double, function)
%   [3,v] double  |  .vertices  | mesh evaluated vertices
%   [3,f] double  |  .faces     | mesh face vertex indices (triangulated)
%   [1,f] double  |  .materials | mesh face material indices
%   [1,1] struct  |  .duke      | mesh custom pervertex properties
%   [?,?] ???     |   .???      | mesh custom pervertex property
%   [1,b] struct  | .bones      | puppet deformation skeleton
%   [1,?] char    |  .name      | bone name
%   [1,?] char    |  .parent    | bone parent name
%   [1,c] cell    |  .children  | bone children names
%   [1,1] struct  |  .A_rest    | bone rest pose (w.r.t. puppet)
%   [1,1] struct  |  .A         | bone pose (w.r.t. puppet)
%   [1,m] cell    |  .indices   | bone mesh vertex indices ([1,w] double)
%   [1,m] cell    |  .weights   | bone mesh vertex weights ([1,w] double)

function [puppet] = PuppetScan(path)
    
    % status
    fprintf('Scanning puppet ''%s''... ', path);
    
    % check path
    if ~exist('path', 'var') || ~ischar(path) || size(path, 1) ~= 1
        error('Usage : [puppet] = PuppetScan([1,?] char path)');
    end
    
    % open file
    fid = fopen(path);
    if fid == -1
        error('File ''%s'' not found!', path);
    end
    
    % scan puppet
    try
        
        % scan puppet type
        ScanType(fid, 'puppet');
        
        % scan puppet name
        puppet.name = ScanString(fid, 'name');
        
        % initalize puppet pose
        puppet.A = Affine();
        
        % scan number of materials
        nmaterials = ScanNumber(fid, 'materials');
        
        % scan number of meshes
        nmeshes = ScanNumber(fid, 'meshes');
        
        % scan number of bones
        nbones = ScanNumber(fid, 'bones');
        
        % scan puppet materials
        puppet.materials = ScanMaterials(fid, nmaterials);
        
        % scan puppet meshes
        puppet.meshes = ScanMeshes(fid, nmeshes, puppet.materials);
        
        % scan puppet bones
        puppet.bones = ScanBones(fid, nbones, nmeshes);
        
        % test for end of file
        data = textscan(fid, '%s', 1);
        if ~isempty(data{1})
            error('format');
        end
        
    catch
        
        % close file
        fclose(fid);
        
        % throw format error
        error('File ''%s'' incorrect format!', path);
        
    end
    
    % close file
    fclose(fid);
    
    % status
    fprintf('[Done]\n');
    
    % sample material custom properties
    puppet = PuppetSample(puppet);
    
    % compute deformation
    puppet = PuppetDeform(puppet);
    
end


function [] = ScanType(fid, type)
    % scan and test type property
    data = textscan(fid, 'type : %s', 1);
    if ~strcmp(data{1}{1}, type)
        error('format');
    end
end


function [name] = ScanString(fid, property)
    % scan string property
    data = textscan(fid, [property, ' : %s'], 1);
    name = data{1}{1};
end


function [name] = ScanNumber(fid, property)
    % scan number property
    data = textscan(fid, [property, ' : %f'], 1);
    name = data{1};
end


function [materials] = ScanMaterials(fid, nmaterials)
    
    % allocate materials
    material = struct('name', '', 'duke', []);
    materials(nmaterials) = material;
    
    % scan materials
    for i = 1 : nmaterials
        
        % scan type
        ScanType(fid, 'material');
        
        % scan name
        materials(i).name = ScanString(fid, 'name');
        
        % scan number of custom properties
        nproperties = ScanNumber(fid, 'properties');
        
        % scan custom properties
        for j = 1 : nproperties
            
            % scan property name-value pair
            data = textscan(fid, '%s : %f', 1);
            name = data{1}{1};
            value = data{2};
            
            % assign to material as named member
            % NOTE : all materials should have the same set of properties
            duke.(name) = value; % obscure syntax, makes name a field
            
        end
        
        % assign custom properties
        materials(i).duke = duke;
        
    end
    
end


function [A] = ScanPose(fid)
    
    % scan pose
    data = textscan(fid, 'pose : %f %f %f %f %f %f %f %f %f %f %f %f', 1);
    func = @(x) nnz(isnan(x));
    if any(cellfun(func, data))
        error('format');
    end
    
    % assign pose
    A = Affine();
    A.M = [ ...
        data{1}, data{4}, data{7}; ...
        data{2}, data{5}, data{8}; ...
        data{3}, data{6}, data{9}];
    A.v = [data{10};  data{11};  data{12}];
    
end


function [shapes] = ScanShapes(fid, nshapes, nvertices)
    
    % allocate shapes
    shape = struct('name', '', 'vertices', [], 'weight', []);
    shapes(nshapes) = shape;
    
    % scan shapes
    for i = 1 : nshapes
        
        % scan shape type
        ScanType(fid, 'shape');
        
        % scan shape name
        shape.name = ScanString(fid, 'name');
        
        % scan shape vertices
        data = textscan(fid, '%f %f %f', nvertices);
        shape.vertices = [data{1}, data{2}, data{3}].';
        
        % initiate shape weight
        if i == 1
            shape.weight = 1.0; % constant on
        else
            shape.weight = 0.0; % constant off
        end
        
        % assign shape
        shapes(i) = shape;
        
    end
    
end


function [triangles, indices] = Triangulate(ngons)
    
    % allocate triangles
    n = nnz(ngons(4 : end, :));
    triangles = zeros(3, size(ngons, 2) + n);
    indices = zeros(1, size(triangles, 2));
    
    % convert n-gons
    k = 1;
    for i = 1 : size(ngons, 2)
        
        % to triangles (uses simple algorithm, could be improved)
        n = nnz(ngons(:, i));
        for j = 1 : n - 2
            
            triangles(:, k) = [ngons(1, i); ngons((1 : 2) + j, i)];
            indices(k) = i;
            k = k + 1;
            
        end
        
    end
    
end


function [normals] = ScanPervertex(fid, nvertices) %#ok<DEFNU> % DISABLED
    
    % scan vertex type
    ScanType(fid, 'vertex');
    
    % scan normals
    data = textscan(fid, '%f %f %f', nvertices);
    normals = [data{1}, data{2}, data{3}].';
    
end


function [faces, materials] = ScanPerface(fid, nfaces)
    
    % scan face type
    ScanType(fid, 'face');
    
    % scan number of shapes
    ngon = ScanNumber(fid, 'ngon');
    
    % allocate vertex indices
    faces = zeros(ngon, nfaces);
    
    % scan perface data
    str = repmat('%f ', [1, ngon]); % vertex indices
    str = [str, ', %f']; % material index
    data = textscan(fid, str, nfaces);
    
    % assign faces
    for i = 1 : ngon
        faces(i, :) = data{i}.' + 1; % convert to 1-indexing
    end
    
    % triangulate (convert ngons into triangles)
    [faces, indices] = Triangulate(faces);
    
    % assign material indices
    materials = data{end}(indices).' + 1;
    
end


function [duke] = InitiateDuke(materials, nvertices)
    
    % get field names
    duke = materials(1).duke;
    names = fieldnames(duke);
    
    % allocate pervertex custom properties
    for i = 1 : numel(names)
        duke.(names{i}) = zeros(1, nvertices); % obscure syntax to name a field
    end
    
end


function [meshes] = ScanMeshes(fid, nmeshes, materials)
    
    % allocate meshes
    mesh = struct('name', '', 'visible', [], 'A_rest', [], 'A', [], ...
        'shapes', [], 'vertices', [], 'faces', [], 'materials', [], 'duke', []);
    meshes(nmeshes) = mesh;
    
    % scan meshes
    for i = 1 : nmeshes
        
        % scan mesh type
        ScanType(fid, 'mesh');
        
        % scan mesh name
        mesh.name = ScanString(fid, 'name');
        
        % scan mesh visiblity
        visible = ScanString(fid, 'visible');
        mesh.visible = strcmp(visible, 'True');
        
        % scan mesh rest pose
        mesh.A_rest = ScanPose(fid);
        
        % initiate mesh pose
        mesh.A = mesh.A_rest;
        
        % scan mesh number of shapes
        nshapes = ScanNumber(fid, 'shapes');
        
        % scan mesh number of vertices
        nvertices = ScanNumber(fid, 'vertices');
        
        % scan mesh number of faces
        nfaces = ScanNumber(fid, 'faces');
        
        % scan mesh shapes
        mesh.shapes = ScanShapes(fid, nshapes, nvertices);
        
        % initiate evaluated vertices
        mesh.vertices = mesh.shapes(1).vertices;
        
        % scan mesh pervertex data
        %[mesh.normals] = ScanPervertex(fid, nvertices);
        
        % scan mesh perface data
        [mesh.faces, mesh.materials] = ScanPerface(fid, nfaces);
        
        % initiate duke material data
        mesh.duke = InitiateDuke(materials, nvertices);
        
        % assign mesh
        meshes(i) = mesh;
        
    end
    
end


function [indices, weights] = ScanWeights(fid, nmeshes)
    
    % allocate cell arrays
    indices = cell(1, nmeshes);
    weights = cell(1, nmeshes);
    
    % scan mesh weights
    for i = 1 : nmeshes
        
        % scan weight type
        ScanType(fid, 'weights');
        
        % scan mesh name and discard (used only for readability)
        data = ScanString(fid, 'name'); %#ok<NASGU>
        
        % scan indices and weights
        nweights = ScanNumber(fid, 'weights');
        data = textscan(fid, '%f %f', nweights);
        func = @(x) nnz(isnan(x));
        if any(cellfun(func, data))
            error('format');
        end
        
        % assign indices and weights
        indices{i} = data{1}.' + 1; % convert to 1-indexing
        weights{i} = data{2}.';
        
    end
    
end


function [bones] = ScanBones(fid, nbones, nmeshes)
    
    % allocate bones
    A = Affine();
    bone = struct('name', '', 'parent', '', 'children', [], ...
        'A_rest', A, 'A', A, 'indices', [], 'weights', []);
    bones(nbones) = bone;
    
    % scan bones
    for i = 1 : nbones
        
        % scan bone type
        data = textscan(fid, 'type : %s', 1);
        if ~strcmp(data{1}, 'bone')
            error('format');
        end
        
        % scan bone name
        bone.name = ScanString(fid, 'name');
        
        % scan bone parent
        bone.parent = ScanString(fid, 'parent');
        
        % scan bone children
        nchildren = ScanNumber(fid, 'children');
        data = textscan(fid, '%s', nchildren);
        bone.children = data{1};
        
        % scan bone rest pose
        bone.A_rest = ScanPose(fid);
        
        % initiate bone pose
        bone.A = bone.A_rest;
        
        % scan bone weights
        [bone.indices, bone.weights] = ScanWeights(fid, nmeshes);
        
        % assign bone
        bones(i) = bone;
        
    end
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
