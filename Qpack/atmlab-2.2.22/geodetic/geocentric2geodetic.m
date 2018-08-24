% GEOCENTRIC2GEODETIC converts from a geocentric coordinate to a geodetic coordinate
%  
%   The geodetic coordinates refer to the reference ellipsoid 
%   specified by input ellipsoid. 
%   See Contents for a defintion of the geocentric coordinate system.
%
% FORMAT [h,lat_gd,lon_gd]=geocentric2geodetic(r,lat_gc,lon_gc[,ellipsoid])
%
% OUT    h         Geodetic height (height above the reference ellipsoid)
%        lat_gd    Geodetic latitude
%        lon_gd    geodetic longitude
%
% IN     r         Radius
%        lat_gc    Geocentric latitude
%        lon_gc    Geocentric longitude
% OPT    ellipsoid a row vector with the form [semimajor axis, eccentricity]
%                  specifying the ellipsoid,
%                  the semimajor axis must use the same units as r  
%        Default is WGS84.

% History: created by Bengt Rydberg 2011-10-31
function [h,lat_gd,lon_gd]=geocentric2geodetic(r,lat_gc,lon_gc,ellipsoid)

if nargin<4
   %WGS84 reference ellipsoid
  ellipsoid = ellipsoidmodels( 'WGS84' );
end 

[x,y,z]           = geocentric2cart(r,lat_gc,lon_gc);

[h,lat_gd,lon_gd] = cart2geodetic(x,y,z,ellipsoid);

