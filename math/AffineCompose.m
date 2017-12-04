% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% AffineCompose() - combines affine transformations by matrix multiplication.
%
% USAGE:
%   [A_ca] = AffineCompose(A_cb, A_ba)
%
% INPUT:
%   [1,1] struct | A_cb | left  multiply affine transformation structure
%   [1,n] struct | A_cb | left  multiply affine transformation structure array
%   [1,1] struct | A_ba | right multiply affine transformation structure
%   [1,n] struct | A_ba | right multiply affine transformation structure array
%
% OUTPUT:
%   [1,n] struct | A_ca | composed affine tranformation structure array
%   [m,m] double | .M   | transformation matrix
%   [m,1] double | .v   | translation vector

function [A_ca] = AffineCompose(A_cb, A_ba)
    
    % count transforms
    na = numel(A_ba);
    nb = numel(A_cb);
    n = max(na, nb);
    
    % allocate
    d = numel(A_ba(1).v);
    A_ca = Affine(n, d);
    
    if nb == na
        
        % pairwise multiply arrays
        for i = 1 : na
            A_ca(i).v = A_cb(i).v + A_cb(i).M * A_ba(i).v;
            A_ca(i).M = A_cb(i).M * A_ba(i).M;
        end
        
    elseif nb == 1 && na > 1
        
        % left multiply right array
        for i = 1 : na
            A_ca(i).v = A_cb.v + A_cb.M * A_ba(i).v;
            A_ca(i).M = A_cb.M * A_ba(i).M;
        end
        
    elseif nb > 1 && na == 1
        
        % right multiply left array
        for i = 1 : nb
            A_ca(i).v = A_cb(i).v + A_cb(i).M * A_ba.v;
            A_ca(i).M = A_cb(i).M * A_ba.M;
        end
        
    elseif nb ~= 0 && na ~= 0
        
        % size mismatch
        error('Size mismatch: numel(A)>1 && numel(B)>1 && numel(A)~=numel(B)');
        
    end
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
