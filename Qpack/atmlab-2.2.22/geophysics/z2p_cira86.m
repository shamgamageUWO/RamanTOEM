% Z2P_CIRA86    Converts altitude to pressure and temperature
%
%    Converts altitude to pressure and temperature assuming cira86
%    climataology. Linear interpolation between log(pressure),
%    latitude, and day of year is performed.
%
%    The function optionally returns the gridded fields for cira 86z and t.
%    This is useful if you need to call Z2P_CIRA86 very often.
%    Store Gc86z and G86t on the first call, then pass them in with every
%    following call. This avoids reading the XML data over and over again.
%
% FORMAT   [P,T,Gc86z,Gc86t] = z2p_cira86( Z , LAT , DOY, Gc86z, Gc86t )
%
% OUT   P     Pressure in pascal, for all combinations of Z, LAT, DOY
%             Size is [np,nlat,ndoy]
%   OPTIONAL
%       T     Temperature in kelvin, for all combinations of Z, LAT, DOY
%             Size is [nz,nlat,ndoy]
%       Gc86z Original cira86 z_field
%       Gc86t Original cira86 t_field
% IN    Z     Altitude in meter. Can be a scalar or column vector
%       LAT   Latitude. Can be a scalar or column vector [-90 to 90].
%       DOY   Day of year. Can be a scalar or column vector
%   OPTIONAL
%       Gc86z Original cira86 z_field
%       Gc86t Original cira86 t_field

% 2007-11-01   Created by Bengt Rydberg

function [p,t,Gc86z,Gc86t]=z2p_cira86(z,lat,doy,Gc86z,Gc86t)

if atmlab('STRICT_ASSERT')
    rqre_datatype( z, @istensor1 );                                    %&%
    rqre_datatype( lat, @istensor1 );                                  %&%
    rqre_datatype( doy, @istensor1 );                                  %&%
    
    errid = ['atmlab:' mfilename ':badInput'];
    
    
    if any(doy)>367 || any(doy<1)                                      %&%
        error(errid,'doy range is [1,367]')              %&%
    end                                                                %&%
    if any(lat)>90 || any(lat<-90)                                     %&%
        error(errid,'latitude range is -90 to 90')      %&%
    end                                                                %&%
end

% Create a a mjd matching the given doy (ie. the inverse of mjd2doy)
mjd = date2mjd( 2000, 1, 1, 0, 0, 0 ) + doy - 1;

if (nargin < 4 || isempty(Gc86z))
    cira86 = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'climatology', ...
        'cira86', 'cira86.z.xml' );
    Gc86z = gf_artsxml( cira86, 'CIRA86', 'z_field' );
end
G    = atmdata_regrid( Gc86z, { Gc86z.GRID1, lat, 0, mjd } );
Z    = G.DATA;
p    = zeros( length(z), size(Z,2), size(Z,4) );
logp = log( G.GRID1 );

if nargout > 1
    if (nargin < 5 || isempty(Gc86t))
        cira86 = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'climatology', ...
            'cira86', 'cira86.t.xml' );
        Gc86t = gf_artsxml( cira86, 'CIRA86', 't_field' );
    end
    G = atmdata_regrid( Gc86t, { Gc86t.GRID1, lat, 0, mjd } );
    T = G.DATA;
    t = zeros( length(z), size(T,2), size(T,4) );
end

for ilat = 1 : size(Z,2)
    for imjd = 1 : size(Z,4)
        if nargout < 2
            p(:,ilat,imjd) = exp( interp1( Z(:,ilat,1,imjd), logp, z ) );
        else
            pnew           = interp1( Z(:,ilat,1,imjd), logp, z );
            t(:,ilat,imjd) = interp1( logp, T(:,ilat,1,imjd), pnew );
            p(:,ilat,imjd) = exp( pnew );
        end
    end
end

% ------------
% NOTES
% These are the same assertion as given by the rqre functions at the beginnig of
% the function. The following are much faster, but if you run is stable you
% should set atmlab('STRICT_ASSERT',0) to skip the assertions all together

%     assert(isnumeric(z) && size(z,1) >=1 && size(z,2) == 1 && ndims(z)==2,...
%         errid, '*grid* must pass the test @isempty || @istensor1')
%     assert(isnumeric(lat) && size(lat,1) >=1 && size(lat,2) == 1 && ndims(lat)==2,...
%         errid, '*grid* must pass the test @isempty || @istensor1')
%     assert(isnumeric(doy) && size(doy,1) >=1 && size(doy,2) == 1 && ndims(doy)==2,...
%         errid, '*grid* must pass the test @isempty || @istensor1')
