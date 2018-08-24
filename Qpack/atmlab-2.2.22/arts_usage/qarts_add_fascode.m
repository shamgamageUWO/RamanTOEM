% QARTS_ADD_FASCODE   Includes a Fascode atmosphere
%
%  Expands Q to import one of the five Fasoce atmospheres. These atmospheres
%  are named as 'tropical', 'midlatitude-summer', 'midlatitude-winter',
%  'subarctic-summer' and 'subarctic-winter'.
%
%  Q.ATMSOPHERE_DIM must be set, and can be 1, 2 or 3. Fields of Q set by 
%  the function are P_GRID, LAT_GRID (only 2D and 3D), LON_GRID (only 3D), 
%  Z_FIELD, T_FIELD, VMR_FIELD, ABS_SPECIES and HSE (set to to true).
%  Further, LAT_TRUE is set (if not 3D) to a value representating the
%  Fascode atmosphere, and if not already set LON_TRUE is set to zero.
%
%  The P_GRID set reaches about 95 km. LAT/LON_TRUE are set to representative
%  values for the selected atmosphere. For 3D, LON_GRID is set to cover the
%  complete planet ([-180,180], can be modfified by *A.lon0*). For 2D and 3D,
%  LAT_GRID is set to cover pole to pole, with a spacing of 5 degrees. T_FIELD
%  and VMR_FIELD have no latitudinal variation, but a latitude grid is required
%  to capture the variation in Z_FIELD originating from the constrain of HSE.
%  Note that LAT_GRID can be controlled cropped by *A.lat_min* and *A.lat_max*.
%
%  Ionospheric data can be included where the IRI (free electrons) and IGRF
%  (magnetic fields) data found in arts_xml-data are used. This part is
%  triggered by setting A.ionosphere to true. See further optional fields
%  listed below. Settings like p_min applies also to this part. Data of free
%  electrons are included only if 'free_electrons' is part of ABS_SPECIES.
%  THe electron content is set to zero for the highest altitude, to ensure a
%  gradual transition to n=1.
%
%  Free electron content is set to zero if A.ionosphere is false.
%
%  The mandatory fields of A are
%   'fascode_atm' : String with name of atmosphere, eg. 'tropical'.
%   'ABS_SPECIES' : These data are copied to Q.ABS_SPECIES. 
%   
%  Optional fields are
%   'p_min'     : Crop P_GRID at this value. Lower values are rejected.
%   'lat_min'   : Crop LAT_GRID at this value. Lower values are rejected.
%   'lat_min'   : Crop LAT_GRID at this value. Higher values are rejected.
%   'lon0'      : Focus LON_GRID on this value, ie. LON_GRID = 
%                 A.lon0 + [-180,180] 
%   'ionosphere': Flag to include ionospheric data. Default is false.
%   'igrf_year' : IGRF data year, where the options are 1980, 1990, 2000 
%                 and 2010. 
%   'iri_sun'   : Solar state to consider for IRI. Options are 'min' and 'max'.
%   'iri_season': Season to consider for IRI. Options are 'spring', 'summer',
%                 'fall' and 'winter'.
%   'iri_utc'   : UTC to consider for IRI. Options are 0:3:21.
%
% Bad choice for any IGRF and IRI settings will result in an error of the
% type "file not found".  
%
% FORMAT Q = qarts_add_fascode( A, Q, workfolder )
%
% OUT   Q          Modified Q
% IN    A          Atmosphere structure, see above.
%       Q          Original Q
%       workfolder Path to workfolder (not used, but an input is demanded)

% 2013-09-29   Created by Patrick Eriksson.

function Q = qarts_add_fascode( A, Q, workfolder )
%
rqre_datatype( A, { @isstruct } );
rqre_datatype( Q, { @isstruct } );
rqre_datatype( workfolder, { @ischar,@isempty } );


arts_xmldata_path       = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to set ARTS_XMLDATA_PATH to use this function.');
end

if ~qarts_isset( Q.ATMOSPHERE_DIM )
  error( 'Q.ATMOSPHERE_DIM must be set.' );
end


