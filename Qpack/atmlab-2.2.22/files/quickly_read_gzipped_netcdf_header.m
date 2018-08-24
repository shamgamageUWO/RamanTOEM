function [varnames, globattr] = quickly_read_gzipped_netcdf_header(file)

% Quickly read a gzipped netcdf header
%
% If you have a large compressed netcdf file and all you need to know is
% what variables are in there, this function may or may not work.  It
% compresses only the beginning of the file, hopefully enough to read out
% header information.  So far it returns only the cell array of strings
% with the variable names.
%
% WARNING: this function can cause Matlab (2013a) to crash if the header
% gets truncated prematurely.
%
% FORMAT
%
%   varnames = quickly_read_gzipped_netcdf_header(file)
%
% IN
%
%   file        string, path to file
%
% OUT
%
%   varnames    cell array of strings, names of variables

% $Id: quickly_read_gzipped_netcdf_header.m 8516 2013-06-26 21:33:48Z gerrit $

% hopefully enough bytes to read the header, otherwise Matlab crashes
% badly.  Therefore, rather on the safe side!  25000 bytes takes <002
header_estimate = 25000;

d = create_tmpfolder();
c1 = onCleanup(@()rmdir(d,'s'));
outfile = fullfile(d, 'temp.nc');

% don't use uncompress, I only want the first part
exec_system_cmd(sprintf('gunzip -c %s | head -c %d > %s', ...
                        file, header_estimate, outfile));

globattr = loadncglobalattr(outfile);
                    
ncid = netcdf.open(outfile, 'NOWRITE');
c2 = onCleanup(@() netcdf.close (ncid));

[~,nvars] = netcdf.inq(ncid);
varnames = cell(1, nvars);
for i = 0:nvars-1
    varnames{i+1} = netcdf.inqVar(ncid, i);
end


end
