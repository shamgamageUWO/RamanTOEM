% ELLIPSOIDRADII   Different geodetic radii of a reference ellipsoid
%
%    The calculation expressions are taken from radiigeo.pdf, found in the
%    same folder as this function.
%
%    Please note that geoDETIC latitudes are used. Use *ellipsoidradii* for
%    geocentric latitudes.
%
% FORMAT   r = ellipsoidradii( ellipsoid, lat_gd )
%    
% OUT   r          Radii. See above.
% IN    ellipsoid  Model ellipsoid as returned by *ellipsoidmodels*.
%       lat_gd     Geodetic latitudes.

% 2011-11-14   Created by Patrick Eriksson.


function r = ellipsoidradii2(ellipsoid,lat_gd)

% Check input                                                          %&%
rqre_datatype( ellipsoid, @isvector );                                 %&%
if length(ellipsoid) ~= 2                                              %&%
 error( 'The argument *ellipsoid* must be a vector of length 2' );     %&%
end                                                                    %&%
rqre_in_range( ellipsoid(2), 0, 1, 'element 2 of ellipsoid' );         %&%
rqre_datatype( lat_gd, @isnumeric );                                   %&%


% Spherical case (all radii the same)
if ellipsoid(2) == 0
  %
  r = repmat( ellipsoid(1), size(lat_gd) );

% The actual radius  
else
  %
  e2   = ellipsoid(2)^2;
  sin2 = sind(lat_gd).^2;
  %
  r = ellipsoid(1) * sqrt((1-e2).^2*sin2+cosd(lat_gd).^2) ./ sqrt(1-e2*sin2);

end