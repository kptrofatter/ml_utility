% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% FileList() - lists pathnames contained within a folder, b/c MATLAB's ls blows.
%
% USAGE:
%   [paths] = FileList(folder)
%
% INPUT:
%   [1,?] char | folder | filesystem folder pathname
%
% OUTPUT:
%   [1,?] cell | paths  | list of absolute pathnames
%
% TODO:
%   + add relative pathname list option
%   + add recursive option

function [paths] = FileList(folder)
    
    % enumerate files
    d = dir(folder);
    
    % test for and remove folders '.' and '..'
    if isequal(d(1).name, '.' ),  d(1) = [];  end
    if isequal(d(1).name, '..'),  d(1) = [];  end
    
    % build pathnames
    npaths = numel(d);
    paths = cell(1, npaths);
    for i = 1 : npaths
        paths{i} = [d(i).folder, '\', d(i).name];
    end

end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
