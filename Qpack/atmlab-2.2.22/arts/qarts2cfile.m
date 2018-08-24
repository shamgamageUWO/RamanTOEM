% QARTS2CFILE   Builds a control file for ARTS
%
%    Creates a control file matching the settings in a Qarts structure.
%    The control file is provided as cell array of strings. This means
%    that the output can be combined with other control file pieces
%    by combining their string arrays. The final control file is
%    created by *strs2file*.
%    
%    The control file structure is determined by putting different 'parts'
%    together, following the format: parts = {'Generl','AtmSrfSave'}
%
%    Defined parts are:
%       Generl / GenerlSave
%       AtmSrf / AtmSrfSave
%       Absrpt / AbsrptSave
%       CldBox / CldBoxSave
%       SctMth / SctMthSave / SctMthBatch
%       RteSet
%       Sensor / SensorSave 
%       Jacobi 
%       RteExe
%       BatchC
%
%    The later options, including 'Save', adds commands to save main
%    variables for the part. These save commands are the only WSM calls that
%    are added automaticlly to the control file, everything else must be
%    specified by the qarts fields or be handled by include control files.
%
%    For fields that can be given both as a Matlab variable or name of a 
%    file, a file is generated automatically if the input a variable.
%    Output is stored in files placed in *workfolder*, with names identical
%    the WSV name and extension '.xml' (e.g. y.xml).
%
%    The parts to combine for some different tasks can be obtained by 
%    this function, using the second format version below. In this case, 
%    there shall only be one input argument, and it shall be a plain string.
%    Defined options, of general interest, for *runtype* are:
%      'GetAtmSrf'  : To obtain variables defining the atmosphere and the 
%                     surface.
%      'GetAbsTable': To obtain an absorption table.
%      'GetSensor'  : To obtain a sensor response matrix.
%      'y':         : A complete calcultion, possibly including sensor,
%                     scattering and jacobians.
%      'y_init':    : Sets up for calculation following the 'y' option, but
%                     no radiative transfer calculations performed.
%      'batch'      : Batch calculations.
%
%    In most of these cases there is a function to directly perform the
%    calculations, named as arts_"runtype", for example arts_y.
%
% FORMAT   S = qarts2cfile( Q, parts, workfolder )
%
% OUT   S           String cell array that can be passed to *strs2file*.
% IN    Q           Qarts structure
%       parts       Control file parts to include. See further above.
%       workfolder  Folder where calculations will be performed. Typically a
%                   temporary folder.
%
%             or
%
% FORMAT   parts = qarts2cfile( runtype )
%
% OUT   parts     As above
% IN    runtype   String describing type of calculation to perform.
%                 See further above.

% 2007-08-21   Large revision of function structure and code. PE 
% 
% 2004-09-08   Created by Patrick Eriksson (PE).


function S = qarts2cfile( Q, parts, workfolder )
                                                                            %&%
                                                                            %&%
%- Check input                                                              %&%
%                                                                           %&%
if ~( nargin == 1  |  nargin == 3 )                                         %&%
  error( 'The function takes 1 or 3 input arguments.' );                    %&%
end                                                                         %&%



%--- Version returning cfile parts --------------------------------------------
%
if nargin == 1
                                                                            %&%
                                                                            %&%
  if ~ischar( Q )                                                           %&%
    error( 'If number of arguments is 1, this argument must be a string' ); %&%
  end                                                                       %&%

  switch Q

  case 'GetAtmSrf'
    %
    S = { 'Generl', 'AtmSrfSave', 'CloseF' };

  case 'GetAbsTable'
    %
    S = { 'Generl', 'AbsrptSave', 'CloseF' };

  case 'GetSensor'
    %
    S = { 'Generl', 'SensorSave', 'CloseF' };
   
  case 'y_init'
    %
    S = { 'Generl', 'AtmSrf', 'Absrpt', 'RteSet', 'SensorSave', ...
          'JacobiSave', 'CloseF' };
    
  case 'y_after_init'
    %
    S = { 'Generl', 'AtmSrf', 'Absrpt', 'RteSet', 'Sensor', 'Jacobi', ...
          'CldBox', 'SctMth', 'RteExe', 'CloseF' };
   
  case 'y'
    %
    S = { 'Generl', 'AtmSrf', 'Absrpt', 'RteSet', 'Sensor', 'JacobiSave', ...
          'CldBox', 'SctMth', 'RteExe', 'CloseF' };

  case 'Batch'
    %
    S = { 'Generl', 'AtmSrf', 'Absrpt', 'RteSet', 'Sensor', 'Jacobi', ...
          'CldBox', 'SctMthBatch', 'BatchC', 'CloseF' };
                                                                            %&%
  otherwise                                                                 %&%
    error( sprintf( 'Unknown cfile type (%s) was requested.', Q ) );        %&%
  end

  return    % --->
end
%------------------------------------------------------------------------------



%--- Version returning string struture ----------------------------------------

if atmlab( 'STRICT_ASSERT' )
  qcheck( @qarts, Q );
end

S    = {};

for ip = 1 : length(parts)

  T = [];

  switch parts{ip}(1:6)
    
   case 'Generl'
    %
    T = cfile_Generl( Q, parts{ip}, workfolder );

   case 'CloseF'
    %
    T = cfile_CloseF( Q, parts{ip}, workfolder );
    
   case 'AtmSrf'
    %
    T = cfile_AtmSrf( Q, parts{ip}, workfolder );
   
   case 'Absrpt'
    %
    T = cfile_Absrpt( Q, parts{ip}, workfolder );
   
   case 'RteSet'
    %
    T = cfile_RteSet( Q, parts{ip}, workfolder );
   
   case 'Sensor'
    %
    T = cfile_Sensor( Q, parts{ip}, workfolder );
    
   case 'Jacobi'
    %
    T = cfile_Jacobi( Q, parts{ip}, workfolder );
   
   case 'CldBox'
    %
    T = cfile_CldBox( Q, parts{ip}, workfolder );
   
   case 'SctMth'
    %
    T = cfile_SctMth( Q, parts{ip}, workfolder );
   
   case 'RteExe'
    %
    T = cfile_RteExe( Q, parts{ip}, workfolder );

   case 'BatchC'
    %
    T = cfile_BatchC( Q, parts{ip}, workfolder );
    
   otherwise
    error( sprintf( 'Unknown cfile part (%s) was requested.', parts{ip} ) );
  end
  
  if ~isempty(T)
   S = { S{:} T{:} };
  end

end

return
%------------------------------------------------------------------------------
%--- End main
%------------------------------------------------------------------------------



%------------------------------------------------------------------------------
%--- Sub-functions for main control file parts
%------------------------------------------------------------------------------

%------------------------------------------------------------------------------
% Sub-function handling:
%
%    Start of cfile
%    output_file_format
%    stokes_dim
%    f_grid  
%    abs_species
%
function T = cfile_Generl( Q, partname, workfolder )
  %                                                                         %&%
  if ~( strcmp( partname, 'Generl' )  |  strcmp( partname, 'GenerlSave' ) ) %&%
    error( 'Only recognised choices are ''Generl'' and ''GenerlSave''.' );  %&%
  end                                                                       %&%
  %
  T{1} = [ '# Control file created by Atmlab function *qarts2cfile*' ];
  T{2} = 'Arts2{';
  %
  T = add_includes( T, 'Q.INCLUDES', Q.INCLUDES );
  %
  if qarts_isset( Q.WSMS_AT_START )
    T = add_wsms( T, ' WSMS_AT_START', Q.WSMS_AT_START, Q );
  end
  %
  if qarts_isset( Q.OUTPUT_FILE_FORMAT )
    rqre_datatype( Q.OUTPUT_FILE_FORMAT, @ischar, 'Q.OUTPUT_FILE_FORMAT' ); %&%
    if ~any( strcmp( lower(Q.OUTPUT_FILE_FORMAT), {'binary','ascii'} ) )    %&%
      error( 'Q.OUTPUT_FILE_FORMAT must be ''binary'' or ''ascii''.' );     %&%
    end                                                                     %&%
    T{end+1} = sprintf( 'output_file_formatSet%s%s', ...
      upper(Q.OUTPUT_FILE_FORMAT(1)), lower(Q.OUTPUT_FILE_FORMAT(2:end)) );
  end
  %
  rqre_datatype( Q.INPUT_FILE_FORMAT, @ischar, 'Q.INPUT_FILE_FORMAT' );     %&%
  if ~any( strcmp( lower(Q.INPUT_FILE_FORMAT), {'binary','double'} ) )      %&%
    error( 'Q.INPUT_FILE_FORMAT must be ''binary'' or ''double''.' );       %&%
  end                                                                       %&%
  %
  if qarts_isset( Q.STOKES_DIM )
    rqre_alltypes( Q.STOKES_DIM, {@istensor0,@iswhole}, 'Q.STOKES_DIM' );   %&%
    rqre_in_range( Q.STOKES_DIM, 1, 4, 'Q.STOKES_DIM' );                    %&%
    T{end+1} = sprintf( 'IndexSet(stokes_dim,%d)', Q.STOKES_DIM );
  end
  %  
  if qarts_isset( Q.F_GRID )
    T = file_or_data( T, 'f_grid', 'Vector', Q.F_GRID, workfolder, ...
                                                     Q.INPUT_FILE_FORMAT );
  end
  %
  if qarts_isset( Q.ATMOSPHERE_DIM )
    rqre_alltypes( Q.ATMOSPHERE_DIM, {@istensor0,@iswhole}, ...             %&%
                                                      'Q.ATMOSPHERE_DIM' ); %&%
    rqre_in_range( Q.ATMOSPHERE_DIM, 1, 3, 'Q.ATMOSPHERE_DIM' );            %&%
    T{end+1} = sprintf( 'AtmosphereSet%dD', Q.ATMOSPHERE_DIM );
  end
  %
  if qarts_isset( Q.ABS_SPECIES )
    rqre_datatype( Q.ABS_SPECIES, @isstruct, 'Q.ABS_SPECIES' );             %&%
    rqre_field( Q.ABS_SPECIES, 'TAG', 'Q.ABS_SPECIES' );                    %&%
    T{end+1} = sprintf( 'abs_speciesSet(species=[%s])', ...
                                           arts_tgs_cnvrt(Q.ABS_SPECIES) );
  end
  %
  if strcmp( partname, 'GenerlSave' )
    T{end+1} = add_savefile( 'output_file_format', workfolder );
    T{end+1} = add_savefile( 'stokes_dim', workfolder );
    T{end+1} = add_savefile( 'f_grid', workfolder );
    T{end+1} = add_savefile( 'abs_species', workfolder );
  end  
return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    Closing of cfile
%    WSMS_AT_END
%
function T = cfile_CloseF( Q, partname, workfolder )
  %
  T = [];
  %
  if qarts_isset( Q.WSMS_AT_END )
    T = add_wsms( T, ' WSMS_AT_END', Q.WSMS_AT_END, Q );
  end
  %
  T{end+1} = '}';
