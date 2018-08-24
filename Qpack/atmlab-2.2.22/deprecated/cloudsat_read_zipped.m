function data = cloudsat_read_zipped(CSin, varargin)
%% CLOUDSAT_READ_ZIPPED unpack CS file, return input, remove unpacked file
%
% This is a wrapper around cloudsat_read that uncompresses the file, reads the data
% and then deletes the uncompressed file.
%
% THIS FUNCTION IS DEPRICATED: this is now done in read_cloudsat_hdf.
%
% $Id: cloudsat_read_zipped.m 8243 2013-02-27 22:05:14Z seliasson $

tmpdir = create_tmpfolder;
c = onCleanup(@() rmdir(tmpdir,'s'));
filename = uncompress(CSin, tmpdir);
data = read_cloudsat_hdf(filename, varargin{:});
