% PLANCK  Planck function
%
% Calculates the Planck function (blackbody radiation) for given frequency 
% and temperature.
% 
%
% FORMAT   BT = planck(f,T)
%
% OUT	   BT = Blackbody radiation.
% IN       f  = frequency
%          T  = Temperature in [K].
%
% See also: i2planckTb

% 2003-10-10 Created by Claudia Emde

function BT = planck(f, T)

planck = constants('PLANCK_CONST');
boltzmann = constants('BOLTZMANN_CONST');
speed_light = constants('SPEED_OF_LIGHT');

a = 2 * planck / speed_light^2;
b = planck / boltzmann;
  
BT =  a * f.^3 ./ ( exp( b*f./T ) - 1 );

end
