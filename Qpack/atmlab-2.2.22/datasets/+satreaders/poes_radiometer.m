function data = poes_radiometer(file, ~)

% satreaders.poes_radiometer Read POES data and arrange in the common format
%
% This file reads data from a POES l1b radiometer file and rearranges the
% fields to the common format. See README.
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% FORMAT
%
%   data = satreaders.poes_radiometer(file)
%
% IN
%
%   file    string  Path to l1b file. Must be FULL PATH!
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%
% $Id: poes_radiometer.m 8720 2013-10-21 20:41:39Z gerrit $

if length(file)>3 && strcmpi(file(end-2:end), 'l1c') % already in l1c (like at LERMA)
    data = atovs_read_data(file);
else
    data = atovs_get_l1c(file);
end

% convert time from milliseconds to seconds

data.time = data.time'/1000;

% compensate time wrapping around

data.time = compensate_wraparound(data.time);

% verify data integrity

assert(~isempty(data.time), ...
    'atmlab:invalid_data', ...
    'Time axis empty: %s', file)

assert(all(diff(data.time)>0), ...
    'atmlab:invalid_data', ...
    'POES time not monotonically increasing: %s', file);

% shift dimensions so that it's [row col (channel)]

for field = {'lat', 'lon', 'lza', 'laa', 'sza', 'saa', 'elev'}
    if isfield(data, field)
        data.(field{1}) = shiftdim(data.(field{1}), 1);
    end
end
data.tb = shiftdim(data.tb, 2);

% add filename and version

data.path = file;
data.version = '0'; % dunno

% add epoch

d = datasets;
info = d.mhs.find_info_from_granule(file);
data.epoch = round(date2unixsecs(str2double(info.year), str2double(info.month), ...
    str2double(info.day)));