return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    atmosphere_dim
%    p_grid
%    lat_grid
%    lon_grid
%    t_field
%    z_field
%    vmr_field
%    refellipsoid
%    z_surface
%    winds
%
function T = cfile_AtmSrf( Q, partname, workfolder )
  %                                                                         %&%
  if ~( strcmp( partname, 'AtmSrf' )  |  strcmp( partname, 'AtmSrfSave' ) ) %&%
    error( 'Only recognised choices are ''AtmSrf'' and ''AtmSrfSave''.' );  %&%
  end                                                                       %&%
  %
  T = [];
  %
  if qarts_isset( Q.WSMS_BEFORE_ATMSURF )
    T = add_wsms( T, 'Q.WSMS_BEFORE_ATMSURF', Q.WSMS_BEFORE_ATMSURF, Q );
  end
  %
  if qarts_isset( Q.P_GRID )
    T = file_or_data( T, 'p_grid', 'Vector', Q.P_GRID, workfolder, ...
                                                     Q.INPUT_FILE_FORMAT );
  end
  %
  if qarts_isset( Q.LAT_GRID ) 
    T = file_or_data( T, 'lat_grid', 'Vector', Q.LAT_GRID, workfolder, ...
                                                         Q.INPUT_FILE_FORMAT );
  end
  if qarts_isset( Q.LON_GRID ) 
    T = file_or_data( T, 'lon_grid', 'Vector', Q.LON_GRID, workfolder, ...
                                                         Q.INPUT_FILE_FORMAT );
  end
  %
  if qarts_isset( Q.LAT_TRUE ) 
    T = file_or_data( T, 'lat_true', 'Vector', Q.LAT_TRUE, workfolder, ...
                                                         Q.INPUT_FILE_FORMAT );
  end
  if qarts_isset( Q.LON_TRUE ) 
    T = file_or_data( T, 'lon_true', 'Vector', Q.LON_TRUE, workfolder, ...
                                                         Q.INPUT_FILE_FORMAT );
  end
  %
  if qarts_isset( Q.RAW_ATMOSPHERE )
    rqre_datatype( Q.RAW_ATMOSPHERE, @ischar, 'Q.RAW_ATMOSPHERE' );         %&%
    if qarts_isset( Q.RAW_ATM_EXPAND_1D )                                   %&%
      rqre_datatype( Q.RAW_ATM_EXPAND_1D, @isboolean, ...                   %&%
                                                   'Q.RAW_ATM_EXPAND_1D' ); %&%
    end                                                                     %&%
    T{end+1} = sprintf( 'AtmRawRead(basename="%s")', Q.RAW_ATMOSPHERE );
    if qarts_isset( Q.RAW_ATM_EXPAND_1D ) & Q.RAW_ATM_EXPAND_1D
      wsm = 'AtmFieldsCalcExpand1D';
    else
      wsm = 'AtmFieldsCalc';
    end
    T{end+1} = sprintf( '%s(vmr_zeropadding=%d)', wsm, 0 );
  end
  %
  if qarts_isset( Q.T_FIELD )
    T = file_or_data( T, 't_field', 'Tensor3', Q.T_FIELD, ...
                                             workfolder, Q.INPUT_FILE_FORMAT );
  end      
  if qarts_isset( Q.VMR_FIELD )
    T = file_or_data( T, 'vmr_field', 'Tensor4', Q.VMR_FIELD, ...
                                             workfolder, Q.INPUT_FILE_FORMAT );
  end      
  if qarts_isset( Q.Z_FIELD )
    T = file_or_data( T, 'z_field', 'Tensor3', Q.Z_FIELD, ...
                                             workfolder, Q.INPUT_FILE_FORMAT );
  end
  %
  if qarts_isset( Q.WIND_U_FIELD )
    T = file_or_data( T, 'wind_u_field', 'Tensor3', Q.WIND_U_FIELD, ...
                                             workfolder, Q.INPUT_FILE_FORMAT );
  end      
  if qarts_isset( Q.WIND_V_FIELD )
    T = file_or_data( T, 'wind_v_field', 'Tensor3', Q.WIND_V_FIELD, ...
                                             workfolder, Q.INPUT_FILE_FORMAT );
  end      
  if qarts_isset( Q.WIND_W_FIELD )
    T = file_or_data( T, 'wind_w_field', 'Tensor3', Q.WIND_W_FIELD, ...
                                             workfolder, Q.INPUT_FILE_FORMAT );
  end
  %
  if qarts_isset( Q.MAG_U_FIELD )
    T = file_or_data( T, 'mag_u_field', 'Tensor3', Q.MAG_U_FIELD, ...
                                             workfolder, Q.INPUT_FILE_FORMAT );
  end      
  if qarts_isset( Q.MAG_V_FIELD )
    T = file_or_data( T, 'mag_v_field', 'Tensor3', Q.MAG_V_FIELD, ...
                                             workfolder, Q.INPUT_FILE_FORMAT );
  end      
  if qarts_isset( Q.MAG_W_FIELD )
    T = file_or_data( T, 'mag_w_field', 'Tensor3', Q.MAG_W_FIELD, ...
                                             workfolder, Q.INPUT_FILE_FORMAT );
  end
  %
  if qarts_isset(Q.REFELLIPSOID)
    rqre_datatype( Q.REFELLIPSOID, {@istensor1}, 'Q.REFELLIPSOID' );        %&%
    T = file_or_data( T, 'refellipsoid', 'Vector', Q.REFELLIPSOID, ...
                                         workfolder, Q.INPUT_FILE_FORMAT );
  end
  %
  if qarts_isset(Q.Z_SURFACE)
    T = file_or_data( T, 'z_surface', 'Matrix', Q.Z_SURFACE, ...
                                         workfolder, Q.INPUT_FILE_FORMAT );
  end
  %
  if qarts_isset(Q.VMR_NEGATIVE_OK) & Q.VMR_NEGATIVE_OK 
    T{end+1} = 'atmfields_checkedCalc(negative_vmr_ok=1)';
  else
    T{end+1} = 'atmfields_checkedCalc';
  end
  T{end+1} = 'atmgeom_checkedCalc';
  %
  if qarts_isset( Q.HSE )
    if ~isfield( Q.HSE, 'ON' ) & ~isbool( Q.HSE.ON )                        %&%
      error( ...                                                            %&%
      'When Q.HSE is present, HSE.ON must be a present and be a boolean.'); %&%
    end                                                                     %&%
    if Q.HSE.ON
      if ~isfield( Q.HSE, {'P','ACCURACY'} )                                %&%
        error( 'With Q.HSE.ON true the fields P and ACCURACY must exist' ); %&%
      end                                                                   %&%
      rqre_datatype( Q.HSE.P, @istensor0, 'Q.HSE.P' );                      %&%
      rqre_datatype( Q.HSE.ACCURACY, @istensor0, 'Q.HSE.ACCURACY' );        %&%
      T{end+1} = sprintf( 'NumericSet(p_hse,%.3f)', Q.HSE.P );      
      T{end+1} = sprintf( 'NumericSet(z_hse_accuracy,%.3f)', Q.HSE.ACCURACY );
      T{end+1} = 'z_fieldFromHSE';
    else
      % To allow dummy values for t retrievals without HSE
      if isfield( Q.HSE, 'P' ) 
        T{end+1} = sprintf( 'NumericSet(p_hse,%.3f)', Q.HSE.P );      
      end
      if isfield( Q.HSE, 'ACCURACY' ) 
        T{end+1} = sprintf( 'NumericSet(z_hse_accuracy,%.3f)', Q.HSE.ACCURACY );
      end
    end
  end
  %
  if strcmp( partname, 'AtmSrfSave' )
    T{end+1} = add_savefile( 'atmosphere_dim', workfolder );
    T{end+1} = add_savefile( 'p_grid', workfolder );
    T{end+1} = add_savefile( 'lat_grid', workfolder );
    T{end+1} = add_savefile( 'lon_grid', workfolder );
    T{end+1} = add_savefile( 't_field', workfolder );
    T{end+1} = add_savefile( 'z_field', workfolder );
    T{end+1} = add_savefile( 'vmr_field', workfolder );
    T{end+1} = add_savefile( 'refellipsoid', workfolder );
    T{end+1} = add_savefile( 'z_surface', workfolder );
  end
  
