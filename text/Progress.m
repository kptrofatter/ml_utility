function [c] = Progress(a,b,c)
    spinner='|\-/';
    if a==b
        % Finish progress
        c = fprintf([Backspace(c),'[!][Done]\n']);
    else
        % Update progress
        time=clock();
        c = -c + fprintf(...
            [Backspace(c),'[%c]%05.2f%%\n'],...
            spinner(1+mod(floor(time(6)*2),numel(spinner))),...
            100*(a-1)/b...
        );
    end
end