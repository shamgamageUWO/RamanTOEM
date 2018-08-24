% QARTS_VMR_FIELD   Extracts vmr field from Q.ABS_SPECIES.ATMDATA
%
%   Performs an interpolation of Q.ABS_SPECIES.ATMDATA. The field ATMDATA must
%   be set for all species. For 3D cases, P_GRID, LAT_GRID and LON_GRID are
%   used as interpolation grids. For 1D and 2D, LAT_TRUE and LON_TRUE replace
%   LAT_GRID and LON_GRID.
%
%   The interpolation is made as using *atmdata_regrid*. That is, the data are
%   assumed to be defined everywhere (end values valid all the way to +-INF).
%   This is also valid for singleton dimensions. The grid for empty/singleton
%   dimensions can be empty or a scalar.
%
%   It is also possible to handle atmdata having date and hour dimensions. The
%   optional arguments must then be set.
%
%   The following fields must always be set:
%      Q.ATMOSPHERE_DIM
%      Q.P_GRID
%      Q.ABS_SPECIES
%
% FORMAT   vmr_field = qarts_vmr_field( Q [, mjd, ltime] )
%        
% OUT   vmr_field   Obtained vmr field.
% IN    Q           Qarts setting structure.
% OPT   mjd         Date as MJD. A scalar.
%       ltime       Local (solar) time, in hours. A scalar.

% 2010-01-09   Created by Patrick Eriksson.

function vmr_field = qarts_vmr_field( Q, varargin )

  
%- Variable checks
%
strict_assert = atmlab( 'STRICT_ASSERT' );
%
if strict_assert

  rqre_nargin( 1, nargin );
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

  if ~qarts_isset( Q.ABS_SPECIES )
    error( 'Q.ABS_SPECIES must be set when using this function' );
  end
  rqre_field( Q.ABS_SPECIES(1), 'ATMDATA', 'Q.ABS_SPECIES' );
end



%- Set and check interpolation grids (some special tricks for 2D!)
%
grids{1} = qarts_get( Q.P_GRID );
%
if Q.ATMOSPHERE_DIM == 1
  grids{2} = qarts_get( Q.LAT_TRUE );
  grids{3} = qarts_get( Q.LON_TRUE );
  if strict_assert  & ( length(grids{2}) ~= 1  |  length(grids{3}) ~= 1 )
      error( 'For 1D, Q.LAT_TRUE and Q.LON_TRUE must have length 1.' );
  end
elseif Q.ATMOSPHERE_DIM == 2
  lat_true = qarts_get( Q.LAT_TRUE );
  lon_true = qarts_get( Q.LON_TRUE );
  if strict_assert  &  length(lat_true) ~= length(lon_true)
    error( 'For 2D, Q.LAT_TRUE and Q.LON_TRUE must have the same length.' );
  end   
  grids{2} = lat_true;
  grids{3} = lon_true(1);
else
  grids{2} = qarts_get( Q.LAT_GRID );
  grids{3} = qarts_get( Q.LON_GRID );
end
%
for i = 1 : length( varargin )
  rqre_datatype( varargin{i}, @istensor0, ...                               %&%
                                 'Optional arguments *mjd* and *ltime*.' ); %&%
  grids{3+i} = varargin{i};
end


%- Allocate vmr_field
%
ns = length( Q.ABS_SPECIES );
n  = [ ns ones(1,3) ];
%
for i = 1 : length(grids)
  l = length( grids{i} );
  if l > 1
    n(i+1) = l;
  end
end
%
vmr_field = zeros( n );


%- Standard "regrid" can be applied for 1D and 3D
%
if Q.ATMOSPHERE_DIM ~= 2
  %
  for i = 1 : ns
    vname = sprintf( 'Q.ABS_SPECIES(%d).ATMDATA', i );
    G     = qarts_get_gformat( Q.ABS_SPECIES(i).ATMDATA );
    %
    if strict_assert
       rqre_datatype( G, @isatmdata, vname );
    end
    %
    % Minimum dimension for interpolation is Q.ATMOSPHERE_DIM
    dim = max( [ G.DIM Q.ATMOSPHERE_DIM ] );
    %
    G                  = atmdata_regrid( G, {grids{1:dim}}, vname );
    vmr_field(i,:,:,:) = G.DATA;
  end

  
%- For 2D we perform repeated 1D regridding
%
else
  %
  for i = 1 : ns
    vname = sprintf( 'Q.ABS_SPECIES(%d).ATMDATA', i );
    G     = qarts_get_gformat( Q.ABS_SPECIES(i).ATMDATA );
    %
    if strict_assert
       rqre_datatype( G, @isatmdata, vname );
    end
    %
    % Minimum dimension for interpolation is Q.ATMOSPHERE_DIM
    dim = max( [ G.DIM Q.ATMOSPHERE_DIM ] );
    %
    for j = 1 : length( lat_true )
      grids{2}         = lat_true(j);
      grids{3}         = lon_true(j);
      Gtemp                = atmdata_regrid( G, {grids{1:dim}}, vname );
      vmr_field(i,:,j) = Gtemp.DATA;
    end
  end
end
  
    

