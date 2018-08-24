% P2Z_CIRA86    Converts pressure to altitude and temperature
%
%    Converts pressure to altitude and temperature assuming cira86
%    climataology. Linear interpolation between log(pressure),
%    latitude, and day of year is performed.
%
% FORMAT   [Z,T] = p2z_cira86( P , LAT , DOY )
%        
% OUT   Z     Altitude in meter, for all combinations of P, LAT, DOY 
%             Size is [np,nlat,ndoy]
%       T     Temperature in kelvin, for all combinations of P, LAT, DOY 
%             Size is [nz,nlat,ndoy]
% IN    P     Pressure in pascal. Can be a scalar or column vector
%       LAT   Latitude. Can be a scalar or column vector [-90 to 90].
%       DOY   Day of year. Can be a scalar or column vector

% 2007-11-01   Created by Bengt Rydberg

function [z,t]=p2z_cira86(p,lat,doy)
                                                                   %&%
rqre_datatype( p, @istensor1 );                                    %&%
rqre_datatype( lat, @istensor1 );                                  %&%
rqre_datatype( doy, @istensor1 );                                  %&%
if any(doy)>367 | any(doy<1)                                       %&%
  error('doy range is [1,367]')                                    %&%
end                                                                %&%
if any(lat)>90 | any(lat<-90)                                      %&%
   error('latitude range is -90 to 90')                            %&%
end                                                                %&%

% Create a a mjd matching the given doy (ie. the inverse of mjd2doy)
mjd = date2mjd( 2000, 1, 1, 0, 0, 0 ) + doy - 1;


cira86 = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'climatology', 'cira86', ...
                                                               'cira86.z.xml' );

G = gf_artsxml( cira86, 'CIRA86', 'z_field' );

G = atmdata_regrid( G, { p, lat, 0, mjd } );

if length(mjd) > 1
  z = reshape( G.DATA, [size(G.DATA,1), size(G.DATA,2), size(G.DATA,4)] );
else
  z = G.DATA;
end

if nargout > 1
  cira86 = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'climatology', 'cira86', ...
                                                               'cira86.t.xml' );
  G = gf_artsxml( cira86, 'CIRA86', 't_field' );

  G = atmdata_regrid( G, { p, lat, 0, mjd } );

  if length(mjd) > 1
    t = reshape( G.DATA, [size(G.DATA,1), size(G.DATA,2), size(G.DATA,4)] );
  else
    t = G.DATA;
  end
end  