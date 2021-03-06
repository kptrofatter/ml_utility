%==============================================================================%
% Utility                                                                      %
%                                                                              %
% math\Resize2.m                                                               %
%==============================================================================%

function [b] = Resize2(a,sb,method)
    % Default
    if ~exist('method','var')
        method='linear';
    end
    
    % Source size
    sa=size(a);
    
    % Target mesh
    [X1,Y1]=ndgrid(...
        linspace(1,sa(1),sb(1)),...
        linspace(1,sa(2),sb(2)) ...
    );
    
    % Interpolate
    b=interpn(a,X1,Y1,method);
    
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
