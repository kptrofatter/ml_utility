% %============================================================================%
% % MetaImager                                                                 %
% %                                                                            %
% % imager/draw/BasisDraw.m                                                    %
% %============================================================================%
% BasisDraw() - draws a coordinate basis defined by an affine transformation.
%
% USAGE:
%   [h] = BasisDraw(ah = gca(), A, scale = 0.1, width = 1.0)
%
% INPUT:
%   [1,1] axes   | ah    | axis handle
%   [m,1] struct | A     | affine transformation
%   [3,3] double | .M    | [#] transformation matrix
%   [3,1] double | .v    | [m] translation vector
%   [1,1] double | scale | unit vector scale factor
%   [1,1] double | width | unit vector width
%
% OUTPUT:
%   [3,1] quiver | h     | graphics handle

function [h] = BasisDraw(ah, A, scale, width)
    % null
    if ~exist('A', 'var') || isempty(A)
        h = [];
        return
    end
    % default axis
    if ~exist('ah', 'var') || isempty(ah)
        ah = gca();
    end
    % default scale
    if ~exist('scale', 'var') || isempty(scale)
        scale = 0.1;
    end
    % default width
    if ~exist('width', 'var') || isempty(width)
        width = 1.0;
    end
    
    % allocate
    o = zeros(3, numel(A));
    x = o;
    y = o;
    z = o;
    % construct basis
    for i = 1 : numel(A)
        o(:, i) = A(i).v;
        x(:, i) = scale * A(i).M(:, 1);
        y(:, i) = scale * A(i).M(:, 2);
        z(:, i) = scale * A(i).M(:, 3);
    end
    
    % draw
    hold(ah, 'on');
    % x-axis
    h(1) = quiver3(ah, o(1, :), o(2, :), o(3, :), x(1, :), x(2, :), x(3, :), 0,...
        'Color', [1.0, 0.0, 0.0],...
        'LineWidth', width);
    % y-axis
    h(2) = quiver3(ah, o(1, :), o(2, :), o(3, :), y(1, :), y(2, :), y(3, :), 0,...
        'Color',[0.0, 1.0, 0.0],...
        'LineWidth', width);
    % z-axis
    h(3) = quiver3(ah, o(1, :), o(2, :), o(3, :), z(1, :), z(2, :), z(3, :), 0,...
        'Color', [0.0, 0.0, 1.0],...
        'LineWidth', width);
    hold(ah, 'off');
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
