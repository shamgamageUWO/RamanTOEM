% ELLIPSOIDRADII   Geocentric radius of a reference ellipsoid
%
%    Gives the distance from the Earth's centre and the reference ellipsoid
%    as a function of geoCENTRIC latitude. 
%
%    To obtain the radii for geoDETIC latitude, use *ellipsoidradii2*.
%
% FORMAT   r = ellipsoidradii( ellipsoid, lat_gd )
%    
% OUT   r          Radii. See above.
% IN    ellipsoid  Model ellipsoid as returned by *ellipsoidmodels*.
%       lat_gd     Geocentric latitudes.

% 2012-02-06   Created by Patrick Eriksson.


function r = ellipsoidradii(ellipsoid,lat)

% Check input                                                          %&%
rqre_datatype( ellipsoid, @isvector );                                 %&%
if length(ellipsoid) ~= 2                                              %&%
 error( 'The argument *ellipsoid* must be a vector of length 2' );     %&%
end                                                                    %&%
rqre_in_range( ellipsoid(2), 0, 1, 'element 2 of ellipsoid' );         %&%
rqre_datatype( lat, @isnumeric );                                      %&%


% Spherical case (all radii the same)
if ellipsoid(2) == 0
  %
  r = repmat( ellipsoid(1), size(lat) );

% 
else
  % A re-arranged form of the follwing expression is used:
  % r = ab/sqrt(b^2*cos(lat)^2+a^2*sin(lat)^2)
  %
  c = 1 - ellipsoid(2)^2;
  b = ellipsoid(1) * sqrt( c );
  %  
  r = b ./ sqrt( c*cosd(lat).^2 + sind(lat).^2 );

end