
close('all');
clear();
clc();

% Plot parameters
p = 0.0; % Phase constant
g = 1.0; % Lightness gradient sign
b = 2.0; % Lightness log base
r = 0.4; % lightness range
% Gif parameters
ani = 1;
gif = 'poop.gif';
loopcount = inf();
delay = 0.1;

% Grid
gq = 512;
aq = 64;
x = pi*1.0*linspace(-1.0, +1.0, gq);
y = pi*1.0*linspace(-1.0, +1.0, gq);
[X,Y] = ndgrid(x,y);
Z = X + 1.0j*Y;

% Test functions
f0 = Z;
f1 = sin(Z);
f2 = sin(1./Z);
f3 = 1 ./ (Z.^6 - 2).^2;
f4 = (Z.^2 - 1.0) .* (Z - 2.0 - 1.0i).^2 ./ (Z.^2 + 2.0 + 2.0i);
% Select
f = f1;

% Animate
a = -linspace(0.0, 2.0*pi, aq+1);
a = a(1:end-1);
fh = figure(1);
fh.Position=[1300,70,380,380];
ah = axes('Parent',fh);
while 1
    for i = 1:numel(a)
        cla(ah);
        Cimage(ah, x,y,f, a(i),g,b,r);
        axis(ah,'equal');
        axis(ah,'tight');
        if ani
            if i == 1
                Gif(fh,gif,delay,loopcount);
            else
                Gif(fh,gif,delay);
            end
        end
        pause(delay);
    end
    if ani
        break
    end
end