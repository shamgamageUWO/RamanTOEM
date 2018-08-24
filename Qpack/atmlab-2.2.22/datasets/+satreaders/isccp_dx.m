function S = isccp_dx(file,varargin)
% SATREADERS.ISCCP_DX reads the ISCCP DX dataset
%
% Read ISCCP data and output the data in the format common to all
% satreaders.<dataset>.m readers in atmlab. Geodata and time data are
% always retrieved from the data file.
% 
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% FORMAT
%
%   S = satreaders.isccp_dx(file,varargin)
%
% IN
%
%   file    string      Path to file (may be zipped)
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
%          S = satreaders.isccp_dx(file,varargin)
%
% $Id: isccp_dx.m 8720 2013-10-21 20:41:39Z gerrit $
% Salomon Eliasson

core_fields   = {'global_attributes','lon','lat'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];

S = read_isccp(file,struct('dataset','dx'));

% all available fields are read from the binary file, so remove all fields,
% but all_fields.
flds = fieldnames(S)';
S = rmfield(S,flds(~ismember(flds,all_fields)));

% Since the data is from geostationary satellites, all times are
% the same within one file
S.time = ones(size(S.lon))*S.global_attributes.UTC*3600; %[s];
S.version = 'DX';
S.path = file;

S = MaskInvalidGeoTimedataWithNaN(S);

end
