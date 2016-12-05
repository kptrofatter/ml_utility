function [r] = IsDec(str)
    if ischar(str) && ~isempty(str)
        r = all( InRange(str,'0','9') );
    else
        r = false();
    end
end