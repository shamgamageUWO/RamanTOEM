function [granules, names] = overlap_granule(sat1, sensor1, date1, sat2, sensor2)

% overlap_granule Find overlapping granules
%
% For granule sat1/sensor1 at date2, find all granules for
% sat2/sensor2 that have a time overlap, +/- the maximum collocation time.
% Also returns the names of the satellites.
%
% Assumes granules contain data for at most one day.
%
% If sat2==poes, returns for all the poes satellites (except sat2==sat1).
%
% FORMAT
%
%   [granules, names] = ...
%       overlap_granule(sat1, sensor1, date1, sat2, sensor2)
%
% IN
%
%   sat1    string  primary satellit
%   sensor1 string  sensor on sat1 to consider
%   date1   vector  starting date/time for sat1
%   sat2    string  secondary satellite (special case 'poes')
%   sensor2 string  sensor on sat2 to consider
%
% OUT
%
%   granules Nx5 mat    [year month day hour minute] for each granule.
%   names    string     for each granule, name of satellite
%
% $Id: overlap_granule.m 7553 2012-04-27 19:08:16Z gerrit $

warning(['atmlab:' mfilename], 'old style function, being phased out, use OO way');

%% special case sat1==poes: do all POES sats

if strcmp(sat2, 'poes')
    allsatnames = datasets_constants('POES_satellite_names');
    allsatnos = datasets_constants('POES_satellite_numbers');
    nsats = length(allsatnames);
    granules = zeros(3*nsats, 5); % pre-allocate
    
    names = cell(3*nsats, 1);
    n = 0;
    for i = 1:nsats
        satname = allsatnames{i};
        if strcmp(sat1, satname) % don't collocate with myself
            continue
        end
        [granules_i, names_i] = overlap_granule(sat1, sensor1, date1, ...
            satname, amsub_or_mhs(satname));
        granules(n+1:n+size(granules_i, 1), 1:5) = granules_i;
        names(n+1:n+size(granules_i, 1)) = names_i;
        n = n + size(granules_i, 1);
    end
    % correct for over-preallocation
    granules(n+1:end, :) = [];
    names(n+1:end) = [];
    return
end

%% get duration of a granule of sensor1

duration = datasets_constants(['granule_duration_' sensor1]);

%% find starting time in unixsecs

granule_start = date2unixsecs(date1(1), date1(2), date1(3), date1(4), date1(5));
granule_end = granule_start + duration;

%% find all granules yesterday/today/tomorrow

today_num = datenum(date1(1), date1(2), date1(3));
yesterday = datevec(today_num - 1);
tomorrow = datevec(today_num + 1);

threedays = [...
    find_granules_by_date(yesterday(1), yesterday(2), yesterday(3), sat2, sensor2, false); ...
    find_granules_by_date(date1(1), date1(2), date1(3), sat2, sensor2, false); ...
    find_granules_by_date(tomorrow(1), tomorrow(2), tomorrow(3), sat2, sensor2, false)];
threedays = sortrows(threedays);
granules_unixsecs = date2unixsecs(...
    threedays(:, 1), threedays(:, 2), threedays(:, 3), threedays(:, 4), threedays(:, 5));

% last granule starting after the reference granule

b = find(granule_start - colloc_config('interval') > granules_unixsecs, 1, 'last');

% first granule ending before the reference granule

e = find(granule_end + colloc_config('interval') < granules_unixsecs, 1, 'first');

granules = threedays(b:e, :);
names = repmat({sat2}, [size(granules, 1) 1]);
