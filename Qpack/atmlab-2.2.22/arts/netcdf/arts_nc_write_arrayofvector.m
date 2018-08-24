% ARTS_NC_WRITE_ARRAYOFVECTOR   Write ArrayOfVector to ARTS NetCDF file.
%
%    Writes an ArrayOfVector to a NetCDF file for use with Arts.
%    Array elements must be column vectors!
%
% FORMAT   arts_nc_write_arrayofvector(filename, v, varargin)
%        
% IN    filename  Name of NetCDF file.
% IN    v         ArrayOfVector variable.
% OPT   varargin  Cell array of name/value pair cells for global attributes

% 2010-02-03   Created by Oliver Lemke.

function arts_nc_write_arrayofvector (filename, v, varargin)

ncid = netcdf.create (filename, 'NC_CLOBBER');

attributes = optargs( varargin, { [] } );

if (~isempty(attributes))
      addncattributes (ncid, attributes);
end

ndim = netcdf.defDim (ncid, 'nelem', length(v));

vdims = zeros (length(v), 1, 'int32');
for i = 1:length(v)
    vdims(i) = length(v{i});
end

ntdim = netcdf.defDim (ncid, 'nelem_total', sum(vdims));

evarid = netcdf.defVar (ncid, 'Vector_nelem', 'int', ndim);
varid = netcdf.defVar (ncid, 'ArrayOfVector', 'double', ntdim);

netcdf.endDef (ncid);

netcdf.putVar (ncid, evarid, vdims);
netcdf.putVar (ncid, varid, vertcat(v{:}));

netcdf.close (ncid);
