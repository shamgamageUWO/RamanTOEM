% LON_CROSSING   Calculates the point where a longitude is passed
%
%    Calculates where a 3D geometrical propagation path crosses a specified
%    longitude (lon). The propagation path is specified by giving a starting
%    point and the line-of-sight at that point. If these data are also at hand
%    as Cartesian coordinates (x,y,z,dx,dy,dz), input these as well and the
%    calculations will be quicker.
%
%    Allowed solutions have a distance above zero (ie. l>0, note that the
%    solution of l=0 is rejected).
%
% FORMAT [r,lat,l,za,aa] = lon_crossing(r0,lat0,lon0,za0,aa0,lon
%                                                          [,x,y,z,dx,dy,dz])
%        
% OUT   r     Radius of crossing point.
%       lat   Latitude of crossing point.
%       l     Distance to crossing point.
%       za    Zenith angle at crossing point
%       aa    Zenith angle at crossing point.
% IN    r0    Radius of starting point.
%       lat   Latitude of starting point.
%       lon   Longitude of starting point.
%       za    Zenith angle at starting point.
%       aa    Azimuth angle at starting point.
%       lon   Longitude, for which crossing point shall be determined.
% OPT   x     x-cartesian coordinate of starting point.
%       y     y-cartesian coordinate of starting point.
%       z     z-cartesian coordinate of starting point.
%       dx    x-component of line-of-sight.
%       dy    y-component of line-of-sight.
%       dz    z-component of line-of-sight.

% 2012-03-01   Created by Patrick Eriksson.

function [r,lat,l,za,aa] = lon_crossing(r0,lat0,lon0,za0,aa0,lon,x,y,z,dx,dy,dz)

  
if nargin < 7
  [x,y,z,dx,dy,dz]=geocentricposlos2cart(r0,lat0,lon0,za0,aa0);
end
  
% Catch cases that needs special attention
if lon == lon0  |  za0 == 0  |  za0 == 180  |  aa0 == 0  |  abs(aa0) == 180
  l = -1;
else
  tanlon = tand( lon );
  l      = ( y - x*tanlon ) / ( dx*tanlon - dy );
end


if l <= 0 
  r   = NaN;
  lat = NaN;
  l   = NaN;
  za  = NaN;
  aa  = NaN; 

else
  
  if nargout <= 3
    zp  = z + dz*l;
    r   = sqrt( (x+dx*l)^2 + (y+dy*l)^2 + zp^2 );
    lat = asind( zp / r );
  else
    [r,lat,lon2,za,aa] = cartposlos2geocentric(x+l*dx,y+l*dy,z+l*dz,dx,dy,dz);
    assert( abs(lon2-lon) < 1e-6 );
  end
end

