function [M, cols_out, limmat, filters] = collocation_read(sat1, sensor1, sat2, sensor2, ...
    start_date, end_date, cols_in, limits, filters)

% collocation_read Read collocations for indicated period
%
% This m-file reads all the collocations for the indicated period, between
% start_date and end_date, for the indicated collocations type (like
% collocations between CloudSat and MHS or between MHS and MHS).
%
% FORMAT
%
%   [M, cols] = collocation_read(...
%       sat1, sensor1, sat2, sensor2, ...
%       start_date, end_date, cols_in[, limits[, filters]])
%
% IN
%
%   sat1        string          primary satellite
%   sensor1     string          sensor on satellite; passed on to reader
%                               function which can still return data from
%                               other sensors; for example,
%                               cloudsat/cpr+noaa18/mhs can also return
%                               data from amsua or hirs.
%   sat2        string          secondary satellite
%   sensor2     string          sensor on satellite
%   start_date  3x1 array       Starting date for which to read collocations
%   end_date    3x1 array       Ending date for which to read collocations
%   cols_in     cell array      Column names. This is passed on to the
%                               reader function.
%   limits      structure       Describes acceptable ranges for the
%                               different columns requested. Data outside
%                               these ranges will not be returned. Note:
%                               [-inf, inf] will still get rid of nans.
%                               Note2: if limits=nan, no filtering is done
%                               AT ALL.
%   filters     cell array      Cell array of cell arrays. Each member of
%                               the cell array is {@filter, {COL1, ...,
%                               COLN}, {'foo', 'bar', ..., 'baz'}}.
%                               The filter is called according to
%                               filter(M(COL1, :), ..., M(COLN, :), 'foo',
%                               'bar', ..., 'baz') and shall return logical
%                               true wherever the filter is passed. See
%                               examples on website (see below).
%
% OUT
%
%   M           NxM matrix  Matrix containing collected info
%   cols        structure   Structure describing the names of the columns
%
% For examples, see <a href="http://www.sat.ltu.se/docs/datasets/collocations/collocations_atmlab.php">online help on the satpage</a>
%
% $Id$

%% prepare configuration things

no = number_sats_in_dataset(['collocation_' sensor1 '_' sensor2]);

cols = colloc_constants(['cols_' sensor1 '_' sensor2]);

if ~exist('filters', 'var')
    filters = {};
end

switch no
    case 1
        s = sat2;
    case 2
        s = {sat1, sat2};
end

%% check legacy format
if iscell(cols_in{1})
    warning('atmlab:collocation_read', ...
        ['fields should be {''a'', ''b'', ''c'', ''d'', ...}, ' ...
         'not {{''a'', ''b'', ...}, {''c'', ''d'', ...}}']);
     cols_in = [cols_in{:}];
end

