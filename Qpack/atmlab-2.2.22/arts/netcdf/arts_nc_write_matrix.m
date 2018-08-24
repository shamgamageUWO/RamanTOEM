% ARTS_NC_WRITE_MATRIX   Write Matrix to ARTS NetCDF file.
%
%    Writes a Matrix to a NetCDF file for use with Arts.
%
% FORMAT   arts_nc_write_matrix(filename, v, varargin)
%        
% IN    filename  Name of NetCDF file.
% IN    v         Matrix variable.
% OPT   varargin  Cell array of name/value pair cells for global attributes

% 2010-02-03   Created by Oliver Lemke.

function arts_nc_write_matrix (filename, v, varargin)

ncid = netcdf.create (filename, 'NC_CLOBBER');

attributes = optargs( varargin, { [] } );

if (~isempty(attributes))
    addncattributes (ncid, attributes);
end

s = size(v);
rdim = netcdf.defDim (ncid, 'nrows', s(1));
cdim = netcdf.defDim (ncid, 'ncols', s(2));

varid = netcdf.defVar (ncid, 'Matrix', 'double', [cdim rdim]);

netcdf.endDef (ncid);

netcdf.putVar (ncid, varid, v');

netcdf.close (ncid);
