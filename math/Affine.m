% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% Affine() - creates an identity affine transformation structure.
%
% USAGE:
%   [A] = Affine(n=1, d=3)
%
% INPUT:
%   [1,1] double | n    | [#] number of elements
%   [1,1] double | d    | [#] vectorspace dimension
%
% OUTPUT:
%   [1,1] struct | A    | affine transformation structure
%   [d,d] double | .M   | transformation matrix
%   [d,1] double | .v   | translation vector
%
% NOTE:
%   The choice of transformation representation and computation is based on the
%   experimental space and time complexity of four different implementations,
%   including homogenerous coordinates representations.

function [A] = Affine(n, d)
    
    % default n
    if ~exist('n', 'var') || isempty(n)
        n = 1;
    end
    
    % default d
    if ~exist('d', 'var') || isempty(d)
        d = 3;
    end
    
    % allocate and initialize
    A(1 : n) = struct('M', eye(d), 'v', zeros(d, 1));
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
