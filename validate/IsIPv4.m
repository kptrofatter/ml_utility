function [r] = IsIPv4(str)
    r = false();
    
    if ischar(str)
        % Split string
        c = strsplit(str,'.');
        % Test address
        if numel(c) == 4
            % Test numbers in address
            for i = 1:4
                % Test if decimal
                if ~IsDec(c{i})
                    return
                end
                % Convert to number
                n = str2double(c{i});
                % Test range
                if ~InRange(n,0,255)
                    return
                end
            end
            % Pass
            r = true();
        end
    end
end