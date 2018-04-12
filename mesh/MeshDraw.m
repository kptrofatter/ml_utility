% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% MeshDraw() - draws a mesh. A shoddy knockoff of PuppetDraw(), lots to do...
%
% USAGE:
%   [gh, ah] = MeshDraw(ah, mesh, name=[], mask='nvefb', alpha=0.2)
%
% INPUT:
%   [1,1] axes    | ah        | axes handle
%   [1,1] struct  | mesh      | mesh structure
%   [1,?] char    | name      | mesh vertex color property ([]=uniform color)
%   [1,?] char    | mask      | draw v=verts, e=edges, f=faces
%   [1,1] double  | alpha     | mesh face alpha
%
% OUTPUT:
%   [1,1] struct  | gh        | puppet graphics handle structure
%   [1,?] scatter | .scatter  | puppet mesh vertex scatters
%   [1,?] patch   | .patch    | puppet mesh patches
%   [1,1] axes    | ah        | axes handle

function [gh, ah] = MeshDraw(ah, mesh, name, mask, alpha)
    
    % status
    fprintf('Drawing mesh... ');
    
    % default axes
    if isempty(ah)
        fh = figure();
        ah = axes('Parent', fh);
        format = true();
    else
        format = false();
    end
    
    % default property name
    if nargin() < 3
        name = [];
    end
    
    % default property name
    if nargin() < 4
        mask = 'vef';
    end
    
    % default alpha
    if nargin() < 5
        alpha = 0.2;
    end
    
    % initate graphics handles
    gh = struct('scatter', [], 'patch', []);
    
    % allocate gobjects
    if any(mask == 'v')
        gh.scatter = gobjects(1);
    end
    if any(mask == 'f')
        gh.patch = gobjects(1);
    end
    
    % draw start
    hold(ah, 'on');
    
    % get faces and vertices
    f = mesh.faces;
    v = mesh.verts;
    
    % draw vertices
    if any(mask == 'v')
        gh.scatter = scatter3(v(1, :), v(2, :), v(3, :), '.b');
    end
    
    % draw faces
    if any(mask == 'f')
        
        % collect face vertices
        X = [v(1, f(1, :)); v(1, f(2, :)); v(1, f(3, :))];
        Y = [v(2, f(1, :)); v(2, f(2, :)); v(2, f(3, :))];
        Z = [v(3, f(1, :)); v(3, f(2, :)); v(3, f(3, :))];
        
        % set face vertex color
        if isempty(name)
            
            % uniform color
            C = ones(1, size(f, 2));
            
        else
            
            % property-based color
            data = mesh.(name);
            C = double(data(mesh.faces));
            
        end
        
        % test for edges
        if any(mask == 'e')
            
            % draw patches with black edge (good for sparser meshes)
            gh.patch = patch(X, Y, Z, C, ...
                'EdgeAlpha', alpha, ...
                'FaceAlpha', alpha, ...
                'Parent', ah);
            
        else
            
            % draw patches with colored edge (good for denser meshes)
            gh.patch = patch(X, Y, Z, C, ...
                'EdgeColor', 'interp', ...
                'EdgeAlpha', alpha, ...
                'FaceAlpha', alpha, ...
                'Parent', ah);
            
        end
        
    end
    
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
    
    % status
    fprintf('[Done]\n');
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
