function [M, c] = collocation_read_dual(...
    sat1, sensor1, sat2, sensor2, ...
    startdate, enddate, varargin)


% collocation_read_dual Read collocations from two linked sources
%
% Read collocation from two sources, where the first dataset links to the
% second dataset. For example, the collocated dataset
% collocation_cpr_mhs/avhrr consists of collocations where the primary is
% collocation_cpr_mhs and the secondary is avhrr. Thus, the collocated
% dataset contains row numbers referring to the (averaged)
% CPR/MHS-collocations. This function reads the 'primary' collocations',
% gets the row-numbers, and then reads the associated information from the
% secondary, linked-to collocated dataset. Hence, whereas <a href="matlab:help collocation_read">collocation_read</a>
% needs one cols, limits and filter argument, this function needs two of
% each: one applying to the primary, one applying to the secondary.
%
% At the time of writing (13 October 2010) the only valid primary
% collocated dataset is collocation_collocation_cpr_mhs_avhrr, so dataset1
% MUST be 'collocation_cpr_mhs' and dataset2 MUST be 'avhrr', or it won't
% work. However, this may change in the future. As the collocations are
% with the averaged dataset (one-per-mhs rather than one-per-cpr), one also
% MUST request at least one mean-datafield.
%
% FORMAT
%
% [M, c] = collocation_read_dual(...
%   sat1, dataset1, sat2, dataset2, ...
%   startdate, enddate[, ...
%   cols1[, cols2[, limits1[, limits2[, ...
%   filters1[, filters2]]]]]])
%
% IN
%
%       sat1        string      primary satellite
%       dataset1    string      primary dataset, such as
%                               'collocation_cpr_mhs'
%       sat2        string      secondary satellite
%       dataset2    string      secondary dataset, such as 'avhrr'
%       startdate   3x1 array   datevec for first date
%       enddate     3x1 array   datevec for last date (inclusive)
%       cols1       cell array  Column names from sat1/dataset1
%       cols2       cell array  Column names for sat2/dataset2; must
%                               include a mean-datafield.
%       limits1     structure   Limits to values for sat1/dataset1
%       limits2     structure   Limits to values for sat2/dataset2
%       filter1     cell array  Filters as for <a href="matlab:help collocation_read">collocation_read</a>
%       filter2     cell array  Filters as for <a href="matlab:help collocation_read">collocation_read</a>
%
% OUT
%
%       M           Nxp matrix  Matrix containing N collocations with p
%                               columns
%       c           structure   c1: column names for sat1/dataset1
%                               c2: column names for sat2/dataset2
%
% EXAMPLE
%
% >> [M, c] = collocation_read_dual(...
%               'noaa18', 'collocation_cpr_mhs', 'noaa18', 'avhrr', ...
%               [2006 7 1], [2006 7 5], ...
%               {'AVHRR_LAT', 'AVHRR_LONG', 'AVHRR', 3:5}, ...
%               {'B_LAT', 'B_LONG', 'MEAN'});
%
% See also <a href="matlab:help collocation_read">collocation_read</a>.
%
% $Id: collocation_read_dual.m 7553 2012-04-27 19:08:16Z gerrit $

cols1 = colloc_constants(['cols_' sensor1 '_' sensor2]);
cols2 = colloc_constants(['cols_' cols1.links.sensor1 '_' cols1.links.sensor2]);

[cols_in1, cols_in2, limits1, limits2, filter1, filter2] = ...
    optargs(varargin, ...
    {{cols1.links.start, cols1.links.lineno}, {}, ...
    struct, struct, {}, {}});

% make sure cols1.links.start and cols1.links.lineno are asked for
for f = {cols1.links.start, cols1.links.lineno}
    if ~any(strcmp(f{1}, cols_in1))
        cols_in1 = [cols_in1 f{1}]; %#ok<AGROW>
    end
end

% verify at least some mean-data-fields in M2 are asked for
if isempty(intersect(...
        fieldnames(cols2.meandata), ...
        cols_in2(cellfun(@isstr, cols_in2))))
    error('atmlab:collocation_read_dual', ...
        'When reading dual collocations, you MUST request meandata for the secondary!');
end

[M1, c1] = collocation_read(sat1, sensor1, sat2, sensor2, ...
    startdate, enddate, cols_in1, limits1, filter1);

% convert limits-structure to limits-matrix for M2
name_struct = cols_cell_to_cols_struct(cols2, cols_in2);
limmat = limstruct2limmat(limits2, name_struct);

% when filtering the secondary, we want to filter out the corresponding
% rows in M1 as well; keep track of the rows we want to keep
M1_rows = true(size(M1, 1), 1);

N = 0;
[starttimes, firsts] = unique(M1(:, c1.(cols1.links.start)), 'first');
[~, lasts] = unique(M1(:, c1.(cols1.links.start)), 'last');
for i = 1:length(starttimes) % loop through secondary granules with any data
    starttime = starttimes(i);
    first = firsts(i);
    last = lasts(i);
    rows = M1(first:last, c1.(cols1.links.lineno));
    [year month day] = unixsecs2date(starttime);
    [M2, c2, ~, f2] = collocation_read(...
        cols1.links.sat1, cols1.links.sensor1, ...
        sat1, cols1.links.sensor2, ...
        [year month day], [year month day], ...
        cols_in2, nan, filter2);                    % don't filter anything;
                                                    % just 'calculate' f2
    M2 = M2(rows, :);                               % make it same size as M1-part
    lim = collocation_restrain(M2, limmat, f2);     % NOW filter
    M1_rows(first:last) = lim;                      % in both M1 
    M2 = M2(lim, :);                                % and M2
    
    % pre-allocate only here, so that we know the width
    if i==1
        M2_all = nan*zeros(size(M1, 1), size(M2, 2));
    end
    M2_all(N+1:N+size(M2, 1), :) = M2;
    N = N + size(M2, 1);
end
M2_all(isnan(M2_all(:, 1)), :) = []; % get rid of superfluous rows 
M2 = M2_all;

% correct column-numbers for subsequent concatenation
c2 = structfun(@(v) v+size(M1, 2), c2, 'UniformOutput', false);
c.c1 = c1;
c.c2 = c2;
M = [M1(M1_rows, :) M2];
