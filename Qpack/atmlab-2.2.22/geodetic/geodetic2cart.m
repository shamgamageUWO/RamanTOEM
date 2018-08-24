% GEODETIC2CART   converts from geodetic to a geocentric cartesian coordinates
%
%   The geodetic coordinates refer to the reference ellipsoid 
%   specified by input ellipsoid. 
%
%   See CART2GEOCENTRIC for a defintion of the geocentric coordinate system.
%
% FORMAT [x, y, z] = geodetic2cart(h,lat,lon[,ellipsoid])
% 
% OUT    x    Coordinate in x dimension
%        y    Coordinate in y dimension
%        z    Coordinate in z dimension
%
% IN     h         Geodetic height (height above the reference ellipsoid)
%        lat       Geodetic latitude
%        lon       Geodetic longitude
% OPT    ellipsoid a vector with the form [semimajor axis; eccentricity]
%                  specifying the ellipsoid. Default is WGS84.

% History: created by Bengt Rydberg 2011-10-31

function [x, y, z] = geodetic2cart(h,lat,lon,ellipsoid)

if nargin<4
  ellipsoid = ellipsoidmodels( 'WGS84' );
end 

a      = ellipsoid(1);
e2     = ellipsoid(2) ^ 2;
sinphi = sind( lat );
cosphi = cosd( lat );
N      = a ./ sqrt(1 - e2 * sinphi.^2);
x      = (N + h) .* cosphi .* cosd(lon);
y      = (N + h) .* cosphi .* sind(lon);
z      = (N*(1 - e2) + h) .* sinphi;

