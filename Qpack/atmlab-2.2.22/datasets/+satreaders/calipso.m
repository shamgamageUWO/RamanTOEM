function [S,attr] = calipso(file, varargin)

% SATREADERS.CALIPSO reads calipso data
%
% Read calipso caliop data and output the data in the format common to all
% satreaders.<dataset>.m readers in atmlab. Geodata and time data are
% always retrieved from the data file.
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% IN
%
%   file    string      Path to gzipped file
%   extra   cell array (optional) extra fields.
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%                   fields  and what ever extra fields you wanted
%
%   attr    struct  With associated attributes
%
% FORMAT
%
%   [S,attr] = satreaders.calipso(file, varargin)

% $Id: calipso.m 8720 2013-10-21 20:41:39Z gerrit $
% Created by Salomon Eliasson

%% INFORMATION
%
% Latitude:      Three values are reported: the footprint latitude for the
%                first pulse included in the 15 shot average; the footprint
%                latitude for the final pulse; and the footprint latitude
%                at the temporal midpoint (i.e., at the 8th of 15
%                consecutive laser shots).
%
% Longitude:     -||-
%
% Profile_UTC_Time :  Time expressed in Coordinated Universal Time (UTC),
%                     and formatted as 'yymmdd.ffffffff', where 'yy'
%                     represents the last two digits of year, 'mm' and 'dd'
%                     represent month and day, respectively, and 'ffffffff'
%                     is the fractional part of the day. For the 5 km
%                     layerproducts, three values are reported: the time
%                     for the first pulse included in the 15 shot average;
%                     the time for the final pulse; and the time at the
%                     temporal midpoint (i.e., at the 8th of 15 consecutive
%                     laser shots).
%
% ExtinctionQC_532: 0 is recommended for proper retrievals
%
% Ice_Water_Path: has 10 values. pressumably allowing for up to 10 clouds
%
core_fields = {'Latitude','Longitude','Profile_UTC_Time'};
extra_fields = optargs(varargin, {{}});
all_fields = [core_fields(:); extra_fields(:)];

% make TEMPDIR & cleanup after I'm done.
tmpdir = create_tmpfolder();
cleanupObject = onCleanup(@() delete_tmpfolder(tmpdir));
file = uncompress(file,tmpdir);

% READ the data. This also scales the data automatically!
for F = all_fields'
    S.(F{1})  = hdfread(file,F{1});
end

%% RENAME some fields

% get epoch. 
% 
D = datasets;
info =  D.calipso.find_info_from_granule(file);
s2d = @str2double;

% See information below header to make sense of this
yymmdd = s2d(sprintf('%2.0f%02.0f%02.0f',s2d(info.year)-2000,s2d(info.month),s2d(info.day)));

% I will only use the midway value for the core
% 
S.lon = double(S.Longitude(:,2));
S.lat = double(S.Latitude(:,2));
S.time = (S.Profile_UTC_Time(:,2)-yymmdd) * (24*3600);
S.epoch = round(date2unixsecs(s2d(info.year), s2d(info.month), s2d(info.day)));
S.path = file;
S.version = '051 (hardcoded)';

S = rmfield(S,core_fields);
S = MaskInvalidGeoTimedataWithNaN(S);

end
