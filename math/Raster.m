% %============================================================================%
% % MetaImager                                                                 %
% %                                                                            %
% % math\Raster.m                                                              %
% %============================================================================%
% Raster() - maps vertices to indices relative to a discretized space. Vertices
% are mapped to the closest voxel center.
%
% USAGE:
%   [indices] = Raster(vertices, space)
%
% INPUT:
%   [m,n] double | vertices | vertices to rasterize
%   [1,1] struct | space    | space structure (see Space())
%
% OUTPUT:
%   [m,n] double | indices  | vertex indices relative to space
%
% NOTE:
%   + resulting indices use MATLAB 1-indexing
%   + vertices at max extents are mapped outside the space; be sure to clip!
%
% TODO:
%   + add clamping option

function [indices] = Raster(vertices, space)
    
    % count vertices to map
    nvertices = size(vertices, 2);
    
    % get voxels along each space axis
    nvoxels = repmat(space.count.', [1, nvertices]);
    
    % get minimum extent along each space axis
    extent0 = repmat(space.extent(:,1), [1, nvertices]);
    
    % get extent length along each space axis
    dextent = space.extent(:, 2) - space.extent(:, 1);
    dextent = repmat(dextent, [1, nvertices]);
    
    % rasterize
    indices = floor(nvoxels .* (vertices - extent0) ./ dextent) + 1;
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
