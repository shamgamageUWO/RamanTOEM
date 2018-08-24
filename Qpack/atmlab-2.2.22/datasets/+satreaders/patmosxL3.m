function [S,attr] = patmosxL3(file, varargin)

% SATREADERS.PATMOSX reads patmosx data
%
% Read PATMOS-x data and output the data in the format common to all
% satreaders.<dataset>.m readers in atmlab. Geodata and time data are
% always retrieved from the data file.
%
% NOTE: This reader actually reads 2 files, one ascending, one descending
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
%
% NOTE: no time output since it's monthly data
%
% FORMAT
%
%   S = satreaders.patmosx(file, varargin)

% $Id: patmosxL3.m 8777 2014-02-12 12:45:13Z gerrit $
% Salomon Eliasson

core_fields = {'cell_latitude','cell_longitude'};
extra_fields = optargs(varargin, {{}});
all_fields = [core_fields(:); extra_fields(:)];

% read the data. This also scales the data automatically!
S       = read_clavrx_hdf(file,all_fields);

% rename some fields
S.lon   = double(S.cell_longitude(:));
S.lat   = double(S.cell_latitude(:));
S.time  = zeros(size(S.lat)); % since Gerrits codes require time
D           = datasets;

date        = D.patmosxL3.find_info_from_granule(file);
% get the month from the filename
info        = regexp(file,'patmosx_aft_mor_.+(?<year>\d{4})_(?<month>.{3})','names');
% the month is unhappily given as a string so...
strmonths   = {'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'}; x=1:12;
date.month  = x(ismember(strmonths,info.month));

S.epoch     = round(date2unixsecs(str2double(date.year), date.month, 1)); %monthly mean
S.version = '4'; %this is given in the README in /storage3/data/patmosx/level3
S.path = file;

S = rmfield(S,core_fields);

end
