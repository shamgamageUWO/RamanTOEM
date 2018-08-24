function datafile = find_datafile_by_date(datevec, satname, sensor, ...
    tol)

% find_datafile_by_date Return full path of datafile by date/time
%
% Returns the full path of the datafile corresponding to the input
% arguments. There are two modes:
%
%   - If datasets_config('DATASET_filename') is defined, the path is
%     calculated directly from datasets_config settings and the arguments
%     passed on. The file may or may not actually exist, so in this case,
%     you can use it to calculate the path when planning to create it.
%
%   - If this is not defined, then datasets_config('DATASET_regexp') has to
%     be defined. It will search the filesystem for a file matching the
%     regular expression and the indicated datevec/satname/dataset. In this
%     case, one can apply a tolerance in seconds.
%
% Valid datasets are returned by <a href="matlab:help list_datasets">list_datasets</a>.
%
% FORMAT
%
%   datafile = find_datafile_by_date(datevec, sat, dataset[, tol])
%
% IN
%
%   datevec     vector  Date/time to find datafile for
%   satname     string/ Name of satellite. For datasets belonging to one
%               cellstr satellite, a simple string. For datasets belonging
%                       to two satellites (such as collocations), a cell
%                       array of two strings.
%   dataset     string  Name of dataset
%   tol         number  Optional: tolerance in seconds. Sometimes, MSPPS
%                       doesn't start the same minute as AMSU :(.
%
% OUT
%
%   datafile    string     Path to the looked-for datafile.
%
%
% $Id$

errid = 'atmlab:find_datafile_by_date';

% implementation:
% 1. find the directory containing the files from basedir/subdir
% 2. if possible, calculate the filename directly
% 3. otherwise, list all files and match with regexp+tolerance

fulldir = find_datadir_by_date(datevec, satname, sensor);

if ~isnan(datasets_config([sensor '_filename'])) % calculate directly
    fn = datasets_config([sensor '_filename']);
    fn = strrep_variables(fn, satname, datevec);
    datafile = fullfile(fulldir, fn);
else % will search through all granules with find_granules_by_date
    [granules, paths] = find_granules_by_date(datevec(1), datevec(2), datevec(3), satname, sensor, false);
    if exist('tol', 'var') % use tolerance
        g = mat2cell(granules, size(granules, 1), [1 1 1 1 1]);
        grans_unisecs = date2unixsecs(g{:});
        dv_unisecs = date2unixsecs(datevec(1), datevec(2), datevec(3), datevec(4), datevec(5));
        found = abs(grans_unisecs - dv_unisecs) < tol;
    else
        found = granules(:, 4)==datevec(4) & granules(:, 5)==datevec(5);
    end
    
    nfound = sum(found);
    if nfound==0
        error(errid, 'No datafile found for %s %s [%s]', satname, sensor, num2str(datevec));
    elseif nfound > 1
        error(errid, 'Multiple datefiles found for %s %s', satname, sensor);
    else
        datafile = paths{found};
    end
    
end

end