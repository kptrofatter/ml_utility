% %============================================================================%
% %                                                                            %
% %                                                                            %
% % math\Affine.m                                                              %
% %============================================================================%
% AFFINE applies an affine transformation to a matrix of column vectors.
%
% USAGE:
%   [b] = Affine(A_ba, a)
%
% INPUT:
%   [1,1] struct | A_ba | affine transformation structure
%   [n,n] double | .M   | transformation matrix
%   [n,1] double | .v   | translation vector
%   [n,m] double | a    | matrix of column vectors to transform
%
% OUTPUT:
%   [n,m] double | b    | matrix of transformed vectors

function [b] = Affine(A_ba, a)
    b = A_ba.M * a + repmat(A_ba.v, [1, size(a, 2)]);
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
