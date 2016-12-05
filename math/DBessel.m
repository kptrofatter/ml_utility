% %============================================================================%
% % Utility                                                                    %
% %                                                                            %
% % /utility/math/DBessel.m                                                    %
% %============================================================================%
% DBessel() computes derivatives of Bessel functions.
%
% USAGE:
%   [y] = DBessel(n,kind,m,x)
% INPUT:
%   [1,1] double  | n    | Derivative order
%   [1,?] char    | kind | Function kind {'J','Y','H1','H2','j','y','h1','h2'}
%   [1,1] double  | m    | Function order
%   [s]   cdouble | x    | Function argument
% OUTPUT:
%   [s]   cdouble | y    | Function mapping

function [y] = DBessel(n,kind,m,x)
    % Kind
    B = @(nu,r) Bessel(kind,nu,r);
    
    % Compute derivative
    if n == 0
        % Order 0
        y = B(m,x);
    else
        % Order n
        s = 0;
        for i = 1:n-1
            s = s + (-1)^i .* B(m-n+2*i,x);
        end
        y = 0.5^n * ( B(m-n,x) + n*s + (-1)^n*B(m+n,x) );
    end
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
