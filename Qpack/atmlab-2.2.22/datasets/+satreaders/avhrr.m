function data = avhrr(file, varargin)

% satreaders.avhrr Read AVHRR l1b data and arrange in a common format
%
% This file reads data from a AVHRR l1b radiometer file and rearranges the
% fields to the common format, used by collocation codes.  This function is
% not meant to be called directly; use either the 'read_granule' method on
% the SatDataset avhrr, or use avhrr_gac_read.
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% FORMAT
%
%   data = satreaders.avhrr(file)
%
% IN
%
%   file        string      Path to l1b file
%   extra       cellstr     fields to read
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%                   y       measurements
%
% See also: avhrr_gac_read, SatDataset/read

% $Id: avhrr.m 8720 2013-10-21 20:41:39Z gerrit $

extra_fields = optargs(varargin, {{}});
% this should actually be implemented as a pseudo-field...
extra_fields = setdiff(extra_fields, {'flag_3_is_3A', 'y'});

newfile = uncompress(file, atmlab('WORK_AREA'), struct('unidentified', 'error'));
c = onCleanup(@()delete(newfile));

header_fields = {'avh_h_l1bversnb'};
core_fields = {'avh_scnlinbit'}; % other core fields are always returned
all_fields = union(core_fields, extra_fields);
superfluous_fields = setdiff(all_fields, extra_fields);

data = avhrr_gac_read(newfile, header_fields, all_fields);

% add file/version

data.file = file;
% netcdf library doesn't like uint16 attribute
data.version = single(data.avh_h_l1bversnb);
data.flag_3_is_3A = logical(bitand(data.avh_scnlinbit, 1));
data = rmfield(data, union(header_fields, superfluous_fields));

end
