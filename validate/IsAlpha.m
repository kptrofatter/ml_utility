function [r] = IsAlpha(str)
    if ischar(str) && ~isempty(str)
        r = all( InRange(str,'a','z') | InRange(str,'A','Z') );
    else
        r = false();
    end
end