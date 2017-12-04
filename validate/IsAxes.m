% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% IsAxes() - tests if variable is a valid axis.
%
% USAGE:
%   [test] = IsAxis(ah)
%
% INPUT:
%   [?,?] ???     | ah   | variable to test
%
% OUTPUT:
%   [1,1] logical | test | result of test

function [test] = IsAxes(ah)
    
    try
        test = strcmp(get(ah, 'type'), 'axes');
    catch
        test = false();
    end
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
