function [V] = CastS2V(varargin)
    % Cast
    if nargin == 0
        % Empty
        V = [];
    else
        % Non-empty
        m = size(varargin{1},1);
        n = size(varargin{1},2);
        if n ~= 0 && (m == 0 || m > n);
            % Columns to vectors
            V = cell2mat(varargin()).';
        else
            % Rows to vectors
            V = cell2mat(varargin().');
        end
    end
end
