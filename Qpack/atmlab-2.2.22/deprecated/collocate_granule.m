function [overlap, data, meandata] = ...
    collocate_granule(sat1, sensor1, sat2, sensor2, date1, oneday)

% collocate_granule Collocate granules from sat/sensor pairs
%
% Given the names of the satellite and the sensors, as well as the starting
% date/time for the primary satellite/sensor-pair, this will find all
% collocations between the two. It finds the granule for the primary
% sat/sensor-pair, all the overlapping granules for the secondary
% sat/sensor-pair, and collocates with each of those granules. It then
% collects additional information and, if applicable, calculates mean
% values for each of the collocations (for example, for CloudSat/MHS, it
% return a matrix with one row for each CloudSat pixel, as well as a matrix
% with one row for each MHS pixel).
%
% A special value for 'sat2' can be 'poes', which is short for 'every POES
% satellite'.
%
% The argument 'oneday' specifies whether data should be limited to the
% starting date for sat1 (oneday=1), the day after this (oneday=2), or no
% limitation (oneday=0, default).
%
% FORMAT
%
%   [overlap, data, meandata] = ...
%       collocate_granule(sat1, sensor1, sat2, sensor2, date1, oneday)
%
% IN
%
%   sat1        string      Primary satellite (example: 'CloudSat')
%   sensor1     string      Primary sensor (example: 'cpr')
%   sat2        string      Secondary satellite (example: 'noaa18')
%   sensor2     string      Secondary sensor (example: 'mhs')
%   date1       vector      Date vector for starting time sat1/sensor1
%   oneday      number      Limit data to one day.
%                           1=start date for sat1, 2=day after
%
% OUT
%
%   overlap     structure   With fields for each satellite (normally just 
%                           one, but for 'poes' multiple), collocation
%                           information along with times, distances, etc.
%   data        structure   With fields for each satellite, data
%                           corresponding to the collocation information,
%                           IWP, brightness temperatures, etc.
%   meandata    structure   With fields for each satellite, for instruments
%                           with very different footprint sizes, statistics
%                           for the smaller within the larger: number of
%                           points, mean, standard deviation, etc.
%                           Otherwise empty.
%
% $Id$

% FIXME: update to new-style
warning(['atmlab:' mfilename], 'old style function, being phased out, use OO way');

if ~exist('oneday', 'var')
    oneday = 0;
end

%% output

fid = atmlab('OUT');
eid = atmlab('ERR');


%% get handles for reading, processing

dummy = @(varargin) (-1);
fhp = colloc_constants(['process_' sensor1 '_' sensor2]);

try
    fhpd = colloc_constants(['process_data_', sensor1 '_' sensor2]);
    fhpm = colloc_constants(['process_meandata_', sensor1 '_' sensor2]);
catch ME
    switch (ME.identifier)
        case 'MATLAB:nonExistentField'
            if any(strfind(ME.message, '_meandata_'))
                fhpm = dummy;
            else % failed already at _data_
                fhpd = dummy;
                fhpm = dummy;
            end
        otherwise
            ME.rethrow();
    end
end


%% set 'date2_all', 'overlap', and 'sat2_all_names'
% find date/times for which to search for secondary granules
% Also pass on the primary satellite, because for poes/poes, we don't want
% overlaps where sat1==sat2

% overlap check 1: primary filename, secondary filename
[date2_all, sat2_all_names] = overlap_granule(sat1, sensor1, ...
    date1, sat2, sensor2);
if size(date2_all, 1)==0
    error('atmlab:collocate_granule:noother', ...
        'No overlapping granules found for [%s] %s/%s with %s/%s', ...
        num2str(date1), sat1, sensor1, sat2, sensor2);
end

% pre-allocate overlap-structure
% TODO: rather than [], have good width already
uniq_names = unique(sat2_all_names);
overlap = cell2struct(repmat({[]}, [length(uniq_names) 1]), uniq_names);

data = overlap; % same pre-allocation
meandata = overlap; % this one as well
M_c = overlap; M_d = overlap; M_m = overlap; % and those

%% read data for sat1/sensor1
% Here, I decide to keep the doubles for now. Simple is better than
% complex. My collocation output are rows and columns, and if I already
% remove doubles /before/ collocation, the row-numbers will be incorrect or
% at least need to be corrected for. This causes more problems than it
% solves, so I will remove the doubles in the postprocessing instead.
try
    data1 = read_granule(sat1, sensor1, date1, false); % keep doubles for now
catch ME
    switch ME.identifier
        case {'MATLAB:load:couldNotReadFile', 'atmlab:invalid_data', 'MATLAB:imagesci:hdfinfo:fileOpen'}
            logtext(eid, 'Collocating failed: %s\n', ME.message);
            return
        otherwise
            ME.rethrow();
    end
end

overlap.version{1} = data1.version;
overlap.version{2} = '?';

if isempty(data1.time)
    logtext(fid, 'Primary is empty, nothing to collocate\n');
    overlap.version{2} = 'N/A';
    return
end

% keep effective range, check time overlap before actually reading the
% secondary data, because the primary might be sparse. E.g. when judging
% from the filenames the granules contain overlapping periods, but if the
% primary in reality only contains data for a certain part of this period
% (e.g. in the case of collocations), should check the primary data with
% the secondary filename in order not to read files one knows will not
% contain overlap anyway.
data1.time_orig = data1.time; % store because of subsequent unify_time_axis can lead to errors
data1.eff_range = double(data1.epoch) + [min(data1.time)-colloc_config('interval'), max(data1.time)+colloc_config('interval')];

