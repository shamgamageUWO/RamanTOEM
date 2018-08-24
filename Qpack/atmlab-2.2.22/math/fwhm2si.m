% FWHM2SI   Converts FWHM to standard deviation
%
%    The standard deviation of a normal distribution is calculated,
%    calculated, based on its full width at half maximum (FWHM) .
%
% FORMAT   si = fwhm2si(w)
%        
% OUT   si   Standard deviation.
% IN    w    Full width at half maximum.

% 2007-11-29   Created by Patrick Eriksson.


function si = fwhm2si(w)
  
si = w ./ (2*sqrt(2*log(2)));

