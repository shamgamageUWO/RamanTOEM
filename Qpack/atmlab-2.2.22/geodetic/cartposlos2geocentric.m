% CARTPOSLOS2GEOCENTRIC   Converts cartesian POS/LOS to spherical coordinates 
%
%   Position is given as (x,y,z), while line-of-sight is given as
%   (dx,dy,dz). The corresponding quantities in polar coordinates are
%   (r,lat,lon) and (za,aa), respectively.
%
%   See *Contents* for defintion of coordinate systems.
%
%   If the optional arguments are given, it is ensured that latitude and
%   longitude are kept constant for zenith or nadir cases, and the longitude
%   and azimuth angle for N-S cases. The optional input shall be interpreted
%   as the [x,y,z] is obtained by moving from [r0,lat0,lon0] in the direction
%   of [za0,aa0].
%
% FORMAT   [r,lat,lon,za,aa] = cartposlos2geocentric(x,y,z,dx,dy,dz,...
%                                                [ppc,lat0,lon0,za0,aa0] )
%        
% OUT   r      Radius.
%       lat    Latitude.
%       lon    Longitude.
%       za     Zenith angle.
%       aa     Azimuth angle.
% IN    x      Coordinate in x dimension.
%       y      Coordinate in y dimension.
%       z      Coordinate in z dimension.
%       dx     LOS component in x dimension.
%       dy     LOS component in y dimension.
%       dz     LOS component in z dimension.
%       ppc    Propagation path constant = r0*sin(za0)
%       lat0   Original latitude
%       lon0   Original longitude
%       za0    Orignal zenith angle
%       aa0    Orignal azimuth angle

% 2011-11-15   Created by Bengt Rydberg.


function [r,lat,lon,za,aa] = cartposlos2geocentric(x,y,z,dx,dy,dz,...
                                                   ppc,lat0,lon0,za0,aa0)

deg2rad = constants( 'DEG2RAD' );
rad2deg = constants( 'RAD2DEG' );


if nargin <= 6
  [r,lat,lon] = cart2geocentric( x, y, z );
else
  [r,lat,lon] = cart2geocentric( x, y, z, lat0, lon0, za0, aa0 );    
end


coslat = cos( deg2rad * lat );
sinlat = sin( deg2rad * lat );
coslon = cos( deg2rad * lon );
sinlon = sin( deg2rad * lon );
dr     = coslat.*coslon.*dx + sinlat.*dz + coslat.*sinlon.*dy;


% LOS angles
if nargin <= 6
  za = rad2deg * acos( dr );
else
  za = rad2deg * asin( ppc ./ r );
end

aa = zeros(size(za));

% FIXME: surely at least some (if not all) cases here can be vectorised

for i = 1 : length(za)

  % Fixes for za with optional input
  if nargin > 6
    if za0(i) < 1e-6  ||  za0(i) > 180-1e-6    % Nadir or zenith
      za(i) = za0(i);
    elseif isnan(za(i))
      za(i) = 90;
    elseif dr(i) < 0              % Expression above gives only za < 90
      za(i) = 180 - za(i);
    end
  end

  % Azimuth angle:
    
  % Take original value if N-S
  if nargin > 6  &&  ( abs(aa0(i)) < 1e-6  ||  abs(aa0(i)-180) < 1e-6 )
    % Check that not lon changed with 180 deg
    if lon(i) == lon0(i)
      aa(i) = aa0(i);
    else
      if abs(aa0(i)) < 1e-6
        aa(i) = 180;
      else
        aa(i) = 0;
      end
    end
  
  % Set to zero for nadir and zenith
  elseif za(i) < 1e-6  ||  za(i) > 180-1e-6 
    aa(i) = 0;
    
  
  % For lat = +- 90 the azimuth angle gives the longitude along which 
  % the LOS goes
  elseif abs( lat(i) ) > 90-1e-8 
    aa(i) = rad2deg * atan2( dy(i), dx(i) );

  %General case
  else
    %
    dlat  = -sinlat(i)*coslon(i)/r(i)*dx(i) + coslat(i)/r(i)*dz(i) - ...
             sinlat(i)*sinlon(i)/r(i)*dy(i);
    dlon  = -sinlon(i)/coslat(i)/r(i)*dx(i) + coslon(i)/coslat(i)/r(i)*dy(i);
    aa(i) = rad2deg * acos( r(i) * dlat / sin( deg2rad * za(i) ) );
    %
    if isnan( aa(i) ) ||  ~isreal( aa(i) )
      if dlat >= 0
        aa(i) = 0;
      else
        aa(i) = 180;
      end
    elseif dlon < 0
      aa(i) = -aa(i);
    end
  end
end

end
