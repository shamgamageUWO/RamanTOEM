% ARTS_OEM_INIT   Initialization of OEM inversions by ARTS
%
%    This function together with *arts_oem* handle bookkeeping and
%    communication to perform OEM inversion with ARTS. Not all possible
%    retrieval set-ups are handled. However, it should be possible to apply
%    this function for most cases, while *arts_oem* is less general (where
%    handling of "non-standard" sensor retrievals are most problematic).
%    The function ignores any ATMDATA, and atmospheric input shall be
%    provided by RAW_ATMOSPHERE and/or ready fields (such as T_FIELD and
%    WIND_V_FIELD).
%
%    The standard sequence of function calls is:
%
%       [Qoem,O,R,xa] = arts_oem_init( Q, O, workfolder );
%       Sx            = arts_sx( Qoem, R );
%       Se            = covmat ...
%       X             = oem( O, Qoem, R, @arts_oem, Sx, Se, [], [], xa, y );
%       %
%       clear Qoem
%
%    For "non-standard" cases, you have to make a function that can replace
%    *arts_oem* and give its function handle as input to *oem*.
%
%    Note that *arts_oem_init* can modify Q in such way that it can not be
%    used for further calculations. 
%
%    The implementation strategy is to avoid unnecessery reading and
%    writing of files, in order to obtain high calculation speed. The drawback
%    is that more variables must be kept in memory.
%
%    All pure forward model variables are stored in Q, while all extra data 
%    needed to handle the inversions are put into R. This data can be used
%    for further processing or "re-packing" of inversions results.
%    These fields always exist:
%       workfolder: Path to the temporary working folder.
%       jq        : ARTS description of jacobian quantities.
%       ji        : Start and stop index in J for each jacobian quantities.
%       cfile_y   : Name of control file to generate only y
%       cfile_yj  : Name of control to generate y and J
%       i_rel     : Index of species retrieved as rel (not including logrel)
%       p_grid    : As the ARTS WSM with same name.
%       lat_grid  : As the ARTS WSM with same name.
%       lon_grid  : As the ARTS WSM with same name.
%       minmax    : A matrix with min and mix limits. 
%
%    R can further contain these fields, depending on retrieval settings:
%       vmr_field0      : A priori vmr field
%       sensor_response : A copy of Q.SENSOR_RESPONSE 
%
% FORMAT   [Q,O,R,xa] = arts_oem_init(Q,O,workfolder)
%        
% Out   Q            Modified Q structure
%       O            Modified O structure
%       R            Structure with retrieval variables. See *arts_oem*.
%       xa           A priori state vector
% In    O            OEM settings.
%       Q            Qarts settings.
%       workfolder   Use this as "workfolder".

% 2010-01-11   Created by Patrick Eriksson.

function [Q,O,R,xa] = arts_oem_init(Q,O,workfolder)


