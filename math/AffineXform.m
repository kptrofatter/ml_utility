% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% AffineXform() applies an affine transformation to a matrix of column vectors.
%
% USAGE:
%   [b] = AffineXform(A_ba, a)
%
% INPUT:
%   [1,1] struct | A_ba | affine transformation structure
%   [m,m] double | .M   | transformation matrix
%   [m,1] double | .v   | translation vector
%   [m,n] double | a    | matrix of column vectors to transform
%
% OUTPUT:
%   [m,n] double | b    | matrix of transformed vectors
%
% NOTE:
%   The choice of transformation representation and computation is based on the
%   experimental space and time complexity of four different implementations,
%   including homogenerous coordinates representations.

function [b] = AffineXform(A_ba, a)
    b = A_ba.M * a + repmat(A_ba.v, [1, size(a, 2)]);
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
