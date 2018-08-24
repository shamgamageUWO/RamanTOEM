% ARTS_NC_WRITE_TENSOR3   Write Tensor3 to ARTS NetCDF file.
%
%    Writes a Tensor3 to a NetCDF file for use with Arts.
%
% FORMAT   arts_nc_write_tensor3(filename, v, varargin)
%        
% IN    filename  Name of NetCDF file.
% IN    v         Tensor3 variable.
% OPT   varargin  Cell array of name/value pair cells for global attributes

% 2010-02-03   Created by Oliver Lemke.

function arts_nc_write_tensor3 (filename, v, varargin)

ncid = netcdf.create (filename, 'NC_CLOBBER');

attributes = optargs( varargin, { [] } );

if (~isempty(attributes))
      addncattributes (ncid, attributes);
end

s = size(v);
pdim = netcdf.defDim (ncid, 'npages', s(1));
rdim = netcdf.defDim (ncid, 'nrows',  s(2));
cdim = netcdf.defDim (ncid, 'ncols',  s(3));

varid = netcdf.defVar (ncid, 'Tensor3', 'double', [cdim rdim pdim]);

netcdf.endDef (ncid);

netcdf.putVar (ncid, varid, permute(v, [3 2 1]));

netcdf.close (ncid);
