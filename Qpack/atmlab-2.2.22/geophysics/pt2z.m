% PT2Z   Hydrostatic altitudes
%
%    Calculates altitudes fulfilling hydrostatic equilibrium, based on
%    vertical profiles of pressure, temperature and water vapour. Pressure
%    and altitude of a reference point must be specified.
%
%    Molecular weights and gravitational constants are hard coded and 
%    function is only valid for the Earth.
%
%    As the gravitation changes with altitude, an iterative process is
%    needed. The accuracy can be controlled by *z_acc*. The calculations
%    are repeated until the max change of the altitudes is below *z_acc*. If
%    z_acc<0, the calculations are run twice, which should give an accuracy
%    better than 1 m.
%
% FORMAT   z = pt2z( p, t, h2o, p0, z0 [,lat,z_acc,refell] )
%        
% OUT   z         Altitudes [m].
% IN    p         Column vector of pressures [Pa].
%       t         Column vector of temperatures [K].
%       h2o       Water vapour [VMR]. Vector or a scalar, e.g. 0. 
%       p0        Pressure of reference point [Pa].
%       z0        Altitude of reference point [m].
%       lat       Latitude. Default is 45.
%       z_acc     Accuracy for z. Default is -1.
%       ellipsoid Reference ellipsoid data, see *ellipsoidmodels*. 
%                 Default is data matching WGS84.

% 2005-05-11   Created by Patrick Eriksson.


function z = pt2z(p,t,h2o,p0,z0,varargin)
%
[lat,z_acc,ellipsoid] = optargs( varargin, { 45, -1, NaN } );
%
if isnan(ellipsoid)
  ellipsoid = ellipsoidmodels('wgs84');
end
                                                                            %&%
rqre_nargin( 5, nargin );                                                   %&%
rqre_datatype( p, @istensor1 );                                             %&%
rqre_datatype( t, @istensor1 );                                             %&%
rqre_datatype( h2o, @istensor1 );                                           %&%
rqre_datatype( p0, @istensor0 );                                            %&%
rqre_datatype( z0, @istensor0 );                                            %&%
rqre_datatype( lat, @istensor0 );                                           %&%
np = length( p );
if length(t) ~= np                                                          %&%
  error('The length of *p* and *t* must be identical.');                    %&%
end                                                                         %&%
if ~( length(h2o) == np  |  length(h2o) == 1 )                              %&%
  error('The length of *h2o* must be 1 or match *p*.');                     %&%
end                                                                         %&%
if p0 > p(1)  |  p0 < p(np)                                                 %&%
  error('Reference point (p0) can not be outside range of *p*.');           %&%
end                                                                         %&%


%= Expand *h2o* if necessary
%
if  length(h2o) == 1
  h2o = repmat( h2o, np, 1 );
end


%= Make rough estimate of *z*
%
z = p2z_simple( p );
z = shift2refpoint( p, z, p0, z0 );


%= Set Earth radius and g at z=0
%
re = ellipsoidradii( ellipsoid, lat );
g0 = lat2g0( lat );


%= Gas constant and molecular weight of dry air and water vapour 
%
r  = constants( 'GAS_CONST' );
md = 28.966;
mw = 18.016;
%
k  = 1-mw/md;        % 1 - eps         
rd = 1e3 * r / md;   % Gas constant for 1 kg dry air


%= How to end iterations
%
if z_acc < 0
  niter = 2;
else
  niter = 99;
end  

for iter = 1:niter

  zold = z;
  
  g = z2g( re, g0, z );

  for i = 1 : (np-1)
      
	gp  = ( g(i) + g(i+1) ) / 2;
  
	%-- Calculate average water VMR (= average e/p)
	hm  = (h2o(i)+h2o(i+1)) / 2;
  
	%--  The virtual temperature (no liquid water)
	tv = (t(i)+t(i+1)) / ( 2 * (1-hm*k) );   % E.g. 3.16 in Wallace&Hobbs
  
	%-- The change in vertical altitude from i to i+1 
	dz = rd * (tv/gp) * log( p(i)/p(i+1) );
	z(i+1) = z(i) + dz;
      
  end
  
  %-- Match the altitude of the reference point
  z = shift2refpoint( p, z, p0, z0 );

  if z_acc >= 0 & max(abs(z-zold)) < z_acc
    break;
  end
  
end

return
%----------------------------------------------------------------------------

function z = shift2refpoint( p, z, p0, z0 )
  %
  z = z - ( interpp( p, z, p0 ) - z0 );
  %
return


function g = z2g(r_geoid,g0,z)
  %
  g = g0 * (r_geoid./(r_geoid+z)).^2;
  %
return

% Expression below taken from Wikipedia page "Gravity of Earth", that is stated
% to be: International Gravity Formula 1967, the 1967 Geodetic Reference System
% Formula, Helmert's equation or Clairault's formula.
function g0 = lat2g0(lat)
  %
  x  = abs( lat );
  g0 = 9.780327 * ( 1 + 5.3024e-3*sind(x).^2 + 5.8e-6*sind(2*x).^2 );
  %
return

