% I2PLANCKTB   Planck brightness temperature
%
%          Convert intensities to brigthness temperatures by "inverting" the
%          Planck function.
%
%          The frequency and intensity vectors/matrices must have the 
%          same size.
%
% FORMAT   tb = i2planckTb(i,f)
%
% OUT      tb   brightness temperatures [K]
% IN       i    intensities [W/m^2Hz]
%          f    frequencies [Hz]
%
% See also: planck, di2planckTb

% 2002-12-12   Created by Claudia Emde.


function tb = i2planckTb(i,f)

planck = constants('PLANCK_CONST');
boltzmann = constants('BOLTZMANN_CONST');
speed_light = constants('SPEED_OF_LIGHT');

a = planck/boltzmann;
b = 2*planck/speed_light^2;

tb = a * f ./ log((b*f.^3)./i + 1 );

end
