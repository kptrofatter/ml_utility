% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% Procrustes() - finds the optimal proper rotation and translation that maps
% one tuple of points onto another. the sets are assumed to be pair-wise sorted.
%
% USAGE:
%   [A_ba] = Procrustes(b, a)
%
% INPUT:
%   [m,n] double | b       | to set, column vectors combined into matrix
%   [m,n] double | a       | from set, column vectors combined into matrix
%
% OUTPUT:
%   [1,1] struct | A_ba    | affine transformation
%   [m,m] double | .M      | transformation matrix
%   [m,1] double | .v      | translation vector
%   [1,1] double | epsilon | error measure (frobenius norm)

function [A_ba, epsilon] = Procrustes(b, a)
    
    % edge sets
    B = Edges(b);
    A = Edges(a);
    
    % compute rotation matrix
    [U, ~, V] = svd(B * A.');
    
    % enforce proper rotation
    d = size(a, 1);
    P = eye(d);
    P(end, end) = sign(det(U * V.')); % set sign of smallest singular value
    A_ba.M = U * P * V.';
    
    % compute translation vector
    A_ba.v = b(:, 1) - A_ba.M * a(:, 1);
    
    % compute epsilon
    C = b - AffineXform(A_ba, a);
    epsilon = sqrt(sum(C(:).^2));
    
end


function e = Edges(r)
    
    % allocate
    n = size(r, 2);
    e = zeros(size(r, 1), n * (n - 1) / 2);
    
    % initiate edge index
    iedge = 1;
    
    % enumerate edges
    for i = 1 : n - 1
        for j = i + 1 : n
            e(:, iedge) = r(:, j) - r(:, i);
            iedge = iedge + 1;
        end
    end
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
