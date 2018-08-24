% SI2FWHM   Converts standard deviation to FWHM
%
%    The full width at half maximum (FWHM) of a normal distribution is
%    calculated, based on its standard deviation.
%
% FORMAT   w = si2fwhm(si)
%        
% OUT   w    Full width at half maximum.
% IN    si   Standard deviation.

% 2007-11-29   Created by Patrick Eriksson.


function w = si2fwhm(si)
  
w = (2*sqrt(2*log(2))) * si;
