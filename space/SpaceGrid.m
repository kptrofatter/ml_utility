% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% SpaceGrid() - constructs grid vectors and arrays for the given space type.
%
% USAGE:
%   [space] = SpaceGrid(space)
%
% INPUT:
%   [1,1] struct | space | space structure (see Space())
%
% OUTPUT:
%   [1,1] struct | space | space structure with grids added
%   [1,?] double | .x    | x grid vector for {'R1', 'R2', 'R3'}
%   [1,?] double | .y    | y grid vector for {'R2', 'R3'}
%   [1,?] double | .z    | z grid vector for {'R3'}
%   [?]   double | .X    | x ndgrid array for {'R1', 'R2', 'R3'}
%   [?]   double | .Y    | y ndgrid array for {'R2', 'R3'}
%   [?]   double | .Z    | z ndgrid array for {'R3'}
%
% TODO:
%   + implement {'polar', 'cylindrical', 'spherical', 'azel'} grids

function [space] = SpaceGrid(space)
    
    % get space variables
    extent = space.extent;
    pitch = space.pitch;
    count = space.count;
    
    % test space type
    switch space.type
    case 'R1'
        space.x = GridVector(extent(1, :), pitch(1), count(1));
        space.X = space.x;
    case 'R2'
        space.x = GridVector(extent(1, :), pitch(1), count(1));
        space.y = GridVector(extent(2, :), pitch(2), count(2));
        [space.X, space.Y] = ndgrid(space.x, space.y);
    case 'R3'
        space.x = GridVector(extent(1, :), pitch(1), count(1));
        space.y = GridVector(extent(2, :), pitch(2), count(2));
        space.z = GridVector(extent(3, :), pitch(3), count(3));
        [space.X, space.Y, space.Z] = ndgrid(space.x, space.y, space.z);
    end
    
end

function [v] = GridVector(extent, pitch, count)
    % compute voxel centers of grid vector
    v =  (0 : count - 1) * pitch + pitch / 2.0 + extent(1);
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
