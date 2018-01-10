% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% Log() - computes a logarithm with a given base.
%
% USAGE:
%   [y] = Log(base, x)
%
% INPUT:
%   [1,1] double | base | logarithm base
%   [?]   double | x    | input
%
% OUTPUT:
%   [?]   double | y    | ouput

function [y] = Log(base, x)
    y = log(x) ./ log(base);
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
