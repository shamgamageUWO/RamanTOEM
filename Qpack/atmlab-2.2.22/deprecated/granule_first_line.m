function first = granule_first_line(sat, sensor, d, reload)

% granule_first_line Returns first scanline not present in previous granule
%
% For a certain granule, return the number of the first scanline that
% is not in the previous scanline. This m-file uses a previously created
% database (a hashtable). This hash-table is cached between subsequent
% calls of the function.
%
% There should exist an entry for each satellite/sensor granule. If it's
% not found, an error is raised, and there is probably a bug somewhere. If
% the satellite/sensor granule exists, but there is no (unique) previous
% granule, line -2 is returned.
%
% FORMAT
%
%   first = granule_first_line(sat, sensor, datevec[, reload])
%
% IN
%
%   sat         string      Satellite
%   sensor      string      Sensor
%   datevec     vector      Starting date/time for granule
%   reload      logical     (optional) Reload scanline data (i.e. not
%                           cached). Defaults to false.
%
% OUT
%
%   first       number      First scanline not in previous granule.
%                           Special values: -1 (no data found), -2 (no
%                           previous granule found)
%
% $Id: granule_first_line.m 7553 2012-04-27 19:08:16Z gerrit $

persistent S;

warning(['atmlab:' mfilename], 'old style function, being phased out, use OO way');

if isempty(S)
    S = struct;
end

if ~exist('reload', 'var')
    reload = false;
end

if isfield(S, sat) && isfield(S.(sat), sensor) && ~reload
    ht = S.(sat).(sensor);
else
    scanfile = datasets_config('firstline_data');
    scanfile = strrep(scanfile, '$SAT', sat);
    scanfile = strrep(scanfile, '$SENSOR', sensor);
    
    t = load(scanfile);
    ht = t.ht;
    S.(sat).(sensor) = ht;
end

if isscalar(d)
    unisecs = uint32(d);
else
    dv = num2cell(d);
    unisecs = uint32(date2unixsecs(dv{:}));
end

first = ht.get(unisecs);
if isempty(first)
    error('atmlab:granule_first_line', 'no data found for %s/%s @ %d', ...
        sat, sensor, unisecs);
end
