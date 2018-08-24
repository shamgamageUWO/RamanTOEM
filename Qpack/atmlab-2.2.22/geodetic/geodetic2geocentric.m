% GEODETIC2GEOCENTRIC converts from a geodetic to a geocentric position
%  
%   The geodetic coordinates refer to the reference ellipsoid 
%   specified by input ellipsoid. 
%   See Contents for a defintion of the geocentric coordinate system.
%
% FORMAT [r,lat_gc,lon_gc]=geodetic2geocentric(h,lat_gd,lon_gd[,ellipsoid])
%
% OUT    r         Radius
%        lat_gc    Geocentric latitude
%        lon_gc    Geocentric longitude
%
% IN     h         Geodetic height (height above the reference ellipsoid)
%        lat_gd    Geodetic latitude
%        lon_gd    geodetic longitude
% OPT    ellipsoid a row vector with the form [semimajor axis, eccentricity]
%                  specifying the ellipsoid,
%                  the semimajor axis must use the same units as h  
%        Default is WGS84.

% History: created by Bengt Rydberg 2011-10-31
function [r_gc,lat_gc,lon_gc]=geodetic2geocentric(h,lat_gd,lon_gd,ellipsoid)

if nargin<4
  %WGS84 reference ellipsoid
  ellipsoid = ellipsoidmodels( 'WGS84' );
end 

[x,y,z]              = geodetic2cart(h,lat_gd,lon_gd, ellipsoid );

[r_gc,lat_gc,lon_gc] = cart2geocentric(x,y,z);


