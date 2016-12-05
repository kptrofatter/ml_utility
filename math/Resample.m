%==============================================================================%
% Utility                                                                      %
%                                                                              %
% math\Resample.m                                                              %
%==============================================================================%

function [b] = Resample(a,ratio,method)
    % Default
    if ~exist('method','var')
        method='linear';
    end
    
    % Source size
    xn=size(a);
    yn=size(a);
    zn=size(a);
    
    % Source mesh
    [X0,Y0,Z0]=ndgrid(1:xn,1:yn,1:zn);
    
    % Target mesh
    [X1,Y1,Z1]=ndgrid(...
        linspace(1,xn,xn*ratio),...
        linspace(1,yn,yn*ratio),...
        linspace(1,zn,zn*ratio) ...
    );
    
    % Interpolate
    b=interpn(X0,Y0,Z0,a,X1,Y1,Z1,method);
    
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
