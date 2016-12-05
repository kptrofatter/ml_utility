function [v] = Linspace2(x1,x2,n)
    v = linspace(x1,x2,n+1) / 2.0;
    dx = (v(end) - v(1)) / n;
    v = v(1:end-1) + dx/2.0;
end