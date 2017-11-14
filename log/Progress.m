% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% Progress() - tracks nested loop execution, prints progress, and logs times
%
% USAGE:
%   [] = Progress(index, goal)
%
% INPUT:
%   [1,n] double | index   | nested indices, in the order they are nested
%   [1,n] double | goal    | maximum indices, in the order they are nested
%
% OUTPUT:
%   ~
%
% GLOBAL:
%   [1,1] struct | LOGGING | logging structure
%   [1,1] struct | .???    | calling function structure (named after function)
%   [1,1] double |  .itime | last execution time index
%   [1,?] double |  .times | execution times
%
% SIDE-EFFECTS:
%   modifies global LOGGING structure upon loop completion
%
% NOTES:
%   + may consume non-negligible amount of time to run, check profiler
%   + best used at nesting level that is iterated often, but not too often

function Progress(index, goal)
    
    % logging structure
    global LOGGING    % logging structure, total time stored under function name
    
    % static variables (don't track progress on nested loops!)
    persistent time0  % start time of currently tracked progress
    persistent nchars % number of chars from fprintf, used for updating spinner
    
    % spinner animation
    spinner = '|\-/';
    nspinner = numel(spinner);
    frequency = 2.0; % [Hz] should evenly divide nspinner and 60, so {1, 2, 4}
    
    % test progress
    if nargin() == 0
        
        % mark start time
        time0 = clock();
        
        % print start
        nchars = fprintf('[|]%%00.00\n');
        
    elseif ~isequal(index, goal)
        
        % get current spinner character
        time = clock();
        seconds = time(6);
        ispinner = floor(seconds * frequency);
        ispinner = 1 + mod(ispinner, nspinner);
        spin = spinner(ispinner);
        
        % get completion percentage
        progress = index(end);
        for i = 1 : numel(index) - 1
            progress = progress + (index(i) - 1) * prod(goal(i + 1 : end));
        end
        
        % compute percentage
        percent = 100 * progress / prod(goal);
        
        % print progress
        str = [Backspace(nchars), '[%c]%05.2f%%\n'];
        nchars = -nchars + fprintf(str, spin, percent);
        
    else
        
        % print goal
        dt = etime(clock(), time0);
        nchars = fprintf([Backspace(nchars), '[+][Done] %.1fs\n'], dt);
        
        % get calling function name
        stack = dbstack;
        if numel(stack) == 1
            caller = 'cli';
        else
            caller = stack(2).name;
        end
        
        % test log for function
        if ~isfield(LOGGING, caller)
            LOGGING.(caller).times = [];
        end
        
        % get timing log index
        if ~isfield(LOGGING.(caller), 'itime')
            
            % initiate time index
            LOGGING.(caller).itime = 1;
            itime = 1;
            
            % allocate times
            LOGGING.(caller).times = inf(1, 128);
            
        else
            
            % get next time index
            itime = LOGGING.(caller).itime + 1;
            LOGGING.(caller).itime = itime;
            
            % test if more times need to be allocated
            times = LOGGING.(caller).times;
            ntimes = numel(times);
            if itime > ntimes
                LOGGING.(caller).times((1 : 128) + ntimes) = inf();
            end
            
        end
        
        % log time
        LOGGING.(caller).times(itime) = dt;
        
    end
    
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
