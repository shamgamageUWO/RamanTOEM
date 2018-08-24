% FRESNEL   Fresnel formulas for surface reflection
%
%    The amplitude reflection coefficients for a flat surface can also be
%    calculated (Rv and Rh). Note that these are the coefficients for the
%    amplitude of the wave. The power reflection coefficients are
%    obtained as
%
%       r = abs(R)^2
%    
%    The expressions used are taken from Eq. 3.31 in "Physical principles of
%    remote sensing", by W.G. Rees, with the simplification that that relative
%    magnetic permeability is 1 for both involved media. The theta2 angle is
%    taken from snell.m.
%
%    The refractive index of medium 2  (n2) can be complex. The refractive 
%    index and the dielectric constant, epsilon, are releated as
%
%      n = sqrt(epsilon)
%
%    No expression for theta2 that allows *n1* to be complex has been found.
%
%    If theta2 is found to be complex, it is returned as NaN. This can happen
%    when n1 > n2, and corresponds to a total reflection and there is no
%    transmitted part. Rv and Rh are here set to 1.
%
% FORMAT   [Rv,Rh,theta2] = fresnel(n1,n2,theta1)
%        
% OUT   Rv       Reflection coefficient for vertical polarisation.
%       Rh       Reflection coefficient for horisontal polarisation.
%       theta2   Angle for transmitted part.
%       
% IN    n1       Refractive index for medium of incoming radiation.
%       n2       Refractive index for reflecting medium.
%       theta1   Angle between surface normal and incoming radiation.

% 2004-04-30   Created by Patrick Eriksson.


function [Rv,Rh,theta2] = fresnel(n1,n2,theta1)
%                                                                           %&%
rqre_nargin( 3, nargin );                                                   %&%
% Checks done in snell.m are not repeated                                   %&% 
if imag(n1)<0 | imag(n2)<0                                                  %&%
  error( 'The imaginary part of *n1* and *n2* can not be negative.' );      %&%
end                                                                         %&%


theta2    = snell( n1, n2, theta1 );

DEG2RAD   = constants('DEG2RAD');

costheta1 = cos( DEG2RAD * theta1 );
costheta2 = cos( DEG2RAD * theta2 );

Rv        = (n2.*costheta1-n1.*costheta2)./(n2.*costheta1+n1.*costheta2);
Rh        = (n1.*costheta1-n2.*costheta2)./(n1.*costheta1+n2.*costheta2);
