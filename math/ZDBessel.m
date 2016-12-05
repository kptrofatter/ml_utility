% %============================================================================%
% % Utility                                                                    %
% %                                                                            %
% % /utility/math/ZDBessel.m                                                   %
% %============================================================================%
% ZDBessel() computes zeros of derivatives of Bessel functions.
%
% USAGE:
%   [z] = ZDBessel(n,kind,m,p)
% INPUT:
%   [1,1] double  | n    | Derivative order
%   [1,?] char    | kind | Function kind {'J','Y','H1','H2','j','y','h1','h2'}
%   [s]   double  | m    | Function order
%   [s]   double  | p    | Zero order
% OUTPUT:
%   [s]   double  | z    | Function mapping
% TODO:
%   !!! THIS FUNCTION DOES NOT WORK YET !!!
%   If argument is greater than 2pi, things are ok
%   If argument is less than 2pi, shit gets weird
%   Need to detect the less regular zeros between 0 and 2pi somehow
%   Once that is figured out merge Bessel with DBessel and ZBessel with ZDBessel

function [z] = ZDBessel(n,kind,m,p)
    % Kind
    B = @(nu,r) DBessel(n,kind,nu,r);
    
    % Search range
    switch kind
    case 'J'
        xa = pi*(p-1+m/2+1/4+mod(n,2)/2);
        xb = pi*(p+0+m/2+1/4+mod(n,2)/2);
    case 'Y'
        xa = pi*(p-2+m/2+3/4);
        xb = pi*(p-1+m/2+3/4);
    case 'j'
        xa = pi*(p-1+m/2+1/4+mod(n,2)/2);
        xb = pi*(p+0+m/2+1/4+mod(n,2)/2);
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
        try
            z(i) = fzero(B2,[xa(i),xb(i)]);
        catch
            xa = xa + pi;
            xb = xb + pi;
            z(i) = fzero(B2,[xa(i),xb(i)]);
        end
    end
    
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
