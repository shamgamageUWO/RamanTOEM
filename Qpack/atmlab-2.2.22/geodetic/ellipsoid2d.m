% ELLIPSOID2D   Approximate ellipsoid for 2D calculations
%
%    Determines an approximate reference ellipsoid following an orbit track.
%    The new ellipsoid is determined simply, by determining the radius at the
%    maximum latitude and from this value calculate a new eccentricity.
%    The orbit is specified by giving the orbit inclination, that is
%    normally a value around 100 deg for polar sun-synchronous orbits.
%
% FORMAT   r = ellipsoid2d( ellipsoid, orbitinc )
%    
% OUT   ellipsoid  Modified ellipsoid vector.
% IN    ellipsoid  Model ellipsoid as returned by *ellipsoidmodels*.
%       orbitinc   Orbit inclination. See above.

% 2012-02-06   Created by Patrick Eriksson.


function ellipsoid = ellipsoid2d(ellipsoid,orbitinc)

% Check input                                                          %&%
rqre_datatype( ellipsoid, @isvector );                                 %&%
if length(ellipsoid) ~= 2                                              %&%
 error( 'The argument *ellipsoid* must be a vector of length 2' );     %&%
end                                                                    %&%
rqre_in_range( ellipsoid(2), 0, 1, 'element 2 of ellipsoid' );         %&%
rqre_datatype( orbitinc, @isscalar );                                  %&%
rqre_in_range( orbitinc, 0, 180, 'orbitinc' );                         %&%


% Radius at max latitude
%
rp = ellipsoidradii( ellipsoid, orbitinc );


% Calculate new eccentricity
%
ellipsoid(2) = sqrt( 1 - (rp /ellipsoid(1))^2 );