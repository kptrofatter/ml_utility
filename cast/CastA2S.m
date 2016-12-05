function [varargout] = CastA2S(a)
    s = size(a);
    n = prod(s(1:end-1));
    varargout = cell(nargout(),1);
    for i = 1:s(end)
        varargout{i} = a((1:n)+(i-1)*n);
    end
end