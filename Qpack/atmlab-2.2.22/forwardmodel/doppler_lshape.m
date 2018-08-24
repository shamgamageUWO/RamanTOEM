% DOPPLER_LSHAPE   Doppler line shape
%
%    Calculates the line shape caused by the molecular thermal motion,
%    the Doppler line shape. Note that the width is defined HWHM (half
%    width at halv maximum).
%
% FORMAT   l = doppler_lshape( f, f0, dd )
%        
% OUT   l    Line shape. Dimensions [f,dd]. 
% IN    f    Frequency vector.
%       f0   Centre frequency. Only scalar input allowed.
%       dd   Doppler line width, given as FWHM/2. See *doppler_width*.
%            Can be a vector. 

% 2006-11-21   Created by Patrick Eriksson.


function l = doppler_lshape(f,f0,dd)

l = zeros( length(f), length(dd) );

a = sqrt( pi );

f = vec2col( f );

dd = dd / sqrt(log(2));

for i = 1 : length(dd)

  l(:,i) = exp(-((f-f0)/dd(i)).^2) / (a*dd(i));

end