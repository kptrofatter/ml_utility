
function [space] = Space(extent, pitch, count)
    % Constrain arguments
    if isempty(extent)
        % Undefined extent
        extent = [ [0;0;0], (count-1).*pitch ];
    elseif isempty(pitch)
        % Undefined pitch
        pitch = (extent(:,2) - extent(:,1)) ./ (count-1);
    else
        % Undefined count and default
        count = floor((extent(:,2)-extent(:,1))./pitch)+1;
        extent = [ extent(:,1), extent(:,1) + (count-1).*pitch ];
    end
    
    % Build grid vectors
    x = linspace(extent(1,1),extent(1,2),count(1));
    y = linspace(extent(2,1),extent(2,2),count(2));
    z = linspace(extent(3,1),extent(3,2),count(3));
    xi= 1:count(1);
    yi= 1:count(2);
    zi= 1:count(2);
    
    % Build grid mesh
    [X,Y,Z] = ndgrid(x,y,z);
    [Xi,Yi,Zi] = ndgrid(xi,yi,zi);
    
    % Assign
    space.count = count;
    space.extent = extent;
    space.pitch = pitch;
    space.x  = x ;  space.y  = y ;  space.z  = z ;
    space.xi = xi;  space.yi = yi;  space.zi = zi;
    space.X  = X ;  space.Y  = Y ;  space.Z  = Z ;
    space.Xi = Xi;  space.Yi = Yi;  space.Zi = Zi;
end