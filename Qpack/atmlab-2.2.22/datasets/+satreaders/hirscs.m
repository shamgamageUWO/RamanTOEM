function data = hirscs(file)

% satreaders.hirscs Read HIRSCS data in the common format (see README)
%
% This file reads data from a HIRSCS radiometer file and rearranges the
% fields to the common format. See README.
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% FORMAT
%
%   data = satreaders.hirscs(file)
%
% IN
%
%   file        string      Path to l1b file
%   channels    vector      vector of channels to read (defaults to 1:5)
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees
%                   lon     longitude in [-180, 180] degrees

% $Id: hirscs.m 8720 2013-10-21 20:41:39Z gerrit $
% Gerrit Holl

tmpdir = create_tmpfolder();
cleanupObject = onCleanup(@() delete_tmpfolder(tmpdir));
file = uncompress(file,tmpdir);

ncid = netcdf.open(file, 'NC_NOWRITE');

[~, nvars] = netcdf.inq(ncid);
for i = 0:nvars-1
    nm = netcdf.inqVar(ncid, i);
    data.(nm) = netcdf.getVar(ncid, i, 'double');
end
netcdf.close(ncid);

% wrap longitudes

data.lon = wrapTo180(data.lon);

% rotate bt, lc

data.bt = data.bt.';
data.lc = data.lc.';

% compensate time wrapping around

data.time = compensate_wraparound(data.time);

% get rid of doubles. FIXME: use scanline numbers

[~, I] = unique([data.time data.lat data.lon], 'rows');
allfields = fieldnames(data);
for i = 1:length(allfields);
    field = allfields{i};
    data.(field) = data.(field)(I, :);
end
