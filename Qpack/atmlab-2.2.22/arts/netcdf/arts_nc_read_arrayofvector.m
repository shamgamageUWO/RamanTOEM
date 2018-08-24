% ARTS_NC_READ_ARRAYOFVECTOR   Read ArrayOfVector from ARTS NetCDF file.
%
%    Reads an ArrayOfVector from a NetCDF file saved with Arts.
%
% FORMAT   ret = arts_nc_read_arrayofvector(filename)
%        
% OUT   ret      ArrayOfVector
% OUT   gattr    Global attributes
%       
% IN    filename Name of NetCDF input file.

% 2010-02-02   Created by Oliver Lemke.

function [ret, gattr] = arts_nc_read_arrayofvector (filename)

ncid = netcdf.open (filename, 'NOWRITE');

gattr = loadncglobalattr (filename);

varid = netcdf.inqVarID (ncid, 'Vector_nelem');
nv = netcdf.getVar (ncid, varid);

varid = netcdf.inqVarID (ncid, 'ArrayOfVector');
v = netcdf.getVar (ncid, varid);
netcdf.close (ncid);

startelem = 1;

ret=cell(1,length(nv));
for i = 1:length(nv)
    endelem = startelem + nv(i) - 1;
    ret{i} = reshape (v(startelem:endelem), nv(i), 1);
    startelem = endelem + 1;
end

