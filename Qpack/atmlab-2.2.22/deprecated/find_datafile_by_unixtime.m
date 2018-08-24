function datafile = find_datafile_by_unixtime(unixtime, varargin)

% find_datafile_by_unixtime Return full path of datafile by unixtime
%
% Like find_datafile_by_date, but takes a unix timestamp rather than five
% arguments specifying year, month, day, hour, and minute.

% $Id: find_datafile_by_unixtime.m 7553 2012-04-27 19:08:16Z gerrit $

[year month day hour minute second] = unixsecs2date(unixtime);
if (60-second) < 0.1
    logtext(atmlab('OUT'), 'WARNING: second=%.16f. Correcting to next minute!\n', second);
    minute = minute+1;
end
datafile = find_datafile_by_date([year, month, day, hour, minute], varargin{:});
