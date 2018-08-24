function S = mspps(file, varargin)

% SATREADERS.MSPPS reads mspps data
%
% Read MSPPS data and output the data in the format common to all
% satreaders.<dataset>.m readers in atmlab. Geodata and time data are
% always retrieved from the data file.
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% IN
%
%   file    string      Path to hdf-file
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
%   attr    struct  empty
%
% FORMAT
%
%   [S,attr] = satreaders.mspps(file, varargin)

% $Id: mspps.m 8720 2013-10-21 20:41:39Z gerrit $
% Created by Salomon Eliasson

%% INFORMATION
% Time : (TAI93) Number of seconds and fractions since 0000 Jan. 1, 1993

core_fields = {'Latitude','Longitude','Time'};
extra_fields = optargs(varargin, {{}});
all_fields = [core_fields(:); extra_fields(:)];

for F = all_fields'
    try
    S.(F{1}) = hdfread(file,F{1});
    catch ME
        if strcmp(ME.identifier,'MATLAB:imagesci:hdfread:noDataSets')
            fprintf(2,'Dataset: %s is missing from file. skipping...\n',F{1})
        end
        if any(strcmp(ME.identifier,{...
                'MATLAB:imagesci:hdfquickinfo:invalidFile',...
                'MATLAB:imagesci:hdfinfo:invalidFile',...
                'MATLAB:imagesci:hdfread:noDataSets'}))
            error('atmlab:invalid_data','"%s:%s" for file: %s',...
                ME.identifier,ME.message,mfilename)
        else
            error(ME.identifier,ME.message)
        end
    end
end

%% RENAME some fields

S.lat = double(S.Latitude);
S.lon = double(S.Longitude);

% get epoch. 
% 
D = datasets;
info = D.mspps.find_info_from_granule(file);
s2d = @str2double;
S.epoch = round(date2unixsecs(s2d(info.year), s2d(info.month), s2d(info.day)));

% See information below header to make sense of this
S.time = S.Time{1}(:)-( S.epoch-date2unixsecs(1993,1,1) );

S.path = file;
S.version = 'unknown';

S = rmfield(S,core_fields);
S = MaskInvalidGeoTimedataWithNaN(S);

end
