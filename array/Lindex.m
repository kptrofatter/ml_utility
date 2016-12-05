%==============================================================================%
% Lindex                                                       Duke University %
%                                                              K. P. Trofatter %
% utility/???/Lindex.m                                           kpt2@duke.edu %
%==============================================================================%
% Lindex() converts a set of multidimensional indexes into a linear index
%
% USAGE:
%   [i] = Lindex(index,s)
% INPUT:
%   double linear [1,m] % Index 
%   double s      [1,n] % Size of multidimensional array
%
% OUTPUT:
%   double i      [1,n] % Matrix of index column vectors
%    -or-
%   cell   i      [1,n] % Cell of index grids


% Get Vector or Array, turn into scalar or grid


function [lindex] = Lindex(index, s)
    n = size(index);
    lindex = ones(n);
    % Lindex loop
    for i = 1:n(1)
        % Accumulate index
        lindex(1,:) = lindex(1,:) + (index(i,:)-1) * prod(s(1:i-1));
    end
    lindex = reshape(squeeze(lindex(1,:)),n(2:end));
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
