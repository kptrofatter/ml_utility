% %============================================================================%
% %                                                                            %
% %                                                                            %
% % utility\Basis.m                                                            %
% %============================================================================%
% BASIS draws a coordinate system basis defined by an affine transformation.
%
% USAGE:
%   [h] = Basis(A_ba, scale?, width?, ah?)
%
% INPUT:
%   [m,1] struct | A_ba. | Affine transformation from space 'a' to space 'b'
%   [3,3] double |  .R   | [#] Rotation
%   [3,1] double |  .t   | [m] Translation
%   [1,1] double | scale | [#] Unit vector scale factor (Defaults to 0.1)
%   [1,1] double | width | [#] Unit vector width        (Defaults to 1.0)
%   [1,1] axes   | ah    | Axis handle                  (Defaults to gca())
%
% OUTPUT:
%   [3,1] quiver | h     | Graphics handles for XYZ<=>RGB quiver3 series

function [h]=Basis(A,scale,width,ah)
    % Null
    if isempty(A)
        h=[];
        return
    end
    
    % Default scale
    if ~exist('scale','var')||isempty(scale)
        scale=0.1;
    end
    % Default width
    if ~exist('width','var')||isempty(width)
        width=1;
    end
    % Default axis
    if ~exist('ah','var')||isempty(ah)
        ah=gca();
    end
    
    % Allocate
    o=zeros(3,numel(A));
    x=o;
    y=o;
    z=o;
    % Construct basis
    for i=1:numel(A)
        o(:,i)=A(i).t;
        x(:,i)=scale*A(i).R(:,1);
        y(:,i)=scale*A(i).R(:,2);
        z(:,i)=scale*A(i).R(:,3);
    end
    
    % Draw begin
    hold(ah,'on');
    % X-axis
    h(1)=quiver3(ah,o(1,:),o(2,:),o(3,:),x(1,:),x(2,:),x(3,:),0,...
        'Color',[1,0,0],...
        'LineWidth',width ...
    );
    % Y-axis
    h(2)=quiver3(ah,o(1,:),o(2,:),o(3,:),y(1,:),y(2,:),y(3,:),0,...
        'Color',[0,1,0],...
        'LineWidth',width ...
    );
    % Z-axis
    h(3)=quiver3(ah,o(1,:),o(2,:),o(3,:),z(1,:),z(2,:),z(3,:),0,...
        'Color',[0,0,1],...
        'LineWidth',width ...
    );
    % Draw end
    hold(ah,'off');
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
