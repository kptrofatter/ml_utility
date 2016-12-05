% %============================================================================%
% % Utility                                                                    %
% %                                                                            %
% % /utility/math/Bessel.m                                                     %
% %============================================================================%
% Bessel() computes Bessel functions.
%
% USAGE:
%   [y] = Bessel(kind,m,x)
% INPUT:
%   [1,?] char    | kind | Function kind {'J','Y','H1','H2','j','y','h1','h2'}
%   [1,1] double  | m    | Function order
%   [s]   cdouble | x    | Function argument
% OUTPUT:
%   [s]   cdouble | y    | Function mapping

function [y] = Bessel(kind,m,x)
    % Bessel function kind
    switch kind
    % Cylindrical functions
    case 'J' , B = @(nu,r) besselj(nu,r);
    case 'Y' , B = @(nu,r) bessely(nu,r);
    case 'H1', B = @(nu,r) besselh(nu,1,r);
    case 'H2', B = @(nu,r) besselh(nu,2,r);
    % Spherical functions
    case 'j' , B = @(nu,r) sqrt(pi./(2.0*r)) .* besselj(nu+0.5,r);
    case 'y' , B = @(nu,r) sqrt(pi./(2.0*r)) .* bessely(nu+0.5,r);
    case 'h1', B = @(nu,r) sqrt(pi./(2.0*r)) .* besselh(nu+0.5,1,r);
    case 'h2', B = @(nu,r) sqrt(pi./(2.0*r)) .* besselh(nu+0.5,2,r);
    end
    % Compute
    y = B(m,x);
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
