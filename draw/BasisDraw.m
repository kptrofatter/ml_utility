% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% BasisDraw() - draws a coordinate basis defined by an affine transformation.
%
% USAGE:
%   [quivers, ah] = BasisDraw(ah, A, scale=1.0, width=1.0)
%
% INPUT:
%   [1,1] axes   | ah      | axes handle
%   [1,n] struct | A       | affine transformation
%   [3,3] double | .M      | [#] transformation matrix
%   [3,1] double | .v      | [m] translation vector
%   [1,1] double | scale   | unit vector scale factor
%   [1,1] double | width   | unit vector line width
%
% OUTPUT:
%   [1,3] quiver | quivers | quiver graphic handles
%   [1,1] axes   | ah      | axes handle

function [quivers, ah] = BasisDraw(ah, A, scale, width)
    
    % default axis
    if ~exist('ah', 'var') || isempty(ah)
        fh = figure();
        ah = axes('Parent', fh);
        format = true();
    else
        format = false();
    end
    
    % return if no bases given
    if ~exist('A', 'var') || isempty(A)
        quivers = [];
        return
    end
    
    % default scale
    if ~exist('scale', 'var') || isempty(scale)
        scale = 1.0;
    end
    
    % default width
    if ~exist('width', 'var') || isempty(width)
        width = 1.0;
    end
    
    % allocate bases points
    nxforms = numel(A);
    o = zeros(3, nxforms);
    x = o;
    y = o;
    z = o;
    
    % construct bases
    for i = 1 : nxforms
        o(:, i) = A(i).v;
        x(:, i) = scale * A(i).M(:, 1);
        y(:, i) = scale * A(i).M(:, 2);
        z(:, i) = scale * A(i).M(:, 3);
    end
    
    % draw begin
    hold(ah, 'on');
    
    % x axis
    quivers(1) = ...
        quiver3(ah, o(1, :), o(2, :), o(3, :), x(1, :), x(2, :), x(3, :), 0, ...
        'Color', 'r', ...
        'LineWidth', width);
    
    % y axis
    quivers(2) = ...
        quiver3(ah, o(1, :), o(2, :), o(3, :), y(1, :), y(2, :), y(3, :), 0, ...
        'Color', 'g', ...
        'LineWidth', width);
    
    % z axis
    quivers(3) = ...
        quiver3(ah, o(1, :), o(2, :), o(3, :), z(1, :), z(2, :), z(3, :), 0, ...
        'Color', 'b', ...
        'LineWidth', width);
    
    % draw end
    hold(ah, 'off');
    
    % format axis
    if format
        axis(ah, 'equal');
        axis(ah, 'tight');
        grid(ah, 'on');
        view(ah, [-45.0, 20.0]);
        xlabel(ah, 'x[m]');
        ylabel(ah, 'y[m]');
        zlabel(ah, 'z[m]');
    end
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
