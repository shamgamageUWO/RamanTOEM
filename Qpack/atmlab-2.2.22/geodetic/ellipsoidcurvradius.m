% ELLIPSOIDCURVRADIUS   Sets ellispoid to local curvature radius
%
%    Calculates the curvature radius for the given latitude and azimuth
%    angle, and uses this to set a spherical reference ellipsoid
%    suitable for 1D calculations. The curvature radius is a better
%    local approximation than using the local ellipsoid radius.
%
%    The calculation expressions are taken from radiigeo.pdf, found in the
%    same folder as this function.
%
%    For exact result the geoDETIC latitude shall be used. 
%
% FORMAT   ellipsoid = ellipsoidcurvradius( ellipsoid, lat_gd, azimuth )
%    
% OUT   ellipsoid  Modified ellipsoid.
% IN    ellipsoid  Model ellipsoid as returned by *ellipsoidmodels*.
%       lat_gd     Geodetic latitude.
%       azimuth    Azimuthal angle (angle from NS plane). If given curvature
%                  radii are returned, see above

% 2011-11-14   Created by Patrick Eriksson.


function ellipsoid = ellipsoidcurvradius(ellipsoid,lat_gd,azimuth)

% Check input                                                          %&%
rqre_datatype( ellipsoid, @isvector );                                 %&%
if length(ellipsoid) ~= 2                                              %&%
 error( 'The argument *ellipsoid* must be a vector of length 2' );     %&%
end                                                                    %&%
rqre_in_range( ellipsoid(2), 0, 1, 'element 2 of ellipsoid' );         %&%
rqre_datatype( lat_gd, @isscalar );                                    %&%
rqre_datatype( azimuth, @isscalar );                                   %&%


% If spherical, nothng to do
if ellipsoid(2) > 0
  %
  e2    = ellipsoid(2)^2;
  aterm = 1 - e2 * sind(lat_gd).^2;
  %
  rn = 1 ./ sqrt(aterm);
  rm = (1-e2) * (rn ./ aterm );
  %
  ellipsoid(1) = ellipsoid(1) ./ ( cosd(azimuth)^2./rm + sind(azimuth)^2./rn );
  ellipsoid(2) = 0;
end