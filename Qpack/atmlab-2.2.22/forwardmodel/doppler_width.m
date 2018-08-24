% DOPPLER_WIDTH   Doppler line shape width
%
%    The Doppler width is here defined as FWHM/2. That is, half
%    width at half maximum (HWHM). More precisely, it is calculated as
%
%       dd = sqrt(log(2)) * f0/c * sqrt(2*R*t/m)
%
% FORMAT   dd = doppler_width( m, f0, t )
%        
% OUT   dd   Doppler width, for each temperature.
% IN    m    Molecular weight. For example 48 for ozone.
%       f0   Centre frequency. Only scalar input allowed.
%       t    Temperature. Can be a vector.

% 2006-11-21   Created by Patrick Eriksson.


function dd = doppler_width(m,f0,t)

c = constants( 'SPEED_OF_LIGHT' );

r = 8.314e3;

a = sqrt( log(2) ) / c;

dd = (a*f0) .* sqrt( (2*r/m) * t );