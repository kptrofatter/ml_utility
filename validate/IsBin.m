function [r] = IsBin(str)
    if ischar(str) && ~isempty(str)
        r = all( InRange(str,'0','1') );
    else
        r = false();
    end
end