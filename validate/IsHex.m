function [r] = IsHex(str)
    if ischar(str) && ~isempty(str)
        r = all( InRange(str,'0','9') |  InRange(str,'A','F') );
    else
        r = false();
    end
end