logtext(fid, 'Found %d other granules to collocate with\n', size(date2_all, 1));


%% loop through all the granules to collocate with

for i = 1:size(date2_all, 1)
    datecell = num2cell(date2_all(i, 1:5));
    satname = sat2_all_names{i};
    
    %% TODO/FIXME: GET RID OF UGLY SPECIAL CASE HACK!
    if strcmp(sat2, 'poes') && any(strcmp(sensor2, {'amsub', 'mhs'}))
        sens = amsub_or_mhs(satname);
    else
        sens = sensor2;
    end
    %% END OF UGLY SPECIAL CASE HACK!
    %% Continue sensibly.
    
    logtext(atmlab('OUT'), 'Collocating with %s %s %04d-%02d-%02d %02d:%02d\n', ...
        satname, sens, datecell{1:5});
    
    % Overlap check 2; primary data with secondary filename
    data2_start = date2unixsecs(datecell{1:5});
    data2_end = data2_start + datasets_constants(['granule_duration_' sensor2]);
    
    if (data2_start > data1.eff_range(2)) || (data2_end < data1.eff_range(1))
        % no possible time overlap; data1 range already compensated for
        % colloc_config('interval'); no use even reading granule2
        logtext(atmlab('OUT'), 'Not reading, no overlap with primary\n');
        continue
    end

    try
        data2 = read_granule(satname, sens, date2_all(i, 1:5), false); % keep doubles for now
    catch ME
        switch ME.identifier
            case {'atmlab:find_datafile_by_date', 'atmlab:invalid_data'}
                logtext(eid, 'Error in reading datafile %4d-%02d-%02d %02d:%02d: %s. SKIPPING\n', ...
                    datecell{:}, ME.message);
                continue
            otherwise
                ME.rethrow();
        end
    end
    
    overlap.version{2} = data2.version;
    data2.time_orig = data2.time; % store, see note at data1.time_orig
    if isempty(data2.time)
        logtext(fid, 'Secondary is empty, skipping\n');
        continue
    end
    
    switch sign(data1.epoch - data2.epoch)
        case -1 % data1 epoch is earliest
            data2.time = data2.time + double(data2.epoch - data1.epoch);
            data2.epoch = data1.epoch;
        case 0 % do nothing
        case 1 % data2 epoch is earliest
            data1.time = data1.time + double(data1.epoch - data2.epoch);
            data1.epoch = data2.epoch;
        otherwise
            error('atmlab:collocate_granule', 'Reached impossible place. Bug.');
    end

    % overlap check 3: primary data, secondary data
    [iv1, iv2] = find_common_time(data1.time, data2.time, colloc_config('interval'));
    % limit to one day (if needed)
    switch oneday
        case 1
            % only consider data on the same date as the start for data1
            if data1.time(1) < 86400
                sameday = data1.time < 86400;
            else
                sameday = data1.time < 2*86400;
            end
            if ~all(sameday)
                logtext(fid, 'taking only %d/%d that are on the same day\n', ...
                    sum(sameday), length(data1.time));
            end
            iv1 = iv1 & sameday;
        case 2
            % only consider data on date after the start date for data1
            sameday = data1.time > 86400;
            iv1 = iv1 & sameday;            
            if ~all(sameday)
                logtext(fid, 'taking only %d/%d that are on the next day\n', ...
                    sum(sameday), length(data1.time));
            end
    end
    if ~(any(iv1) && any(iv2)) % no overlap
        logtext(fid, 'no time overlap, so nothing to collocate\n');
        continue
    end
    
    % perform collocations
    collocations = collocate(data1.time(iv1), data1.lat(iv1, :), data1.lon(iv1, :), ...
        data2.time(iv2), data2.lat(iv2, :), data2.lon(iv2, :), ...
        colloc_config('distance'), colloc_config('interval'));
    if any(collocations)
        % compensate for the fact that we passed only a subset to collocate
        collocations(:, 1) = collocations(:, 1) + find(iv1, 1, 'first') - 1;
        collocations(:, 3) = collocations(:, 3) + find(iv2, 1, 'first') - 1;
    else
        logtext(fid, 'No collocations\n');
        continue
    end
    % process data
    % should return a matrix with info
    logtext(fid, 'Collecting info for %d collocations\n', size(collocations, 1));
    M_c.(satname) = fhp(collocations, ...
        sat1, date1, data1, ...
        satname, date2_all(i, :), data2);

    if nargout > 1 && ~isequal(fhpd, dummy) % also data
        M_d.(satname) = fhpd(collocations, M_c.(satname), ...
            sat1, date1, data1, ...
            satname, date2_all(i, :), data2);
    end
    
    if nargout > 2 && ~isequal(fhpm, dummy) % also meandata
        M_m.(satname) = fhpm(collocations, M_c.(satname), M_d.(satname), date1, data1, date2_all(i, :), data2);
    end
    
    [overlap, data, meandata] = colloc_concatenate_colloc_data_mean(...
        overlap, M_c, data, M_d, meandata, M_m);
    
    logtext(fid, 'Info collected\n');
end
end
