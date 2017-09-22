% %============================================================================%
% %                                                                            %
% %                                                                            %
% % math/AffineInverse.m                                                       %
% %============================================================================%
% AFFINEINVERSE calculates the inverse of affine transformations.
%
% USAGE:
%   [A_ab] = AffineInverse(A_ba)
%
% INPUT:
%   [m,1] struct | A_ba | affine transformation structure array
%   [n,n] double | .M   | transformation matrix
%   [n,1] double | .t   | translation vector
%
% OUTPUT:
%   [m,1] struct | A_ab | inverse affine transformation structure array

function [A_ab] = AffineInverse(A_ba)
    % Invert
    A_ab = A_ba;
    for i = 1 : numel(A_ba)
        A_ab(i).M = inv(A_ba(i).M);
        A_ab(i).t = -A_ab(i).M * A_ba(i).t;
    end
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
