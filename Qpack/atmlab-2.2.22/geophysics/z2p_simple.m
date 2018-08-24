% Z2P_SIMPLE   Simple conversion from altitudes to pressures
%
%    Altitudes are converted to pressures by assuming that the pressure
%    at 0 m is 1000 hPa, and that the pressure drops with a factor of 10
%    for each 16 km increase in altitude.
%
% FORMAT   p = z2p_simple( z )
%        
% OUT   p   Pressure [Pa]
% IN    z   Altitudes [m]

% 2004-09-26   Created by Patrick Eriksson.

function p = z2p_simple( z )

p = 10.^( 5 - z/16e3 );