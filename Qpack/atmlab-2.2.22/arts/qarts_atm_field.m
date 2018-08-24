% QARTS_ATM_FIELD   Extracts a basic atmospheric field from e.g. Q.T_ATMDATA
%
%   Performs an interpolation of ATMDATA, for those variables having such a
%   sub-field. Those variables include: T, Z, WIND_U, WIND_V and WIND_W.
%
%   The field ATMDATA must be set. For 3D cases, P_GRID, LAT_GRID and LON_GRID
%   are used as interpolation grids. For 1D and 2D, LAT_TRUE and LON_TRUE
%   replace LAT_GRID and LON_GRID.
%
%   The interpolation is made as using *atmdata_regrid*. That is, the data are
%   assumed to be defined everywhere (end values valid all the way to +-INF).
%   This is also valid for singleton dimensions. The grid for empty/singleton
%   dimensions can be empty or a scalar.
%
%   It is also possible to handle atmdata having day and hour dimensions. The
%   optional arguments must then be set.
%
%   The following fields must always be set:
%      Q.ATMOSPHERE_DIM
%      Q.P_GRID
%
% FORMAT   atmfield = qarts_atm_field( Q, vstring [, day, hour] )
%        
% OUT   atmfield    Obtained data field.
% IN    Q           Qarts setting structure.
%       vstring     The variable for which ATMDATA shall be interpolated.
%                   Case of strong is ignored. Examples: 't', 'T', 'z', 
%                   'wind_u' and 'WIND_w'.
% OPT   mjd         Date as MJD. A scalar.
%       ltime       Local (solar) time, in hours. A scalar.

% 2010-01-09   Created by Patrick Eriksson.

function atmfield = qarts_atm_field( Q, vstring, varargin )


%- Some help variables
%
VNAME = upper( vstring );
astr  = sprintf( 'Q.%c.ATMDATA', VNAME );


%- Variable checks
%
strict_assert = atmlab( 'STRICT_ASSERT' );
%
if strict_assert

  rqre_nargin( 2, nargin );
  rqre_datatype( vstring, @ischar );
  for i = 1 : length( varargin )
    rqre_datatype( varargin{i}, @istensor0, ...
                                     'Optional arguments *mjd* and *ltime*.' ); 
  end
  
  if ~qarts_isset( Q.ATMOSPHERE_DIM )
    error( 'Q.ATMOSPHERE_DIM must be set when using this function' );
  end
  if ~qarts_isset( Q.P_GRID )
    error( 'Q.P_GRID must be set when using this function' );
  end
  if Q.ATMOSPHERE_DIM < 3
    if ~qarts_isset( Q.LAT_TRUE )
      error( 'For 1D and 2D, Q.LAT_TRUE must be set when using this function' );
    end
    if ~qarts_isset( Q.LON_TRUE )
      error( 'For 1D and 2D, Q.LON_TRUE must be set when using this function' );
    end
  else
    if ~qarts_isset( Q.LAT_GRID )
      error( 'For 3D, Q.LAT_GRID must be set when using this function' );
    end
    if ~qarts_isset( Q.LON_GRID )
      error( 'For 3D, Q.LON_GRID must be set when using this function' );
    end
  end
  
  if ~isfield( Q.(VNAME), 'ATMDATA' ) | ~qarts_isset( Q.(VNAME).ATMDATA )
    error( sprintf( '%s must be set when using this function', astr ) );
  end

end


%- Get data to interpolate
%
G = qarts_get_gformat( Q.(VNAME).ATMDATA );
%
if strict_assert
  rqre_datatype( G, @isatmdata, astr ); 
end


%- Standard "regrid" can be applied for 1D and 3D
%
if Q.ATMOSPHERE_DIM ~= 2
  %
  grids{1} = qarts_get( Q.P_GRID );
  %
  if Q.ATMOSPHERE_DIM == 1
    grids{2} = qarts_get( Q.LAT_TRUE );
    grids{3} = qarts_get( Q.LON_TRUE );
    if strict_assert  &  ( length(grids{2}) ~= 1  |  length(grids{3}) ~= 1 )
      error( 'For 1D, Q.LAT_TRUE and Q.LON_TRUE must have length 1.' );
    end
  else
    grids{2} = qarts_get( Q.LAT_GRID );
    grids{3} = qarts_get( Q.LON_GRID );
  end
  %
  for i = 1 : length( varargin )
    grids{3+i} = varargin{i};
  end
  %  
  % Minimum dimension for interpolation is Q.ATMOSPHERE_DIM
  dim = max( [ G.DIM Q.ATMOSPHERE_DIM ] );
  %
  G = atmdata_regrid( G, {grids{1:dim}}, astr );
  %
  atmfield = G.DATA;
  
  
%- For 2D we perform repeated 1D regridding
%
else
  %
  lat_true = qarts_get( Q.LAT_TRUE );
  lon_true = qarts_get( Q.LON_TRUE );
  %
  if strict_assert  &  length(lat_true) ~= length(lon_true)
    error( 'For 2D, Q.LAT_TRUE and Q.LON_TRUE must have the same length.' );
  end
  %
  grids{1} = qarts_get( Q.P_GRID );
  grids{2} = lat_true(1);
  grids{3} = lon_true(1);
  %
  for i = 1 : length( varargin )
    grids{3+i} = varargin{i};
  end
  %  
  dim             = max( [ G.DIM Q.ATMOSPHERE_DIM ] );
  Gtemp               = atmdata_regrid( G, {grids{1:dim}}, astr );
  n               = length( lat_true );
  atmfield        = zeros( size(Gtemp.DATA,1), n );
  atmfield(:,1)   = Gtemp.DATA;  
  %
  for i = 2 : n
    grids{2}      = lat_true(i);
    grids{3}      = lon_true(i);
    Gtemp             = atmdata_regrid( G, {grids{1:dim}}, astr );
    atmfield(:,i) = Gtemp.DATA;  
  end
end
