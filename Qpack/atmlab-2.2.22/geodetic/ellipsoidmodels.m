% ELLIPSOIDMODELS   Data for different reference ellipsoids
%
%    Returns data for a number of geodetic reference ellipsoids. The
%    following models are covered:
%       'SphericalEarth'     (radius set as constants('EARTH_RADIUS'))
%       'WGS84'
%       'SphericalVenus'     (radius same as used in ARTS)
%       'SphericalMars'      (radius same as used in ARTS)
%       'SphericalJupiter'   (radius same as used in ARTS)
%
%    The reference ellipsoid is returned as [equatorial radius; eccentricity].
%
% FORMAT   ellipsoid = ellipsoidmodels( [model] ) 
%        
% OUT   ellipsoid  Model ellipsoid.
% OPT   model      Reference ellipsoid model. Default is 'WGS84'. Upper- or
%                  lower case letters do not matter.

% 2011-11-14   Created by Patrick Eriksson.


function ellipsoid = ellipsoidmodels( model ) 
  
if nargin == 0
  model = 'wgs84';
end


switch lower(model)
  
 case 'sphericalearth'
  ellipsoid = [ constants('EARTH_RADIUS') 0 ]';
  
 case 'wgs84'
  % e calculated as:
  % f=1/298.257223563;
  % e=sqrt(f*(2-f)) ];  
  ellipsoid = [ 6378137, 0.081819190842621 ]'; 

 case 'sphericalvenus'
  ellipsoid = [ 6051.8e3 0 ]';
 
 case 'sphericalmars'
  ellipsoid = [ 3389.5e3 0 ]';

 case 'sphericaljupiter'
  ellipsoid = [ 69911e3 0 ]';
  
 otherwise
  error( 'Unknown selection of *model*.' );
  
end

      
      