function gmt_nc_save_gridded (x, y, z, cdf)
%% GMT_NC_SAVE_GRIDDED   write a gridded netcdf file for GMT.
%
% This function writes a netcdf file that can be used as input for
% GMT plotting routines.
% 
% FORMAT  write_gmtgrid(x,y,z,cdf_file)
%
% IN    x    Longitude grid vector
%       y    Latitude grid vector
%       z    Data matrix
%
% Example:  x=[ 1 2 ];
%           y=[ 1 2 3 ];
%           z=[ 1 2; 3 4; 5 6];
%           contour(x,y,z);
%           write_gmtgrid(x,y,z,grdfile);
%
% x and y can be either row or column vectors

% 2010-01-20 Created by Oliver Lemke.

if exist('OCTAVE_VERSION','builtin')
  write_gmtgrid_octave( x, y, z, cdf);
  return;
end;

[ny,nx] = size(z);

% Create the file  
ncid = netcdf.create ( cdf, 'NC_CLOBBER' );

%
% Define the dimensions.
lon_dimid = netcdf.defDim ( ncid, 'x', nx );
lat_dimid = netcdf.defDim ( ncid, 'y', ny );

%
% Define the coordinate variables. We will only define coordinate
% variables for lat and lon.  
lon_varid = netcdf.defVar ( ncid, 'x', 'double', lon_dimid );
lat_varid = netcdf.defVar ( ncid, 'y', 'double', lat_dimid );

% 
% The dimids array is used to pass the dimids of the dimensions of
% the netCDF variables.
dimids = [ lon_dimid lat_dimid ];

% 
% Define the netCDF data variable.
mean_varid = netcdf.defVar (ncid, 'z', 'float', dimids);

netcdf.putAtt ( ncid, lon_varid, 'long_name', 'x' );
netcdf.putAtt ( ncid, lat_varid, 'long_name', 'y' );
netcdf.putAtt ( ncid, mean_varid, 'long_name', 'z' );
netcdf.putAtt ( ncid, netcdf.getConstant ('NC_GLOBAL'), 'node_offset', 1 );

netcdf.endDef (ncid);

netcdf.putVar ( ncid, lon_varid, x );
netcdf.putVar ( ncid, lat_varid, y );
netcdf.putVar ( ncid, mean_varid, single(z)' );

netcdf.close (ncid);


%% WRITE_GMTGRID_OCTAVE

function write_gmtgrid_octave (x, y, z, cdf)

[ny,nx] = size(z);

nc = netcdf ( cdf, 'c' );

%
% Define the dimensions.
nc('x') = nx;
nc('y') = ny;

%
% Write the variable dimensions.
nc{'x'} = ncdouble ( 'x' );
nc{'x'}.long_name = 'x';

nc{'y'} = ncdouble ( 'y' );
nc{'y'}.long_name = 'y';

nc{'z'} = ncdouble ( 'y', 'x' );
nc{'z'}.long_name = 'z';

%
% Write the variables.
nc{'x'}(:) = x;
nc{'y'}(:) = y;
nc{'z'}(:) = z;

nc.node_offset = '1';

close (nc);