switch lower( A.fascode_atm )
  
 case 'tropical'  
  Q.LAT_TRUE = 10;
 case 'midlatitude-summer'  
  Q.LAT_TRUE = 45;
 case 'midlatitude-winter'  
  Q.LAT_TRUE = 45;
 case 'subarctic-summer'  
  Q.LAT_TRUE = 75;
 case 'subarctic-winter'  
  Q.LAT_TRUE = 75;
 otherwise
  error( 'Unrecognised choice for *A.fascode_atm* (%s).', A.fascode_atm );
end
%
if ~qarts_isset( Q.LON_TRUE )
  Q.LON_TRUE = 0;
end
  

% Use z as reference for p_grid
%
R = xmlLoad( fullfile( arts_xmldata_path, 'planets', 'Earth', 'Fascod', ...
                                   A.fascode_atm, [A.fascode_atm,'.z.xml'] ) );
%
Q.P_GRID  = vec2col( R.grids{1} );
%
if isfield( A, 'p_min' )
  ind      = find( Q.P_GRID >= A.p_min );
  Q.P_GRID = Q.P_GRID( ind );  
end
%
Q.Z_FIELD = vec2col( R.data );

% t_field
R = xmlLoad( fullfile( arts_xmldata_path, 'planets', 'Earth', 'Fascod', ...   
                                   A.fascode_atm, [A.fascode_atm,'.t.xml'] ) );
Q.T_FIELD = interpp( R.grids{1}, R.data, Q.P_GRID );

% vmr_field
%
Q.ABS_SPECIES = A.ABS_SPECIES;
%
nabs          = length( Q.ABS_SPECIES );
Q.VMR_FIELD   = zeros( nabs, length(Q.P_GRID) );
%
fe_found      = 0;
%
for i = 1 : nabs
  species = arts_tgs2species( Q.ABS_SPECIES(i).TAG{1} );
  
  if strcmp( species, 'free_electrons' )
    fe_found = i;
  else
    R = xmlLoad( fullfile( arts_xmldata_path, 'planets', 'Earth', 'Fascod', ...
                         A.fascode_atm, [A.fascode_atm,'.',species,'.xml'] ) );
    % Use nearest interpolation downwards
    Q.VMR_FIELD(i,:) = interpp( [1e99;R.grids{1}], [R.data(1);R.data], ...
                                                                    Q.P_GRID );
  end
end

Q.HSE.ON                = true;
Q.HSE.P                 = Q.P_GRID(2);
Q.HSE.ACCURACY          = 1;


% If no ionosphere, handle 2D and 3D, and return
if ~safegetfield( A, 'ionosphere', false );

  if Q.ATMOSPHERE_DIM == 2
    Q.LAT_GRID = [ -90 : 5 : 90 ]';
    Q.LAT_TRUE = Q.LAT_GRID;
    Q.LON_TRUE = repmat( Q.LON_TRUE, size(Q.LAT_GRID) );
    nlon = 1;
  elseif Q.ATMOSPHERE_DIM == 3
    Q.LAT_TRUE = {};
    Q.LON_TRUE = {};
    Q.LAT_GRID = [ -90 : 3 : 90 ]';
    Q.LON_GRID = [ -180 180 ];
    if isfield( A, 'lon0' )
      Q.LON_GRID = A.lon0 + Q.LON_GRID;    
    end
    nlon = length(Q.LON_GRID);
  end 

  if Q.ATMOSPHERE_DIM > 1
    ind        = find( Q.LAT_GRID >= safegetfield( A, 'lat_min', -Inf )  &  ...
                       Q.LAT_GRID <= safegetfield( A, 'lat_max', Inf  )   );
    Q.LAT_GRID = Q.LAT_GRID( ind );
    %
    nlat = length( Q.LAT_GRID );
    %
    Q.Z_FIELD   = repmat( Q.Z_FIELD, [ 1 nlat nlon ] );
    Q.T_FIELD   = repmat( Q.T_FIELD, [ 1 nlat nlon ] );
    Q.VMR_FIELD = repmat( Q.VMR_FIELD, [ 1 1 nlat nlon ] );
  end

  return;   % --->
end


%-----------------------------------------------------------------------------
%--- Add ionopshere
%-----------------------------------------------------------------------------

if Q.ATMOSPHERE_DIM == 2
  error( 'Adding an ionosphere not supported for 2D.' );
