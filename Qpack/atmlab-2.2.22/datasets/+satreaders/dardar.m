function S = dardar(file, varargin)

% SATREADERS.DARDAR Read DARDAR data in the common format
%
% This file reads data from a DARDAR file and rearranges the fields to
% the common format. Geodata and time data are always retrieved from the
% data file.
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% IN
%
%   file    string      Path to hdf file
%   extra   cell array (optional) extra fields.
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%
% FORMAT
%
%   S = satreaders.dardar(file, varargin)

% $Id: dardar.m 8720 2013-10-21 20:41:39Z gerrit $
% Created by Salomon Eliasson

core_fields   = {'time','latitude','longitude'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];

for F = all_fields'
    S.(F{1}) = hdfread(file,F{1});
    if isvector(S.(F{1})) && ~iscolumn(S.(F{1})) && length(S.(F{1})) == length(S.time)
        S.(F{1}) = S.(F{1}).';
    end
end


% CONSTRUCT time axis with same dimensions
S.lat = double(S.latitude);
S.lon = double(S.longitude);
S.time = double(S.time);

% get the verion directly from the filename
D = datasets;
info = D.dardar.find_info_from_granule(file);
date = dayofyear_inverse(str2double(info.year), str2double(info.doy));
S.epoch = round(date2unixsecs(date.year, date.month, date.day));

S.version = info.version;
S.path = file;

S = rmfield(S,{'latitude','longitude'});

S = MaskInvalidGeoTimedataWithNaN(S);

end