%-----------------------------------------------------------------------------
%--- Checks of input and settings --------------------------------------------
%-----------------------------------------------------------------------------
if atmlab( 'STRICT_ASSERT' )

  % Input
  rqre_nargin( 3, nargin );
  rqre_datatype( Q, @isstruct ); 
  rqre_datatype( O, @isstruct ); 
  rqre_datatype( workfolder, @ischar ); 

  % These checks are of course not complete. They focus on demands of
  % arts_oem, mainly to make sure that iteration results can be mapped back
  % to arts correctly. Other stuff expected to be captured by qarts2cfile
  % and arts itself.
  
  % General settings
  if ~qarts_isset( Q.J_DO) | ~Q.J_DO
    error( 'Q.J_DO must be set to true.' );
  end
  
  % t_field and vmr_field
  if ~qarts_isset( Q.RAW_ATMOSPHERE ) | ~Q.RAW_ATMOSPHERE
    if isfield( Q, 'T.RETRIEVE' ) & Q.T.RETRIEVE & ~qarts_isset( Q.T_FIELD )
      error( ['If temperature is retrieved, T_FIELD or RAW_ATMOSPHERE ',...
                                                           'must be set.'] );
    end
    if isfield( Q.T, 'MINMAX' )
      rqre_datatype( Q.T.MINMAX, @istensor1, 'Q.T.MINMAX' );
      if length( Q.T.MINMAX ) > 2
        error( 'Max allowed length of Q.T.MINMAX is 2.' );
      end
    end
    %
    if isfield( Q, 'ABS_SPECIES.RETRIEVE' ) & ...
                 any([Q.ABS_SPECIES.RETRIEVE]) & ~qarts_isset( Q.VMR_FIELD )
      error( ['If any absorption species is retrieved, VMR_FIELD or ',...
                                          'RAW_ATMOSPHERE must be set.'] );
    end
    for i = 1 : length(Q.ABS_SPECIES)
      if isfield( Q.ABS_SPECIES(i), 'MINMAX' )
        rqre_datatype( Q.ABS_SPECIES(i).MINMAX, @istensor1, ...
                                     sprintf('Q.ABS_SPECIES(%d).MINMAX',i) );
        if length( Q.ABS_SPECIES(i).MINMAX ) > 2
          error( 'Max allowed length of Q.ABS_SPECIES(%d).MINMAX is 2.', i );
        end
      end 
    end 
  end  

  % vind fields
  if isfield( Q, 'WIND_U.RETRIEVE' ) & Q.WIND_U.RETRIEVE & ...
                                              ~qarts_isset( Q.WIND_U_FIELD )
    error( 'If wind u-component is retrieved, WIND_U_FIELD must be set.' );
  end  
  if isfield( Q, 'WIND_V.RETRIEVE' ) & Q.WIND_V.RETRIEVE & ...
                                              ~qarts_isset( Q.WIND_V_FIELD )
    error( 'If wind v-component is retrieved, WIND_V_FIELD must be set.' );
  end  
  if isfield( Q, 'WIND_W.RETRIEVE' ) & Q.WIND_W.RETRIEVE & ...
                                              ~qarts_isset( Q.WIND_W_FIELD )
    error( 'If wind w-component is retrieved, WIND_W_FIELD must be set.' );
  end  
  
  % Sensor stuff
  if qarts_isset(Q.POINTING) & Q.POINTING.RETRIEVE
    if ~qarts_isset( Q.SENSOR_LOS )
      error( ['When any pointing retrieval is performed, Q.SENSOR_LOS ',...
              'must be set.'] );
    end
    if ~qarts_isset( Q.SENSOR_TIME )
      error( ['When any pointing retrieval is performed, Q.SENSOR_TIME ',...
              'must be set.'] );
    end
  end
  % 
  if ( qarts_isset(Q.FSHIFTFIT)   & Q.FSHIFTFIT.RETRIEVE )  | ...
     ( qarts_isset(Q.FSTRETCHFIT) & Q.FSTRETCHFIT.RETRIEVE )
    if ~isstruct( Q.SENSOR_RESPONSE )
      error( ['When any frequency fit is performed Q.SENSOR_RESPONSE ',...
              'must follow qartsSensor (i.e. be a structure).'] );
    end
  end
end
%-----------------------------------------------------------------------------
%--- End checks --------------------------------------------------------------
%-----------------------------------------------------------------------------



%- Initialization of variables
%
R            = [];
R.i_rel      = [];
R.workfolder = workfolder;
%
[Q,R,t_field,z_field,vmr_field,wind_u,wind_v,wind_w] = init_local( Q, R );



%- Some internal variables
%
nq          = length( R.jq );
nx          = R.ji{nq}{2};
i_asj       = find( [ Q.ABS_SPECIES.RETRIEVE ] );
store_vmr0  = false;


%- xa
%
xa       = zeros( nx, 1 );


%- R.minmax
%
R.minmax = repmat( [-Inf Inf], nx, 1 );



%--- Loop retrieval quantities and fill xa and R fields ----------------------
%-----------------------------------------------------------------------------

