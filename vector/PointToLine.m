function [d] = PointToLine(x,c,n)
    c = repmat(c,[1,size(x,2)]);
    n = repmat(n,[1,size(x,2)]);
    m = repmat(dot(n,x-c)./Norms(n).^2,[3,1]);
    d = Norms( x - c - n.*m );
end