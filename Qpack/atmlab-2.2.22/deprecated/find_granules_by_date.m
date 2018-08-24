function [M, paths] = find_granules_by_date(year, month, day, sat, dataset, ...
    with_yesterday)

% find_granules_by_date Find all granule start times for date/sat/dataset
%
% This function finds all granule start times for granules with any coverage
% for the the indicated for the indicated satellite/dataset pair. This
% includes the last granule of the date before, unless this is explicitly
% prohibited. Note that the last granule of the date before may or may not
% actually contain information for the day requested. Also note that there may
% also be more than one granule on the date before containing information
% for the day requested. This is not currently taken into account.
%
% Valid datasets are shown by <a href="matlab:help list_datasets">list_datasets</a>
%
% FORMAT
%
%   [M, paths] = find_granules_by_date(year, month, day, sat, dataset, with_yesterday)
%
% OUT
%
%   M     N x m matrix     where each row corresponds to one granule and is
%                          a datevec.
%   paths cell strings     Cell array of strings, corresponding full paths
%
% IN
%
%  year             (numeric)  Year for which to find the times.
%  month            (numeric)  Month for which to find the times.
%  day              (numeric)  Day for which to find the times.
%  sat              string     Describing the satellite.
%  dataset          string     Describing the dataset.
%  with_yesterday   bool       Include last of yesterday (defaults to true)
%
% For POES satellites (NOAA-15 -- NOAA-19 and MetOp-A), AMSU, MHS, HIRS and
% AVHRR have the same granule times.
%
% $Id$

% errid = 'atmlab:find_granules_by_date';

warning(['atmlab:' mfilename], 'old style function, being phased out, use OO way');

if ~exist('with_yesterday', 'var')
    with_yesterday = true;
end

datadir = find_datadir_by_date([year month day], sat, dataset);
yearstr = num2str(year, '%04d'); % for comparing easily with 2digit years

matchy = datasets_config([dataset '_regexp']);
if isnan(matchy)
    matchy = datasets_config([dataset '_filename']); % exact match only
end
matchy = strrep_variables(matchy, sat, [year month day]);
files = dir(datadir);
nfiles = length(files);
M = zeros(nfiles, 5);
for i = 1:nfiles
    fname = files(i).name;
    nam = regexp(fname, matchy, 'names');
    if ~isempty(nam)
        % if present, year/month/day should be the same
        if (isfield(nam, 'year02') && ~isempty(nam.year02) && ~strcmp(nam.year02, yearstr(3:4))) || ...
            (isfield(nam, 'year04') && ~isempty(nam.year04) && str2double(nam.year04)~=year) || ...
            (isfield(nam, 'year') && ~isempty(nam.year) && str2double(nam.year)~=year) || ...
            (isfield(nam, 'month') && ~isempty(nam.month) && str2double(nam.month)~=month) || ...
            (isfield(nam, 'day') && ~isempty(nam.day) && str2double(nam.day)~=day) || ...
            (isfield(nam, 'doy') && ~isempty(nam.doy) && str2double(nam.doy)~=dayofyear(year, month, day));
           continue;
        end
            
        M(i, 1:3) = [year month day];
        if isfield(nam, 'hour')
            M(i, 4) = str2double(nam.hour);
        end
        if isfield(nam, 'minute')
            M(i, 5) = str2double(nam.minute);
        end
    end
end
% all paths
paths = cellfun(@(f) fullfile(datadir, f), {files.name}, 'UniformOutput', false);
% remove lines with zeroes (those are not granules)
nogran = M(:, 1)==0;
M(nogran, :) = [];
paths(nogran) = [];
% sort
[M, I] = sortrows(M);
paths = paths(I);
% add yesterday
if with_yesterday
    yesterday = datevec(datenum([year month day])-1);
    [M_yesterday, paths_yesterday] = find_granules_by_date(...
        yesterday(1), yesterday(2), yesterday(3), sat, dataset, false);
    if ~isempty(M_yesterday) % maybe today is genesis/big bang/epoch/birth/1970-01-01
        M = [M_yesterday(end, :); M];
        paths = [paths_yesterday(end) paths];
    end
end
