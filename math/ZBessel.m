% %============================================================================%
% % Utility                                                                    %
% %                                                                            %
% % /utility/math/ZBessel.m                                                    %
% %============================================================================%
% ZBessel() computes zeros of Bessel functions.
%
% USAGE:
%   [z] = ZBessel(kind,m,p)
% INPUT:
%   [1,?] char    | kind | Function kind {'J','Y','H1','H2','j','y','h1','h2'}
%   [s]   double  | m    | Function order
%   [s]   double  | p    | Zero order
% OUTPUT:
%   [s]   double  | z    | Function mapping

function [z] = ZBessel(kind,m,p)
    % Kind
    B = @(nu,r) Bessel(kind,nu,r);
    
    % Search range
    switch kind
    case 'J'
        xa = pi*(p-1+m/2+1/4);
        xb = pi*(p+0+m/2+1/4);
    case 'Y'
        xa = pi*(p-2+m/2+3/4);
        xb = pi*(p-1+m/2+3/4);
    case 'j'
        xa = pi*(p-1+m/2+1/4);
        xb = pi*(p+0+m/2+1/4);
    case 'y'
        xa = pi*(p-2+m/2+3/4);
        xb = pi*(p-1+m/2+3/4);
    end
    % Clamp
    xa = Clamp(xa, 0.5, inf());
    
    % Find zeros
    z = zeros(size(xa));
    for i = 1 : numel(xa)
        B2 = @(x) B(m(i),x);
        z(i) = fzero(B2,[xa(i),xb(i)]);
    end
    
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
