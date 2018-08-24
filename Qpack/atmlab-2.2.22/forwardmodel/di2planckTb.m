% DI2PLANCKTB   Planck Tb of jacobians and higher Stokes components
%
%     Converts intensities to brigthness temperatures by "inverting" the Planck
%     function. The function *i2planckTb* performs the same operation, but this
%     function handles also conversion of jacobians and higher Stokes
%     components. These later quantities can be seen as differences between two
%     radiance values, and can not be converted to Tb as the spectrum (*i*).
%
%     Use *i2planckTb* if only a spectrum shall be converted.
%
% FORMAT   [tb,dtb] = di2planckTb(f,i,di)
%
% OUT      tb    Brightness temperature for *i* [K].
% OUT      dtb   Brightness temperature for *di*.
% IN       f     Frequencies [Hz]. Must be a column vector.
%          i     Intensities for spectrum [W/sr*m^2*Hz]. Must be a column 
%                vector.
%          di    Jacobian or higher Stokes components, in radiance. Can be a
%                matrix, where each row corresponds to a frequency.
%
% See also: i2planckTb, planck

% 2010-12-15   Created by Patrick Eriksson.


function [tb,dtb] = di2planckTb(f,i,di)

rqre_datatype( f, @istensor1 );                                             %&%
rqre_datatype( i, @istensor1 );                                             %&%
rqre_datatype( di, @istensor2 );                                            %&%
if length(f) ~= length(i)                                                   %&%
  error( 'The vectors *f* and *i* must have the same length.' );            %&%
end                                                                         %&%
if length(f) ~= size(di,1)                                                  %&%
  error( ...                                                                %&%
   'The length of vector *f* and number of rows in *di* must be equal.' );  %&%
end                                                                         %&%

planck = constants('PLANCK_CONST');
boltzmann = constants('BOLTZMANN_CONST');
speed_light = constants('SPEED_OF_LIGHT');

a = planck/boltzmann;
b = 2*planck/speed_light^2;

tb = a * f ./ log((b*f.^3)./i + 1 );

dtb = repmat( tb.^2./(a*i.*f.*(1+i./(b*f.^3))), 1, size(di,2) ) .* di;

end
