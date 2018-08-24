% P2Z_SIMPLE   Simple conversion from pressures to altitudes
%
%    Pressures are converted to altitudes by assuming that the pressure
%    at 0 m is 1000 hPa, and that the pressure drops with a factor of 10
%    for each 16 km increase in altitude.
%
% FORMAT   z = p2z_simple( p )
%        
% OUT   z   Altitudes [m]
% IN   p   Pressure [Pa]

% 2005-05-11   Created by Patrick Eriksson.

function z = p2z_simple( p )

z = 16e3 * ( 5 - log10(p) );