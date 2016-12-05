% %============================================================================%
% %                                                                            %
% %                                                                            %
% % math\Affine.m                                                              %
% %============================================================================%
% AFFINE applies an affine transformation to a matrix of column vectors.
%
% USAGE:
%   [b]=Affine(A_ba,a)
%
% INPUT:
%   [1,1] struct | A_ba | Affine transformation structure
%   [n,n] double | .R   | Rotation
%   [n,1] double | .t   | Translation
%   [n,m] double | a    | Matrix of column vectors to transform
%
% OUTPUT:
%   [n,m] double | b    | Matrix of transformed vectors

function [b]=Affine(A_ba,a)
    b = A_ba.R * a + repmat(A_ba.t,[1,size(a,2)]);
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
