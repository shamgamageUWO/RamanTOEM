% ARTS_NC_WRITE_ARRAYOFMATRIX   Write ArrayOfMatrix to ARTS NetCDF file.
%
%    Writes an ArrayOfMatrix to a NetCDF file for use with Arts.
%
% FORMAT   arts_nc_write_arrayofmatrix(filename, v, varargin)
%        
% IN    filename  Name of NetCDF file.
% IN    v         ArrayOfMatrix variable.
% OPT   varargin  Cell array of name/value pair cells for global attributes

% 2010-02-03   Created by Oliver Lemke.

function arts_nc_write_arrayofmatrix (filename, v, varargin)

ncid = netcdf.create (filename, 'NC_CLOBBER');

attributes = optargs( varargin, { [] } );

if (~isempty(attributes))
      addncattributes (ncid, attributes);
end

ndim = netcdf.defDim (ncid, 'nelem', length(v));

vrdims = zeros (length(v), 1, 'int32');
vcdims = zeros (length(v), 1, 'int32');
for i = 1:length(v)
    s = size(v{i});
    vrdims(i) = s(1);
    vcdims(i) = s(2);
end

ntdim = netcdf.defDim (ncid, 'nelem_total', sum(vrdims.*vcdims));

ervarid = netcdf.defVar (ncid, 'Matrix_nrows', 'int', ndim);
ecvarid = netcdf.defVar (ncid, 'Matrix_ncols', 'int', ndim);
varid = netcdf.defVar (ncid, 'ArrayOfMatrix', 'double', ntdim);

netcdf.endDef (ncid);

netcdf.putVar (ncid, ecvarid, vcdims);
netcdf.putVar (ncid, ervarid, vrdims);
v2=cellfun(@(x) reshape(x', 1, []), v, 'UniformOutput', false);
netcdf.putVar (ncid, varid, [v2{:}]);

netcdf.close (ncid);
