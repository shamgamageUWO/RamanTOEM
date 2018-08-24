% BACKCOEF2DBZ   Radar dBZ reflectivity.
%
%    Converts backscattering coefficient to decibels of Z, where Z is the
%    equivalent reflectivity.
%
% FORMAT  Ze = backcoef2dBZ(lambda,b)
%
% OUT     Ze         10*log10 of radar equivalent reflectivity 
%                    (defined w.r.t. liquid water) [mm6/m3] 
%
% IN      lambda     wavelength  [m] (scalar)
%         b          backscattering coefficient [1/m] (any numeric)
         
% History: 2010-02-02 Created by Bengt Rydberg

function Ze = backcoef2dBZ( lambda, b )
%                                                                           %&%
rqre_datatype( lambda, @istensor0 );                                        %&%
rqre_in_range( lambda, 0.3e-3, 1 );                                         %&%
rqre_datatype( b, {@isnumeric} );                                           %&%


%calculate dielectric factor of water
c       = constants('SPEED_OF_LIGHT');
nwater  = sqrt( eps_water_liebe93(c/lambda,273.15) );
Kwater2 = ( abs( (nwater.^2-1)./ (nwater.^2+2) ) ).^2;

Ze = 10*log10( (1e18*lambda^4/Kwater2/pi^5) * b );

