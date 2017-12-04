% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% DarkAxes() - creates a new axes with a dark color scheme.
%
% USAGE:
%   [ah] = DarkAxes(fh?, position?)
%
% INPUT:
%   [1,1] figure | fh       | parent figure handle
%   [1,4] double | position | axes position w.r.t figure (x,y,w,h)
%
% OUTPUT:
%   [1,1] axes   | ah       | axes handle

function [ah] = DarkAxes(fh, position, color)
    
    % figure
    if ~exist('fh', 'var') || isempty(fh)
        fh = DarkFigure();
    end
    
    % axes
    ah = axes('Parent', fh);
    
    % axes position w.r.t. figure
    if exist('position', 'var')
        ah.Position = position;
    end
    
    % format
    grid(ah,'on');
    axis(ah, 'equal', 'tight');
    
    % main color
    if ~exist('color', 'var') || isempty(color)
        color = [0.00, 0.00, 0.00]; % axes background
    end
    
    % complement color
    color2 = [1.00, 1.00, 1.00] - color; % axes labels, try not to use gray
    
    % set color
    ah.Color = color;
    ah.XColor = color2;
    ah.YColor = color2;
    ah.ZColor = color2;
    ah.XLabel.Color = color2;
    ah.YLabel.Color = color2;
    ah.ZLabel.Color = color2;
    ah.Title.Color = color2;
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
