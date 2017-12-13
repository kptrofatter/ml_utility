% %============================================================================%
% % Duke University                                                            %
% % K. P. Trofatter                                                            %
% % kpt2@duke.edu                                                              %
% %============================================================================%
% Timestamp() - generates a timestamp string accurate to seconds suitable for
% filenames, feedback, and notes.
%
% USAGE:
%   [timestamp] = Timestamp()
%
% INPUT:
%   ~
%
% OUTPUT:
%   [1,20] char | timestamp | timestamp string (format 'yyyy-mm-dd_HHhMMmSSs')

function [timestamp] = Timestamp()
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH MM SS ');
    timestamp(14) = 'h';
    timestamp(17) = 'm';
    timestamp(20) = 's';
end


%==============================================================================%
%                                                                              %
%                                                                              %
%                                                                              %
%==============================================================================%
