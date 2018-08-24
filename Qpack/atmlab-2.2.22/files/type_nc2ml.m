function ml_type = type_nc2ml(nc_type)

% convert netcdf3 type to matlab type
%
% According to http://www.unidata.ucar.edu/software/netcdf/docs/netcdf-c/NetCDF_002d3-Variable-Types.html
%
% USAGE
%
%   ml_type = type_nc2ml(nc_type)


S.BYTE = 'int8';
S.CHAR = 'char';
S.SHORT = 'int16';
S.INT = 'int32';
S.FLOAT = 'single';
S.DOUBLE = 'double';

ml_type = S.(upper(nc_type));

end
