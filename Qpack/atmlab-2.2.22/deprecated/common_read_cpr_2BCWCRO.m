function S = common_read_cpr_2BCWCRO(file, varargin)

% common_read_cpr_2BCWCRO Read CloudSat CPR data in the common format (see README)
%
% This file reads data from a CloudSat CPR file and rearranges the fields to
% the common format.
%
% FORMAT
%
%   data = common_read_cpr(file[, extra])
%
% IN
%
%   file    string      Path to zipped CPR file
%   extra   cell array (optional) extra fields.
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%
% $Id: common_read_cpr_2BCWCRO.m 8243 2013-02-27 22:05:14Z seliasson $

if (nargin==1)
    warning(['atmlab:' mfilename], ['Calling ' mfilename ' with 1 argument ' ...
                'is deprecated. Four additional fields will be included for ' ...
                'backward compatibility. Pass empty cell-array if this is ' ...
                'not desired!']);
end

core_fields = {'Longitude'; 'Latitude'; 'UTC_start'; 'Profile_time'; 'product_version'};
extra_fields = optargs(varargin, {{'RO_ice_water_path'; 'RO_ice_water_path_uncertainty'; 'IO_RO_ice_water_path'; 'IO_RO_ice_water_path_uncertainty'}});
all_fields = [core_fields; extra_fields];
%S = cloudsat_read_zipped(file, all_fields);
S = read_cloudsat_hdf(file, all_fields);

% construct time axis with same dimensions
S.time = S.UTC_start + S.Profile_time;

% rename some fields

S.lon = double(S.Longitude(:));
S.lat = double(S.Latitude(:));
S.version = S.product_version; % will be written to NetCDF

% add filename

S.path = file;

% get epoch

info = find_info_from_granule('cpr', file);
date = dayofyear_inverse(str2double(info.year), str2double(info.doy));
S.epoch = round(date2unixsecs(date.year, date.month, date.day));

% remove redundant fields
S = rmfield(S, {'Longitude', 'Latitude', 'UTC_start', 'Profile_time', 'product_version'});

% convert 1-D fields into column vectors. This is required for processing.
flds = fieldnames(S);
for i = 1:length(flds)
    fld = flds{i};
    if isvector(S.(fld))
        S.(fld) = S.(fld)(:);
    end
end

end
