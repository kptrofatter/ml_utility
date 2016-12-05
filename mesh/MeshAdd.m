% %==================================================================% +-------+
% % Utility                                                          % | | | * |
% %                                                                  % | |/    |
% % mesh/MeshAdd.m                                                   % | |_| * |
% %==================================================================% +-------+
% MeshAdd() adds a constant vector to vector data in mesh format.
%
% USAGE:
%   [z1,z2,z3,...zn]=MeshAdd(y,x1,x2,x3,...xn)
% INPUT:
%   [n,1] double | y         | Constant vector
%   [???] double | xn        | Input  coordinate meshes (n-dimensional)
% OUPUT:
%   [???] double | zn        | Output coordinate meshes (n-dimensional)

function [varargout]=MeshAdd(y,varargin)
    % Vector to mesh
    varargout=cell(1,nargin-1);
    for i=1:nargin-1
        varargout{i}=y(i)+varargin{i};
    end
end
