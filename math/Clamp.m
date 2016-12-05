% %============================================================================%
% % MetaImager                                                                 %
% %                                                                            %
% % math\Clamp.m                                                               %
% %============================================================================%
% CLAMP restricts input to a range, clamping to the closest extrema if outside.
%
% USAGE:
%  [a]=CLAMP(a,min,max)
%  [a]=CLAMP(a,extrema)
%
% INPUT:
%  [m,n] double | a       | Input matrix
%  [1,1] double | min     | Minimum
%  [m,n] double | min     | Minima
%  [1,1] double | max     | Maximum
%  [m,n] double | max     | Maxima
%  [1,2] double | extrema | Extrema [minimum maximum]
%
% OUTPUT:
%  [m,n] double | a       | Clamped matrix

function [a]=Clamp(a,min,max)
    % Single input with 2 elements
    if nargin() == 2
        max=min(2);
        min=min(1);
    end
    
    % Lower clamp
    if numel(min)==1
        a(a<min)=min;
    else
        a(a<min)=min(a<min);
    end
    % Upper clamp
    if numel(max)==1
        a(a>max)=max;
    else
        a(a>max)=max(a>max);
    end
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
