% %============================================================================%
% % Cimage                                                                     %
% %                                                                            %
% % /utility/draw/Cimage.m                                                     %
% %============================================================================%
% Cimage() displays a complex valued 2D image.
%
% USAGE:
%   [h] = Cimage(ah,x,y,z,p?,g?,b?,r?)
% INPUT:
%   [1,1] axes    | ah | Axes handle. Setting ah = [] invokes the current axes.
%   [1,m] double  | x  | X grid vector
%   [1,n] double  | y  | Y grid vector
%   [m,n] cdouble | z  | Complex data
%   [1,1] double  | p  | [rad] Hue phase constant        [0.0,2.0*pi] (p? = 0.0)
%   [1,1] double  | g  | Lightness gradient direction     {+1.0,-1.0} (g? = 1.0)
%   [1,1] double  | b  | Lightness log base, 0 = no log          {R+} (b? = 2.0)
%   [1,1] double  | r  | Lightness range                    [0.0,1.0] (r? = 0.5)
% OUTPUT:
%   [1,1] image   | h  | Image handle
% NOTES:
%   Either all optional arguments must be specified, or none at all.

function [h] = Cimage(ah,x,y,z,p,g,b,r)
    
    % Mode
    if nargin()<5
        p = 0.0; % [rad] Phase colormap offset
        g = 1.0; % [#] Gradient direction
        b = 2.0; % [#] Log base
        r = 0.5; % [#] Intensity range
    end
    
    % Compute HSL
    H = mod(angle(z)+p,2.0*pi);
    S = ones(size(H));
    if b == 0.0
        E = z;
        L = (abs(E)-min(abs(E(:))))./(max(abs(E(:)))-min(abs(E(:))));
    else
        [~,~,E] = Split(Log(b,abs(z)));
        E = (E - 0.5) * r + 0.5;
        % Gradient
        if g < 0.0
            % Darker with more magnitude
            L = b.^-abs(E);
        else
            % Lighter with more magnitude
            L = 1.0 - b.^-abs(E);
        end
    end
    
    % Convert to RGB
    [R,G,B] = Hsl2Rgb(H,S,L);
    img(:,:,1) = R;
    img(:,:,2) = G;
    img(:,:,3) = B;
    
    % Axes
    if isempty(ah)
        ah = gca();
    end
    % Draw
    hold(ah,'on');
    h = image(x,y,flip(rot90(img)),'Parent',ah);
    contour(ah,x,y,flip(rot90(abs(z))),0.95*[1,1],'Color','b','LineWidth',2);
    contour(ah,x,y,flip(rot90(abs(z))),1.05*[1,1],'Color','r','LineWidth',2);
    hold(ah,'off');
    % Format
    ah.YDir = 'normal';
    
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
