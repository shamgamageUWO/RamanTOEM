function M = colloc_process_hirscs_poes(collocations, ...
    ~, date1, data1, ...
    ~, date2, data2)

% colloc_process_hirscs_poes Gather collocation info to store for hirscs+MHS
%
% After collocating, we want to gather information about the collocations: not
% only indices and columns, but also time, lat, long, distance, interval. This
% file collects such data.
%
% FORMAT
%
%   M = colloc_process_hirscs_poes(collocations, ...
%       name1, date1, data1, ...
%       name2, date2, data2);
%
% IN
%
%   collocations    Nx4 matrix  As returned by collocate
%   name1           string      Name of primary satellite (not used here)
%   date1           1x5 vector  Contains [year month day hour minute] for the
%                               start of the primary granule.
%   data1           structure   Fields time, lat and lon should be present; as
%                               returned by datasets_constants('read_hirscs')
%   name2           string      Name of secondary satellite (not used here)
%   date2           1x5 vector  As date1, but for secondary granule.
%   data2           structure   As data1, but for secondary granule; as
%                               returned by dataset_constants('read_mhs').
%
% OUT
%
%   M               Nxp matrix  Matrix containing p fields of information for
%                               all N collocations.
%
% $Id: colloc_process_hirscs_poes.m 7553 2012-04-27 19:08:16Z gerrit $

%% prepare
c = colloc_constants('cols_hirscs_poes');
c = c.overlap;
n = size(collocations, 1);
M = nan*zeros(n, c.NCOLS);

% convert to cell array for easy passing into date2unixsecs
date1_cell = num2cell(date1);
date2_cell = num2cell(date2);

% row and column numbers
i1 = collocations(:, 1);
%c1 = collocations(:, 2);
r2 = collocations(:, 3);
c2 = collocations(:, 4);
    
% index for direct addressing
%i1 = sub2ind(size(data1.lat), r1, c1);
i2 = sub2ind(size(data2.lat), r2, c2);

%% store info

% lat/long
M(:, c.H_LAT) = data1.lat(i1);
M(:, c.H_LONG) = data1.lon(i1);
M(:, c.MHS_LAT) = data2.lat(i2);
M(:, c.MHS_LONG) = data2.lon(i2);

% time
M(:, c.H_START) = round(date2unixsecs(date1_cell{1:5}));
M(:, c.MHS_START) = round(date2unixsecs(date2_cell{1:5}));


M(:, c.H_TIME) = data1.epoch + data1.time(i1);
M(:, c.MHS_TIME) = data2.epoch + data2.time(r2);

% angles
M(:, c.MHS_LZA) = data2.lza;
M(:, c.MHS_LAA) = data2.laa;
M(:, c.SZA) = data2.sza;
M(:, c.SAA) = data2.saa;

% index/column
M(:, c.H_I) = i1;
M(:, c.MHS_ROW) = r2;
M(:, c.MHS_COL) = c2;

% distance and interval
M(:, c.DIST) = sphdist(M(:, c.H_LAT), M(:, c.H_LONG), ...
    M(:, c.MHS_LAT), M(:, c.MHS_LONG), constants('EARTH_RADIUS')/1e3);
M(:, c.INT) = M(:, c.MHS_TIME) - M(:, c.H_TIME);

% other HIRSCS
M(:, c.H_ZEN) = data1.zen(i1);
M(:, c.H_ALT) = data1.alt(i1);
M(:, c.H_LINE) = data1.line(i1);
M(:, c.H_POSI) = data1.posi(i1);

%% select only the nearest one

M = sortrows(M, [c.H_I c.DIST]);
[~, I_first] = unique(M(:, c.H_I), 'first');
M = M(I_first, :);
