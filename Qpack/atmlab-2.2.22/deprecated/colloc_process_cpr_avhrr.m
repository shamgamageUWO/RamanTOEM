function M = colloc_process_cpr_avhrr(collocations, ...
    name_cpr, date_cpr, data_cpr, name_avhrr, date_avhrr, data_avhrr)

% colloc_process_cpr_avhrr Gather collocation info to store for CloudSat+AVHRR
%
% After the collocating process is done by 'collocate', one wants to
% collect some additional information: longitudes, latitudes, times,
% viewing angles, distances, intervals, etc. This function takes care of
% that in the case of CPR/AVHRR.
%
% All colloc_process_* functions are automatically called by
% collocate_granule and thus have the same interface. Not all arguments are
% used by all.
% 
% FORMAT
%
%   M = colloc_process_cpr_avhrr(collocations, ...
%       name_cpr, date_cpr, data_cpr, ...
%       name_avhrr, date_avhrr, data_avhrr)
%
% IN
%
%   collocations    Nx4 matrix  Collocations as returned by collocate
%   name_cpr        string      Name of satellite carrying CPR ('cloudsat')
%   date_cpr        vector      Date vector for CPR starting time
%   data_cpr        structure   Data for CPR, as returned by read_cpr
%   name_avhrr      string      Name of AVHRR-carrying satellite
%   date_avhrr      vector      Date vector for AVHRR starting time
%   data_avhrr      structure   Data for AVHRR, as returned by read_avhrr
%
% OUT
%
%   M               matrix      Matrix with one row for each collocation
%                               and columns as in
%                               colloc_constants('cols_cpr_avhrr').overlap
%
% $Id: colloc_process_cpr_avhrr.m 7553 2012-04-27 19:08:16Z gerrit $

%% prepare
c = colloc_constants('cols_cpr_avhrr');
c = c.overlap;
n = size(collocations, 1);
M = nan*zeros(n, c.NCOLS);
if n==0
    return % don't bother
end

% convert to cell array for easy passing into date2unixsecs
date_cpr_cell = num2cell(date_cpr);
date_avhrr_cell = num2cell(date_avhrr);

% row and column numbers
cr = collocations(:, 1);
ar = collocations(:, 3);
ac = collocations(:, 4);

% index for direct addressing
ai = sub2ind(size(data_avhrr.lat), ar, ac);

%% cloudsat info

% lat/long
M(:, c.C_LONG) = data_cpr.lon(cr);
M(:, c.C_LAT) = data_cpr.lat(cr);

% time
        
M(:, c.C_START, :) = round(date2unixsecs(date_cpr_cell{1:5}));
M(:, c.C_TIME, :) = data_cpr.epoch + data_cpr.time(cr);
M(:, c.C_I, :) = cr;

%% avhrr

M(:, c.AVHRR_LAT) = data_avhrr.lat(ai);
M(:, c.AVHRR_LONG) = data_avhrr.lon(ai);
M(:, c.AVHRR_START) = round(date2unixsecs(date_avhrr_cell{1:5}));
M(:, c.AVHRR_TIME) = data_avhrr.epoch + data_avhrr.time(ar);
M(:, c.AVHRR_ROW) = ar;
M(:, c.AVHRR_COL) = ac;
M(:, c.AVHRR_RAA) = data_avhrr.raa(ai);
M(:, c.AVHRR_SZA) = data_avhrr.sza(ai);
M(:, c.AVHRR_LZA) = data_avhrr.lza(ai);
M(:, c.DIST) = sphdist(data_cpr.lat(cr), data_cpr.lon(cr), ...
    data_avhrr.lat(ai), data_avhrr.lon(ai), constants('EARTH_RADIUS')/1e3);
M(:, c.INT) = M(:, c.AVHRR_TIME) - M(:, c.C_TIME);

%% remove doubles

wrongrows = M(:, c.AVHRR_ROW)< granule_first_line(name_avhrr, 'avhrr', date_avhrr);
M(wrongrows, :) = [];

% %% select only the nearest one
% 
% M = sortrows(M, [c.C_ROW c.DIST]);
% [~, I_first] = unique(M(:, c.C_ROW), 'first');
% M = M(I_first, :);
