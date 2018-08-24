% LAT_CROSSING   Calculates the point where a latitude is passed
%
%    Calculates where a 3D geometrical propagation path crosses a specified
%    latitude (lat). The propagation path is specified by giving a starting
%    point and the line-of-sight at that point. If these data are also at hand
%    as Cartesian coordinates (x,y,z,dx,dy,dz), input these as well and the
%    calculations will be quicker.
%
%    Allowed solutions have a distance above zero (ie. l>0, note that the
%    solution of l=0 is rejected).
%
% FORMAT [r,lon,l,za,aa] = lat_crossing(r0,lat0,lon0,za0,aa0,lat
%                                                          [,x,y,z,dx,dy,dz])
%        
% OUT   r     Radius of crossing point.
%       lon   Longitude of crossing point.
%       l     Distance to crossing point.
%       za    Zenith angle at crossing point
%       aa    Zenith angle at crossing point.
% IN    r0    Radius of starting point.
%       lat   Latitude of starting point.
%       lon   Longitude of starting point.
%       za    Zenith angle at starting point.
%       aa    Azimuth angle at starting point.
%       lat   Latitude, for which crossing point shall be determined.
% OPT   x     x-cartesian coordinate of starting point.
%       y     y-cartesian coordinate of starting point.
%       z     z-cartesian coordinate of starting point.
%       dx    x-component of line-of-sight.
%       dy    y-component of line-of-sight.
%       dz    z-component of line-of-sight.

% 2012-03-01   Created by Patrick Eriksson.

function [r,lon,l,za,aa] = lat_crossing(r0,lat0,lon0,za0,aa0,lat,x,y,z,dx,dy,dz)

  
if nargin < 7
  [x,y,z,dx,dy,dz]=geocentricposlos2cart(r0,lat0,lon0,za0,aa0);
end
  

% For za=0/180 and lat0+-90 there is no solution
if za0 == 0  |  za0 == 180  |  abs(lat) == 90
  l = -1;

% The expressions below can not be used for lat=0
elseif abs(lat) < 1e-7    % lat=1e-8 is tested not work 
  l = -z / dz;
  
else
  
  t2     = tand(lat)^2;
  a      = t2 * ( dx*dx + dy*dy ) - dz*dz;
  b      = 2 * ( t2 * ( x*dx + y*dy ) - z*dz );
  c      = t2 * ( x*x + y*y ) - z*z;
  bb     = b*b;
  ac4    = 4*a*c;
  
  % Check if a real solution is possible
  if ac4 > bb
    l = -1;
  else
    d    = -0.5*b/a;
    e    = -0.5*sqrt(b*b-4*a*c)/a;      
    l1   = d + e;
    l2   = d - e;

    % If both l1 and l2 are > 0, we want theoretically the smallest
    % value. However, with lat=lat0 the "zero solution" can deviate
    % slightly from zero due to numerical issues, and it is not just to
    % pick the smallest positive value. As a solution, don't except a
    % final l below 1e-6 if not both l1 and l2 are inside [0,1e-6].
    lmin = min( l1, l2 );
    lmax = max( l1, l2 );
    if( lmin >= 0  && lmax < 1e-6 )
      l = lmax;
    else
      if( lmin > 1e-6 ) 
        l = lmin;
      elseif( lmax > 1e-6 )
        l = lmax;
      else
        l = -1;
      end
    end
  end
end


if l <= 0
  r   = NaN;
  lon = NaN;
  l   = NaN;
  za  = NaN;
  aa  = NaN; 

else
 
  if nargout <= 3
    RAD2DEG = constants( 'RAD2DEG' );
    xp      = x+dx*l;
    yp      = y+dy*l;
    r       = sqrt( xp^2 + yp^2 + (z+dz*l)^2 );
    lon     = RAD2DEG * atan2( yp, xp );
  else
    [r,lat2,lon,za,aa] = cartposlos2geocentric(x+l*dx,y+l*dy,z+l*dz,dx,dy,dz);
    assert( abs(lat2-lat) < 1e-6 );
  end
  
end
