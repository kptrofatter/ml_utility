% %============================================================================%
% %                                                                            %
% %                                                                            %
% % math\AffineCompose.m                                                       %
% %============================================================================%
% AFFINECOMPOSE combines affine transformations by matrix multiplication.
%
% USAGE:
%   [A_ca]=AffineCompose(A_cb,A_ba)
%
% INPUT:
%   [1,1] struct | A_cb | Left  multiply affine transformation structure
%   [m,1] struct | A_cb | Left  multiply affine transformation structure array
%   [1,1] struct | A_ba | Right multiply affine transformation structure
%   [m,1] struct | A_ba | Right multiply affine transformation structure array
%
% OUTPUT:
%   [m,1] struct | A_ca | Composed affine tranformation structure array
%   [n,n] double | .R   | Rotation
%   [n,1] double | .t   | Translation

function [A_ca]=AffineCompose(A_cb,A_ba)
    % Count
    na=numel(A_ba);
    nb=numel(A_cb);
    
    % Allocate
    A_ca(max(na,nb),1)=struct('R',eye(3),'t',[0;0;0]);
    
    if nb==na
        % Per element multiply arrays
        for i=1:na
            A_ca(i).t = A_cb(i).t + A_cb(i).R * A_ba(i).t;
            A_ca(i).R = A_cb(i).R * A_ba(i).R;
        end
    elseif nb==1&&na>1
        % Left multiply array
        for i=1:na
            A_ca(i).t = A_cb.t + A_cb.R * A_ba(i).t;
            A_ca(i).R = A_cb.R * A_ba(i).R;
        end
    elseif nb>1&&na==1
        % Right multiply array
        for i=1:nb
            A_ca(i).t = A_cb(i).t + A_cb(i).R * A_ba.t;
            A_ca(i).R = A_cb(i).R * A_ba.R;
        end
    elseif nb~=0&&na~=0
        % Error
        error('Size mismatch: numel(A)>1 && numel(B)>1 && numel(A)~=numel(B)');
    end
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
