% %==================================================================% +-------+
% % Utility                                                          % | | | * |
% %                                                                  % | |/    |
% % /utility/math/Split.m                                            % | |_| * |
% %==================================================================% +-------+
% Split() seperates a real floating point array into its sign, integral, and
% fractional parts.
%
% USAGE:
%   [s,i,f] = Split(r)
%
% INPUT:
%   [?] double | r | Real number array
%   
% OUTPUT:
%   [?] double | s | Sign part
%   [?] double | i | Integral part
%   [?] double | f | Fractional part

function [s,i,f] = Split(r)
    a = abs(r);
    s = sign(r);
    i = fix(a);
    f = a - i;
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
