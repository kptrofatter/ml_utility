% %============================================================================%
% %                                                                            %
% %                                                                            %
% %                                                                            %
% %============================================================================%
% PrintEtime() prints an elapsed time. Uses clock() and etime() rather than
% tic() and toc() because the later cannot reliably time heterogeneous computing
% situations (ie CPU+GPU). Note that these functions rely on the system clock.
%
% USAGE:
%   [n] = PrintEtime(file,time,unit?,space?)
% INPUT:
%   [1,1] double | file   | File identifier, [] for stdout
%   [1,6] double | time   | Time datum returned from previous call to clock()
%   [1,?] char   | unit   | Time unit {'us','ms','s','min','hr','dy','wk'}
% OUTPUT:
%   [1,1] double | n      | Number of characters printed
% TODO:
%   + Total output width input argument, so times can be aligned.

function [n] = PrintEtime(file,time,unit)
    % Build string
    label = {'us'    , 'ms' , 's', 'min', 'hr'  , 'dy'   , 'wk'    };
    spu   = [0.000001, 0.001, 1.0, 60.0 , 3600.0, 86400.0, 604800.0];
    
    % Etime
    dt = etime(clock(),time);
    
    % Identitfy unit
    if nargin() <= 2
        % Set automatically
        i = find(spu<dt,1,'last');
        % Minimal unit
        if isempty(i) || i<3
            i = 3;
        end
    else
        % Set manually
        i = find( cellfun( @(s)strcmp(unit,s), label ) );
    end
    
    % Print
    if isempty(file)
        n = fprintf('%5.3f [%s]',dt/spu(i),label{i});
    else
        n = fprintf(file,'%5.3f [%s]',dt/spu(i),label{i});
    end
end

%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
