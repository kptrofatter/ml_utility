% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% ProcrustesUnsorted() - finds the optimal proper rotation and translation that
% maps one set of points onto another. the sets are assumed to be the same size
% and unsorted.
%
% USAGE:
%   [A_ba] = ProcrustesUnsorted(b, a)
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
%
% NOTE:
%   primitive brute forced permutation sort takes O(n!), so keep n <= 8

function [A_ba, epsilon] = ProcrustesUnsorted(b, a)
    
    % count dimension, vectors
    [d, n] = size(a);
    
    % initalize results
    A_ba = Affine(1, d);
    epsilon = inf();
    
    % generate permutations
    p = perms(1 : n);
    
    % permutation loop
    for i = 1 : size(p, 1)
        
        % permute
        ap = a(:, p(i, :));
        
        % procrustes
        [A, e] = Procrustes(b, ap);
        
        % greedy search
        if e < epsilon
            A_ba = A;
            epsilon = e;
        end
        
    end
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
