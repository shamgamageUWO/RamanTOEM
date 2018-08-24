function S = cpr(file, varargin)

% SATREADERS.CPR reads cloudsat data
% 
% Read CloudSat data and output the data in the format common to all
% satreaders.<dataset>.m readers in atmlab. Geodata and time data are
% always retrieved from the data file.
% 
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% FORMAT
%
%   S = satreaders.cpr(file,varargin)
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

% $Id: cpr.m 8720 2013-10-21 20:41:39Z gerrit $
% Gerrit Holl

% NB: CloudSat appears not to have attributes in E05 and E06, implement a
% workaround for that...

% get info from filename
D = datasets;
info = D.cpr.find_info_from_granule(file);
date = dayofyear_inverse(str2double(info.year), str2double(info.doy));

switch info.epoch
    case {'E00', 'E01', 'E02', 'E03', 'E04'}
        haspv = true;
    case {'E05', 'E06'}
        haspv = false;
    otherwise
        error(['atmlab:' mfilename ':unkownepoch'], ...
            'Got epoch %s, I don''t like that :(', info.epoch);
end

core_fields = {'Longitude'; 'Latitude'; 'UTC_start'; 'Profile_time'};

if haspv
    core_fields = [core_fields; 'product_version'];
end

extra_fields = optargs(varargin, {{}});
all_fields = [core_fields(:); extra_fields(:)];

S = read_cloudsat_hdf(file, all_fields);

S.epoch = round(date2unixsecs(date.year, date.month, date.day));

% rename some fields
S.lon = double(S.Longitude);
S.lat = double(S.Latitude);
% construct time axis with same dimensions. Must convert to double because
% otherwise unixsecstodate will give the wrong time.
S.time = double( S.UTC_start + S.Profile_time);


S.path = file;
if haspv
    S.version = S.product_version;
else
    S.version = 'not_given';
end

% remove redundant fields
S = rmfield(S, core_fields);

% convert 1-D fields into column vectors. This is required for processing.
flds = fieldnames(S);
for i = 1:length(flds)
    fld = flds{i};
    if isvector(S.(fld))
        S.(fld) = S.(fld)(:);
    end
end

S = MaskInvalidGeoTimedataWithNaN(S);

end