end
  

% Take altitudes and pressures from free electron data 
%
R = xmlLoad( fullfile( arts_xmldata_path, 'planets', 'Earth', 'IRI', ...
                                                         'IRI.Ne.z.xml.gz' ) );
%  
ind = find( R.grids{1} <= Q.P_GRID(end)/10  &  ...
            R.grids{1} >= safegetfield( A, 'p_min', 0 ) );
%
pnew = vec2col( R.grids{1}(ind) );
%
Q.P_GRID  = [ Q.P_GRID;  pnew ];
Q.Z_FIELD = [ Q.Z_FIELD; R.data(ind,1,1) ];
Q.T_FIELD = [ Q.T_FIELD; repmat( Q.T_FIELD(end), [ length(pnew), 1 ] ) ];
% Use "zeropadding" for vmr
vmr_field   = Q.VMR_FIELD;
Q.VMR_FIELD = zeros( size(vmr_field,1), length(Q.P_GRID) );
Q.VMR_FIELD(:,1:size(vmr_field,2)) = vmr_field;
clear vmr_field;


% Load magnetic fields (lat and lon taken from these data)
%
R = xmlLoad( fullfile( arts_xmldata_path, 'planets', 'Earth', 'IGRF', ...
            sprintf('IGRF11_%d_200km-5deg-5deg.B_u.xml.gz', A.igrf_year ) ) );
%
if Q.ATMOSPHERE_DIM == 1
  outgrids = { Q.P_GRID, Q.LAT_TRUE, Q.LON_TRUE };
else
  Q.LAT_GRID = R.grids{2};
  ind        = find( Q.LAT_GRID >= safegetfield( A, 'lat_min', -Inf )  &  ...
                     Q.LAT_GRID <= safegetfield( A, 'lat_max', Inf  )   );
  Q.LAT_GRID = Q.LAT_GRID( ind ); 
  %
  Q.LON_GRID = R.grids{3};
  % 
  outgrids = { Q.P_GRID, Q.LAT_GRID, Q.LON_GRID };
end
%
Q.MAG_U_FIELD = arts_regrid( Q.ATMOSPHERE_DIM, R.grids, R.data, outgrids );
%
%
R = xmlLoad( fullfile( arts_xmldata_path, 'planets', 'Earth', 'IGRF', ...
            sprintf('IGRF11_%d_200km-5deg-5deg.B_v.xml.gz', A.igrf_year ) ) );
Q.MAG_V_FIELD = arts_regrid( Q.ATMOSPHERE_DIM, R.grids, R.data, outgrids );
%
%
R = xmlLoad( fullfile( arts_xmldata_path, 'planets', 'Earth', 'IGRF', ...
            sprintf('IGRF11_%d_200km-5deg-5deg.B_w.xml.gz', A.igrf_year ) ) );
Q.MAG_W_FIELD = arts_regrid( Q.ATMOSPHERE_DIM, R.grids, R.data, outgrids );


% Expand to 3D
%
if Q.ATMOSPHERE_DIM == 3
  nlat = length( Q.LAT_GRID );
  nlon = length( Q.LON_GRID );
  %
  Q.Z_FIELD   = repmat( Q.Z_FIELD, [ 1 nlat nlon ] );
  Q.T_FIELD   = repmat( Q.T_FIELD, [ 1 nlat nlon ] );
  Q.VMR_FIELD = repmat( Q.VMR_FIELD, [ 1 1 nlat nlon ] );
end


if fe_found
  R = xmlLoad( fullfile( arts_xmldata_path, 'planets', 'Earth', 'IRI', ...
                         sprintf( 'IRI_sol%s_%s_%02dUTC.Ne.xml.gz', ...
                                    A.iri_sun, A.iri_season, A.iri_utc ) )  );
  Q.VMR_FIELD(fe_found,:,:,:) = arts_regrid( Q.ATMOSPHERE_DIM, R.grids, ...
                                                           R.data, outgrids );
  Q.VMR_FIELD(fe_found,end,:,:) = 0;
end


% Centre on lon0?
%
if isfield( A, 'lon0' )
  Q.LON_GRID = Q.LON_GRID - mean(Q.LON_GRID([1 end])) + A.lon0
end


