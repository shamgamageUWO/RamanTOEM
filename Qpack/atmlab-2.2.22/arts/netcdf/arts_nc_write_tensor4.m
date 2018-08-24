% ARTS_NC_WRITE_TENSOR4   Write Tensor4 to ARTS NetCDF file.
%
%    Writes a Tensor4 to a NetCDF file for use with Arts.
%
% FORMAT   arts_nc_write_tensor4(filename, v, varargin)
%        
% IN    filename Name of NetCDF file.
% IN    v        Tensor4 variable.
% OPT   varargin  Cell array of name/value pair cells for global attributes

% 2010-02-03   Created by Oliver Lemke.

function arts_nc_write_tensor4 (filename, v, varargin)

ncid = netcdf.create (filename, 'NC_CLOBBER');

attributes = optargs( varargin, { [] } );

if (~isempty(attributes))
      addncattributes (ncid, attributes);
end

s = size(v);
bdim = netcdf.defDim (ncid, 'nbooks', s(1));
pdim = netcdf.defDim (ncid, 'npages', s(2));
rdim = netcdf.defDim (ncid, 'nrows',  s(3));
cdim = netcdf.defDim (ncid, 'ncols',  s(4));

varid = netcdf.defVar (ncid, 'Tensor4', 'double', [bdim cdim rdim pdim]);

netcdf.endDef (ncid);

netcdf.putVar (ncid, varid, permute(v, [4 3 2 1]));

netcdf.close (ncid);
