function [overlap, data, meandata] = collocate_date(year, month, day, sat1, sensor1, sat2, sensor2)

% collocate_date Collect all collocations for given date
%
% This m-file collects all collocations for the given date between the
% indicated sensor pairs and returns the result in a structure.
%
% FORMAT
%
%   collocate_date(year, month, day, sat1, sensor1, sat2, sensor2)
%
% IN
%
%   year    (numeric)   Year for which to find collocations
%   month   (numeric)   Month for which to find collocations
%   day     (numeric)   Day for which to find collocations
%   sat1    string      Primary satellite
%   sensor1 string      Sensor on sat1 to consider
%   sat2    string      Secondary satellite: POES means many
%   sensor2 string      Sensor on secondary satellite to consider
%
% OUT
%
%   S       structure   S contains the collocations for all satellites for the
%                       date of interest. Its fields are the satellite names
%                       (only one if sat2 is not equal to poes). The values of
%                       those fields are the collections of collocate_granule
%                       for all granules of sat1/sensor1 for that date.
%   data    structure   Similar to S but with data.
%
% $Id$

% FIXME: update to new-style
warning(['atmlab:' mfilename], 'old style function, being phased out, use OO way');

fid = atmlab('OUT');

% find granules for primary dataset; if the length equals one day, do not
% take the day before as it's already sorted per day
grans = find_granules_by_date(year, month, day, sat1, sensor1, ...
    datasets_constants(['granule_duration_' sensor1])~=86400);
if isempty(grans)
    logtext(atmlab('ERR'), 'no granules found %s/%s %d-%d-%d\n', ...
        sat1, sensor1, year, month, day);
end
ngrans = size(grans, 1);
% initialise overlap structure
empty = struct();
switch lower(sat2)
    case 'poes'
        sats = datasets_constants('POES_satellite_names');
        for i = 1:length(sats)
            empty.(sats{i}) = []; % FIXME: get good width
        end
    otherwise
        empty.(sat2) = [];
end
overlap = empty;
data = empty;
meandata = empty;
nout = max(nargout, 1);
S = {empty, empty, empty};
anysuccess = false;

for i = 1:ngrans
    % keep track, because first granule is probably yesterday
    thisyear = grans(i, 1);
    thismonth = grans(i, 2);
    thisday = grans(i, 3);
    hour = grans(i, 4);
    minute = grans(i, 5);
    
    logtext(fid, 'Collocating %s %s %04d-%02d-%02d %02d:%02d with %s %s \n', ...
        sat1, sensor1, thisyear, thismonth, thisday, hour, minute, sat2, sensor2);
    
    if ~isequal([thisyear thismonth thisday], [year month day]);
        % only take collocations happening in part of granule occuring on
        % the day requested
        oneday = 2;
    else % take any collocations happening on the day requested
        oneday = 1;
    end
    
    try
        [S{1:nout}] = collocate_granule(sat1, sensor1, sat2, sensor2, ...
            [thisyear, thismonth, thisday, hour, minute], oneday);
        anysuccess = true;
    catch ME
        switch ME.identifier
            case 'atmlab:find_datafile_by_date'
                logtext(atmlab('ERR'), 'Error in searching for datafile %4d-%02d-%02d %02d:%02d %s %s: %s. SKIPPING\n', ...
                    thisyear, thismonth, thisday, hour, minute, sat1, sensor1, ME.message);
                continue
            case {'atmlab:collocate', 'atmlab:atovs_get_l1c:zamsu2l1c', 'atmlab:collocate_granule:noother'}
                logtext(atmlab('ERR'), 'Error in collocating with datafile at %4d-%02d-%02d %02d:%02d %s %s: %s. SKIPPING\n', ...
                    thisyear, thismonth, thisday, hour, minute, sat1, sensor1, ME.message);
                continue
            case {'MATLAB:hdfinfo:invalidFile'}
                logtext(atmlab('ERR'), 'Cannot read datafile %s %s %4d-%02d-%02d %02d:%02d: %s. SKIPPING\n', ...
                    sat1, sensor1, thisyear, thismonth, thisday, hour, minute, ME.message);
                continue
            otherwise
                ME.rethrow();
        end
    end
    [overlap, data, meandata] = colloc_concatenate_colloc_data_mean(...
        overlap, S{1}, data, S{2}, meandata, S{3});
end

if ~anysuccess
    error('atmlab:collocate_date:nosource', 'no source data found at all');
end
end
