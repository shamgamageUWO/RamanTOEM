% QARTS_HSE   Calculation of hydrostatic altitudes
%
%    An interface for Qarts to *pt2z*. The main usage should be:
%       Q.Z_FIELD = qarts_hse( Q, hse_p, hse_t );
%
%    The altitudes are calculated using the following fields of Q:
%       P_GRID
%       T_FIELD
%       VMR_FIELD
%       ABS_SPECIES, that must contain data for H2O. 
%
%    In addition, LAT_GRID, or LAT_TRUE for 1D and 2D, must be set.
%
% FORMAT   Z = qarts_hse( Q, hse_p, hse_z )
%        
% OUT   Z       Calculated altitudes.
% IN    Q       Qarts setting structure.
%       hse_p   Pressure of reference point [Pa].
%       hse_z   Altitude of reference point [m].

% 2009-07-01   Created by Patrick Eriksson.

function Z = qarts_hse( Q, hse_p, hse_z )
                                                                            %&%
rqre_nargin( 3, nargin );                                                   %&%
rqre_datatype( hse_p, @istensor0 );                                         %&%
rqre_datatype( hse_z, @istensor0 );                                         %&%
if ~qarts_isset( Q.P_GRID )                                                 %&%
  error( 'Q.P_GRID must be set when using this function' );                 %&%
end                                                                         %&%
if Q.ATMOSPHERE_DIM < 3  &&  ~qarts_isset( Q.LAT_TRUE )                     %&%
  error( 'Q.LAT_TRUE must be set when using this function for 1D and 2D.' );%&%
end                                                                         %&%
if Q.ATMOSPHERE_DIM == 3  &&  ~qarts_isset( Q.LAT_GRID )                    %&%
  error( 'Q.LAT_GRID must be set when using this function for 3D.' );       %&%
end                                                                         %&%
if ~qarts_isset( Q.T_FIELD     )                                            %&%
  error( 'Q.T_FIELD must be set when using this function' );                %&%
end                                                                         %&%
if ~qarts_isset( Q.VMR_FIELD )                                              %&%
  error( 'Q.VMR_FIELD must be set when using this function' );              %&%
end                                                                         %&%
if ~qarts_isset( Q.ABS_SPECIES )                                            %&%
  error( 'Q.ABS_SPECIES must be set when using this function' );            %&%
end                                                                         %&%

%- Find first H2O among ABS_SPECIES 
ih2o = [];
%
for i = 1 : length( Q.ABS_SPECIES )
  if strcmp( lower(arts_tgs2species(Q.ABS_SPECIES(i).TAG{1})), 'h2o' )
    ih2o = i;
    break;
  end
end
if isempty( ih2o )                                                          %&%
  error( 'H2O must be included among ABS_SPECIES.' );                       %&%
end                                                                         %&%


T        = qarts_get( Q.T_FIELD );
VMR      = qarts_get( Q.VMR_FIELD );
p_grid   = qarts_get( Q.P_GRID );
if Q.ATMOSPHERE_DIM < 3  
  lat_grid = qarts_get( Q.LAT_TRUE );
else
  lat_grid = qarts_get( Q.LAT_GRID );
end
  

rqre_gridmatch( T, 1, p_grid );                                             %&%
rqre_gridmatch( T, 2, lat_grid );                                           %&%
rqre_gridmatch( VMR, 2, p_grid );                                           %&%
rqre_gridmatch( VMR, 3, lat_grid );                                         %&%


Z = zeros( size( T ) );
%
for ilon = 1 : size( T, 3 )
  for ilat = 1 : size( T, 2 )

    Z(:,ilat,ilon) = pt2z( p_grid, T(:,ilat,ilon), ...
                           getdims(VMR(ih2o,:,ilat,ilon),2), ...
                           hse_p, hse_z, lat_grid(ilat) );  
  end
end
