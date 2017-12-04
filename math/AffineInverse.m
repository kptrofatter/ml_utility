% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% AffineInverse() - calculates the inverse of invertible affine transformations.
%
% USAGE:
%   [A_ab] = AffineInverse(A_ba)
%
% INPUT:
%   [1,n] struct | A_ba | affine transformation structure array
%   [m,m] double | .M   | transformation matrix
%   [m,1] double | .v   | translation vector
%
% OUTPUT:
%   [1,n] struct | A_ab | inverse affine transformation structure array

function [A_ab] = AffineInverse(A_ba)
    A_ab = A_ba;
    for i = 1 : numel(A_ba)
        A_ab(i).M = inv(A_ba(i).M);
        A_ab(i).v = -A_ab(i).M * A_ba(i).v;
    end
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
