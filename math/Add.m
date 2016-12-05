function [s] = Add(a,b)
    an = size(a);
    bn = size(b);
    if isequal(an,bn)
        % Array + array
        s = a + b;
    elseif an(2) == 1
        if an(1) == 1
            % Scalar + array
            s = a + b;
        else
            % Vector + array
            s = repmat(a,[1,size(b,2)]) + b;
        end
    elseif bn(2) == 1
        if bn(1) == 1
            % Array + scalar
            s = a + b;
        else
            % Array + vector
            s = a + repmat(b,[1,size(a,2)]);
        end
    end
end