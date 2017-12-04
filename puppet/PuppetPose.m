% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% PuppetPose() - sets puppet pose using animation data.
%
% USAGE:
%   [puppet] = PuppetPose(puppet)                   % set rest pose
%   [puppet] = PuppetPose(puppet, animation, frame) % set pose from data
%
% INPUT:
%   [1,1] struct | puppet    | puppet structure (see PuppetScan())
%   [1,1] struct | animation | animation structure (see AnimationScan())
%   [1,1] double | frame     | [#] frame index
%
% OUTPUT:
%   [1,1] struct | puppet    | posed puppet structure

function [puppet] = PuppetPose(puppet, animation, frame)
    
    % status
    fprintf('Posing puppet ''%s'' with ', puppet.name);
    
    % decide which pose data to use
    if nargin() == 1
        
        % rest pose data
        fprintf('rest pose... ');
        
        % puppet pose
        puppet.A = Affine();
        
        % mesh poses
        for i = 1 : numel(puppet.meshes)
            puppet.meshes(i).A = puppet.meshes(i).A_rest;
        end
        
        % bone poses
        for i = 1 : numel(puppet.bones)
            puppet.bones(i).A =  puppet.bones(i).A_rest;
        end
        
    else
        
        % animation pose data
        fprintf('animation ''%s'' frame %i... ', animation.name, frame);
        
        % puppet pose
        puppet.A = animation.A(frame);
        
        % mesh poses
        for i = 1 : numel(puppet.meshes)
            puppet.meshes(i).A = animation.meshes(i).A(frame);
        end
        
        % bone poses
        for i = 1 : numel(puppet.bones)
            puppet.bones(i).A = animation.bones(i).A(frame);
        end
        
    end
    
    % status
    fprintf('[Done]\n');
    
    % compute deformation
    puppet = PuppetDeform(puppet);
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
