% Casts vectors to scalar data types
%
% A  = [v1,v2,v3, ... vn] where v1 = [v11, v12, ... v1n]
%
% =>
%
% a1 = [v11; v21; ... vn1]
% a2 = [v12; v22; ... vn2]
% ...
% am = [vm1; vm2; ... vmn]

function [varargout] = CastV2S(V)
    % Count components to copy
    if nargin() == 0
        n = 0;
    else
        n = min(nargout,size(V,1));
    end
    % Allocate
    varargout = cell(n,1);
    % Copy output head
    for i = 1:n
        varargout{i} = V(i,:);
    end
    % Null output tail
    for i = n+1:nargout()
        varargout{i} = [];
    end
end
