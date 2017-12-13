% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% IsDec() - tests if a string only contains decimal characters [0-9].
%
% USAGE:
%   [test] = IsDec(str)
%
% INPUT:
%   [1,?] char    | str  | string to test
%
% OUTPUT:
%   [1,1] logical | test | result of the test

function [test] = IsDec(str)
    test = ischar(str) && ~isempty(str) && all(InRange(str, '0', '9'));
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
