% GEOMTANPOINT   Geometrical tangent point
%
%    Calculates the 3D geometrical tangent point for arbitrary reference
%    ellipsiod. That is, a spherical planet is not assumed. The tangent
%    point is thus defined as the point closest to the ellipsoid (not as the
%    ppoint with za=90).
%   
%    Geocentric coordinates are used for both sensor and tangent point
%    positions.
% 
%    The algorithm used for non-spherical cases is derived by Nick Lloyd at
%    University of Saskatchewan, Canada (nick.lloyd@usask.ca), and is part of
%    the operational code for both OSIRIS and SMR on-board- the Odin
%    satellite.
% 
% FORMAT  [rt,latt,lont] = geomtanpoint( ellipsoid, r, lat, lon, za, aa )
%
% OUT   rt         Radius of tangent point.
%       latt       Latitude of tangent point.
%       lont       Longitude of tangent point.
% IN    ellipsoid  Model ellipsoid as returned by *ellipsoidmodels*.
%       r          Radius of sensor position.
%       lat        Latitude of sensor position.
%       lon        Longitude of sensor position.
%       za         Zenith angle of sensor line-of-sight.
%       aa         Azimuth angle of sensor line-of-sight.

% 2012-02-10 Created by Patrick Eriksson

function [rt,latt,lont] = geomtanpoint( ellipsoid, r, lat, lon, za, aa )

  
% Check input                                                          %&%
rqre_datatype( ellipsoid, @isvector );                                 %&%
if length(ellipsoid) ~= 2                                              %&%
 error( 'The argument *ellipsoid* must be a vector of length 2' );     %&%
end                                                                    %&%
rqre_in_range( ellipsoid(2), 0, 1, 'element 2 of ellipsoid' );         %&%
rqre_datatype( r, @istensor0 );                                        %&%
rqre_datatype( lat, @istensor0 );                                      %&%
rqre_datatype( lon, @istensor0 );                                      %&%
rqre_datatype( za, @istensor0 );                                       %&%
rqre_datatype( aa, @istensor0 );                                       %&%
% Values of r, lat, lon, za and aa checked by geocentricposlos2cart    %&%

[x,y,z,dx,dy,dz] = geocentricposlos2cart( r, lat, lon, za, aa );


%- Spherical planet
%
if ellipsoid(2) < 1e-7
   
  ppc = r * sind( abs(za) );
  
  l_tan = sqrt( r*r - ppc*ppc );
   
  [rt,latt,lont] = cart2geocentric( x+dx*l_tan, y+dy*l_tan, z+dz*l_tan );
 
  
%- Ellipsoidal planet
%
else
  
  % Equatorial and polar radii squared:
  a2 = ellipsoid(1)^2;
  b2 = a2 * ( 1 - ellipsoid(2)^2 ); 
  
  X = [x,y,z]';
  
  xunit = [dx,dy,dz]';
  
  zunit = cross( xunit, X );
  zunit = zunit / norm(zunit);
 	
  yunit = cross( zunit, xunit );
  yunit = yunit / norm(yunit);
  
  w11 = xunit(1);
  w12 = yunit(1);
  w21 = xunit(2);
  w22 = yunit(2);
  w31 = xunit(3);
  w32 = yunit(3);
  yr  = dot( X, yunit );
  xr  = dot( X, xunit );
 	   
  A = (w11*w11 + w21*w21)/a2 + w31*w31/b2;
  B = 2.0*((w11*w12 + w21*w22)/a2 + (w31*w32)/b2);
  C = (w12*w12 + w22*w22)/a2 + w32*w32/b2;
 	
  if B == 0.0
    xx = 0.0;
  else 
    K = -2.0*A/B;
    factor = 1.0/(A+(B+C*K)*K);
    xx = sqrt(factor);
    yy = K*x;
  end 
 	
  dist1 = (xr-xx)*(xr-xx) + (yr-yy)*(yr-yy);
  dist2 = (xr+xx)*(xr+xx) + (yr+yy)*(yr+yy);
 	
  if dist1 > dist2
    xx = -xx;
  end

  [rt,latt,lont] = cart2geocentric( w11*xx + w12*yr, ...
                                    w21*xx + w22*yr, ...
                                    w31*xx + w32*yr );
end


  
