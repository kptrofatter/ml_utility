% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% SpaceEqual() - compares the equality of two space structures.
%
% USAGE:
%   [equal] = SpaceEqual(a, b)
%
% INPUT:
%   [1,1] struct  | a     | space structure (see Space())
%   [1,1] struct  | b     | space structure
%
% OUTPUT:
%   [1,1] logical | equal | logical result of the comparision

function [equal] = SpaceEqual(a, b)
    
    % test equality
    equal = isequal(a.type, b.type) ...
        && isequal(a.extent, b.extent) ...
        && isequal(a.pitch, b.pitch) ...
        && isequal(a.count, b.count);
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
