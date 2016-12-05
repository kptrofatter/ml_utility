%==============================================================================%
% Index                                                        Duke University %
%                                                              K. P. Trofatter %
% utility/???/Index.m                                            kpt2@duke.edu %
%==============================================================================%
% Index() converts linear indexes into multidimensional indexes.
%
% USAGE:
%   [i_l, ..., i_d] = Index(lindex,s)
%   [i] = Index(lindex,s)
% INPUT:
%   [?]   double | lindex | [#] Linear indexes
%   [1,d] double | s      | [#] Size of multidimensional array
% OUTPUT:
%   [1,m] double | i_1    | [#] 1st index (Multi output, any index input)
%   [1,m] double | ...    | [#] ... index
%   [1,m] double | i_d    | [#] dth index
%    -or-
%   [d,m] double | i      | [#] Column (row) vectors (One out, one index input)
%    -or-
%   [d,?] double | i      | [#] Index array (One output, multi index input)

function [varargout] = Index(lindex, s)
    % Index loop
    varargout = cell(1, numel(s));
    t = lindex-1;
    for i = 1:numel(varargout)
        % Get index
        varargout{end-i+1} = floor(t ./ prod(s(1:end-i)) ) + 1;
        % Remove index part
        t = mod(t, prod(s(1:end-i)) );
    end
    
    % Return type
    if nargout() == 1
        if size(lindex,1) == 1
            % Column vectors
            varargout = { cell2mat(varargout') };
        elseif size(lindex,2) == 1
            % Row vectors
            varargout = { cell2mat(varargout) };
        else
            % Array
            n = ndims(index);
            varargout = { permute( cat(n+1,varargout{:}), [n+1, 1:n] ) };
        end
    end
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
