function [d] = Dots(a,b)
    if size(a,2) == 1
        d = dot(repmat(a,[1,size(b,2)]),b);
    else
        d = dot(a,repmat(b,[1,size(a,2)]));
    end
end