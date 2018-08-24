% SNELL   Snell's law
%
%    Calculates the angle of the transmitted wave, according to Snell's law.  
%
%    Snell's law for the case when both *n1* and *n2* have no imaginary part
%    is found in all physics handbooks. 
%
%    The expression for complex *n2* is taken from "An introduction to
%    atmospheric radiation" by K.N. Liou (Sec. 5.4.1.3).
%
%    No expression that allows *n1* to be complex has been found.
%
%    If theta2 is found to be complex, it is returned as NaN. This can happen
%    when n1 > n2, and corresponds to a total reflection and there is no
%    transmitted part.
%
%    The refractive index and the dielectric constant, epsilon, are releated 
%    as
%
%      n = sqrt(epsilon)
%
% FORMAT   theta2 = snell(n1,n2,theta1)
%        
% OUT   theta2   Angle for transmitted part.
% IN    n1       Refractive index for medium of incoming radiation.
%       n2       Refractive index for reflecting medium.
%       theta1   Angle between surface normal and incoming radiation.

% 2010-01-28   Created by Patrick Eriksson.


function theta2 = snell(n1,n2,theta1)
%                                                                           %&%
rqre_nargin( 3, nargin );                                                   %&%
rqre_datatype( n1, @isnumeric );                                            %&%
rqre_datatype( n2, @isnumeric );                                            %&%
rqre_datatype( theta1, @isnumeric );                                        %&%
rqre_element_math( n1, n2 );                                                %&%
rqre_element_math( n1, theta1 );                                            %&%
if real(n1)<=0 | real(n2)<=0                                                %&%
  error( 'The real part of *n1* and *n2* can not be <= 0.' );               %&%
end                                                                         %&%


isr1 = isreal( n1 );
isr2 = isreal( n2 );

DEG2RAD = constants( 'DEG2RAD' );
RAD2DEG = constants( 'RAD2DEG' );


if isr1 & isr2
  theta2 = asin( n1 .* sin( DEG2RAD * theta1 ) ./ n2 );
  if isreal( theta2 )
    theta2 = RAD2DEG * theta2;
  else
    theta2 = NaN;
  end
  
elseif isr1
  mr2  = ( real(n2) ./ n1 ).^2;
  mi2  = ( imag(n2) ./ n1 ).^2;
  sin1 = sin( DEG2RAD * theta1 );
  s2   = sin1 .* sin1; 
  Nr   = sqrt( ( mr2-mi2+s2 + sqrt( (mr2-mi2-s2).^2 + 4*mr2.*mi2 ) ) / 2.0 );
  theta2 = asin( sin1 ./ Nr );
  if isreal( theta2 )
    theta2 = RAD2DEG * theta2;
  else
    theta2 = NaN;
  end
  
else
  error( 'No expression implemented for imaginary *n1*.' );
end
  