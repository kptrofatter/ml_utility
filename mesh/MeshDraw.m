% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% () - TODO, LOTS!
%
% USAGE:
%   [] = ()
%
% INPUT:
%   [,] | |
%
% OUTPUT:
%   [,] | |

function [] = MeshDraw(mesh, color)
    
    % draw
    hold on;
    
    % draw vertices
    %scatter3(mesh.verts(1, :), mesh.verts(2, :), mesh.verts(3, :), 'k.');
    
    % collect faces
    nfaces = size(mesh.faces, 2);
    x = zeros(3, nfaces);
    y = x;
    z = x;
    c = x;
    for i = 1 : nfaces
        face = mesh.faces(:, i);
        x(:, i) = mesh.verts(1, face).';
        y(:, i) = mesh.verts(2, face).';
        z(:, i) = mesh.verts(3, face).';
        c(:, i) = color(face).';
    end
    
    % draw faces
    patch(x, y, z, c, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
