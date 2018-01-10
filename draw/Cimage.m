% %============================================================================%
% % Cimage                                                                     %
% %                                                                            %
% % /utility/draw/Cimage.m                                                     %
% %============================================================================%
% Cimage() displays a complex valued 2D image.
%
% USAGE:
%   [h] = Cimage(ah, x=1:,, y=1:n, z, type='linear', base=2, range=0.4, phase=0)
%
% INPUT:
%   [1,1] axes    | ah    | axes handle. [] gets current axes.
%   [1,m] double  | x     | x grid vector
%   [1,n] double  | y     | y grid vector
%   [m,n] cdouble | z     | complex data
%   [1,?] char    | type  | draw type {'flat', 'linear', 'log'}
%   [1,1] double  | base  | lightness log base, 0.0=off [0.0, inf())
%   [1,1] double  | range | lightness range size [0.0, 1.0]
%   [1,1] double  | phase | [rad] hue phase offset [0.0, 2.0*pi]
%
% OUTPUT:
%   [1,1] ?       | h     | image or surf handle

function [h] = Cimage(ah, x, y, z, type, base, range, phase)
    
    % defaults
    if isempty(ah)
        ah = gca();
    end
    if isempty(x) && isempty(y)
        [nx, ny] = size(z);
        x = 1 : nx;
        y = 1 : ny;
    end
    if ~exist('type', 'var') || isempty(type)
        type = 'linear';
    end
    if ~exist('base', 'var') || isempty(base)
        base  = 2.0;
    end
    if ~exist('range', 'var') || isempty(range)
        range = 0.4;
    end
    if ~exist('phase', 'var') || isempty(phase)
        phase = 0.0;
    end
    
    % compute hs_
    H = mod(angle(z) + phase, 2.0 * pi);
    S = ones(size(H));
    
    % compute __l
    Z = abs(z);
    Zlog = Log(base, Z);
    if base == 0.0
        
        % linear gradient
        Zmin = min(Z(:));
        Zmax = max(Z(:));
        L = (Z - Zmin) ./ (Zmax - Zmin);
        
    else
        
        % logarithmic gradient
        L = Zlog - floor(Zlog);
        
    end
        
    % scale lightness = [0.0, 1.0] by range = [0.0, 1.0] and center
    L = (L - 0.5) * range + 0.5;
    
    % convert hsl to rgb
    [R, G, B] = Hsl2Rgb(H, S, L);
    img(:, :, 1) = R;
    img(:, :, 2) = G;
    img(:, :, 3) = B;
    
    % matlab insanity (saved for the last second so other programming is sane)
    img = permute(img, [2, 1, 3]);
    
    % draw begin
    hold(ah,'on');
    
    % complex data
    switch type
    case 'flat'
        % flat surface
        h = image(x, y, img, 'Parent', ah);
        
    case 'linear'
        % modular surface
        h = surf(x, y, Z.', img, 'EdgeColor', 'none');
        
    case 'log'
        % log of modular surface
        h = surf(x, y, Zlog.', img, 'EdgeColor', 'none');
        
    end
    
    % draw end
    hold(ah, 'off');
    
    % format
    ah.YDir = 'normal';
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
