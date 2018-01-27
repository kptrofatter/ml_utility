% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% LabFolders() - constructs folder paths suitable for managing labwork.
%
% For example, if working on imaging where you have assembled a variation of a
% system and want to run a series of experiments or simulations, one could call
% >> folder = Folders('home/kpt2/', 'imager', 'layout', 'wall', 'person');
%
% [home]/
%   code/                % stores code folders
%     [project]/         % stores project code
%   data/                % stores data folders
%     shared/            % stores shared project data
%     [project]/         % stores project data
%       [study]/         % stores code/data for a particular study of a project
%         [trial]/       % stores code/data for a particular trial of a study
%           [run]/       % stores data from an individual run of a trial
%
% USAGE: [folder] = Folders(home, project, study, trial, run)
%
% INPUT:
%   [1,?] char   | home      | home path
%   [1,?] char   | project   | project folder name
%   [1,?] char   | study     | study folder name
%   [1,?] char   | trial     | trial folder name
%   [1,?] char   | run       | run folder name
%
% OUTPUT:
%   [1,1] struct | folder    | folder structure
%   [1,?] char   | .home     | home folder
%   [1,?] char   | .code     | code folder
%   [1,?] char   | .codebase | project code folder
%   [1,?] char   | .data     | data folder
%   [1,?] char   | .shared   | shared data folder
%   [1,?] char   | .project  | project data folder
%   [1,?] char   | .study    | study folder
%   [1,?] char   | .trial    | trial folder
%   [1,?] char   | .run      | individual run folder

function [folder] = LabFolders(home, project, study, trial, run)
    
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
    folder.run      = [fullfile(folder.trial  , run     ), delimiter];
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
