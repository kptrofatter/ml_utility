% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% DarkFigure() - creates a new figure with a dark color scheme.
%
% USAGE:
%   [fh] = DarkFigure(position?, palette=parula(32), color=[0.40,0.40,0.40])
%
% INPUT:
%   [1,4] double | position | figure position w.r.t screen (x,y,w,h)
%   [?,3] double | palette  | figure colormap palette
%   [1,3] double | color    | figure background color
%
% OUTPUT:
%   [1,1] figure | fh       | figure handle

function [fh] = DarkFigure(position, palette, color)
    
    % figure
    fh = figure();
    
    % position
    if exist('position', 'var') && ~isempty(position)
        fh.Position = position;
    end
    
    % colormap
    if ~exist('palette', 'var') || isempty(palette)
        palette = parula(32);
    end
    colormap(fh, palette);
    
    % set color
    if ~exist('color', 'var') || isempty(color)
        color = [0.40, 0.40, 0.40]; % dark gray
    end
    fh.Color = color;

end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
