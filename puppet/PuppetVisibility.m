% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% PuppetVisibility() - sets mesh visibility quickly.
%
% USAGE:
%   [data] = PuppetVisibility(puppet, flags)
%
% INPUT:
%   [1,1] struct  | puppet | puppet structure (see PuppetScan())
%   [1,m] logical | flags  | array of mesh visibility flags
%
% OUTPUT:
%   [1,1] struct  | puppet | puppet with updated mesh visibility flags

function [puppet] = PuppetVisibility(puppet, flags)
    
    % status
    fprintf('Setting puppet ''%s'' visibility...\n', puppet.name);
    
    % count meshes
    nmeshes = numel(puppet.meshes);
    
    % default flags
    if nargin() < 2
        flags = true(1, nmeshes);
    end
    
    % count visible flags
    nvisibles = min(nmeshes, numel(flags));
    
    % covert flags to cell array
    % this is to turn the flags into a comma seperated list for the assignment
    cells = num2cell(logical(flags));
    
    % assign flags
    % i don't think anyone else in the group would understand this...
    % hell, i don't think half the folks at MathWorks would understand this...
    [puppet.meshes(1 : nvisibles).visible] = cells{:};
    
    % status
    for i = 1 : nmeshes
        
        % get mesh
        mesh = puppet.meshes(i);
        
        % get visibility string
        if mesh.visible
            status = 'visible';
        else
            status = 'hidden';
        end
        
        % print status
        spaces = repmat(' ', [1, max(0, 16 - numel(mesh.name))]);
        fprintf('  mesh : ''%s''%s %s\n', mesh.name, spaces, status);
        
    end
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
