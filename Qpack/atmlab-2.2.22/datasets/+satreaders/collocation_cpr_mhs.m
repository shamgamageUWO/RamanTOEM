function data = collocation_cpr_mhs(file)

% satreaders.collocation_cpr_mhs Read CPR/MHS collocation file
%
% Read a CPR/MHS collocation file and return things in the common format.
% Additionally, all data from the collocation file are included.
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
% IN
%
%   file        string      path to collocations file
%
% out
%
%   data        structure   data with time, lat, lon
%
%
% $Id: collocation_cpr_mhs.m 8720 2013-10-21 20:41:39Z gerrit $


tmp = tempname(atmlab('WORK_AREA'));
exec_system_cmd(['zcat ' file '>' tmp]); % 3x faster than gunzip
%gunzipped = gunzip(file, atmlab('WORK_AREA'));
%data = loadncfile(gunzipped{1});
data = loadncfile(tmp);
delete(tmp);
data.info = data.global_attributes;

data.version = ['colloc:' data.info.software_version ':' ...
    data.info.primary_version ':' data.info.secondary_version ':' ...
    data.info.date];

rows = data.FIRST;
data.lat = data.B_LAT(rows);
data.lon = data.B_LONG(rows);

% use C_TIME to calculate the epoch, but return B_TIME as we're working
% with meandata here
[y, mo, d, ~, ~, ~] = unixsecs2date(double(data.C_TIME(rows)));
data.epoch = round(unique(date2unixsecs(y, mo, d)));
assert(isempty(data.epoch)||isscalar(data.epoch), 'atmlab:satreaders.collocation_cpr_mhs', ...
     'Data in %s appears to contain measurement from more than one day', ...
     file);
[~, ~, ~, h, mi, s] = unixsecs2date(double(data.B_TIME(rows)));

data.time = compensate_wraparound(3600*h + 60*mi + s);
data.file = file;
