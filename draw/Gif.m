% [1,1] handle | fh        | Figure handle to capture
% [1,?] char   | gif       | Gif file path
% [1,1] double | delay     | Frame delay [s]
% [1,1] double | loopcount | Number of times gif loops. First frame only. Inf ok

function Gif(fh,gif,delay,loopcount)
    % Frame to gif
    [imind,cm]=rgb2ind(frame2im(getframe(fh)),256);
    
    if exist('loopcount','var')
        % Opening frame
        imwrite(imind,cm,gif,'gif','DelayTime',delay,'loopcount',loopcount);
    else
        % Other frames
        imwrite(imind,cm,gif,'gif','DelayTime',delay,'writemode','append');
    end
end
