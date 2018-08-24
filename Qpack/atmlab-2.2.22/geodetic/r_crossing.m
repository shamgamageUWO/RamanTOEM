% R_CROSSING   Calculates the point where a radius is passed
%
%    Calculates where a 3D geometrical propagation path crosses a specified
%    radius (r). The propagation path is specified by giving a starting point
%    and the line-of-sight at that point. If these data are also at hand as
%    Cartesian coordinates (x,y,z,dx,dy,dz), input these as well and the
%    calculations will be quicker.
%
%    Allowed solutions have a distance above zero (ie. l>0, note that the
%    solution of l=0 is rejected).
%
% FORMAT [lat,lon,l,za,aa] = r_crossing(r0,lat0,lon0,za0,aa0,r[,x,y,z,dx,dy,dz])
%        
% OUT   lat   Latitude of crossing point.
%       lon   Longitude of crossing point.
%       l     Distance to crossing point.
%       za    Zenith angle at crossing point
%       aa    Zenith angle at crossing point.
% IN    r0    Radius of starting point.
%       lat   Latitude of starting point.
%       lon   Longitude of starting point.
%       za    Zenith angle at starting point.
%       aa    Azimuth angle at starting point.
%       r     Radius, for which crossing point shall be determined.
% OPT   x     x-cartesian coordinate of starting point.
%       y     y-cartesian coordinate of starting point.
%       z     z-cartesian coordinate of starting point.
%       dx    x-component of line-of-sight.
%       dy    y-component of line-of-sight.
%       dz    z-component of line-of-sight.

% 2012-03-01   Created by Patrick Eriksson.

function [lat,lon,l,za,aa] = r_crossing(r0,lat0,lon0,za0,aa0,r,x,y,z,dx,dy,dz)

  
if nargin < 7
  [x,y,z,dx,dy,dz]=geocentricposlos2cart(r0,lat0,lon0,za0,aa0);
end
  
  
if ( r0 >= r  &  za0 <= 90 )  |  r0*sind(za0) > r
  lat = NaN;
  lon = NaN;
  l   = NaN;
  za  = NaN;
  aa  = NaN; 

else

  p  = x.*dx + y.*dy + z.*dz;
  pp = p .* p;
  q  = x.*x + y.*y + z.*z - r.*r;
  sq = sqrt( pp - q );
  l1 = -p + sq;
  l2 = -p - sq;

  lmin = min( l1, l2 );
  lmax = max( l1, l2 );

  % If r0 equals r solutions just above zero can appear (that
  % shall be rejected). So we pick the biggest solution if lmin is
  % negative or just above zero. 
  l = zeros(size(lmax));
  l(lmin < 1e-6) = lmax(lmin < 1e-6);
  l(lmin >= 1e-6) = lmin(lmin >= 1e-6);
  assert(all(l > 0));  
 
  if nargout <= 3
    RAD2DEG = constants( 'RAD2DEG' );
    lat     = RAD2DEG .* asin( ( z+dz.*l ) ./ r );
    lon     = RAD2DEG .* atan2( y+dy.*l, x+dx.*l );
  else
    [r2,lat,lon,za,aa] = cartposlos2geocentric(x+l.*dx,y+l.*dy,z+l.*dz,dx,dy,dz);
    assert( all(abs(r2-r) < 1e-6) );
  end

end   
end
