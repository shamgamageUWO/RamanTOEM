% PLANCK_WLENGTH  Planck function, as a function if wavelength
%
% Calculates the Planck function (blackbody radiation) for given wavelength 
% and temperature.
% 
% FORMAT   BT = planck_wlength(la,T)
%
% OUT	   BT = Blackbody radiation.
% IN       la = wavelength in [m]
%          T  = Temperature in [K].

% 2003-10-27 Created by Patrick Eriksson

function BT = planck_wlength( la, T )

planck = constants('PLANCK_CONST');
boltzmann = constants('BOLTZMANN_CONST');
speed_light = constants('SPEED_OF_LIGHT');

a = 2 * planck * speed_light^2;
b = planck * speed_light / boltzmann;
  
BT =  a ./ la.^5 ./ ( exp( b./(la.*T) ) - 1 );
