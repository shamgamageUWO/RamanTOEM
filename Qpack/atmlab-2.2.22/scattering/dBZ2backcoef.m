% DBZ2BACKCOEF   "Inverting" radar dBZ reflectivity.
%
%    Converts equivalent radar reflectivity to backscattering coefficient.
%    The "inverse" of backcoef2dBZ.
%
% FORMAT  b = dBZ2backcoef( lambda, Ze )
%
% OUT     b          backscattering coefficient [1/m]
% IN      lambda     wavelength  [m] (scalar)
%         Ze         10*log10 of radar equivalent reflectivity 
%                    (defined w.r.t. liquid water) [mm6/m3] 
%
         
% History: 2010-02-25 Created by Patrick Eriksson

function b = dBZ2backcoef( lambda, Ze )
%                                                                           %&%
rqre_datatype( lambda, @istensor0 );                                        %&%
rqre_in_range( lambda, 0.3e-3, 1 );                                         %&%
rqre_datatype( Ze, {@isnumeric} );                                          %&%

%- Use sister function to get relationship to dBZ
bref = 1e-6;
c = backcoef2dBZ( lambda, bref );

b = bref * 10.^( (Ze-c)/10 );
