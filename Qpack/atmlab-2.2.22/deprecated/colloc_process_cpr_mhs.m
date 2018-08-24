function M = colloc_process_cpr_mhs(collocations, ...
    ~, date_cpr, data_cpr, name_mhs, date_mhs, data_mhs)

% colloc_process_cpr_mhs Gather collocation info to store for CloudSat+MHS
%
% After the collocating process is done by 'collocate', one wants to
% collect some additional information: longitudes, latitudes, times,
% viewing angles, distances, intervals, etc. This function takes care of
% that in the case of CPR/MHS.
%
% All colloc_process_* functions are automatically called by
% collocate_granule and thus have the same interface. Not all arguments are
% used by all.
% 
% FORMAT
%
%   M = colloc_process_cpr_mhs(collocations, ...
%       name_cpr, date_cpr, data_cpr, ...
%       name_mhs, date_mhs, data_mhs)
%
% IN
%
%   collocations    Nx4 matrix  Collocations as returned by collocate
%   name_cpr        string      Name of satellite carrying CPR ('cloudsat')
%   date_cpr        vector      Date vector for CPR starting time
%   data_cpr        structure   Data for CPR, as returned by read_cpr
%   name_mhs        string      Name of MHS-carrying satellite
%   date_mhs        vector      Date vector for MHS starting time
%   data_mhs        structure   Data for MHS, as returned by read_mhs
%
% OUT
%
%   M               matrix      Matrix with one row for each collocation
%                               and columns as in
%                               colloc_constants('cols_cpr_mhs').overlap
%
% $Id$

% prepare
c = colloc_constants('cols_cpr_mhs');
c = c.overlap;
n = size(collocations, 1);
M = nan*zeros(n, c.NCOLS);
if n==0
    return % don't bother
end

% convert to cell array for easy passing into date2unixsecs
date_cpr_cell = num2cell(date_cpr);
date_mhs_cell = num2cell(date_mhs);

% row and column numbers
cr = collocations(:, 1);
ar = collocations(:, 3);
ac = collocations(:, 4);

% index for direct addressing
ai = sub2ind(size(data_mhs.lat), ar, ac);

%% cloudsat info

% lat/long
M(:, c.C_LONG) = data_cpr.lon(cr);
M(:, c.C_LAT) = data_cpr.lat(cr);

% time
        
M(:, c.C_START, :) = round(date2unixsecs(date_cpr_cell{1:5}));
M(:, c.C_TIME, :) = data_cpr.epoch + data_cpr.time(cr);
M(:, c.C_I, :) = cr;

%% amsub/mhs

M(:, c.B_LONG) = data_mhs.lon(ai);
M(:, c.B_LAT) = data_mhs.lat(ai);
M(:, c.B_START) = round(date2unixsecs(date_mhs_cell{1:5}));
M(:, c.B_TIME) = data_mhs.epoch + data_mhs.time(ar);
M(:, c.B_I) = ar;
M(:, c.B_C) = ac;
M(:, c.B_DIST) = sphdist(data_cpr.lat(cr), data_cpr.lon(cr), ...
    data_mhs.lat(ai), data_mhs.lon(ai), constants('EARTH_RADIUS')/1e3);
M(:, c.B_INT) = M(:, c.B_TIME) - M(:, c.C_TIME);
M(:, c.B_LZA) = data_mhs.lza(ai);
M(:, c.B_LAA) = data_mhs.laa(ai);

%% amsua

amsua = read_granule(name_mhs, 'amsua', date_mhs, false);

[aah aaw] = size(amsua.lon); % amsu-a width, amsu-a height
M(:, c.A_I) = min(max(round(ar/3), 1), aah); % amsu-a row
M(:, c.A_C) = min(max(round(ac/3), 1), aaw); % amsu-a column
aai = sub2ind(size(amsua.lat), M(:, c.A_I), M(:, c.A_C));
M(:, c.A_LONG) = amsua.lon(aai);
M(:, c.A_LAT) = amsua.lat(aai);
M(:, c.A_START) = M(:, c.B_START);
M(:, c.A_TIME) = data_mhs.epoch + ...
    amsua.time(M(:, c.A_I));
M(:, c.A_DIST) = sphdist(data_cpr.lat(cr), data_cpr.lon(cr), ...
    amsua.lat(aai), amsua.lon(aai), constants('EARTH_RADIUS')/1e3);
M(:, c.A_INT) = M(:, c.A_TIME) - M(:, c.C_TIME);

%% hirs

hirs = read_granule(name_mhs, 'hirs', date_mhs, false, true);


if ~isempty(hirs)
    % TODO: optimise this bit of code
    % find hirs scanline (row) closest in time for each mhs scanline
    hr = arrayfun(...
        @(v) mini(abs(hirs.time-v)), ...
        data_mhs.time(M(:, c.B_I)));
    % find hirs pixel (col) in scanline closest in distance to CPR-point
    hc = arrayfun(...
        @(i) mini(...
        (hirs.lat(hr(i), :)-M(i, c.C_LAT)).^2 + ...
        (hirs.lon(hr(i), :)-M(i, c.C_LONG)).^2 ...
        ), 1:n);
    % find index from (row, column)
    hi = sub2ind(size(hirs.lat), hr, hc');
    % ready to add information to matrix
    M(:, c.H_LONG) = hirs.lon(hi);
    M(:, c.H_LAT) = hirs.lat(hi);
    M(:, c.H_START) = M(:, c.B_START);
    M(:, c.H_TIME) = data_mhs.epoch + hirs.time(hr);
    M(:, c.H_I) = hr;
    M(:, c.H_C) = hc;
    M(:, c.H_DIST) = sphdist(M(:, c.C_LAT), M(:, c.C_LONG), ...
        M(:, c.H_LAT), M(:, c.H_LONG), constants('EARTH_RADIUS')/1e3);
    M(:, c.H_INT) = M(:, c.H_TIME) - M(:, c.C_TIME);
end

%% others

%M(:, c.SZA) = circ_rad2ang(ignoreNaN([data_mhs.sza(ai) amsua.sza(aai) hirs.sza(hi)], ...
%    @circ_meand, 2));
%M(:, c.SAA) = circ_rad2ang(ignoreNaN([data_mhs.saa(ai) amsua.saa(aai) hirs.saa(hi)], ...
%    @circ_meand, 2));
% assert(all(circ_distd(data_mhs.sza(ai), amsua.sza(aai))<0.5), ...
%     'atmlab:colloc_process_cpr_mhs', ...
%     'solar zenith angles MHS/AMSUA do not match. Bug?');

%% sort by: MHS row, then MHS column, then CloudSat pixel

M = sortrows(M, [c.B_I c.B_C c.C_I]);

%% remove doubles

try
    wrongrows = M(:, c.B_I)< granule_first_line(name_mhs, amsub_or_mhs(name_mhs), date_mhs);
    M(wrongrows, :) = [];
catch ME
    switch ME.identifier
        case 'atmlab:granule_first_line'
            logtext(atmlab('ERR'), ...
                'Warning: Unable to remove doubles: %s\n', ...
                ME.message);
        otherwise
            ME.rethrow();
    end
end

end

function i = mini(v)
% mini return index for minimum of v (arrayfun wants 1 output)
[~, i] = min(v);
end
