% %============================================================================%
% %                                                                            %
% %                                                                            %
% % math/AffineCompose.m                                                       %
% %============================================================================%
% AFFINECOMPOSE combines affine transformations by matrix multiplication.
%
% USAGE:
%   [A_ca] = AffineCompose(A_cb, A_ba)
%
% INPUT:
%   [1,1] struct | A_cb | left  multiply affine transformation structure
%   [m,1] struct | A_cb | left  multiply affine transformation structure array
%   [1,1] struct | A_ba | right multiply affine transformation structure
%   [m,1] struct | A_ba | right multiply affine transformation structure array
%
% OUTPUT:
%   [m,1] struct | A_ca | composed affine tranformation structure array
%   [n,n] double | .M   | transformation matrix
%   [n,1] double | .t   | translation vector

function [A_ca] = AffineCompose(A_cb, A_ba)
    % count
    na = numel(A_ba);
    nb = numel(A_cb);
    
    % allocate
    A_ca(max(na, nb), 1) = struct('M', eye(3), 't', [0;0;0]);
    
    if nb == na
        % per element multiply arrays
        for i = 1 : na
            A_ca(i).t = A_cb(i).t + A_cb(i).M * A_ba(i).t;
            A_ca(i).M = A_cb(i).M * A_ba(i).M;
        end
    elseif nb == 1 && na > 1
        % left multiply array
        for i = 1 : na
            A_ca(i).t = A_cb.t + A_cb.M * A_ba(i).t;
            A_ca(i).M = A_cb.M * A_ba(i).M;
        end
    elseif nb > 1 && na == 1
        % right multiply array
        for i = 1 : nb
            A_ca(i).t = A_cb(i).t + A_cb(i).M * A_ba.t;
            A_ca(i).M = A_cb(i).M * A_ba.M;
        end
    elseif nb ~= 0 && na ~= 0
        % Error
        error('Size mismatch: numel(A)>1 && numel(B)>1 && numel(A)~=numel(B)');
    end
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
