function [allgrans, allpaths] = find_granules_for_period(date1, date2, sat, sensor)

% find_granules_for_period List all granules for sat/dataset for period
%
% For the period between date1 and date2, list all granules (as vectors
% indicating the starting date/time) available.
%
% Valid datasets are returned by <a href="matlab:help list_datasets">list_datasets</a>.
%
% FORMAT
%
%   [allgrans, allpaths] = find_granules_for_period(date1, date2, sat, dataset)
%
% IN
%
%   date1   datevec     starting date
%   date2   datevec     ending date
%   sat     string      satellite
%   dataset  string      sensor
%
% OUT
%
%   allgrans matrix     all granules in daterange
%   allpaths cellstr    all paths to those granules
%
% $Id: find_granules_for_period.m 7553 2012-04-27 19:08:16Z gerrit $

% FIXME: update to new-style
warning(['atmlab:' mfilename], 'old style function, being phased out, use OO way');

dates = daterange(date1, date2);
ndates = size(dates, 1);

allgrans = nan*zeros(ndates*15, 5);
allpaths = cell(size(allgrans));

n = 0;
for i = 1:ndates
    date = dates(i, :);
    [grans, paths] = find_granules_by_date(date(1), date(2), date(3), sat, sensor, false);
    ngrans = size(grans, 1);
    allgrans(n+1:n+ngrans, :) = grans;
    allpaths(n+1:n+ngrans) = paths;
    n = n + ngrans;
end

to_remove = isnan(allgrans(:, 1));
allgrans(to_remove, :) = [];
allpaths(to_remove) = [];
[allgrans, I] = sortrows(allgrans);
allpaths = allpaths(I);
