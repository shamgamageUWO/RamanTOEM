function M = read_collocs_data_mean(fn, cols, c)

% read_collocs_data_mean read fields from collocation netcdf
%
% Given the paths to a collocation NetCDF file, reads collocations,
% collocation data and collocation meandata respectively. The 'cols'
% cell describes what fields to return.
%
% FORMAT
%
%   M = read_collocs_data_mean(fn, cols)
%
% IN
%
%   fn          string      filename with collocations in NetCDF
%   cols        cell array  cells with what fields to read
%   c           struct      as colloc_constants('cols_cpr_mhs') or so
%
% OUT
%
%   M           NxM matrix  Matrix containing the collected info
%
% $Id: read_collocs_data_mean.m 7553 2012-04-27 19:08:16Z gerrit $

%% read data

logtext(atmlab('OUT'), 'Reading %s\n', fn);
tmp = tempname(atmlab('WORK_AREA'));
exec_system_cmd(['zcat ' fn '>' tmp]); % 3x faster than ML gunzip
%filenames = gunzip(fn, atmlab('WORK_AREA')); 
%ncid = netcdf.open(filenames{1}, 'NOWRITE');
ncid = netcdf.open(tmp, 'NOWRITE');
%delete(filenames{1});
delete(tmp);
cleanupObj = onCleanup(@()netcdf.close(ncid));
varids = nan(size(cols));
varwidth = zeros(size(cols));
hasmean = false;
% check dimensions, if any mean will need those first
% also to know pre-alloc size
alloc_length = 0;
i = 1;
while i <= length(cols)
    if isnumeric(cols{i}) % refers to no. in previous
        varids(i) = -1;
        i = i + 1;
        continue
    end
    col = cols{i};
    % If col is an alias (e.g. MHS = AMSU(16:20)), replace accordingly
    if any(strcmp(col, fieldnames(c.aliases)))
        % if columns to read specified, replace those as well
        if i~=length(cols) && isnumeric(cols{i+1})
            cols{i+1} = c.aliases.(col){2}(cols{i+1});
        elseif length(c.aliases.(col)) > 1
            % insert channels to read
            cols = [cols(1:i) c.aliases.(col){2} cols((i+1):end)];
        end
        cols{i} = c.aliases.(col){1};
        col = cols{i};
    end
    % proceed with getting information
    varid = netcdf.inqVarID(ncid, col);
    [~, ~, dimids] = netcdf.inqVar(ncid, varid);
    % check that it has <3 dimensions
    assert(length(dimids)<3, 'atmlab:read_collocs_data_mean', ...
        'Error: variable %s has %d dimensions, but shall have max 2', ...
        col, length(dimids));
    
    if length(dimids)==1
        % only Collocations/Averaged_collocations, so no width, so it's
        % a vector, width=1
        varwidth(i) = 1;
    end
    for dimid = dimids
        [dimname, dimlen] = netcdf.inqDim(ncid, dimid);
        switch dimname
            case 'Collocations'
                if ~hasmean
                    alloc_length = dimlen;
                end
            case 'Averaged_collocations'
                hasmean = true;
                alloc_length = dimlen;
            otherwise
                % not Collocations/Averaged_collocations, so additional
                % dimension, so width=dimlen, unless user has specified
                % the additional dimension
                % check if additional dimension specified:
                if i~=length(cols) && isnumeric(cols{i+1})
                    varwidth(i) = length(cols{i+1});
                else
                    varwidth(i) = dimlen;
                end
        end
    end % for each dim
    varids(i) = varid;
    i = i + 1;
end % for each col
M = zeros(alloc_length, sum(varwidth));
if alloc_length==0 % nothing
    return
end
if hasmean
    var_mean = netcdf.inqVarID(ncid, 'FIRST');
    rows = netcdf.getVar(ncid, var_mean);
else
    rows = true(alloc_length, 1);
end

n = 1; % keep track of dims
for i = 1:length(cols)
    if varids(i)==-1 % not a var, see comment about skipping above
        continue;
    end
    var = netcdf.getVar(ncid, varids(i));
    % determine what rows to read
    if size(var, 1) > alloc_length
        rows_here = rows;
    elseif size(var, 1) == alloc_length
        rows_here = true(alloc_length, 1);
    else
        error('atmlab:read_collocs_data_mean', ...
            'Incorrect number of rows in data');
    end
    % determine what columns to read
    if i~=length(cols) && varids(i+1)==-1 % next var is column
        cols_here = cols{i+1};
    else % read all columns
        cols_here = 1:varwidth(i);
    end
    M(:, n:(n+varwidth(i)-1)) = ...
        reshape(var(rows_here, cols_here), [alloc_length varwidth(i)]);
    n = n + varwidth(i);
end
