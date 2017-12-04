% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% Space() - makes a new space structure.
%
% USAGE:
%   [space] = Space(type)
%
% INPUT:
%   [1,?] char   | type    | {'R1', 'R2', 'R3', ...
%                             'polar', 'cylindrical', 'spherical', 'azel'}
%
% OUTPUT:
%   [1,1] struct | space   | newly initiated space structure
%   [1,?] char   | .type   | space type
%   [n,2] double | .extent | min and max extent of space
%   [1,n] double | .pitch  | pitch of axis divisions
%   [1,n] double | .count  | number of axis divisions

function [space] = Space(type)
    
    % create space
    space = struct('type', type, 'extent', [], 'pitch', [], 'count', []);
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
