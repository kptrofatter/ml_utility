% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% SpaceSet() - set defining space properties and solve for the rest.
%
% USAGE:
%  [space] = SpaceSet(space, name1, data1, name2, data2)
%
% INPUT:
%   [1,1] struct | space | space structure (see Space())
%   [1,?] char   | name1 | name of first data
%   [n,2] double | data1 | either extent, pitch, or size
%
% OUTPUT:
%   [1,1] struct | space | set space structure

function [space] = SpaceSet(space, name1, data1, name2, data2)
    
    % format names
    name1 = lower(name1);
    name2 = lower(name2);
    
    % initialize data
    extent = [];
    pitch = [];
    count = [];
    
    % map argument 1
    switch name1
    case 'extent'
        extent  = data1;
    case 'pitch'
        pitch   = data1;
    case 'count'
        count = data1;
    otherwise
        error('unrecognized field name ''%s''', name1);
    end
    
    % map argument 2
    switch name2
    case 'extent'
        extent  = data2;
    case 'pitch'
        pitch   = data2;
    case 'count'
        count = data2;
    otherwise
        error('unrecognized field name ''%s''', name1);
    end
    
    % set data
    space.extent = extent;
    space.pitch  = pitch;
    space.count  = count;
    
    % variable mask
    mask = [isempty(extent), isempty(pitch), isempty(count)];
    
    % solve for unknowns
    if isequal(mask, [1, 0, 0])
        
        % solve for (centered) extent
        n = numel(pitch);
        extent = zeros(n, 2);
        extent(:, 2) = count .* pitch;
        space.extent = extent - extent(:, [2, 2]) ./ 2.0;
        
    elseif isequal(mask, [0, 1, 0])
        
        % solve for pitch
        dextent = extent(:, 2) - extent(:, 1);
        space.pitch = dextent.' ./ count;
        
    elseif isequal(mask, [0, 0, 1])
        
        % solve for count (holding pitch constant and expanding extent maxes)
        dextent = extent(:, 2) - extent(:, 1);
        space.count = ceil(dextent.' ./ pitch);
        space.extent(:, 2) = (space.count .* pitch).' + extent(:, 1);
        
    else
        
        % duplicate fields
        error('duplicate field names ''%s''', name1);
        
    end
    
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
