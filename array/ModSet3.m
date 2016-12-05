function [a] = CyclicSet3(a,x,y,z,b)
    x=mod(x-1,size(a,1))+1;
    y=mod(y-1,size(a,2))+1;
    z=mod(z-1,size(a,3))+1;
    a(x,y,z)=b;
end

