% GEOCENTRICPOSLOS2CART converts from spherical POS/LOS to cartesian coordinates
%
% See Contents for a defintion of the geocentric coordinate system. 
% The local LOS angles are defined following the EAST-NORTH-UP system:
%         za    aa
%         90    0   points towards north
%         90    90  points towards east
%         0     aa  points up
% 
% FORMAT  [x,y,z,dx,dy,dz]=geocentricposlos2cart(r,lat,lon,za,az) 
%
% OUT     x    Coordinate in x dimension
%         y    Coordinate in y dimension
%         z    Coordinate in z dimension
%         dx   LOS component in x dimension
%         dy   LOS component in y dimension
%         dz   LOS 
%
% IN      r    Radius 
%         lat  Latitude
%         lon  Longitude
%         za   zenith angle
%         aa   azimuth angle

% History: created by Bengt Rydberg 2011-10-31
function [x,y,z,dx,dy,dz]=geocentricposlos2cart(r,lat,lon,za,aa)

if any( r == 0 )
  error( 'This function is not handling the case of r = 0.' );  
end
rqre_in_range( lat, -90, 90 )
rqre_in_range( lon, -360, 360 )
rqre_in_range( za, 0, 180 )


deg2rad = constants( 'DEG2RAD' );


% For lat = +- 90 the azimuth angle gives the longitude along which the
% LOS goes
%
if abs( lat ) > 90-1e-8
  %
  s = sign( lat );
  %
  x = 0;
  y = 0;
  z = s .* r;
  %
  dz = s .* cos( deg2rad .* za );
  dx = sin( deg2rad .* za );
  dy = dx .* sin( deg2rad .* aa );
  dx = dx .* cos( deg2rad .* aa );

else
  %
  latrad = deg2rad * lat;
  lonrad = deg2rad * lon;
  zarad  = deg2rad * za;
  aarad  = deg2rad * aa;
  clear lat lon za aa;
  %
  coslat = cos( latrad );
  sinlat = sin( latrad );
  coslon = cos( lonrad );
  sinlon = sin( lonrad );
  cosza  = cos( zarad );
  sinza  = sin( zarad );
  cosaa  = cos( aarad );
  sinaa  = sin( aarad );
  clear latrad lonrad zarad aarad
  %
  % As in geocentric2cart, but uses local variables
  x = r .* coslat; 
  y = x .* sinlon;
  x = x .* coslon;
  z = r .* sinlat;  
  %
  dr     = cosza;
  clear cosza;
  dlat   = sinza .* cosaa;            % r-terms cancel out below
  clear cosaa;
  dlon   = sinza .* sinaa ./ coslat;
  clear sinza sinaa;
  %
  dx = coslat.*coslon.*dr - sinlat.*coslon.*dlat - coslat.*sinlon.*dlon;
  dz =         sinlat.*dr +         coslat.*dlat;
  dy = coslat.*sinlon.*dr - sinlat.*sinlon.*dlat + coslat.*coslon.*dlon;
end






