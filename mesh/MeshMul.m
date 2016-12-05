% %==================================================================% +-------+
% % Utility                                                          % | | | * |
% %                                                                  % | |/    |
% % mesh/MeshMul.m                                                   % | |_| * |
% %==================================================================% +-------+
% MeshMul() applies matrix multiplication to vector data in mesh format.
%
% USAGE:
%   [b1,b2,b3,...bm]=MeshMul(A,x1,x2,x3,...xn)
% INPUT:
%   [m,n] double | A         | Matrix transformation
%   [???] double | xn        | Input  coordinate meshes (n-dimensional)
% OUPUT:
%   [???] double | bm        | Output coordinate meshes (m-dimensional)

function [varargout]=MeshMul(A,varargin)
    % Mesh to vector
    x=zeros(size(A,2),numel(varargin{1}));
    for i=1:size(A,2)
        x(i,:)=varargin{i}(:)';
    end
    
    % Transform
    b=A*x;
    
    % Vector to mesh
    varargout=cell(1,size(A,1));
    for i=1:size(A,1)
        varargout{i}=reshape(b(i,:),size(varargin{1}));
    end
end