for i = 1 : nq

  ind = R.ji{i}{1} : R.ji{i}{2};

  switch R.jq{i}.maintag


  case 'Absorption species'   %-----------------------------------------------
    %
    store_vmr0 = true;
    ig         = i_asj(i);    % Gas species index
    %
    if strcmp( R.jq{i}.mode, 'rel' )
      xa(ind)    = 1;
      R.i_rel    = [ R.i_rel ind ];
    elseif strcmp( R.jq{i}.mode, 'vmr' )
      xa(ind)    = mat2col( arts_regrid( Q.ATMOSPHERE_DIM, Q, ...
                          get_vmrfield_local(vmr_field,ig), R.jq{i}.grids ) );
    elseif strcmp( R.jq{i}.mode, 'nd' )
      xa(ind)    = vmr2nd( ...
                     mat2col( arts_regrid( Q.ATMOSPHERE_DIM, Q, ...   % VMR
                       get_vmrfield_local(vmr_field,ig), R.jq{i}.grids ) ), ...
                     repmat( R.jq{i}.grids{1}, ...                    % P
                       length(ind)/length(R.jq{i}.grids{1}), 1 ), ...
                     mat2col( arts_regrid( Q.ATMOSPHERE_DIM, Q, ...   % T
                       t_field, R.jq{i}.grids ) ) ...
                   );
    elseif strcmp( R.jq{i}.mode, 'logrel' )
      xa(ind)    = 0;
    else
      error( sprintf('Unknown gas species retrieval unit (%s).', ...
                                                              R.jq{i}.mode ) ); 
    end
    if isfield( Q.ABS_SPECIES(ig), 'MINMAX' )  &  ...
                                             ~isempty(Q.ABS_SPECIES(ig).MINMAX)
      
      R.minmax(ind,1:length(Q.ABS_SPECIES(ig).MINMAX)) = ...
                           repmat( Q.ABS_SPECIES(ig).MINMAX', length(ind), 1 );
    end
    
  case 'Atmospheric temperatures'   %-----------------------------------------
    %
    xa(ind) = mat2col( arts_regrid( Q.ATMOSPHERE_DIM, Q, t_field, ...
                                                             R.jq{i}.grids ) );
    if isfield( Q.T, 'MINMAX' )  & ~isempty(Q.T.MINMAX)
      R.minmax(ind,1:length(Q.T.MINMAX)) = ...
                                         repmat( Q.T.MINMAX', length(ind), 1 );
    end

  case 'Wind'   %-------------------------------------------------------------
    %
    if strcmp( R.jq{i}.subtag, 'u' )
      Q = force_file_local( Q, 'WIND_U_FIELD', 'Tensor3', R );
      if isempty( wind_u )
        wind_u = zeros( size( t_field ) );
      end
      xa(ind) = mat2col( arts_regrid( Q.ATMOSPHERE_DIM, Q, wind_u, ...
                                                             R.jq{i}.grids ) );
    elseif strcmp( R.jq{i}.subtag, 'v' )
      Q = force_file_local( Q, 'WIND_V_FIELD', 'Tensor3', R );
      if isempty( wind_v )
        wind_v = zeros( size( t_field ) );
      end
      xa(ind) = mat2col( arts_regrid( Q.ATMOSPHERE_DIM, Q, wind_v, ...
                                                             R.jq{i}.grids ) );
    elseif strcmp( R.jq{i}.subtag, 'w' )
      Q = force_file_local( Q, 'WIND_W_FIELD', 'Tensor3', R );
      if isempty( wind_w )
        wind_w = zeros( size( t_field ) );
      end
      xa(ind) = mat2col( arts_regrid( Q.ATMOSPHERE_DIM, Q, wind_w, ...
                                                             R.jq{i}.grids ) );
    else
      error( 'Unknown wind subtag.' );
    end
    
   %---------------------------------------------------------------------------
   case { 'Frequency', 'Sensor pointing', 'Polynomial baseline fit', ...
                                          'Sinusoidal baseline fit' }
    %
    xa(ind) = 0;    

  otherwise   %---------------------------------------------------------------
    error('Unknown retrieval quantitity.'); 
  end
end 



%--- More to put into R ? -----------------------------------------------------

if store_vmr0
  R.vmr_field0 = vmr_field;
end



%--- Create control files -----------------------------------------------------
%
%- Only y
Q.J_DO    = false;
parts     = qarts2cfile( 'y_after_init' );
S         = qarts2cfile( Q, parts, R.workfolder );
cfile     = fullfile( R.workfolder, 'cfile_y.arts' );
strs2file( cfile, S );
R.cfile_y = cfile;
%
%- y+j
Q.J_DO     = true;
S          = qarts2cfile( Q, parts, R.workfolder );
cfile      = fullfile( R.workfolder, 'cfile_yj.arts' );
strs2file( cfile, S );
R.cfile_yj = cfile;

return





%-----------------------------------------------------------------------------
%--- Internal sub-functions
%-----------------------------------------------------------------------------

function Q = force_file_local( Q, fieldname, datatype, R )
  if ~ischar( getfield( Q, fieldname ) )
    filename = fullfile( R.workfolder, [lower(fieldname),'.xml'] );
    xmlStore( filename, Q.(fieldname), datatype, Q.INPUT_FILE_FORMAT );
    Q.(fieldname) = filename;
  end
return



function V = get_vmrfield_local( vmr_field, i )
  s               = ones( 1, 4 );
  s2              = size( vmr_field );
  s(1:length(s2)) = s2;
  V = zeros( s(2:end) );
  V(:,:,:) = vmr_field(i,:,:,:);
return



function [Q,R,t_field,z_field,vmr_field,wind_u,wind_v, wind_w] = ...
                                                             init_local( Q, R )

  %- Copy some data to R
  %
  % This is done here to possible save time; the data are forced to files below
  %
  R.p_grid   = qarts_get( Q.P_GRID );
  R.lat_grid = qarts_get( Q.LAT_GRID );
  R.lon_grid = qarts_get( Q.LON_GRID );

  %- Force some ARTS variables to be files 
  %
  % This is done to avoid creating the same file repeatedly in qarts2cfile.
  % This can be done for variables that never are part of the retrieval 
  % quantities. Some variables, beside the ones included here, are handled 
  % below.
  Q = force_file_local( Q, 'F_GRID', 'Vector', R );
  %
  Q = force_file_local( Q, 'P_GRID', 'Vector', R );
  if Q.ATMOSPHERE_DIM > 1
    Q = force_file_local( Q, 'LAT_GRID', 'Vector', R );
    if Q.ATMOSPHERE_DIM > 2
      Q = force_file_local( Q, 'LON_GRID', 'Vector', R );
    end
  end
  %
  Q = force_file_local( Q, 'SENSOR_POS', 'Matrix', R );
  Q = force_file_local( Q, 'SENSOR_LOS', 'Matrix', R );

  %- Atmospheric fields
  %
  if qarts_isset( Q.RAW_ATMOSPHERE )  &  Q.RAW_ATMOSPHERE
    [t_field,z_field,vmr_field]       = arts_atmfields( Q );
    [Q.T_FIELD,Q.Z_FIELD,Q.VMR_FIELD] = deal( t_field, z_field, vmr_field );   
    Q.RAW_ATMOSPHERE                  = {};
  else
    t_field   = qarts_get( Q.T_FIELD );
    z_field   = qarts_get( Q.Z_FIELD );
    vmr_field = qarts_get( Q.VMR_FIELD );
  end
  %
  Q = force_file_local( Q, 'T_FIELD', 'Tensor3', R );
  Q = force_file_local( Q, 'Z_FIELD', 'Tensor3', R );
  Q = force_file_local( Q, 'VMR_FIELD', 'Tensor4', R );
  %
  % Winds (some stuff done, further above if wind is retrieved):
  if qarts_isset( Q.WIND_U_FIELD )
    wind_u = qarts_get( Q.WIND_U_FIELD );
  else
    wind_u = NaN;
  end
  if qarts_isset( Q.WIND_V_FIELD )
    wind_v = qarts_get( Q.WIND_V_FIELD );
  else
    wind_v = NaN;
  end
  if qarts_isset( Q.WIND_W_FIELD )
    wind_w = qarts_get( Q.WIND_W_FIELD );
  else
    wind_w = NaN;
  end
  
  %- Absorption
  %
  if strcmp( Q.ABSORPTION, 'LoadTable' )
    Q = force_file_local( Q, 'ABS_LOOKUP', 'GasAbsLookup', R );
  elseif strcmp( Q.ABSORPTION, 'CalcTable' )
    Q            = qarts_abstable( Q );
    Q.ABS_LOOKUP = arts_abstable( Q, R.workfolder );
    Q.ABSORPTION = 'LoadTable';
  end
  
  %- Run arts to create jacobian and sensor variables
  %
  parts = qarts2cfile( 'y_init' );
  %
  S     = qarts2cfile( Q, parts, R.workfolder );
  cfile = fullfile( R.workfolder, 'cfile.arts' );
  strs2file( cfile, S );
  arts( cfile );

  %- Jacobian
  %
  R.jq = xmlLoad( fullfile( R.workfolder, 'jacobian_quantities.xml' ) );
  R.ji = xmlLoad( fullfile( R.workfolder, 'jacobian_indices.xml' ) );
  % 
  if length( R.jq ) == 0
    error( 'No retrieval quantities defined!?' );
  end
  %
  for i = 1 : length(R.ji)           % Fix different indexing
    for j = 1 : length(R.ji{i})
      R.ji{i}{j} = R.ji{i}{j} + 1;
    end
  end

  %- Sensor
  %
  if qarts_isset(Q.POINTING) & Q.POINTING.RETRIEVE
    R.los = qarts_get( Q.SENSOR_LOS );
  end
  % 
  if ( qarts_isset(Q.FSHIFTFIT)   & Q.FSHIFTFIT.RETRIEVE )  | ...
     ( qarts_isset(Q.FSTRETCHFIT) & Q.FSTRETCHFIT.RETRIEVE )
    %- A copy of Q.SENSOR_RESPONSE is needed here
    R.sensor_response = Q.SENSOR_RESPONSE;
  end
  %
  Q.SENSOR_RESPONSE     = fullfile( R.workfolder, 'sensor_response.xml' );
  %
  Q.SENSOR_RESPONSE     = fullfile( R.workfolder, 'sensor_response.xml' );
  Q.SENSOR_RESPONSE_F   = fullfile( R.workfolder, 'sensor_response_f.xml' );
  Q.SENSOR_RESPONSE_ZA  = fullfile( R.workfolder, 'sensor_response_za.xml' );
  Q.SENSOR_RESPONSE_AA  = fullfile( R.workfolder, 'sensor_response_aa.xml' );
  Q.SENSOR_RESPONSE_POL = fullfile( R.workfolder, 'sensor_response_pol.xml' );
  Q.SENSOR_RESPONSE_F_GRID = ...
                        fullfile( R.workfolder, 'sensor_response_f_grid.xml' );
  Q.SENSOR_RESPONSE_ZA_GRID = ...
                       fullfile( R.workfolder, 'sensor_response_za_grid.xml' );
  Q.SENSOR_RESPONSE_AA_GRID  = ...
                       fullfile( R.workfolder, 'sensor_response_aa_grid.xml' );
  Q.SENSOR_RESPONSE_POL_GRID = ...
                      fullfile( R.workfolder, 'sensor_response_pol_grid.xml' );
  Q.MBLOCK_ZA_GRID      = fullfile( R.workfolder, 'mblock_za_grid.xml' );
  Q.MBLOCK_AA_GRID      = fullfile( R.workfolder, 'mblock_aa_grid.xml' );
return
