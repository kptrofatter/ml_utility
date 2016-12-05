function [d] = PointToPlane(x,c,n)
    n = repmat(n./norm(n),[1,size(x,2)]);
    d = dot(Sub(x,c),n);
end