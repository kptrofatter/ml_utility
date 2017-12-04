% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% PuppetCoverage() - computes a puppet coverage map from reconstructed image
% intensity data.
%
% USAGE:
%   [] = PuppetCoverage(puppet, coverage, image)
%
% INPUT:
%   [1,1]   struct  | puppet   | puppet structure (see PuppetScan())
%   [1,c]   logical | coverage | given coverage map ([] initiates a new map)
%   [x,y,z] complex | image    | reconstructed image
%   [1,1]   struct  | space    | space structure (See Space())
%
% OUTPUT:
%   [1,c]   logical | coverage | updated coverage map
%   [1,1]   double  | ratio    | coverage ratio

function [coverage, ratio] = PuppetCoverage(puppet, coverage, image, space)
    
    % get geometry
    verts = PuppetGet(puppet, 'vertices');
    faces = PuppetGet(puppet, 'faces');
    
    % count
    nverts = size(verts, 2);
    nfaces = size(faces, 2);
    
    % initiate coverage map
    if isempty(coverage)
        coverage = false(1, nverts);
    end
    
    % update coverage map
    for i = 1 : nverts
        %   sample image data
        %   determine if sample is above a threshold
        %   modify coverage map
    end
    
    % compute coverage percentage
    for i = 1 : nfaces
        % for all faces
        %   compute area
        %   accumulate total area
        %   if all vertices are covered
        %     add to covered area
    end
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