return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    basic absorption variables, such as abs_lines (if used)
%    abs_lookup  (if used)
%    propmat_clearsky_agenda
%    abs_xsec_agenda
%
function T = cfile_Absrpt( Q, partname, workfolder )
  %
  abstable = false;
  %
  T = {};
  %                                                                         %&%
  if ~( strcmp( partname, 'Absrpt' )  |  strcmp( partname, 'AbsrptSave' ) ) %&%
    error( 'Only recognised choices are ''Absrpt'' and ''AbsrptSave''.' );  %&%
  end                                                                       %&%
  %
  if qarts_isset( Q.ABSORPTION )
    rqre_datatype( Q.ABSORPTION, @ischar, 'Q.ABSORPTION' );                 %&%
    %                                                                       %&%
    if ~( strcmp(Q.ABSORPTION,'OnTheFly') | ...                             %&%
          strcmp(Q.ABSORPTION,'LoadTable') | ...                            %&%
          strcmp(Q.ABSORPTION,'CalcTable') )                                %&%
      error( ['Only recognised choices for *ABSORPTION* are ',...           %&%
                       '''OnTheFly'', ''LoadTable'' and ''CalcTable''.'] ); %&%
    end                                                                     %&%
    %
    if strcmp(Q.ABSORPTION,'OnTheFly') | strcmp(Q.ABSORPTION, 'CalcTable')
      %
      nset = qarts_isset( Q.ABS_LINESHAPE )  +  ...
             qarts_isset( Q.ABS_LINESHAPE_FACTOR ) + ...
             qarts_isset( Q.ABS_LINESHAPE_CUTOFF );
      %
      if nset  
        if nset < 3
          error( ['Q.ABS_LINESHAPE, Q.ABS_LINESHAPE_FACTOR, and ', ...
         'Q.ABS_LINESHAPE_CUTOFF must all be left empty ({}), or all be set.']);
        end
        %                                                                   %&%
        rqre_datatype( Q.ABS_LINESHAPE, @ischar, 'Q.ABS_LINESHAPE' );       %&%
        rqre_datatype( Q.ABS_LINESHAPE_FACTOR, @ischar, ...                 %&%
                                                'Q.ABS_LINESHAPE_FACTOR' ); %&%
        rqre_datatype( Q.ABS_LINESHAPE_CUTOFF, @istensor0, ...              %&%
                                                'Q.ABS_LINESHAPE_CUTOFF' ); %&%
        T{end+1} = sprintf('abs_lineshapeDefine(abs_lineshape,"%s","%s",%e)',...
             Q.ABS_LINESHAPE, Q.ABS_LINESHAPE_FACTOR, Q.ABS_LINESHAPE_CUTOFF );
      end
      %
      if qarts_isset( Q.ABS_LINES_FORMAT )
        %                                                                   %&%
        rqre_datatype( Q.ABS_LINES_FORMAT, @ischar, 'Q.ABS_LINES_FORMAT' ); %&%
        %
        if strcmp( upper(Q.ABS_LINES_FORMAT), 'NONE' )
          T{end+1} = 'abs_lines_per_speciesSetEmpty';
        else
          %
          rqre_datatype( Q.ABS_LINES, {@ischar,@isstruct,@isempty}, ...     %&%
                                                           'Q.ABS_LINES' ); %&%
          %
          if strcmp(upper(Q.ABS_LINES_FORMAT),'ARTS') & ~ischar(Q.ABS_LINES)
            filename = fullfile( workfolder, 'abs_lines.xml' );
            T = file_or_data( T, 'abs_lines', 'ArrayOfLineRecord', ...
                            Q.ABS_LINES, workfolder, Q.INPUT_FILE_FORMAT );
          else
            if ~ischar( Q.ABS_LINES )                                       %&%
              error( ...                                                    %&%
               'Q.ABS_LINES must be a filename for formats beside Arts.' ); %&%
            end                                                             %&%
            filename = Q.ABS_LINES;
          end
          %
          if qarts_isset( Q.ABS_LINES_FLIMS )
            if ~( isnumeric( Q.ABS_LINES_FLIMS )  &  ...                    %&%
                  length( Q.ABS_LINES_FLIMS ) == 2 )                        %&%
              error( ...                                                    %&%
                 'If set, Q.ABS_LINES_FLIMS must be a vector of length 2' );%&%
            end                                                             %&%
            f1 = Q.ABS_LINES_FLIMS(1);   f2 = Q.ABS_LINES_FLIMS(2);
          else
            f1 = 0;                      f2 = 1e99;
          end
          T{end+1} = sprintf( ...
                          'abs_linesReadFrom%s(abs_lines,"%s",%.3e,%.3e)', ...
                                       Q.ABS_LINES_FORMAT, filename, f1, f2 );
          T{end+1} = 'abs_lines_per_speciesCreateFromLines';
        end
      end
      %
      T = add_includes( T, 'Q.ABS_MODELS', Q.ABS_MODELS );
      %
      if qarts_isset( Q.ABS_WSMS )
        T = add_wsms( T, 'ABS_WSMS', Q.ABS_WSMS, Q );
      end
    end
        
    if qarts_isset( Q.ABS_XSEC_AGENDA )
      T = add_agenda( T, 'abs_xsec_agenda', Q.ABS_XSEC_AGENDA );
    else      
      T = add_agenda( T, 'abs_xsec_agenda', { ...
                         'abs_xsec_per_speciesInit', ...
                         'abs_xsec_per_speciesAddLines', ...
                         'abs_xsec_per_speciesAddConts' } );
    end
    T{end+1} = 'abs_xsec_agenda_checkedCalc';

    if strcmp( Q.ABSORPTION, 'OnTheFly' )
      %
      if qarts_isset( Q.PROPMAT_CLEARSKY_AGENDA )
        T = add_agenda( T, 'propmat_clearsky_agenda', ...
                                                Q.PROPMAT_CLEARSKY_AGENDA );
      else      
        T = add_agenda( T, 'propmat_clearsky_agenda', { ...
                  'Ignore(rtp_mag)', 'Ignore(rtp_los)', ...
                  'propmat_clearskyInit', 'propmat_clearskyAddOnTheFly' } );
      end
      %
    elseif strcmp( Q.ABSORPTION, 'CalcTable' )
      %
      if qarts_isset( Q.ABS_P )
        T = file_or_data( T, 'abs_p', 'Vector', Q.ABS_P, ...
                                         workfolder, Q.INPUT_FILE_FORMAT );
      end
      if qarts_isset( Q.ABS_T )
        T = file_or_data( T, 'abs_t', 'Vector', Q.ABS_T, ...
                                         workfolder, Q.INPUT_FILE_FORMAT );
      end
      if qarts_isset( Q.ABS_T_PERT )
        T = file_or_data( T, 'abs_t_pert', 'Vector', Q.ABS_T_PERT, ...
                                         workfolder, Q.INPUT_FILE_FORMAT );
      end
      if qarts_isset( Q.ABS_VMRS )
        T = file_or_data( T, 'abs_vmrs', 'Matrix', Q.ABS_VMRS, ...
                                         workfolder, Q.INPUT_FILE_FORMAT );
      end
      if qarts_isset( Q.ABS_NLS )
        rqre_datatype( Q.ABS_NLS, {@isempty,@iscellstr}, 'Q.ABS_NLS' );     %&%
        if isempty( Q.ABS_NLS )
          T{end+1} = 'abs_speciesSet(abs_species=abs_nls,species=[])';
        else
          T{end+1} = sprintf( ...
              'abs_speciesSet(abs_species=abs_nls,species=[%s])', ...
                                                   arts_tgs_cnvrt(Q.ABS_NLS) );
        end
        % As abs_species changed, this must be repeated:
        T{end+1} = 'abs_xsec_agenda_checkedCalc'; 
      end
      if qarts_isset( Q.ABS_NLS_PERT )
        T = file_or_data( T, 'abs_nls_pert', 'Vector', Q.ABS_NLS_PERT, ...
                                         workfolder, Q.INPUT_FILE_FORMAT );
      end
      %
      T{end+1} = 'abs_lookupCalc'; 
      if qarts_isset( Q.PROPMAT_CLEARSKY_AGENDA )
        T = add_agenda( T, 'propmat_clearsky_agenda', ...
                                                Q.PROPMAT_CLEARSKY_AGENDA );
      else      
        T = add_agenda( T, 'propmat_clearsky_agenda', { ...
            'Ignore(rtp_mag)', 'Ignore(rtp_los)', ...
            'propmat_clearskyInit', 'propmat_clearskyAddFromLookup' } );
      end 
      %
      abstable = true;
      %   
    elseif strcmp( Q.ABSORPTION, 'LoadTable' )
      %
      T = file_or_data( T, 'abs_lookup', 'GasAbsLookup', Q.ABS_LOOKUP, ...
                                         workfolder, Q.INPUT_FILE_FORMAT );
      T{end+1} = 'abs_lookupAdapt';
      if qarts_isset( Q.PROPMAT_CLEARSKY_AGENDA )
        T = add_agenda( T, 'propmat_clearsky_agenda', ...
                                                Q.PROPMAT_CLEARSKY_AGENDA );
      else      
        T = add_agenda( T, 'propmat_clearsky_agenda', { ...
                'Ignore(rtp_mag)', 'Ignore(rtp_los)',...
                'propmat_clearskyInit', 'propmat_clearskyAddFromLookup' } );
      end
      %
      abstable = true;
      %
    end
    
    T{end+1} = 'propmat_clearsky_agenda_checkedCalc';
    
  end %  qarts_isset( Q.ABSORPTION )

  
  if abstable  &  strcmp( partname, 'AbsrptSave' )
    T{end+1} = add_savefile( 'abs_lookup', workfolder );
  end
return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    blackbody_radiation_agenda
%    surface_rtprop_agenda
%    iy_surface_agenda
%    iy_space_agenda
%    iy_transmitter_agenda
%    ppath_lmax
%    ppath_lraytrace
%    ppath_step_agenda
%    refr_index_air__agenda
%    rte_agenda
%    sensor_pos
%    sensor_los
%    sensor_time
%    transmitter_pos
%
function T = cfile_RteSet( Q, partname, workfolder )
  %                                                                         %&%
  if ~strcmp( partname, 'RteSet' )                                          %&%
    error( 'Only recognised choices is ''RteSet''.' );                      %&%
  end                                                                       %&%
  %
  T = {};
  %
  if qarts_isset( Q.BLACKBODY_RADIATION_AGENDA )
    T = add_agenda( T, 'blackbody_radiation_agenda', ...
                                                Q.BLACKBODY_RADIATION_AGENDA );
  end    
  if qarts_isset( Q.SURFACE_RTPROP_AGENDA )
    T = add_agenda( T, 'surface_rtprop_agenda', Q.SURFACE_RTPROP_AGENDA );
  end
  if qarts_isset( Q.IY_SURFACE_AGENDA )
    T = add_agenda( T, 'iy_surface_agenda', Q.IY_SURFACE_AGENDA );
  end
  if qarts_isset( Q.IY_SPACE_AGENDA )
    T = add_agenda( T, 'iy_space_agenda', Q.IY_SPACE_AGENDA );
  end
  if qarts_isset( Q.IY_TRANSMITTER_AGENDA )
    T = add_agenda( T, 'iy_transmitter_agenda', Q.IY_TRANSMITTER_AGENDA );
  end
  if qarts_isset( Q.PPATH_LMAX )
    rqre_datatype( Q.PPATH_LMAX, @istensor0, 'Q.PPATH_LMAX' );              %&%
    T{end+1} = sprintf( 'NumericSet( ppath_lmax, %.2e )', Q.PPATH_LMAX );
  end  
  if qarts_isset( Q.PPATH_LRAYTRACE )
    rqre_datatype( Q.PPATH_LRAYTRACE, @istensor0, 'Q.PPATH_LRAYTRACE' );    %&%
    T{end+1} = sprintf( 'NumericSet( ppath_lraytrace, %.2e )', ...
                                                       Q.PPATH_LRAYTRACE );
  end  
  if qarts_isset( Q.PPATH_AGENDA )
    T = add_agenda( T, 'ppath_agenda', Q.PPATH_AGENDA );
  end
  if qarts_isset( Q.PPATH_STEP_AGENDA )
    T = add_agenda( T, 'ppath_step_agenda', Q.PPATH_STEP_AGENDA );
  end
  if qarts_isset( Q.REFR_INDEX_AIR_AGENDA )
    T = add_agenda( T, 'refr_index_air_agenda', Q.REFR_INDEX_AIR_AGENDA );
  end
  if qarts_isset( Q.SENSOR_POS )
    T = file_or_data( T, 'sensor_pos', 'Matrix', Q.SENSOR_POS,...
                                          workfolder, Q.INPUT_FILE_FORMAT );
  end
  if qarts_isset( Q.SENSOR_LOS )
    T = file_or_data( T, 'sensor_los', 'Matrix', Q.SENSOR_LOS,...
                                          workfolder, Q.INPUT_FILE_FORMAT );
  end
  if qarts_isset( Q.SENSOR_TIME )
    T = file_or_data( T, 'sensor_time', 'Vector', Q.SENSOR_TIME,...
                                          workfolder, Q.INPUT_FILE_FORMAT );
  end
  if qarts_isset( Q.TRANSMITTER_POS )
    T = file_or_data( T, 'transmitter_pos', 'Matrix', Q.TRANSMITTER_POS,...
                                          workfolder, Q.INPUT_FILE_FORMAT );
  end
  if qarts_isset( Q.IY_MAIN_AGENDA )
    T = add_agenda( T, 'iy_main_agenda', Q.IY_MAIN_AGENDA );
  end
  if qarts_isset( Q.IY_SUB_AGENDA )
    T = add_agenda( T, 'iy_sub_agenda', Q.IY_SUB_AGENDA );
  end
  if qarts_isset( Q.IY_AUX_VARS )
    T = file_or_data( T, 'iy_aux_vars', 'ArrayOfString', Q.IY_AUX_VARS,...
                                          workfolder, Q.INPUT_FILE_FORMAT );
  end
  if qarts_isset( Q.IY_UNIT )
    rqre_datatype( Q.IY_UNIT, @ischar, 'Q.IY_UNIT' );                       %&%
    T{end+1} = sprintf( 'StringSet(iy_unit,"%s")', Q.IY_UNIT );
  end
  %
  T{end+1} = add_savefile( 'sensor_pos', workfolder );
  T{end+1} = add_savefile( 'sensor_los', workfolder );
  %
return



% Sub-function handling:
%
%    y and associated variables
%    jacobian
%
function T = cfile_RteExe( Q, partname, workfolder )
  %                                                                         %&%
  if ~strcmp( partname, 'RteExe' )                                          %&%
    error( 'Only recognised choice is ''RteExe''.' );                       %&%
  end                                                                       %&%
  %
  T = add_rtecalcstart( Q );
  %       
  T{end+1} = 'sensor_checkedCalc';
  %
  if qarts_isset( Q.YCALC_WSMS )
    T = add_wsms( T, 'YCALC_WSMS', Q.YCALC_WSMS, Q );
  end
  %
  T{end+1} = add_savefile( 'y',       workfolder );
%  T{end+1} = add_savefile( 'y_f',     workfolder );
%  T{end+1} = add_savefile( 'y_pol',   workfolder );
%  T{end+1} = add_savefile( 'y_pos',   workfolder );
%  T{end+1} = add_savefile( 'y_los',   workfolder );
  T{end+1} = add_savefile( 'y_aux',   workfolder );
  %
  if qarts_isset( Q.J_DO ) 
    rqre_datatype( Q.J_DO, @isboolean, 'Q.J_DO' );                          %&%
    if Q.J_DO
      T{end+1} = add_savefile( 'jacobian', workfolder );
    end
  end
return



% Sub-function handling:
%
%    sensor variables
%
function T = cfile_Sensor( Q, partname, workfolder )
  %                                                                         %&%
  if ~( strcmp( partname, 'Sensor' )  |  strcmp( partname, 'SensorSave' ) ) %&%
    error( 'Only recognised choices are ''Sensor'' and ''SensorSave''.' );  %&%
  end                                                                       %&%

  do_parts = false;

  if ~qarts_isset( Q.SENSOR_DO )
    T = {};
    return                           % Return
  end
    
  rqre_datatype( Q.SENSOR_DO, @isboolean, 'Q.SENSOR_DO' );                  %&%
  if ~Q.SENSOR_DO
    T{1} = 'sensorOff';
    return                           % Return
  end
    
  rqre_datatype( Q.SENSOR_RESPONSE, ...                                     %&%
           {@ischar,@issparse,@iscellstr,@isstruct}, 'Q.SENSOR_RESPONSE' ); %&%

  do_parts = 0;
  %
  if isstruct( Q.SENSOR_RESPONSE )
    do_parts = 1;
  elseif ischar(Q.SENSOR_RESPONSE)  |  issparse(Q.SENSOR_RESPONSE)
    T = file_or_data( {}, 'sensor_response', 'Sparse', Q.SENSOR_RESPONSE, ...
                                         workfolder, Q.INPUT_FILE_FORMAT );
    if qarts_isset( Q.ANTENNA_DIM )
      T = file_or_data( T, 'antenna_dim', 'Index', Q.ANTENNA_DIM, ...
                                         workfolder, Q.INPUT_FILE_FORMAT );
    end
    if qarts_isset( Q.MBLOCK_ZA_GRID )
      T = file_or_data( T, 'mblock_za_grid', 'Vector', Q.MBLOCK_ZA_GRID,...
                                         workfolder, Q.INPUT_FILE_FORMAT );
    end
    if qarts_isset( Q.MBLOCK_AA_GRID )
      T = file_or_data( T, 'mblock_aa_grid', 'Vector', Q.MBLOCK_AA_GRID,...
                                         workfolder, Q.INPUT_FILE_FORMAT );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_F )
      T = file_or_data( T, 'sensor_response_f', 'Vector', ...
                    Q.SENSOR_RESPONSE_F, workfolder, Q.INPUT_FILE_FORMAT );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_ZA )
      T = file_or_data( T, 'sensor_response_za', 'Vector', ...
                   Q.SENSOR_RESPONSE_ZA, workfolder, Q.INPUT_FILE_FORMAT );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_AA )
      T = file_or_data( T, 'sensor_response_aa', 'Vector', ...
                   Q.SENSOR_RESPONSE_AA, workfolder, Q.INPUT_FILE_FORMAT );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_POL )
      T = file_or_data( T, 'sensor_response_pol', 'ArrayOfIndex', ...
                  Q.SENSOR_RESPONSE_POL, workfolder, Q.INPUT_FILE_FORMAT );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_F_GRID )
      T = file_or_data( T, 'sensor_response_f_grid', 'Vector', ...
               Q.SENSOR_RESPONSE_F_GRID, workfolder, Q.INPUT_FILE_FORMAT );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_ZA_GRID )
      T = file_or_data( T, 'sensor_response_za_grid', 'Vector', ...
              Q.SENSOR_RESPONSE_ZA_GRID, workfolder, Q.INPUT_FILE_FORMAT );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_AA_GRID )
      T = file_or_data( T, 'sensor_response_aa_grid', 'Vector', ...
              Q.SENSOR_RESPONSE_AA_GRID, workfolder, Q.INPUT_FILE_FORMAT );
    end
    if qarts_isset( Q.SENSOR_RESPONSE_POL_GRID )
      T = file_or_data( T, 'sensor_response_pol_grid', 'ArrayOfIndex', ...
             Q.SENSOR_RESPONSE_POL_GRID, workfolder, Q.INPUT_FILE_FORMAT );
    end
  elseif iscellstr( Q.SENSOR_RESPONSE ) 
    T = Q.SENSOR_RESPONSE;
  end

  %- Structure version:
  %
  if do_parts  
    %
    H = Q.SENSOR_RESPONSE;
    %
    qcheck( @qartsSensor, H );

    % Find out sensor structure
    parts{1} = 'init';
    if qarts_isset( H.SENSOR_POL )
      parts{end+1} = 'polarisation';
    end
    if qarts_isset( H.ANTENNA_DO ) & H.ANTENNA_DO
      parts{end+1} = 'antenna';
    end
    if qarts_isset( H.FILL_FGRID )
      parts{end+1} = 'fill_fgrid';
    end
    if qarts_isset( H.MIXER_DO ) & H.MIXER_DO 
      parts{end+1} = 'mixer';
    end
    if qarts_isset( H.IF2RF ) & H.IF2RF 
      parts{end+1} = 'if2rf';
    end
    if qarts_isset( H.BACKEND_DO ) & H.BACKEND_DO
      parts{end+1} = 'backend';
    end
    if qarts_isset( H.BEAM_SWITCHING )  &  H.BEAM_SWITCHING
      parts{end+1} = 'beamswitch';
    end
    % If multiple LO are given exchange 'mixer' for 'multimixer' and 'remove
    % 'backend' 
    if( any(strcmp( 'mixer', parts ))   &  ...
        any(strcmp( 'backend', parts )) &  length(H.LO) > 1 )
      %
      ir        = find( strcmp('mixer',parts) );
      parts{ir} = 'multimixer';
      parts     = parts{ find( ~strcmp('backend',parts) ) };
    end
    parts{end+1} = 'close';
        
    % Start writing to output structure
    T = {};

    for it = 1 : length(parts)
      %
      U = {};

      switch parts{it}

      case 'init'
        U{1} = ['# Start of sensor part:'];
        if qarts_isset( H.ANTENNA_DO )  &  ~H.ANTENNA_DO
          U{end+1} = 'AntennaOff';
        end
        if qarts_isset( Q.ANTENNA_DIM ) 
          rqre_alltypes( Q.ANTENNA_DIM, {@istensor0,@iswhole}, ...          %&%
                                                          'Q.STOKES_DIM' ); %&%
          rqre_in_range( Q.ANTENNA_DIM, 1, 2, 'Q.ANTENNA_DIM' );            %&%
          U{end+1} = sprintf( 'AntennaSet%dD', Q.ANTENNA_DIM );
        end
        if qarts_isset( Q.MBLOCK_ZA_GRID ) 
          U = file_or_data( U, 'mblock_za_grid', 'Vector', ...
                       Q.MBLOCK_ZA_GRID, workfolder, Q.INPUT_FILE_FORMAT );
        end        
        if qarts_isset( Q.MBLOCK_AA_GRID ) 
          U = file_or_data( U, 'mblock_aa_grid', 'Vector', ...
                       Q.MBLOCK_AA_GRID, workfolder, Q.INPUT_FILE_FORMAT );
        end
        if qarts_isset( H.SENSOR_NORM )
          rqre_datatype( H.SENSOR_NORM, @isboolean, ...                     %&%
                                         'Q.SENSOR_RESPONSE.SENSOR_NORM' ); %&%
          U{end+1} = sprintf( 'IndexSet(sensor_norm,%d)', H.SENSOR_NORM );
        end
        U{end+1} = 'sensor_responseInit';
        
      case 'fill_fgrid'
        v = qarts_get( H.FILL_FGRID );
        if ~( isnumeric(v) & isvector(v) & length(v) == 2 )                 %&%
          error( 'The sensor *FILL_FGRID* must be a vector of length 2.' ); %&%
        end                                                                 %&%
        U{end+1} = sprintf( ...
           'sensor_responseFillFgrid(polyorder=%d,nfill=%d)', v(1), v(2) );
       
      case 'polarisation'
        if qarts_isset( H.SENSOR_POL )
          U = file_or_data( U, 'sensor_pol', 'ArrayOfIndex', ...
                               H.SENSOR_POL, workfolder, Q.INPUT_FILE_FORMAT );
        end
        U{end+1} = 'sensor_responsePolarisation';
       
       case 'antenna'
        if qarts_isset( H.ANTENNA_LOS )
          U = file_or_data( U, 'antenna_los', 'Matrix', H.ANTENNA_LOS, ...
                                        workfolder, Q.INPUT_FILE_FORMAT );
        end
        if qarts_isset( H.ANTENNA_RESPONSE )
          U = file_or_data( U, 'antenna_response', 'GriddedField4',...
                    H.ANTENNA_RESPONSE, workfolder, Q.INPUT_FILE_FORMAT );
        end
        U{end+1} = 'sensor_responseAntenna';
        
      case 'mixer'
        if qarts_isset( H.LO ) 
          U = file_or_data( U, 'lo', 'Numeric', H.LO, ...
                                        workfolder, Q.INPUT_FILE_FORMAT );
        end
        if qarts_isset( H.SIDEBAND_RESPONSE )           
          U = file_or_data( U, 'sideband_response', 'GriddedField1', ...
                   H.SIDEBAND_RESPONSE, workfolder, Q.INPUT_FILE_FORMAT );
        end
        if qarts_isset( H.SIDEBAND_MODE )           
          U = file_or_data( U, 'sideband_mode', 'String', ...
                   H.SIDEBAND_MODE, workfolder, Q.INPUT_FILE_FORMAT );
        end
        U{end+1} = 'sensor_responseMixer';

      case 'if2rf'
        U{end+1} = 'sensor_responseIF2RF';
        
      case 'backend'
        if qarts_isset( H.F_BACKEND ) 
          U = file_or_data( U, 'f_backend', 'Vector', H.F_BACKEND, ...
                                        workfolder, Q.INPUT_FILE_FORMAT );
        end        
        if qarts_isset( H.BACKEND_CHANNEL_RESPONSE )
          U = file_or_data( U, 'backend_channel_response', ...
            'ArrayOfGriddedField1', H.BACKEND_CHANNEL_RESPONSE, ...
                                        workfolder, Q.INPUT_FILE_FORMAT );
        end
        if ~qarts_isset( H.F_SWITCHING )
          U{end+1} = 'sensor_responseBackend';
        else
          df = qarts_get( H.F_SWITCHING );
          if ~( isnumeric(df) & isvector(df) & length(df)==2 )              %&%
          error( 'The sensor *F_SWITCHING* must be a vector of length 2.' );%&%
          end                                                               %&%
          U{end+1} = 'sensor_responseBackendFrequencySwitching(';
          U{end+1} = sprintf( '   df1=%.6e, df2=%.6e)', df(1), df(2) );
        end
        
       case 'multimixer'
        if qarts_isset( H.F_SWITCHING )
          error( 'The sensor *F_SWITCHING* option can not be used together ',...
                                                         'with multiple LO.' );
        end
        if qarts_isset( H.LO ) 
          U = file_or_data( U, 'lo_multi', 'Vector', H.LO, workfolder, ...
                                                     Q.INPUT_FILE_FORMAT );
        end
        if qarts_isset( H.SIDEBAND_RESPONSE )           
          U = file_or_data( U, 'sideband_response_multi', ...
                     'ArrayOfGriddedField1', H.SIDEBAND_RESPONSE, ...
                                         workfolder, Q.INPUT_FILE_FORMAT );
        end   
        if qarts_isset( H.SIDEBAND_MODE )           
          U = file_or_data( U, 'sideband_mode_multi', 'ArrayOfString', ...
                            H.SIDEBAND_MODE, workfolder, Q.INPUT_FILE_FORMAT );
        end   
        if qarts_isset( H.F_BACKEND ) 
          U = file_or_data( U, 'f_backend_multi', 'ArrayOfVector', ...
                            H.F_BACKEND, workfolder, Q.INPUT_FILE_FORMAT );
        end        
        if qarts_isset( H.BACKEND_CHANNEL_RESPONSE )
          U = file_or_data( U, 'backend_channel_response_multi', ....
                 'ArrayOfArrayOfGriddedField1', H.BACKEND_CHANNEL_RESPONSE, ... 
                                         workfolder, Q.INPUT_FILE_FORMAT );
        end
        U{end+1} = 'sensor_responseMultiMixerBackend';
        
      case 'beamswitch'
        U{1} = 'sensor_responseBeamSwitching';
        
      case 'close'
        U{1} = '# End of sensor part';

      otherwise
        error(sprintf('Unknown action (%s) was requested.',parts{it}));
      end

      T = { T{:} U{:} };
    end
  end
  
  %- Saving
  %
  if strcmp( partname, 'SensorSave' )
    T{end+1} = add_savefile( 'sensor_response',          workfolder );
    T{end+1} = add_savefile( 'sensor_response_f',        workfolder );
    T{end+1} = add_savefile( 'sensor_response_za',       workfolder );
    T{end+1} = add_savefile( 'sensor_response_aa',       workfolder );
    T{end+1} = add_savefile( 'sensor_response_pol',      workfolder );
    T{end+1} = add_savefile( 'sensor_response_f_grid',   workfolder );
    T{end+1} = add_savefile( 'sensor_response_za_grid',  workfolder );
    T{end+1} = add_savefile( 'sensor_response_aa_grid',  workfolder );
    T{end+1} = add_savefile( 'sensor_response_pol_grid', workfolder );
    T{end+1} = add_savefile( 'antenna_dim',              workfolder );
    T{end+1} = add_savefile( 'mblock_za_grid',           workfolder );
    T{end+1} = add_savefile( 'mblock_aa_grid',           workfolder );
  end

return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    jacobians
%
function T = cfile_Jacobi( Q, partname, workfolder )
  %
  if ~( strcmp( partname, 'Jacobi' ) |  strcmp( partname, 'JacobiSave' ) )
    error( 'Only recognised choices are ''Jacobi'' and ''JacobiSave''.' );
  end

  do_parts = false;
  
  if ~qarts_isset( Q.J_DO )
     T={};
     return
  elseif ~Q.J_DO
    T{1} = 'jacobianOff';
    return
  end


  T{1} = 'jacobianInit';

  %- Gas species
  %                                                                         %&%
  rqre_field( Q.ABS_SPECIES, 'RETRIEVE', 'Q.ABS_SPECIES' );                 %&%
  %
  if any( [ Q.ABS_SPECIES.RETRIEVE ] == true )      
    %                                                                       %&%
    if ~isfield( Q.ABS_SPECIES, {'UNIT','GRIDS'} )                          %&%
      error( ['With Q.ABS_SPECIES.RETRIEVED true the fields ', ...          %&%
              '''UNIT'' and ''GRIDS'' must exist.'] );                      %&%
    end                                                                     %&%
    %
    for i = 1 : length(Q.ABS_SPECIES)
      %
      rqre_datatype( Q.ABS_SPECIES(i).RETRIEVE, @isboolean, ...             %&%
                                 sprintf('Q.ABS_SPECIES(%d).RETRIEVE',i) ); %&%
      %
      if Q.ABS_SPECIES(i).RETRIEVE
        %
        rqre_datatype( Q.ABS_SPECIES(i).UNIT, @ischar, ...                  %&%
                                     sprintf('Q.ABS_SPECIES(%d).UNIT',i) ); %&%
        rqre_datatype( Q.ABS_SPECIES(i).GRIDS, @iscell, ...                 %&%
                                    sprintf('Q.ABS_SPECIES(%d).GRIDS',i) ); %&%
        if length(Q.ABS_SPECIES(i).GRIDS) ~= 3                              %&%
              error( 'Q.ABS_SPECIES(%d).GRIDS has not length 3.', i );      %&%
        end                                                                 %&%
        %
        name1    = sprintf( 'gas%d_jac_p_grid', i );
        T{end+1} = create_var( name1, 'Vector' );
        T = file_or_data( T, name1, 'Vector', Q.ABS_SPECIES(i).GRIDS{1},...
                                  workfolder, Q.INPUT_FILE_FORMAT, name1 );
        name2 = sprintf( 'gas%d_jac_lat_grid', i );
        T{end+1} = create_var( name2, 'Vector' );
        T = file_or_data( T, name2, 'Vector', Q.ABS_SPECIES(i).GRIDS{2},...
                                  workfolder, Q.INPUT_FILE_FORMAT, name2 );
        name3 = sprintf( 'gas%d_jac_lon_grid', i );
        T{end+1} = create_var( name3, 'Vector' );
        T = file_or_data( T, name3, 'Vector', Q.ABS_SPECIES(i).GRIDS{3},...
                                  workfolder, Q.INPUT_FILE_FORMAT, name3 );

        T{end+1} ='jacobianAddAbsSpecies(jacobian_quantities,jacobian_agenda,';
        T{end+1} = '   atmosphere_dim,p_grid,lat_grid,lon_grid,';
        T{end+1} = sprintf( '  %s,%s,%s,', name1, name2, name3 );
        T{end+1} = sprintf( '  %s,', arts_tgs_cnvrt(Q.ABS_SPECIES(i).TAG) );
        T{end+1} = sprintf( '  "analytical","%s",0.0)', Q.ABS_SPECIES(i).UNIT);
      end
    end % for
  end % if

  
  %- Atmospheric temperatures
  %                                                                         %&%
  if qarts_isset( Q.T )
    if ~isfield( Q.T, 'RETRIEVE' )                                          %&%
       error( 'When Q.T exists, the field RETRIEVE must be set.' );         %&%
    end                                                                     %&%
    rqre_datatype( Q.T.RETRIEVE, @isboolean, 'Q.T.RETRIEVE' );              %&%
    if Q.T.RETRIEVE
      %                                                                     %&%
      if ~isfield( Q.T, {'GRIDS'} )                                         %&%
        error( 'With Q.T.RETRIEVED true the field ''GRIDS'' must exist.' ); %&%
      end                                                                   %&%
      rqre_datatype( Q.T.GRIDS, @iscell, 'Q.T.GRIDS' );                     %&%
      if length(Q.T.GRIDS) ~= 3                                             %&%
        error( 'Q.T.GRIDS has not length 3.' );                             %&%
      end                                                                   %&%
      %
      name1    = 'temperature_jac_p_grid';
      T{end+1} = create_var( name1, 'Vector' );
      T        = file_or_data( T, name1, 'Vector', Q.T.GRIDS{1}, ...
                                workfolder, Q.INPUT_FILE_FORMAT, name1 );
      name2    = 'temperature_jac_lat_grid';
      T{end+1} = create_var( name2, 'Vector' );
      T        = file_or_data( T, name2, 'Vector', Q.T.GRIDS{2}, ...
                                workfolder, Q.INPUT_FILE_FORMAT, name2 );
      name3    = 'temperature_jac_lon_grid';
      T{end+1} = create_var( name3, 'Vector' );
      T        = file_or_data( T, name3, 'Vector', Q.T.GRIDS{3},...
                                    workfolder, Q.INPUT_FILE_FORMAT, name3 );
      hse = 'on'; method = 'analytical'; dt = 1;
      if isfield( Q.T, 'HSE' ) & qarts_isset( Q.T.HSE ), hse = Q.T.HSE; end
      if isfield( Q.T, 'METHOD' ) & qarts_isset( Q.T.METHOD ), 
        method = Q.T.METHOD; 
      end
      if isfield( Q.T, 'DT' ) & qarts_isset( Q.T.DT ), dt = Q.T.DT; end      
      T{end+1} ='jacobianAddTemperature(jacobian_quantities,jacobian_agenda,';
      T{end+1} = '   atmosphere_dim,p_grid,lat_grid,lon_grid,';
      T{end+1} = sprintf( '  %s,%s,%s,', name1, name2, name3 );
      T{end+1} = sprintf( '  "%s","%s",%.3f)', hse, method, dt );
    end  
  end

  %- Wind, U
  %                                                                         %&%
  if qarts_isset( Q.WIND_U )
    if ~isfield( Q.WIND_U, 'RETRIEVE' )                                     %&%
       error( 'When Q.WIND_U exists, the field RETRIEVE must be set.' );    %&%
    end                                                                     %&%
    rqre_datatype( Q.WIND_U.RETRIEVE, @isboolean, 'Q.WIND_U.RETRIEVE' );    %&%
    if Q.WIND_U.RETRIEVE                                                    
      %                                                                     %&%
      if ~isfield( Q.WIND_U, {'GRIDS'} )                                    %&%
        error( ...                                                          %&%
          'With Q.WIND_U.RETRIEVED true the field ''GRIDS'' must exist.' ); %&%
      end                                                                   %&%
      rqre_datatype( Q.WIND_U.GRIDS, @iscell, 'Q.WIND_U.GRIDS' );           %&%
      if length(Q.WIND_U.GRIDS) ~= 3                                        %&%
        error( 'Q.WIND_U.GRIDS has not length 3.' );                        %&%
      end                                                                   %&%
      %
      name1    = 'wind_u_jac_p_grid';
      T{end+1} = create_var( name1, 'Vector' );
      T        = file_or_data( T, name1, 'Vector', Q.WIND_U.GRIDS{1}, ...
                                workfolder, Q.INPUT_FILE_FORMAT, name1 );
      name2    = 'wind_u_jac_lat_grid';
      T{end+1} = create_var( name2, 'Vector' );
      T        = file_or_data( T, name2, 'Vector', Q.WIND_U.GRIDS{2}, ...
                                workfolder, Q.INPUT_FILE_FORMAT, name2 );
      name3    = 'wind_u_jac_lon_grid';
      T{end+1} = create_var( name3, 'Vector' );
      T        = file_or_data( T, name3, 'Vector', Q.WIND_U.GRIDS{3},...
                                    workfolder, Q.INPUT_FILE_FORMAT, name3 );
      T{end+1} ='jacobianAddWind(jacobian_quantities,jacobian_agenda,';
      T{end+1} = '   atmosphere_dim,p_grid,lat_grid,lon_grid,';
      T{end+1} = sprintf( '  %s,%s,%s,"u")', name1, name2, name3 );
    end  
  end  

  %- Wind, V
  %                                                                         %&%
  if qarts_isset( Q.WIND_V )
    if ~isfield( Q.WIND_V, 'RETRIEVE' )                                     %&%
       error( 'When Q.WIND_V exists, the field RETRIEVE must be set.' );    %&%
    end                                                                     %&%
    rqre_datatype( Q.WIND_V.RETRIEVE, @isboolean, 'Q.WIND_V.RETRIEVE' );    %&%
    if Q.WIND_V.RETRIEVE                                                    
      %                                                                     %&%
      if ~isfield( Q.WIND_V, {'GRIDS'} )                                    %&%
        error( ...                                                          %&%
          'With Q.WIND_V.RETRIEVED true the field ''GRIDS'' must exist.' ); %&%
      end                                                                   %&%
      rqre_datatype( Q.WIND_V.GRIDS, @iscell, 'Q.WIND_V.GRIDS' );           %&%
      if length(Q.WIND_V.GRIDS) ~= 3                                        %&%
        error( 'Q.WIND_V.GRIDS has not length 3.' );                        %&%
      end                                                                   %&%
      %
      name1    = 'wind_v_jac_p_grid';
      T{end+1} = create_var( name1, 'Vector' );
      T        = file_or_data( T, name1, 'Vector', Q.WIND_V.GRIDS{1}, ...
                                workfolder, Q.INPUT_FILE_FORMAT, name1 );
      name2    = 'wind_v_jac_lat_grid';
      T{end+1} = create_var( name2, 'Vector' );
      T        = file_or_data( T, name2, 'Vector', Q.WIND_V.GRIDS{2}, ...
                                workfolder, Q.INPUT_FILE_FORMAT, name2 );
      name3    = 'wind_v_jac_lon_grid';
      T{end+1} = create_var( name3, 'Vector' );
      T        = file_or_data( T, name3, 'Vector', Q.WIND_V.GRIDS{3},...
                                    workfolder, Q.INPUT_FILE_FORMAT, name3 );
      T{end+1} ='jacobianAddWind(jacobian_quantities,jacobian_agenda,';
      T{end+1} = '   atmosphere_dim,p_grid,lat_grid,lon_grid,';
      T{end+1} = sprintf( '  %s,%s,%s,"v")', name1, name2, name3 );
    end  
  end  
  
  %- Wind, W
  %                                                                         %&%
  if qarts_isset( Q.WIND_W )
    if ~isfield( Q.WIND_W, 'RETRIEVE' )                                     %&%
       error( 'When Q.WIND_W exists, the field RETRIEVE must be set.' );    %&%
    end                                                                     %&%
    rqre_datatype( Q.WIND_W.RETRIEVE, @isboolean, 'Q.WIND_W.RETRIEVE' );    %&%
    if Q.WIND_W.RETRIEVE                                                    
      %                                                                     %&%
      if ~isfield( Q.WIND_W, {'GRIDS'} )                                    %&%
        error( ...                                                          %&%
          'With Q.WIND_W.RETRIEVED true the field ''GRIDS'' must exist.' ); %&%
      end                                                                   %&%
      rqre_datatype( Q.WIND_W.GRIDS, @iscell, 'Q.WIND_W.GRIDS' );           %&%
      if length(Q.WIND_W.GRIDS) ~= 3                                        %&%
        error( 'Q.WIND_W.GRIDS has not length 3.' );                        %&%
      end                                                                   %&%
      %
      name1    = 'wind_w_jac_p_grid';
      T{end+1} = create_var( name1, 'Vector' );
      T        = file_or_data( T, name1, 'Vector', Q.WIND_W.GRIDS{1}, ...
                                workfolder, Q.INPUT_FILE_FORMAT, name1 );
      name2    = 'wind_w_jac_lat_grid';
      T{end+1} = create_var( name2, 'Vector' );
      T        = file_or_data( T, name2, 'Vector', Q.WIND_W.GRIDS{2}, ...
                                workfolder, Q.INPUT_FILE_FORMAT, name2 );
      name3    = 'wind_w_jac_lon_grid';
      T{end+1} = create_var( name3, 'Vector' );
      T        = file_or_data( T, name3, 'Vector', Q.WIND_W.GRIDS{3},...
                                    workfolder, Q.INPUT_FILE_FORMAT, name3 );
      T{end+1} ='jacobianAddWind(jacobian_quantities,jacobian_agenda,';
      T{end+1} = '   atmosphere_dim,p_grid,lat_grid,lon_grid,';
      T{end+1} = sprintf( '  %s,%s,%s,"w")', name1, name2, name3 );
    end  
  end  
  
  %- Frequency
  %
  if qarts_isset(Q.FSHIFTFIT) 
    rqre_datatype( Q.FSHIFTFIT, @isstruct, 'Q.FSHIFTFIT' );                 %&%
    rqre_field( Q.FSHIFTFIT, 'RETRIEVE', 'Q.FSHIFTFIT' );                   %&%
    rqre_datatype( Q.FSHIFTFIT.RETRIEVE, @isboolean, ...                    %&%
                                                 'Q.FSHIFTFIT.RETRIEVAL' ); %&%
    if Q.FSHIFTFIT.RETRIEVE
      rqre_field( Q.FSHIFTFIT, 'DF', 'Q.FSHIFTFIT' );                       %&%
      rqre_datatype( Q.FSHIFTFIT.DF, @istensor0, 'Q.FSHIFTFIT.DF' );        %&%
      T{end+1} = 'jacobianAddFreqShift(jacobian_quantities,jacobian_agenda,';
      T{end+1} = sprintf('   f_grid,sensor_pos,sensor_time,0,%f)', ...
                                                            Q.FSHIFTFIT.DF );
    end
  end
  if qarts_isset(Q.FSTRETCHFIT) 
    rqre_datatype( Q.FSTRETCHFIT, @isstruct, 'Q.FSTRETCHFIT' );             %&%
    rqre_field( Q.FSTRETCHFIT, 'RETRIEVE', 'Q.FSTRETCHFIT' );               %&%
    rqre_datatype( Q.FSTRETCHFIT.RETRIEVE, @isboolean, ...                  %&%
                                               'Q.FSTRETCHFIT.RETRIEVAL' ); %&%
    if Q.FSTRETCHFIT.RETRIEVE
      rqre_field( Q.FSTRETCHFIT, 'DF', 'Q.FSTRETCHFIT' );                   %&%
      rqre_datatype( Q.FSTRETCHFIT.DF, @istensor0, 'Q.FSTRETCHFIT.DF' );    %&%
      T{end+1} = 'jacobianAddFreqStretch(jacobian_quantities,jacobian_agenda,';
      T{end+1} = sprintf('   f_grid,sensor_pos,sensor_time,0,%f)', ...
                                                          Q.FSTRETCHFIT.DF );
    end
  end

  %- Pointing
  %
  if qarts_isset(Q.POINTING) 
    rqre_datatype( Q.POINTING, @isstruct, 'Q.POINTING' );                   %&%
    rqre_field( Q.POINTING, 'RETRIEVE', 'Q.POINTING' );                     %&%
    rqre_datatype( Q.POINTING.RETRIEVE, @isboolean, ...                     %&%
                                                  'Q.POINTING.RETRIEVAL' ); %&%
    if Q.POINTING.RETRIEVE
      rqre_field( Q.POINTING, 'DZA', 'Q.POINTING' );                        %&%
      rqre_datatype( Q.POINTING.DZA, @istensor0, 'Q.POINTING.DZA' );        %&%
      rqre_field( Q.POINTING, 'POLY_ORDER', 'Q.POINTING' );                 %&%
      rqre_alltypes( Q.POINTING.POLY_ORDER, {@istensor0,@iswhole}, ...      %&%
                                                 'Q.POINTING.POLY_ORDER' ); %&%
      rqre_field( Q.POINTING, 'CALCMODE', 'Q.POINTING' );                   %&%
      rqre_datatype( Q.POINTING.CALCMODE, @ischar, Q.POINTING.CALCMODE' );  %&%
      T{end+1} = 'jacobianAddPointingZa(jacobian_quantities, jacobian_agenda,';
      T{end+1} =  '   sensor_pos, sensor_time,';
      T{end+1} = sprintf( '   %d,"%s",%d)', Q.POINTING.POLY_ORDER, ...
                                         Q.POINTING.CALCMODE, Q.POINTING.DZA );
    end
  end

  %- Polyfit
  %
  if qarts_isset(Q.POLYFIT) 
    rqre_datatype( Q.POLYFIT, @isstruct, 'Q.POLYFIT' );                     %&%
    rqre_field( Q.POLYFIT, 'RETRIEVE', 'Q.POLYFIT' );                       %&%
    rqre_datatype( Q.POLYFIT.RETRIEVE, @isboolean, 'Q.POLYFIT.RETRIEVAL' ); %&%
    if Q.POLYFIT.RETRIEVE
      rqre_field( Q.POLYFIT, 'ORDER', 'Q.POLYFIT' );                        %&%
      rqre_alltypes( Q.POLYFIT.ORDER, {@istensor0,@iswhole}, ...            %&%
                                                       'Q.POLYFIT.ORDER' ); %&%
      T{end+1} = 'jacobianAddPolyfit(jacobian_quantities, jacobian_agenda,';
      T{end+1} =  '   sensor_response_pol_grid,sensor_response_za_grid,';
      T{end+1} = sprintf( '   sensor_pos,%d)', Q.POLYFIT.ORDER );
    end
  end
  
  %- Sinefit
  %
  if qarts_isset(Q.SINEFIT) 
    rqre_datatype( Q.SINEFIT, @isstruct, 'Q.SINEFIT' );                     %&%
    rqre_field( Q.SINEFIT, 'RETRIEVE', 'Q.SINEFIT' );                       %&%
    rqre_datatype( Q.SINEFIT.RETRIEVE, @isboolean, 'Q.SINEFIT.RETRIEVAL' ); %&%
    if Q.SINEFIT.RETRIEVE
      rqre_field( Q.SINEFIT, 'PERIODS', 'Q.SINEFIT' );                      %&%
      rqre_datatype( Q.SINEFIT.PERIODS, @istensor1, 'Q.SINEFIT.PERIODS' );  %&%
      T{end+1} = 'jacobianAddSinefit(jacobian_quantities, jacobian_agenda,';
      T{end+1} =  '   sensor_response_pol_grid,sensor_response_za_grid,';
      s = sprintf( '   sensor_pos,[%f', Q.SINEFIT.PERIODS(1) );
      for i = 2:length(Q.SINEFIT.PERIODS)
        s = sprintf( '%s,%f', s, Q.SINEFIT.PERIODS(i) );
      end
      s = [ s, '])' ];
      T{end+1} = s;
    end
  end
  
  T{end+1} = 'jacobianClose';    

  
  %- Saving 
  %
  if strcmp( partname, 'JacobiSave' )
    T{end+1} = add_savefile( 'jacobian_quantities', workfolder );
    T{end+1} = add_savefile( 'jacobian_indices', workfolder );
  end
return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    cloudbox_on
%    cloudbox_limits
%    pnd_field
%    scat_data_array
%    spt_calc_agenda
%    opt_prop_gas_agenda
%
function T = cfile_CldBox( Q, partname, workfolder )
  %                                                                         %&%
  if ~( strcmp( partname, 'CldBox' )  |  strcmp( partname, 'CldBoxSave' ) ) %&%
    error( 'Only recognised choices are ''CldBox'' and ''CldBoxSave''.' );  %&%
  end                                                                       %&%

  if ~qarts_isset(Q.CLOUDBOX_DO)
     T={};
     return
  end

  rqre_datatype( Q.CLOUDBOX_DO, @isboolean, 'Q.CLOUDBOX_DO' );              %&%
  
  if ~Q.CLOUDBOX_DO
    T{1}     = 'cloudboxOff';
    T{end+1} = 'cloudbox_checkedCalc';
    return
  end
  
  if ~isstruct( Q.CLOUDBOX )                                                %&%
    error( 'Q.CLOUDBOX must be a structure if Q.CLOUD_BOX=1.' );            %&%
  end                                                                       %&%

  %= Check that all fields are present
  %
  qcheck( @qartsCloudbox, Q.CLOUDBOX );

  rqre_datatype( Q.CLOUDBOX.METHOD, @ischar, 'Q.CLOUDBOX.METHOD' );         %&%
  if ~any( strcmp( upper(Q.CLOUDBOX.METHOD), {'DOIT','MC','FOS','NONE'} ) ) %&%
    error( ...                                                              %&% 
       'Q.CLOUDBOX.METHOD must be ''DOIT'', ''MC'', ''FOS'' or ''none''.' ) %&%
  end                                                                       %&%

  %= Cloudbox
  %
  if qarts_isset (Q.CLOUDBOX.LIMITS)
    rqre_alltypes( Q.CLOUDBOX.LIMITS, {@isnumeric,@isvector}, ...           %&%
                                                    'Q.CLOUDBOX.LIMITS' );  %&%
    nlims = length(Q.CLOUDBOX.LIMITS);
    if  nlims < 6
      limits          = zeros(1,6);
      limits(1:nlims) = Q.CLOUDBOX.LIMITS;
    else
      limits = Q.CLOUDBOX.LIMITS(1:6);
    end
    T{1}     = 'cloudboxSetManuallyAltitude(';
    T{end+1} = '   cloudbox_on,cloudbox_limits,atmosphere_dim,z_field,';
    T{end+1} = sprintf( ...
            '   lat_grid,lon_grid,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f', limits );
    T{end+1} = ')';
  end

  if qarts_isset( Q.CLOUDBOX.PARTICLE_MASSES )
    T = file_or_data( T, 'particle_masses', 'Matrix', ...
                 Q.CLOUDBOX.PARTICLE_MASSES, workfolder, Q.INPUT_FILE_FORMAT );
  end
  
  %= Particle field and single scattering data
  %
  nset = qarts_isset(Q.CLOUDBOX.PND_FIELD) + qarts_isset(Q.CLOUDBOX.SCAT_DATA);
  %                                                                         %&%
  if nset == 1                                                              %&%
    error( 'Q.CLOUDBOX.PND_FIELD and Q.CLOUDBOX.SCAT_DATA must both ',...   %&%
                                    'be set, or both be undefined ({}).' ); %&%
  end                                                                       %&%
  if nset                                                                   
    if length(Q.CLOUDBOX.PND_FIELD) ~= length(Q.CLOUDBOX.SCAT_DATA)         %&%
      error( 'Q.CLOUDBOX.PND_FIELD and Q.CLOUDBOX.SCAT_DATA must have ',... %&%
                                                          'same length.' ); %&%
    end                                                                     %&%
    %
    T{end+1}  = 'ParticleTypeInit';
    do_pfCALC = false;
    %
    for i = 1 : length(Q.CLOUDBOX.PND_FIELD)
      if isstr( Q.CLOUDBOX.SCAT_DATA{i} )
        sfile = Q.CLOUDBOX.SCAT_DATA{i};
      else
        sfile = fullfile( workfolder, sprintf( 'scat_data_array_%d.xml', i ) );
        xmlStore( sfile, Q.CLOUDBOX.SCAT_DATA{i}, 'SingleScatteringData',...
                                                       Q.INPUT_FILE_FORMAT );
      end
      if isstr( Q.CLOUDBOX.PND_FIELD{i} )
        pfile = Q.CLOUDBOX.PND_FIELD{i};
      else
        pfile = fullfile( workfolder, sprintf( 'pnd_field_raw_%d.xml', i ) ); 
        xmlStore( pfile, Q.CLOUDBOX.PND_FIELD{i}, 'GriddedField3', ...
                                                       Q.INPUT_FILE_FORMAT );
      end
      %
      if length(pfile)
        do_pfCALC = true;
      end
      %
      T{end+1} = 'ParticleTypeAdd(';
      T{end+1} = sprintf('   filename_scat_data="%s",',sfile );
      T{end+1} = sprintf('   filename_pnd_field="%s")',pfile );
    end
    %
    if do_pfCALC 
      T{end+1} = 'pnd_fieldCalc';
    end
  end
  %
  T{end+1} = 'cloudbox_checkedCalc';

  %= Agendas for scattering properties 
  %
  if qarts_isset(Q.CLOUDBOX.OPT_PROP_PART_AGENDA)
    T = add_agenda( T, 'opt_prop_part_agenda', Q.CLOUDBOX.OPT_PROP_PART_AGENDA);
  end
  if qarts_isset(Q.CLOUDBOX.SPT_CALC_AGENDA)
    T = add_agenda( T, 'spt_calc_agenda', Q.CLOUDBOX.SPT_CALC_AGENDA );
  end

  %= Saving?
  %
  if strcmp( partname, 'CldBoxSave' )
    T{end+1} = add_savefile( 'cloudbox_on', workfolder );
    T{end+1} = add_savefile( 'cloudbox_limits', workfolder );
    T{end+1} = add_savefile( 'pnd_field', workfolder );
    T{end+1} = add_savefile( 'scat_data_array', workfolder );
  end
return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    variables for the different scattering methods
%
function T = cfile_SctMth( Q, partname, workfolder )
  %                                                                         %&%
  if ~( strcmp( partname, 'SctMth' )  |  ...                                %&%
        strcmp( partname, 'SctMthSave' )  |  ...                            %&%
        strcmp( partname, 'SctMthBatch' ) )                                 %&%
    error( ['Only recognised choices are ''SctMth'', ''SctMthSave'' ',...   %&%
            'and ''SctMthBatch''.'] );                                      %&%
  end                                                                       %&%

  if ~qarts_isset(Q.CLOUDBOX_DO)
     T={};
     return                           % Return
  else
    rqre_datatype( Q.CLOUDBOX_DO, @isboolean, 'Q.CLOUDBOX_DO' );            %&%
    if ~Q.CLOUDBOX_DO
      T={};
      return                           % Return
    end    
  end
  
  % It is assumed that cfile_CldBox has been called and checks of Q.CLOUDBOX 
  % have been performed

  %= DOIT / MC
  %
  if strcmp( upper(Q.CLOUDBOX.METHOD), 'DOIT' )
    %
    rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, {'N_ZA_GRID','N_AA_GRID',...      %&%
          'ZA_GRID_OPT_FILE', 'SCAT_ZA_INTERP', 'EPSILON', 'ALL_F' }, ...   %&%
                              'Q.CLOUDBOX.METHOD_PRMTRS when using DOIT' ); %&%
    rqre_alltypes( Q.CLOUDBOX.METHOD_PRMTRS.N_ZA_GRID, ...                  %&%
             {@istensor0,@iswhole}, 'Q.CLOUDBOX.METHOD_PRMTRS.N_ZA_GRID' ); %&%
    rqre_alltypes( Q.CLOUDBOX.METHOD_PRMTRS.N_AA_GRID, ...                  %&%
             {@istensor0,@iswhole}, 'Q.CLOUDBOX.METHOD_PRMTRS.N_AA_GRID' ); %&%
    rqre_datatype( Q.CLOUDBOX.METHOD_PRMTRS.SCAT_ZA_INTERP, @ischar, ...    %&%
                               'Q.CLOUDBOX.METHOD_PRMTRS.SCAT_ZA_INTERP' ); %&%
    if ~any( strcmp( Q.CLOUDBOX.METHOD_PRMTRS.SCAT_ZA_INTERP, ...           %&%
                                               {'linear','polynomial'} ) )  %&%
      error( ['Unknown interpolation method. ',...                          %&%
              'Q.CLOUDBOX.METHOD_PRMTRS.SCAT_ZA_INTERP can be ',...         %&%
              '''linear'' or ''polynomial''.'] );                           %&%
    end                                                                     %&%
    rqre_datatype( Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE, ...           %&%
       {@ischar,@istensor0}, 'Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE' ); %&%
    rqre_datatype( Q.CLOUDBOX.METHOD_PRMTRS.ALL_F, @isboolean, ...          %&%
                                        'Q.CLOUDBOX.METHOD_PRMTRS.ALL_F' ); %&%
    
    if isnumeric( Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE )      
      optfile = fullfile( workfolder, 'scat_za_grid.xml' ); 
      xmlStore( filename, Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE, ...
                                           'Vector', Q.INPUT_FILE_FORMAT );
    else     
      optfile = Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE;
    end
    
    T{1}     = sprintf( ...
                    'doit_za_interpSet(doit_za_interp,atmosphere_dim,"%s")', ...
                                      Q.CLOUDBOX.METHOD_PRMTRS.SCAT_ZA_INTERP );
    T{end+1} = 'DoitAngularGridsSet(';
    T{end+1} = '   doit_za_grid_size,scat_aa_grid,scat_za_grid,';
    T{end+1} = sprintf('   %d,%d,"%s"', Q.CLOUDBOX.METHOD_PRMTRS.N_ZA_GRID,...
                                Q.CLOUDBOX.METHOD_PRMTRS.N_AA_GRID, optfile );
    T{end+1} = ')';
    %
    T = add_agenda( T, 'doit_mono_agenda', { ...
           'DoitScatteringDataPrepare', ...
           'doit_i_fieldSetClearsky(', ...
           '   doit_i_field,scat_i_p,scat_i_lat,scat_i_lon,f_grid,f_index', ...
           sprintf( ...
           '   p_grid,lat_grid,lon_grid,cloudbox_limits,atmosphere_dim,%d', ...
                                          Q.CLOUDBOX.METHOD_PRMTRS.ALL_F ), ...
           ')', ...
           'doit_i_fieldIterate',...
           'DoitCloudboxFieldPut' } ...
    );
    %
    T = add_agenda( T, 'pha_mat_spt_agenda', { ...
        'pha_mat_sptFromDataDOITOpt' } );
    
    if ischar( Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE )  &  ...
       strcmp( Q.CLOUDBOX.METHOD_PRMTRS.ZA_GRID_OPT_FILE, '""' )
      T = add_agenda( T, 'doit_scat_field_agenda', ...
                                             { 'doit_scat_fieldCalc' } );
    else
      T = add_agenda( T, 'doit_scat_field_agenda', ...
                                             { 'doit_scat_fieldCalcLimb' } );
    end

    if isfield( Q.CLOUDBOX.METHOD_PRMTRS, 'NORMALIZE' )
      T = add_agenda( T, 'doit_rte_agenda', { sprintf( ...
        'doit_i_fieldUpdateSeq%dD(normalize=%d,norm_error_threshold=%.3f)',...
                     Q.ATMOSPHERE_DIM, Q.CLOUDBOX.METHOD_PRMTRS.NORMALIZE, ...
                           Q.CLOUDBOX.METHOD_PRMTRS.NORM_ERROR_THRESHOLD ) } );
    else
      T = add_agenda( T, 'doit_rte_agenda', { sprintf( ...
                            'doit_i_fieldUpdateSeq%dD', Q.ATMOSPHERE_DIM ) } );
    end
    
    T = add_agenda( T, 'doit_conv_test_agenda', { ...
         'doit_conv_flagAbsBT(', ...
         '   doit_conv_flag,doit_iteration_counter,doit_i_field,', ...
         sprintf('   doit_i_field_old,f_grid,f_index,[%s]', ...
         vector2commalist(Q.CLOUDBOX.METHOD_PRMTRS.EPSILON(1:Q.STOKES_DIM))),...
         ')' } ...
        );
    T = add_agenda( T, 'iy_cloudbox_agenda', { 'Ignore(rtp_pos)', ...
                       'Ignore(rtp_los)', 'iyInterpCloudboxField' } );

    if ~strcmp( partname, 'SctMthBatch' )
      T{end+1} = 'sensor_checkedCalc';
      T{end+1} = 'DoitInit';
      T{end+1} = 'CloudboxGetIncoming';
      T{end+1} = 'ScatteringDoit';
    end
    
  elseif strcmp( upper(Q.CLOUDBOX.METHOD), 'MC' )
    %
    T = {};
    %
  elseif strcmp( upper(Q.CLOUDBOX.METHOD), 'FOS' )
    %
    T = {};
    %
  elseif strcmp( upper(Q.CLOUDBOX.METHOD), 'NONE' )
    %
    T = add_agenda( {}, 'iy_cloudbox_agenda', { 'Ignore(rtp_pos)', ...
                        'Ignore(rtp_los)', 'Ignore(f_grid)', 'Touch(iy)' } );
    %
  else                                                                      %&%
    error( 'Unknown choice for Q.CLOUDBOX.METHOD.' );                       %&%
  end

return



%------------------------------------------------------------------------------
% Sub-function handling:
%
%    batch calculations
%
function T = cfile_BatchC( Q, partname, workfolder )

  error(' Batch part of *qarts2cfile* not updated.' );
  
  %- Some checks of data
  %
  if ~isstruct( Q.BATCH )
    error( 'Batch calculations can only be described by a structure.' );
  end
  %
  qcheck( @qartsBatch, Q.BATCH );
  %
  if length(Q.BATCH.DATA)  &  ~isstruct( Q.BATCH.DATA(1) )
    error( 'Q.BATCH.DATA must be a structure array.' );
  end
  %
  rqre_datatype( Q.BATCH.N, {@istensor0} );

  %- Store batch data and create batch_calc_agenda
  %
  T = [];
  A = [];
  %
  n_num = zeros(5,1);   % Number of "numeric" batch variables of different dim
  n_int = zeros(5,1);   % Same for index variables
  %
  for i = 1 : length( Q.BATCH.DATA )
    
    rqre_field( Q.BATCH.DATA(i), 'TYPE', 0 );
    rqre_char( sprintf('Q.BATCH{%d}.TYPE',i), Q.BATCH.DATA(i).TYPE );
    rqre_field( Q.BATCH.DATA(i), 'WSV', 0 );
    rqre_char( sprintf('Q.BATCH{%d}.WSV',i), Q.BATCH.DATA(i).WSV );
    rqre_field( Q.BATCH.DATA(i), 'X', 0 );
  
    %if size(Q.BATCH.DATA(i).X,1) < Q.BATCH.N 
    %  error( sprintf( ...
    %         'Q.BATCH.DATA{%d}.X contains fewer cases than Q.BATCH.N', i ) );
    %end

    %- Determine dimensionality and type (num or int) of variable
    %
    [dim,datatype] = arts_datatypes( Q.BATCH.DATA(i).TYPE );
    %
    if strcmp(datatype,'num')
      n_num(dim) = n_num(dim) + 1;
      vn         = n_num(dim);      % "variable number" 
    elseif strcmp(datatype,'int')
      n_int(dim) = n_int(dim) + 1;
      vn         = n_int(dim);      % "variable number" 
    else
      vn         = 1;               % Assume only one variable of other types
    end
    
    mainname  = Q.BATCH.DATA(i).WSV;
    batchtype = arts_datatypes( dim+1, datatype );
    batchname = sprintf( '%s_%d', lower(batchtype), vn );
    
    T = file_or_data( T, batchname, batchtype, Q.BATCH.DATA(i).X, ...
         workfolder, Q.INPUT_FILE_FORMAT, sprintf('%s_batch.xml',mainname) );
    A{end+1} = sprintf( '%sExtractFrom%s(%s,%s,ybatch_index)', ...
                        Q.BATCH.DATA(i).TYPE, ...
                        batchtype, ...
                        mainname, ...
                        batchname );
  end
  %
  Arc = add_rtecalc( Q );
  A   = { A{:} Q.BATCH.WSM{:} Arc{:} };
  %
  T = add_agenda( T, 'ybatch_calc_agenda', A );
  
  %- Make actual calculations
  %
  T{end+1} = sprintf( 'IndexSet(ybatch_n){%d}', Q.BATCH.N );
  T{end+1} = 'ybatchCalc';
  %
  T{end+1} = add_savefile( 'ybatch', workfolder );
  
return





%------------------------------------------------------------------------------
% Smaller help functions
%------------------------------------------------------------------------------

function s = create_var(artsvar,datatype)
  s = sprintf( '%sCreate(%s)', datatype, artsvar );
return


function T = file_or_data(T,artsvar,datatype,qvalue,workfolder,dformat,...
                                                                  nonDefFileId)

  % Check if string array with include cfile code. If yes, fill T and return.
  if iscellstr(qvalue)  &  length(qvalue) > 1  &  ...
     strcmp( qvalue{1}, 'Arts2{' )  &  strcmp( qvalue{end}, '}' )

    for i = 2 : length(qvalue)-1
      T{end+1} = qvalue{i};
    end
    return  % --->
  end
  
  if strcmp( datatype, 'Index' )                                           %&%
    rqre_datatype( qvalue, {@ischar,@iswhole}, ...                         %&%
                                    sprintf('The input for %s',artsvar) ); %&%
  elseif strcmp( datatype, 'Numeric' )                                     %&%
    rqre_datatype( qvalue, {@ischar,@istensor0}, ...                       %&%
                                    sprintf('The input for %s',artsvar) ); %&%
  elseif strcmp( datatype, 'Vector' )                                      %&%
    rqre_datatype( qvalue, {@ischar,@istensor1}, ...                       %&%
                                    sprintf('The input for %s',artsvar) ); %&%
  elseif strcmp( datatype, 'Matrix' )                                      %&%
    rqre_datatype( qvalue, {@ischar,@istensor2}, ...                       %&%
                                    sprintf('The input for %s',artsvar) ); %&%
  elseif strcmp( datatype, 'Tensor3' )                                     %&%
    rqre_datatype( qvalue, {@ischar,@istensor3}, ...                       %&%
                                    sprintf('The input for %s',artsvar) ); %&%
  elseif strcmp( datatype, 'Tensor4' )                                     %&%
    rqre_datatype( qvalue, {@ischar,@istensor4}, ...                       %&%
                                    sprintf('The input for %s',artsvar) ); %&%
  elseif strcmp( datatype, 'Sparse' )                                      %&%
    rqre_datatype( qvalue, {@ischar,@issparse}, ...                        %&%
                                    sprintf('The input for %s',artsvar) ); %&%
  elseif strcmp( datatype, 'String' )                                      %&%
    rqre_datatype( qvalue, {@ischar,@isempty}, ...                         %&%
                                    sprintf('The input for %s',artsvar) ); %&%
  elseif strcmp( datatype, 'ArrayOfString' )                               %&%
    rqre_datatype( qvalue, {@ischar,@isempty,@iscellstr,}, ...             %&%
                                    sprintf('The input for %s',artsvar) ); %&%
  % A generic check for remaining array types                              %&%
  elseif strncmp( datatype, 'ArrayOf', 7 )                                 %&%
    rqre_datatype( qvalue, {@ischar,@isempty,@iscell}, ...                 %&%
                                    sprintf('The input for %s',artsvar) ); %&%
  end                                                                      %&%
  
  % Determine if input data are a file
  isfile = ischar( qvalue );
  if strcmp( datatype, 'String' )       % Special handling of String vars.
    [p,n,ext] = fileparts( qvalue );  
    if ~strcmp( ext, {'xml','nc'} )
      isfile = false;
    end
  end
  
  if isfile
    T{end+1} = add_readfile( artsvar, qvalue );
  else
    if nargin > 6
      filename = fullfile( workfolder, [nonDefFileId,'.xml'] );
    else
      filename = fullfile( workfolder, [artsvar,'.xml'] );
    end
    xmlStore( filename, qvalue, datatype, dformat );
    T{end+1} = add_readfile( artsvar, filename );
  end
return

function s = add_readfile( artsvar, filename )
  [p,n,ext] = fileparts( filename );
  switch lower(ext)
   case '.xml'
     s = sprintf('ReadXML(%s,"%s")', artsvar, filename );
   case '.nc'
     s = sprintf('ReadNetCDF(%s,"%s")', artsvar, filename );     
   otherwise
    error( sprintf( ... 
    'Unknown file extension (%s), Allowed options are ''xml'' and ''nc''', ...
        ext ) );
  end
return


function s = add_savefile( artsvar, workfolder )
  filename = fullfile( workfolder, [ artsvar, '.xml' ] );
  s = sprintf('WriteXML(output_file_format,%s,"%s")', artsvar, filename );
return


function T = add_agenda( T, agenda, strarray )
  if ~iscellstr( strarray )                                                %&%
    error( sprintf( ...                                                    %&%
          'The agenda %s must be specified as cell array of strings.', ... %&%
                                                        upper(agenda) ) ); %&%
  end                                                                      %&%
  if length(strarray) == 1  &  ~isempty(strfind( strarray{1}, [agenda,'__'] ) )
    T{end+1} = sprintf( 'Copy(%s,%s)', agenda, strarray{1} );  
  else
    T{end+1} = sprintf( 'AgendaSet(%s){', agenda );
    for j = 1 : length(strarray)
      T{end+1} = sprintf( '   %s', strarray{j} );
    end
    T{end+1} = '}';
  end
return


function T = add_wsms( T, field, strarray, Q )
  if ~iscellstr( strarray )                                                %&%
    error( sprintf( ...                                                    %&%
           'The field %s must be specified as cell array of strings.', ... %&%
                                                                field ) ); %&%
  end                                                                      %&%
  inif   = false;
  insert = true;
  for j = 1 : length(strarray)
    thisline = strarray{j};
    if length(thisline) > 0  &  thisline(1) == '<' 
      if strncmp( thisline, '<IF>', 4 )
        if length(thisline) < 5
          error( 'Empty <IF> found in %s.', field );
        end
        qfield = strtrim( thisline(5:end) );
        if ~qarts_isset( Q.(qfield) ) | ~isboolean(Q.(qfield))
          error( ['Incorrect usage of if-statement in %s. The argument (in ',...
                  'this case %s) must be a field of Q that is set and is ',  ...
                  'a boolean.'], field, qfield );
        end
        if Q.(qfield)
          insert = true;
        else
          insert = false;        
        end
        inif = true;
      elseif strncmp( thisline, '<ELSE>', 6 )
        if length( deblank( thisline ) ) ~= 6
          error( 'Incorrect line including <ELSE> found in %s.', field );
        end
        insert = ~insert;
      elseif strncmp( thisline, '<END>', 5 )
        if length( deblank( thisline ) ) ~= 5
          error( 'Incorrect line including <END> found in %s.', field );
        end
        inif   = false;
        insert = true;
      else
      end
    else    
      if insert
        T{end+1} = sprintf( '%s', strarray{j} );
      end
    end
  end
return


function T = add_includes( T, name, field )
  %
  if qarts_isset( field )
    if ~iscellstr( field )                                                 %&%
      error( sprintf('%s must be given as a cell array of strings.',...    %&%
                                                                  name) ); %&%
    end                                                                    %&%
    %
    arts_includes = atmlab( 'ARTS_INCLUDES' );
    %
    for i = 1 : length( field )
      if strfind( field{i}, 'ARTS_INCLUDES' )
        if isnan( arts_includes )                                          %&%
          error( ...                                                       %&%
           'Atmlab setting ARTS_INCLUDES is requested, but is not set.' ); %&%
        end                                                                %&%
        s = strrep( field{i}, 'ARTS_INCLUDES', arts_includes );
      else
        s = field{i};
      end
      T{end+1} = sprintf( 'INCLUDE "%s"', s );
    end
  end
return


function T = add_rtecalcstart( Q )

  T = {};

  %----------
  %- MC 
  %----------
  if qarts_isset( Q.CLOUDBOX_DO )  &  Q.CLOUDBOX_DO  &  ...
                                        strcmp( upper(Q.CLOUDBOX.METHOD), 'MC' )
    %                                                                       %&%
    % Some checks of Q.CLOUDBOX performed already in cfile_CldBox           %&%
    %                                                                       %&%
    if ~isfield( Q.CLOUDBOX.METHOD_PRMTRS, 'STD_ERR' )  |  ...              %&%
       ~isfield( Q.CLOUDBOX.METHOD_PRMTRS, 'MAX_TIME' )  |  ...             %&%
       ~isfield( Q.CLOUDBOX.METHOD_PRMTRS, 'MAX_ITER' )  |  ...             %&%
       ~isfield( Q.CLOUDBOX.METHOD_PRMTRS, 'MIN_ITER' )                     %&%
      error( ['With Q.CLOUDBOX_DO=1 and MC method selected, ',...           %&%
           'CLOUDBOX.METHOD_PRMTRS must contain the fields: STD_ERR, ',...  %&%
              'MAX_TIME, MAX_ITER and MIN_ITER'] )                          %&%
    end                                                                     %&%
    %                                                                       %&%
    rqre_field( Q.CLOUDBOX.METHOD_PRMTRS, {'STD_ERR','MAX_TIME',...         %&%
                                       'MAX_ITER', 'MIN_ITER' }, ...        %&%
                                'Q.CLOUDBOX.METHOD_PRMTRS when using MC' ); %&%
    rqre_datatype( Q.CLOUDBOX.METHOD_PRMTRS.STD_ERR, @istensor0, ...        %&%
                                      'Q.CLOUDBOX.METHOD_PRMTRS.STD_ERR' ); %&%
    rqre_datatype( Q.CLOUDBOX.METHOD_PRMTRS.MAX_TIME, @istensor0, ...       %&%
                                     'Q.CLOUDBOX.METHOD_PRMTRS.MAX_TIME' ); %&%
    rqre_datatype( Q.CLOUDBOX.METHOD_PRMTRS.MAX_ITER, @istensor0, ...       %&%
                                     'Q.CLOUDBOX.METHOD_PRMTRS.MAX_ITER' ); %&%
    rqre_datatype( Q.CLOUDBOX.METHOD_PRMTRS.MIN_ITER, @istensor0, ...       %&%
                                     'Q.CLOUDBOX.METHOD_PRMTRS.MIN_ITER' ); %&%
    %
    T{end+1} = sprintf( 'NumericSet(mc_std_err,%.3e)', ...
                                       Q.CLOUDBOX.METHOD_PRMTRS.STD_ERR );
    T{end+1} = sprintf( 'IndexSet(mc_max_time,%.0f)', ...
                                       Q.CLOUDBOX.METHOD_PRMTRS.MAX_TIME );
    T{end+1} = sprintf( 'IndexSet(mc_max_iter,%d)', ...
                                       Q.CLOUDBOX.METHOD_PRMTRS.MAX_ITER );
    T{end+1} = sprintf( 'IndexSet(mc_min_iter,%d)', ...
                                       Q.CLOUDBOX.METHOD_PRMTRS.MIN_ITER );
  end

  if qarts_isset( Q.WSMS_BEFORE_RTE )
    T = add_wsms( T, 'WSMS_BEFORE_RTE', Q.WSMS_BEFORE_RTE );
  end
return  
%------------------------------------------------------------------------------
