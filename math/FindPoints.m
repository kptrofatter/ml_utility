% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% LocatePoints() - locates point-like features in a scalar image.
%
% USAGE:
%   [points] = RfLocatePoints(img, npoints, psf?)
%   [points] = RfLocatePoints(img, guesses, psf?)
%
% INPUT:
%   [x,y,z] complex | img     | [?] image
%   [1,1]   double  | npoints | [#] number of points
%   [3,n]   double  | guesses | [m] supposed location of points
%   [a,b,c] double  | psf     | [?] point-spread function to correlate against
%
% OUTPUT:
%   [3,n]   double  | points  | [m] located points

function [points] = FindPoints(guesses, img, x, y, z, psf)
    
    % count number of point to find
    if numel(guesses) == 1
        npoints = guesses;
    else
        npoints = size(guesses, 2);
    end
    
    % find points
    points = zeros(3, npoints);
    for i = 1 : npoints
        
        % guess center
        if numel(guesses) == 1
            [~, index] = max(real(img(:)));
            
        else
            guess = guesses(:, i);
        end
        
        % determine radius
        % find centroid
        % remove point
        
    end
    
    
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
