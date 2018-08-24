% Functions related ATOVS data reading and processing.
%
% These functions are separated from the other sensor functions in
% the sensors directory, because the atovs data structure is
% complicated, which makes the functions less general than other
% functions in sensors.
%
% ATOVS Data is available as level 1B files from CLASS. It has to
% be converted to level 1C with an external program, e.g., AAPP.
%
% To use the routines here, you will need that program. You should
% also have the file "zamsu2l1c.sh" that is included in this
% directory in your shell search path. (It is used to execute AAPP.)
% 
% 2007-12-11 Stefan Buehler
