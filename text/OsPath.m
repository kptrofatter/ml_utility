% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% SlashPath() - converts path name slashes to correct OS type of slash.
%
% USAGE:
%   [ospath] = SlashPath(path)
%
% INPUT:
%   [1,n] char | path   | path with mangled slashes
%
% OUTPUT:
%   [1,n] char | ospath | os correct path
%
% NOTES:
%   ! slashes are assumed to be delimters, and no escape sequence exists

function [ospath] = OsPath(path)
    
    % pick slash
    if isunix()
        delimiter = '/'; % *nix
        replace = '\';
    else
        delimiter = '\'; % windows
        replace = '/';
    end
    
    % replace slashes
    ospath = strrep(path, replace, delimiter);
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
