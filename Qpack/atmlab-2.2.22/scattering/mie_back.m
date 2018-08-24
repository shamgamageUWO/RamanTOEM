% MIE_BACK   Mie backscattering for individual particles   
%
%   Basically an interface to mie.m. The function handles a single
%   combination of refractive index and wavelength, but a multiple of
%   particle sizes are allowed.
%
%   Returns Mie-backscattering cross-sections to be used
%   for e.g. a monostatic radar.
%
% FORMAT  y = mie_back(m,lambda,r)
%
% OUT     y          Mie backscattering cross-section per particle [m2]
%                    (e.g. to be used for a monostatic radar)
%
% IN      m          complex refractive index (imaginary part should 
%                    be positive)   (scalar)
%         lambda     wavelength [m] (scalar)
%         r          particle radius [m] (vector)   

% History: 2010-02-02 Created by Bengt Rydberg

function [y]=mie_back(m,lambda,r)
%                                                                           %&%
rqre_datatype( m, @istensor0 );                                             %&%
rqre_datatype( lambda, @istensor0 );                                        %&%
rqre_alltypes(r, {@isnumeric,@isvector} );                                  %&%
if imag( m ) < 0                                                            %&%
  error( 'Imaginary part of the refractive index must be positive.' );      %&%
end                                                                         %&%

  

x = (2*pi/lambda) * r;
y = zeros( length(r), 1 );

%loop over particle sizes
for i=1:length(x)
  
    result = mie(m, x(i));
    y(i)   = result(4)*pi*r(i)^2;

end

