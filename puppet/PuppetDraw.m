% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% PuppetDraw() - draws a puppet name and visible meshes, bone bases, and faces.
%
% USAGE:
%   [gh, ah] = PuppetDraw(ah, puppet, name=[], mask='nvefb', alpha=0.2)
%
% INPUT:
%   [1,1] axes    | ah        | axes handle
%   [1,1] struct  | puppet    | puppet structure (see PuppetScan())
%   [1,?] char    | name      | mesh vertex color property ([]=uniform color)
%   [1,?] char    | mask      | draw n=name, v=verts, e=edges, f=faces, b=bones
%   [1,1] double  | alpha     | mesh face alpha
%
% OUTPUT:
%   [1,1] struct  | gh        | puppet graphics handle structure
%   [1,1] text    | .text     | puppet name text
%   [1,?] scatter | .scatters | puppet mesh vertex scatters
%   [1,?] patch   | .patches  | puppet mesh patches
%   [3,?] quiver  | .quivers  | puppet bone basis quivers
%   [1,1] axes    | ah        | axes handle

function [gh, ah] = PuppetDraw(ah, puppet, name, mask, alpha)
    
    % status
    fprintf('Drawing puppet ''%s''... ', puppet.name);
    
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
        mask = 'nvefb';
    end
    
    % default alpha
    if nargin() < 5
        alpha = 0.2;
    end
    
    % initate graphics handles
    gh = struct('text', [], 'scatters', [], 'patches', [], 'quivers', []);
    
    % draw name
    if any(mask == 'n')
        
        % draw text
        r = puppet.A.v;
        gh.text = text(...
            r(1), r(2), r(3), puppet.name, 'Color', 'r', 'Parent', ah);
        
    end
    
    % allocate gobjects
    nmeshes = numel(puppet.meshes);
    if any(mask == 'v')
        gh.scatters = gobjects(1, nmeshes);
    end
    if any(mask == 'f')
        gh.patches = gobjects(1, nmeshes);
    end
    
    % draw start
    hold(ah, 'on');
    
    % draw meshes
    for i = 1 : nmeshes
        
        % get mesh
        mesh = puppet.meshes(i);
        
        % visibility test
        if mesh.visible
            
            % get faces and vertices
            f = mesh.faces;
            v = mesh.vertices;
            
            % draw vertices
            if any(mask == 'v')
                gh.scatters(i) = scatter3(v(1, :), v(2, :), v(3, :), '.b');
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
                    C = ones(3, size(f, 2));
                    
                else
                    
                    % property-based color
                    data = mesh.duke.(name);
                    C = double(data(mesh.faces));
                    
                end
                
                % test for edges
                if any(mask == 'e')
                    
                    % draw patches with black edge (good for sparser meshes)
                    gh.patches(i) = patch(X, Y, Z, C, ...
                        'EdgeAlpha', alpha, ...
                        'FaceAlpha', alpha, ...
                        'Parent', ah);
                    
                else
                    
                    % draw patches with colored edge (good for denser meshes)
                    gh.patches(i) = patch(X, Y, Z, C, ...
                        'EdgeColor', 'interp', ...
                        'EdgeAlpha', alpha, ...
                        'FaceAlpha', alpha, ...
                        'Parent', ah);
                    
                end
                
            end
        end
        
    end
    
    % draw bone bases
    if any(mask == 'b')
        
        % compute bone pose (w.r.t. world)
        A = AffineCompose(puppet.A, [puppet.bones(:).A]);
        
        % draw bone basis
        gh.quivers = BasisDraw(ah, A, 0.02, 2.0);
        
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
