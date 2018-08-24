% CART2GEODETIC    converts from cartesian to a geodetic coordinates
%
%   The geodetic coordinates refer to the reference ellipsoid 
%   specified by input ellipsoid. 
%   See Contents for a defintion of the geocentric coordinate system.
%
% FORMAT [h, lat, lon] = cart2geodetic(x,y,z[,ellipsoid]) 
%
% OUT    h    Geodetic height (height above the reference ellipsoid)
%        lat  Geodetic latitude
%        lon  Geodetic longitude
%
% IN     x    Coordinate in x dimension
%        y    Coordinate in y dimension
%        z    Coordinate in z dimension
% OPT    ellipsoid   a row vector with the form [semimajor axis, eccentricity]
%                    specifying the ellipsoid,
%                    Default is WGS84.

% History: created by Bengt Rydberg 2011-10-31

function [h, lat, lon] = cart2geodetic(x,y,z,ellipsoid)

if nargin<4
  %WGS84 reference ellipsoid
  ellipsoid = ellipsoidmodels( 'WGS84' );
end 

rad2deg = constants( 'RAD2DEG' );
%longitude
lon=atan2(y,x)*rad2deg;

% Latitude
B0=atan2(z,sqrt(x.^2+y.^2));
B=ones(size(B0));
e2=ellipsoid(2)^2;
while(any(abs(B-B0)>1e-10))
    N=ellipsoid(1)./sqrt(1-e2*sin(B0).^2);
    h=sqrt(x.^2+y.^2)./cos(B0)-N;
    B=B0;
    B0=atan((z./sqrt(x.^2+y.^2)).*(1-e2*N./(N+h)).^(-1));
end
lat=B*rad2deg;



