% %==================================================================% +-------+
% % Imager                                                           % | | | * |
% %                                                                  % | |/    |
% % Draw3.m                                                          % | |_| * |
% %==================================================================% +-------+
% Draw3() is a quick way to visualize volumetric data that hides the insanity.
%
% USAGE:
%   [ah,h]=Draw3(ah?,v,x,y,z,name?,look?)
% INPUT:
%   [1,1]   axis    | ah   | Axis handle (default=axes('Parent',figure()))
%   [x,y,z] double  | v    | Volumetric data [?]
%   [1,x]   double  | x    | X grid vector [m]
%   [1,y]   double  | y    | Y grid vector [m]
%   [1,z]   double  | z    | Z grid vector [m]
%   [1,?]   char    | name | Axis title
%   [1,2]   double  | look | Axis view angle (default=[40,35]) [deg]
% OUPUT:
%   [1,1]   axis    | ah   | Axis handle
%   [1,1]   struct  | h    | Vol3d() handle structure

function [ah,h]=Draw3(ah,v,x,y,z,name,look)
    % Default axis
    if ~exist('ah','var')||isempty(ah)
        fh=figure();
        ah=axis('Parent',fh);
    end
    % Default name
    if ~exist('name','var')||isempty(name)
        name='';
    end
    % Default look
    if ~exist('look','var')||isempty(look)
        look=[40,35];
    end
    
    % Draw
    h=vol3d(...
        'CData',permute(v,[2,1,3]),...
        'XData',x([1,end]),...
        'YData',y([1,end]),...
        'ZData',z([1,end]),...
        'Parent',ah ...
    );
    % Format
    axis(ah,'equal');
    axis(ah,'tight');
    grid(ah,'on');
    view(ah,look(1),look(2));
    % Notate
    xlabel(ah,'x [m]');
    ylabel(ah,'y [m]');
    zlabel(ah,'z [m]');
    title(ah,name);
end
