function M = colloc_process_data_cpr_avhrr(~, M_c, ~, ~, data1, ~, ~, data2)

% colloc_process_data_cpr_avhrr Gather collocation data to store for CPR+AVHRR
%
% After collocating, and gathering information about the collocations, we
% want to collect some actual data: in this case, brightness temperatures.
%
% Because this m-file has the same format as other colloc_process_data_* files
% (so that the caller doesn't need to know what is being collocated), some of
% the arguments are ignored.
%
% FORMAT
%
%   M = process_data_cpr_avhrr(collocations, M_c, ...
%       sat1, date1, data1, ...
%       sat2, date2, data2)
%
% IN
%
%   collocations    Nx4 matrix  (ignored) as returned by collocate
%   M_c             Nxp matrix  As returned by process_cpr_avhrr
%   sat1            string      name of 1st satellite
%   date1           1x5 vector  (ignored) starting time of 1st satellite
%   data1           structure   As returned by read_cpr
%   sat2            string      name of 2nd satellite
%   date2           1x5 vector  As date1, but for secondary granule.
%   data2           structure   As returned by read_avhrr
%
% OUT
%
%   M               Nxp matrix  Matrix containing p fields of information for
%                               all N collocations.
%
% $Id: colloc_process_data_cpr_avhrr.m 7553 2012-04-27 19:08:16Z gerrit $

% prepare
c = colloc_constants('cols_cpr_avhrr');
n = size(M_c, 1);
M = nan*zeros(n, c.data.NCOLS);

% row and column numbers
r1 = M_c(:, c.overlap.C_I);
r2 = M_c(:, c.overlap.AVHRR_ROW);
c2 = M_c(:, c.overlap.AVHRR_COL);

%% cloudsat data
M(:, c.data.ROIWP) = data1.RO_ice_water_path(r1);
M(:, c.data.dROIWP) = data1.RO_ice_water_path_uncertainty(r1);
M(:, c.data.IOROIWP) = data1.IO_RO_ice_water_path(r1);
M(:, c.data.dIOROIWP) = data1.IO_RO_ice_water_path_uncertainty(r1);

%% AVHRR data

% index for direct addressing
i2 = sub2ind(size(data2.lat), r2, c2);

% WARNING! channel 3b->column 4, 4->column 5, 5->column 6!
M(:, c.data.AVHRR(1)) = data2.albedoCh1(i2);
M(:, c.data.AVHRR(2)) = data2.albedoCh2(i2);
M(:, c.data.AVHRR(3)) = data2.albedoCh3A(i2);
M(:, c.data.AVHRR(4)) = data2.brightnessTempCh3B(i2);
M(:, c.data.AVHRR(5)) = data2.brightnessTempCh4(i2);
M(:, c.data.AVHRR(6)) = data2.brightnessTempCh5(i2);
M(:, c.data.CLOUDFLAG) = data2.cloudFlag(i2);

is_3A = logical(data2.chan3A3B);
M(is_3A(r2), c.data.AVHRR(4)) = nan; % set 3B to 0 if 3A on
M(~is_3A(r2), c.data.AVHRR(3)) = nan; % set 3A to 0 if 3B on
