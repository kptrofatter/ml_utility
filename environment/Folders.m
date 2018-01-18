% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% Folders() - constructs folder paths suitable for managing labwork.
%
% For example, if working on imaging where you have assembled a variation of a
% system and want to run a series of experiments or simulations, one could call
% >> folder = Folders('home/', 'imager', 'newsystem', 'resolution_target');
%
% [home]/
%   code/
%     [project]/    % use to organize project code
%   data/
%     shared/
%     [project]/    % use to store project studies, which reuse project code
%       [study]/    % use to store shared study data and individual trials
%         [trial]/  % use to store individual data sets
%
% USAGE: [folder] = Folders(home, project, study, trial)
%
% INPUT:
%   [1,?] char   | home      | home folder
%   [1,?] char   | project   | project folder
%   [1,?] char   | study     | study folder
%   [1,?] char   | trial     | trial folder
%
% OUTPUT:
%   [1,1] struct | folder    | folder structure
%   [1,?] char   | .home     | home folder
%   [1,?] char   | .code     | code folder
%   [1,?] char   | .codebase | project code folder
%   [1,?] char   | .data     | data folder
%   [1,?] char   | .shared   | shared data folder
%   [1,?] char   | .database | project data folder
%   [1,?] char   | .study    | study folder
%   [1,?] char   | .trial    | trial folder

function [folder] = Folders(home, project, study, trial)
    
    % pick slashes
    if isunix()
        
        % *nix (a gentleman's choice)
        delimiter = '/';
        
    else
        
        % windows (boo! wrong!)
        delimiter = '\';
        
    end
    
    % home
    home = fullfile(home);
    if home(end) == delimiter
        folder.home = fullfile(home);
    else
        folder.home = [fullfile(home), delimiter];
    end
    
    % code
    folder.code     = [fullfile(folder.home   , 'code'  ), delimiter];
    folder.codebase = [fullfile(folder.code   , project ), delimiter];
    
    % data
    folder.data     = [fullfile(folder.home   , 'data'  ), delimiter];
    folder.shared   = [fullfile(folder.data   , 'shared'), delimiter];
    folder.project  = [fullfile(folder.data   , project ), delimiter];
    folder.study    = [fullfile(folder.project, study   ), delimiter];
    folder.trial    = [fullfile(folder.study  , trial   ), delimiter];
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
