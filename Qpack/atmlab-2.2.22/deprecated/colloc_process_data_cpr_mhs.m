function M = colloc_process_data_cpr_mhs(~, M_c, ~, ~, data1, sat2, date2, data2)

% colloc_process_data_cpr_mhs Gather collocation data to store for CPR+MHS
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
%   M = process_data_cpr_mhs(collocations, M_c, sat1, date1, data1, ...
%       sat2, date2, data2)
%
% IN
%
%   collocations    Nx4 matrix  (ignored) as returned by collocate
%   M_c             Nxp matrix  As returned by process_cpr_mhs
%   sat1            string      name of 1st satellite
%   date1           1x5 vector  (ignored) starting time of 1st satellite
%   data1           structure   As returned by read_cpr
%   sat2            string      name of 2nd satellite
%   date2           1x5 vector  As date1, but for secondary granule.
%   data2           structure   As returned by read_mhs
%
% OUT
%
%   M               Nxp matrix  Matrix containing p fields of information for
%                               all N collocations.
%
% $Id$

% prepare
c = colloc_constants('cols_cpr_mhs');
n = size(M_c, 1);
M = nan*zeros(n, c.data.NCOLS);

% row and column numbers
r1 = M_c(:, c.overlap.C_I);
r2 = M_c(:, c.overlap.B_I);
c2 = M_c(:, c.overlap.B_C);

%% cloudsat data
M(:, c.data.ROIWP) = data1.RO_ice_water_path(r1);
M(:, c.data.dROIWP) = data1.RO_ice_water_path_uncertainty(r1);
M(:, c.data.IOROIWP) = data1.IO_RO_ice_water_path(r1);
M(:, c.data.dIOROIWP) = data1.IO_RO_ice_water_path_uncertainty(r1);

%% AMSUB/MHS data

% index for direct addressing
i2 = sub2ind(size(data2.lat), r2, c2);

% reshape so that I can use direct addressing for brightness temperatures
tb = reshape(data2.tb, [numel(data2.lat) 5]);

M(:, c.data.MHS) = tb(i2, :);

%% AMSUA, HIRS
% those require reading additional files

% TODO/FIXME: optimise this, I already read for the earlier processing
amsua_data = read_granule(sat2, 'amsua', date2, false, true);
hirs_data = read_granule(sat2, 'hirs', date2, false, true);

if ~isempty(amsua_data)
    % AMSU_A
    ai = sub2ind(size(amsua_data.lat), M_c(:, c.overlap.A_I), M_c(:, c.overlap.A_C));
    tb = reshape(amsua_data.tb, [numel(amsua_data.lat) 15]);
    M(:, c.data.AMSU_A) = tb(ai, :);
end

if ~isempty(hirs_data)
    % HIRS
    hi = sub2ind(size(hirs_data.lat), M_c(:, c.overlap.H_I), M_c(:, c.overlap.H_C));
    tb = reshape(hirs_data.tb, [numel(hirs_data.lat) 20]);
    M(:, c.data.HIRS) = tb(hi, :);
end

%% MSPPS

% Apply scalefactor.
% From
% http://www.ncdc.noaa.gov/oa/pod-guide/ncdc/docs/klm/html/c9/sec96-3.htm
% divide by the scalefactor to get kg/m^2
% we want g/m^2 so we multiply by 1000/scalefactor
% TODO: convert to specialised reading function
try
    mspps_file = find_datafile_by_date(date2, sat2, 'mspps', 120); % 120 seconds tolerance
    logtext(atmlab('OUT'), ...
        'Reading mspps\n');
    scalefactor = 1000/double(cell2mat(hdfread(mspps_file, 'IWP_SCAL')));
    MSPPS_IWP_raw = hdfread(mspps_file, 'IWP');
    MSPPS_IWP = ((MSPPS_IWP_raw<0) + (MSPPS_IWP_raw>0)*scalefactor) .* double(MSPPS_IWP_raw);
    assert(size(MSPPS_IWP, 1)==size(data2.tb, 1), ...
        'atmlab:colloc_process_data_cpr_mhs', ...
        'MSPPS has not the same number of rows as AMSU. Skipping');
    M(:, c.data.MSPPS_IWP) = MSPPS_IWP(i2);
catch ME
    switch (ME.identifier)
        case {'MATLAB:HDF:invalidFile', 'atmlab:find_datafile_by_date', ...
                'atmlab:colloc_process_data_cpr_mhs'}
            logtext(atmlab('ERR'), ...
                'WARNING: Unable to process mspps: %s\n', ME.message);
        otherwise
            ME.rethrow();
    end
end


