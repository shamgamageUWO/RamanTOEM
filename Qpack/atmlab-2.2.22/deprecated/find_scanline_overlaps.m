function find_scanline_overlaps(sat, sensor, startdate, enddate)

% find_scanline_overlaps Create hashtable with scanline overlaps
%
% Creates a hashtable (such as used by granule_first_line) that maps for
% each sat/sensor granule the first scanline not occuring in the previous
% scanline.
%
% The resulting hashtable is written to a file according to
% datasets_config('firstline_data'), which is also where
% granule_first_line is looking for it.
%
% FORMAT
%
%   find_scanline_overlaps(sat, sensor, startdate[, enddate])
%
% IN
%
%   sat         string      Satellite
%   sensor      string      sensor
%   startdate   datevec     start here
%   enddate     datevec     (optional) end here. Default: today
%                           or end of data, whichever comes first
%
% OUT
%
%   none, but writes a file

% Created by Gerrit Holl
%
% $Id: find_scanline_overlaps.m 7564 2012-05-02 14:24:45Z gerrit $

warning(['atmlab:' mfilename ':deprecated'], ...
    'Deprecated, use SatDataset.find_granule_first_line instead');

%colloc_config('stdout', fopen(fullfile('~/log', ['line_overlap_' sat '_' sensor '_out']), 'a'));
%colloc_config('stderr', fopen(fullfile('~/log', ['line_overlap_' sat '_' sensor '_err']), 'a'));
scanfile = datasets_config('firstline_data');
scanfile = strrep(scanfile, '$SAT', sat);
scanfile = strrep(scanfile, '$SENSOR', sensor);
% read directly, not with read_granule, now I WANT the doubles
reader = datasets_constants(['read_' sensor]);

if ~exist('enddate', 'var')
    enddate = datevec(now);
end

logtext(atmlab('OUT'), 'Locating granules\n');
allgrans = find_granules_for_period(startdate, enddate, sat, sensor);
ngrans = size(allgrans, 1);
logtext(atmlab('OUT'), 'Found %d granules\n', ngrans);

if exist(scanfile, 'file')
    tm = load(scanfile);
    ht = tm.ht;
else
    ht = java.util.Hashtable;
end

next = 0;
for i = 1:ngrans-1
    logtext(atmlab('OUT'), 'granule %d/%d: %d-%02d-%02d %02d:%02d\n', i, ngrans-1, ...
            allgrans(i, 1), allgrans(i, 2), allgrans(i, 3), allgrans(i, 4), allgrans(i, 5));
    uni = date2unixsecs(allgrans(i+1, 1), allgrans(i+1, 2), allgrans(i+1, 3), allgrans(i+1, 4), allgrans(i+1, 5));
    if ht.containsKey(uint32(uni))
        logtext(atmlab('OUT'), 'Already exists (%d:%d)\n', uint32(uni), ht.get(uint32(uni)));
        continue
    end
    try
        couldreadcur = false;
        if isequal(next, 0)
            cur = reader(find_datafile_by_date(allgrans(i, :), sat, sensor));
        else
            cur = next;
        end
        couldreadcur = true;
        couldreadnext = false;
        next = reader(find_datafile_by_date(allgrans(i+1, :), sat, sensor));
        couldreadnext = true;
    catch ME
        switch ME.identifier
            case {'atmlab:find_datafile_by_date', 'atmlab:atovs_get_l1c:zamsu2l1c', 'atmlab:invalid_data'}
                logtext(atmlab('ERR'), 'Problem: %s\n', ME.message);
            otherwise
                ME.rethrow();
        end
    end
    %uni = date2unixsecs(allgrans(i+1, 1), allgrans(i+1, 2), allgrans(i+1, 3), allgrans(i+1, 4), allgrans(i+1, 5));
    if couldreadcur && couldreadnext
        t_cur = cur.epoch + cur.time;
        t_next = next.epoch + next.time;
        %[t_cur, t_next] = unify_time_axis(cur.time, next.time);
        firstline = find(t_next > t_cur(end), 1, 'first');
        if ~isempty(firstline)
            logtext(atmlab('OUT'), 'First line: %d\n', firstline);
            ht.put(uint32(uni), firstline);
        else
            logtext(atmlab('OUT'), 'No first line, setting to -2\n');
            ht.put(uint32(uni), -2);
        end
    elseif couldreadcur
        logtext(atmlab('OUT'), 'Could not read next, setting next to -3\n');
        ht.put(uint32(uni), -3);
    else
        logtext(atmlab('OUT'), 'Could not read current. setting to -4\n');
        ht.put(uint32(uni), -4);
    end
end

save(scanfile, 'ht');

%if ~isempty(getenv('SGE_CWD_PATH')) % running inside queing system
%    exit
%end
