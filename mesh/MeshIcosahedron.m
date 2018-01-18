% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% MeshIcosahedron() - returns an icosahedron with vertices at unit distance from
% the origin.
%
% USAGE:
%   [mesh] = MeshIcosahedron()
%
% INPUT:
%   ~
%
% OUTPUT:
%   [1,1]  struct | mesh   | icosahedron mesh structure
%   [3,12] double | .verts | mesh vertices
%   [3,20] double | .faces | mesh face vertex indices

function [mesh] = MeshIcosahedron()
    
    % golden ratio
    phi = (1.0 + sqrt(5)) / 2.0;
    
    % vertices
    mesh.verts = [ ...
        +phi, +phi, +1.0,  0.0,  0.0, +1.0, -1.0,  0.0,  0.0, -1.0, -phi, -phi; ...
         0.0,  0.0, +phi, +1.0, -1.0, -phi, -phi, -1.0, +1.0, +phi,  0.0,  0.0; ...
        +1.0, -1.0,  0.0, +phi, +phi,  0.0,  0.0, -phi, -phi,  0.0, +1.0, -1.0];
    mesh.verts = mesh.verts / norm(mesh.verts(:, 1));
    
    % faces
    mesh.faces = [ ...
        1, 1, 1, 1, 1, 2, 9,  3, 10,  4, 11,  5, 7, 6, 8, 12, 12, 12, 12, 12; ...
        2, 3, 4, 5, 6, 8, 3,  9,  4, 10,  5, 11, 6, 7, 2, 11, 10,  9,  8,  7; ...
        3, 4, 5, 6, 2, 9, 2, 10,  3, 11,  4,  7, 5, 8, 6, 10,  9,  8,  7, 11];
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
