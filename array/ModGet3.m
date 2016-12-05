function [b] = CyclicGet3(a,x,y,z)
    x=mod(x-1,size(a,1))+1;
    y=mod(y-1,size(a,2))+1;
    z=mod(z-1,size(a,3))+1;
    b=a(x,y,z);
end

