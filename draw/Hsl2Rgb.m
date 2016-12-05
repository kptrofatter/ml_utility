% %============================================================================%
% %                                                                            %
% %                                                                            %
% %                                                                            %
% %============================================================================%

function [R,G,B] = Hsl2Rgb(H,S,L)
    
    % Allocate
    R = zeros(size(H));
    G = zeros(size(H));
    B = zeros(size(H));
    
    % Compute
    P = mod(H,2.0*pi)*(180.0/pi)/60.0;
    C = (1.0 - abs(2.0*L-1.0)) .* S;
    X = C .* (1.0 - abs(mod(P,2.0)-1.0));
    m = L - 0.5*C;
    % Assign
    Z = zeros(size(H));
    i = ( isnan(P) );        R(i) = Z(i);  G(i) = Z(i);  B(i) = Z(i);
    i = ( 0 <= P & P < 1 );  R(i) = C(i);  G(i) = X(i);  B(i) = Z(i);
    i = ( 1 <= P & P < 2 );  R(i) = X(i);  G(i) = C(i);  B(i) = Z(i);
    i = ( 2 <= P & P < 3 );  R(i) = Z(i);  G(i) = C(i);  B(i) = X(i);
    i = ( 3 <= P & P < 4 );  R(i) = Z(i);  G(i) = X(i);  B(i) = C(i);
    i = ( 4 <= P & P < 5 );  R(i) = X(i);  G(i) = Z(i);  B(i) = C(i);
    i = ( 5 <= P & P <= 6 );  R(i) = C(i);  G(i) = Z(i);  B(i) = X(i);
    % Lighten
    R = R + m;
    G = G + m;
    B = B + m;

end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