%% ALWAYS get rid of doubles
% FIXME: at some point in the future, this should be redundant
if isfield(cols.overlap, 'filter_double')
    filters = [filters ...
        {{@colloc_select_good_lines, cols.overlap.filter_double{1}, {sat1, sensor1}}, ...
        {@colloc_select_good_lines, cols.overlap.filter_double{2}, {sat2, sensor2}}}];
    % but only where filter_double has a value
    filters(cellfun(@(c) isempty(c{2}), filters)) = [];
    
    % make sure the fields are asked for
    for c = horzcat(cols.overlap.filter_double{:})
        % cannot use union here, because it wants a cellstr :(
        if ~any(cellfun(@(d) isequal(c, d), cols_in))
            cols_in = [cols_in c]; %#ok<AGROW>
        end
    end
else
    logtext(atmlab('OUT'), 'Not filtering doubles, hopefully this was done when processing\n');
end
%% get name_struct

name_struct = cols_cell_to_cols_struct(cols, cols_in);
% ncols: highest value
C = struct2cell(name_struct);
ncols = max(horzcat(C{:}));

%% convert limits structure to matrix as wanted by restrain_collocations

dolimits = true;
if exist('limits', 'var') 
    if isequalwithequalnans(limits, nan)
        dolimits = false;
        limmat = zeros(0, 3);
    else
        limmat = limstruct2limmat(limits, name_struct);
    end
else
    limmat = zeros(0, 3);
end

% for the filters, convert column names to column numbers, using the
% earlier obtained name_struct
if ~isempty(filters)
    for i = 1:length(filters)
        filters{i}{2} = cellfun(@(s) name_struct.(s)', filters{i}{2}, 'UniformOutput', false);
    end
end

%% check if this can be done via hdf5 (much faster!)

years = start_date(1):end_date(1);
paths_hdf5 = cell(size(years));
for i = 1:length(years)
    year = years(i);
    try
        paths_hdf5{i} = find_datafile_by_date([year 1 1], s, ['collocation_' sensor1 '_' sensor2 '_hdf5']);
        assert(~~exist(paths_hdf5{i}, 'file'), ...
            'atmlab:collocation_read', 'HDF5-file does not exist: %s', ...
            paths_hdf5{i});
    catch ME
        switch (ME.identifier)
            case {'atmlab:find_datadir_by_date', 'atmlab:collocation_read', 'atmlab:find_granules_by_date', 'atmlab:input:undefined'}
                if iscell(s)
                    s_p = horzcat(s{:});
                else
                    s_p = s;
                end
                logtext(atmlab('OUT'), ...
                    'Note: no HDF5 @ %d %s %s %s\n', ...
                    year, s_p, sensor1, sensor2)
                continue
            otherwise
                ME.rethrow()
        end
    end
end

% if any(cellfun(@length, paths_hdf5))
%     %% do this stuff via HDF5
%     if ~all(cellfun(@length, C))
%         error('atmlab:collocation_read', ...
%             'Period PARTIALLY covered by HDF-5, this is not supported yet');
%     end
%     logtext(atmlab('OUT'), 'Found HDF5\n');
%     % Convert limits-matrix to limits-strings
%     baselimstrs = {'', ''};
%     fieldnames_both = {union(fieldnames(cols.overlap), fieldnames(cols.data)), fieldnames(cols.meandata)};
%     for i = 1:2
%         
%         limcellstr = cellfun(@(v) ...
%             ['(' v ' >= ' num2str(limits.(v)(1)) ') & (' ...
%             v ' <= ' num2str(limits.(v)(2)) ') & '], ...
%             intersect(fieldnames_both{i}, fieldnames(limits)), ...
%             'UniformOutput', false);
%         baselimstrs{i} = horzcat(limcellstr{:});
%     end
%     for i = 1:length(years)
%         year = years(i);
%         hdf5file = paths_hdf5{i};
%         % and limit dates
%         global_start = date2unixsecs(start_date(1), start_date(2), start_date(3));
%         this_year_start = date2unixsecs(year, 1, 1);
%         this_start = max(global_start, this_year_start);
%         global_end = date2unixsecs(end_date(1), end_date(2), end_date(3));
%         this_year_end = date2unixsecs(year, 12, 31, 24);
%         this_end = min(global_end, this_year_end);
%         % add datelimits to limstr
%         limstr = [baselimstrs{1} sprintf(' (B_TIME >= %d) & (B_TIME <= %d)', ...
%             this_start, this_end) ' MEANSEP ' baselimstrs{2}];
%         limstr = deblank(limstr);
%         if strcmp(limstr(end), '&')
%             limstr = deblank(limstr(1:end-2));
%         end
%         M = collocation_read_frompipe(hdf5file, cols_in, limstr);
%         cols_out = name_struct;
%         return
%     end
% end

%% pre-allocate at least zero rows

M = zeros(0, ncols);

%% loop through all the dates

dates = daterange(start_date, end_date);
for i = 1:size(dates, 1)
    date = dates(i, :);
    %% read collocations for date

    path = find_datafile_by_date(date, s, ...
        ['collocation_' sensor1 '_' sensor2]);
    
    try
        collocations_day = read_collocs_data_mean(path, cols_in, cols);

    catch ME
        switch (ME.identifier)
            case {'MATLAB:load:couldNotReadFile', 'MATLAB:nonExistentField', ...
                    'MATLAB:gunzip:invalidFilename','MATLAB:netcdf:open:noSuchFile', ...
                    'atmlab:exec_system_cmd:shell'}
                logtext(atmlab('ERR'), 'Problem for %04d-%02d-%02d: %s\n', ...
                    date(1), date(2), date(3), ME.message);
                continue
            otherwise
                ME.rethrow();
        end
    end
    if isempty(collocations_day)
        logtext(atmlab('OUT'), 'no collocations\n');
        continue
    end
    
    %% apply limitations
    if dolimits
        lim = collocation_restrain(collocations_day, limmat, filters);
        collocations_day = collocations_day(lim, :);
    end
    
    %% add to total
    L = size(M, 1);
    N = size(collocations_day, 1);
    M((L+1):(L+N), :) = collocations_day;
end

cols_out = name_struct;
