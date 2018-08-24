% ARTS_NC_WRITE_VECTOR   Write Vector to ARTS NetCDF file.
%
%    Writes a Vector to a NetCDF file for use with Arts.
%
% FORMAT   arts_nc_write_vector(filename, v, varargin)
%        
% IN    filename  Name of NetCDF file.
% IN    v         Vector variable.
% OPT   varargin  Cell array of name/value pair cells for global attributes

% 2010-02-03   Created by Oliver Lemke.

function arts_nc_write_vector (filename, v, varargin)

ncid = netcdf.create (filename, 'NC_CLOBBER');

attributes = optargs( varargin, { [] } );

if (~isempty(attributes))
      addncattributes (ncid, attributes);
end

ndim = netcdf.defDim (ncid, 'nelem', length(v));

varid = netcdf.defVar (ncid, 'Vector', 'double', ndim);

netcdf.endDef (ncid);

netcdf.putVar (ncid, varid, v);

netcdf.close (ncid);
