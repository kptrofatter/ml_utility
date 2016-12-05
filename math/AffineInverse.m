% %============================================================================%
% %                                                                            %
% %                                                                            %
% % math\AffineInverse.m                                                       %
% %============================================================================%
% AFFINEINVERSE calculates the inverse of affine transformations.
%
% USAGE:
%   [A_ab]=AffineInverse(A_ba)
%
% INPUT:
%   [m,1] struct | A_ba | Affine transformation structure array
%   [n,n] double | .R   | Rotation
%   [n,1] double | .t   | Translation
%
% OUTPUT:
%   [m,1] struct | A_ab | Inverse affine transformation structure array

function [A_ab]=AffineInverse(A_ba)
    % Invert
    A_ab=A_ba;
    for i=1:numel(A_ba)
        A_ab(i).R = inv(A_ba(i).R);
        A_ab(i).t = -A_ab(i).R * A_ba(i).t;
    end
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
