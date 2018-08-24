% QPACK2   Main function of Qpack2
%
%    Read qpack2.pdf for an introduction to Qpack2 and user instructions.
%
%    The main task to make OEM type inversions. The measurement data in *Y* are
%    inverted by combining the function oem.m and Qarts (interface to arts-2).
%    Forward model and retrieval variables are packed into the Qarts structure
%    Q. OEM specific parameters are found in O.
%
%    The data fields of the output structure L2 depends on selected retrieval
%    quantities and settings in Q. See further *qp2_l2*.
%
% FORMAT   [L2,X] = qpack2(Q,O,Y)
%
% IN    Q        Qarts setting structure. See *qarts*.
%       O        OEM settings. See *oem*.
%       Y        Measurement data. See *qp2_y*.
% OUT   L2       Retrieved data. See *qp2_l2*.
%       X        As the output of *oem*, providing additional information.
%
%    The measurement matching the apriori conditions can be calculated through
%    this function. This can be useful for test retrievals, or comparison with
%    som measurement data. Such calculations are triggered by setting all
%    measurement vectors in Y (that is, Y.Y) to be empty ([]). Note that the
%    field shall be set to [], and not to {} that inside qpack2 and qarts
%    identifies an undefined field.
%
%    The calculated spctre are inserted into Y, and the format is:
%
% FORMAT   Y = qpack2(Q,O,Y)

% 2010-05-10   Created by Patrick Eriksson.


function [L2,X] = qpack2(Q,O,Y)



%------------------------------------------------------------------------------
%- Check input
%------------------------------------------------------------------------------
if atmlab( 'STRICT_ASSERT' )
  rqre_nargin( 3, nargin );
  rqre_datatype( Q, @isstruct );
  rqre_datatype( O, @isstruct );
  rqre_datatype( Y, @isstruct );
  qcheck( @qarts, Q );
  qcheck( @oem, O );
  qcheck( @qp2_y, Y );
end
%
empty_y = checkY( Y );



%------------------------------------------------------------------------------
%- Loop measurements
%------------------------------------------------------------------------------
%
L2 = [];
% 
workfolder = create_tmpfolder;
cu = onCleanup( @()delete_tmpfolder( workfolder ) );
%
ny = length(Y);
%
for m = 1 : ny
  
  %- Simulate a (noise free) measurement if y is empty
  if empty_y
    %
    Qm = qp2_y2Q( Q, Y, m );
    %
    if m == 1
      L2    = Y(m);
    else
      L2(m) = Y(m);
    end
    %
    if out(1)
      fprintf( 'Simulating spectrum %d/%d\n', m, ny );
    end
    %
    L2(m).Y = arts_y( Qm, workfolder );
  
    
  %- Inversion
  else
    
    %- Init retrieval
    %
    if ny > 1
      O.msg = sprintf( 'Inversion case %d (of %d)', m, ny );
    end
    %
    [Qm,Se]     = qp2_y2Q( Q, Y, m );
    [Qm,O,R,xa] = arts_oem_init( Qm, O, workfolder );
    
    %- Sx
    if m == 1
      %
      Sx = arts_sx( Qm, R );
      %
      si = sqrt( diag( Sx ) );
      if max(si) / min(si) <= 1e3
        Sxinv    = Sx \ speye(size(Sx));
        O.sxnorm = 0;
      else
        Sxinv    = [];
        O.sxnorm = 1;
      end
    end

    %- Perform retrieval
    %
    [X,R] = oem( O, Qm, R, @arts_oem, Sx, Se, Sxinv, [], xa, Y(m).Y );
    
    %- Fill return structure
    %
    if m == 1
      L2    = qp2_l2( Qm, R, xa, O, X, Y, m );
    else
      L2(m) = qp2_l2( Qm, R, xa, O, X, Y, m );
    end
  
  end % empty_y
end % for m
%
return
%
%------------------------------------------------------------------------------
%------------------------------------------------------------------------------
%------------------------------------------------------------------------------



% Checks if all Y.Y have the same length
%
function empty_y = checkY( Y )

  errid = ['atmlab:' mfilename];
  empty_y = isempty( Y(1).Y );
  
  if atmlab( 'STRICT_ASSERT' )
    if empty_y
      for i = 2 : length(Y)                                          
        if ~isempty(Y(i).Y)                                        
          error( errid, ['First spectrum in Y is empty. Then all other '... 
                         'spectra must also be empty.'] );                  
        end                                                          
      end                                                            
      
    else            
      rqre_datatype( Y(1).Y, @istensor1, 'Y(1).Y' );                 
      n = length( Y(1).Y );                                          
      for i = 2 : length(Y)                                          
        rqre_datatype( Y(i).Y, @istensor1, sprintf('Y(%d).Y',i) );   
        if length(Y(i).Y) ~= n                                       
          error( errid, 'All spectra must have the same length.' );         
        end                                                          
      end                                                            
    end
  end
return      





function  [Q,Se] = qp2_y2Q( Q, Y, m )

  % If output does not include Se, it assumed that no retrieval will 
  % be performed (for all m). 
    
  %- Stuff only done for first measurement
  %
  errid = ['atmlab:' mfilename];
  do_checks = atmlab( 'STRICT_ASSERT' );
  %    
  if m == 1

    Q.ATMOSPHERE_DIM = qarts_get( Q.ATMOSPHERE_DIM );  

    if do_checks
      if ~qarts_isset(Q.ATMOSPHERE_DIM)                                       
        error( errid, 'Qpack2 requires that Q.ATMOSPHERE_DIM is set.' );
      end                                                                     
      rqre_datatype( Q.ATMOSPHERE_DIM, @istensor0, Q.ATMOSPHERE_DIM );         
     %if Q.ATMOSPHERE_DIM ~= 1                                                
     %   error( errid, 'Qpack2 requires that Q.ATMOSPHERE_DIM is set to 1.' ); 
     % end 
      %
      if ~qarts_isset(Q.ABSORPTION)                                           
        error( errid, 'Qpack2 requires that Q.ABSORPTION is set.' ); 
      end                                                                     
      rqre_datatype( Q.ABSORPTION, @ischar, Q.ABSORPTION );                   
      if strcmp( Q.ABSORPTION, 'CalcTable' )                                  
        error( errid, ...
                     'Qpack2 is not handling Q.ABSORPTION == ''CalcTable''.' );
      end
      %
      if ~qarts_isset(Q.HSE)                                                  
        error( errid, 'Qpack2 requires that Q.HSE is set.' ); 
      end                                                                     
      rqre_datatype( Q.HSE.ON, @isboolean, Q.HSE.ON );                        
      %
      if qarts_isset(Q.RAW_ATMOSPHERE)                                        
        error( errid, 'Qpack2 requires that Q.RAW_ATMOSPHERE is unset.' ); 
      end                                                                     
      if ~( isfield(Q.ABS_SPECIES,'ATMDATA') | qarts_isset(Q.VMR_FIELD) )
        error( errid, ['Qpack2 requires that Q.VMR_FIELD is set or ',...
                       'Q.ABS_SPECIES has the field ATMDATA.'] );
      end                                                                     
      if ~( isfield(Q.T,'ATMDATA') | qarts_isset(Q.T_FIELD) )
        error( errid, ['Qpack2 requires that Q.T_FIELD is set or ',...
                       'Q.T has the field ATMDATA.'] );
      end                                                                     
      if ~( Q.HSE.ON | isfield(Q.Z,'ATMDATA') | qarts_isset(Q.Z_FIELD) )
        error( errid, ['Qpack2 requires that either Q.Z_FIELD is set, ',...
                       'Q.HSE.ON is true or Q.Z has the field ATMDATA.'] );
      end
    end
    
    if nargout < 2
      Q.J_DO = 0;
    else
      Q.J_DO = 1;
      Q.TNOISE_C = qarts_get( Q.TNOISE_C ); 
      if do_checks
        if ~qarts_isset(Q.TNOISE_C)                                          
          error( errid, 'Qpack2 requires that Q.TNOISE_C is set.' ); 
        end                                                                  
        if ~issparse(Q.TNOISE_C)                                             
          error( errid, ...
                     'Q.TNOISE_C is required to be sparse (to save memory).' );
        elseif dimens(Q.TNOISE_C)~=2 || size(Q.TNOISE_C,1)~=size(Q.TNOISE_C,2)
          error( errid, 'Q.TNOISE_C must be square.' );
        end                                                                 
      end  
    end % nargout < 2
  end % if m==1

  
  % Checks of Y(m)                                                          
  %                                                                         
  if do_checks
    rqre_datatype( Y(m).LATITUDE, @istensor0, sprintf('Y(%d).LATITUDE',m) );  
    rqre_datatype( Y(m).LONGITUDE, @istensor0, sprintf('Y(%d).LONGITUDE',m) );
    rqre_datatype( Y(m).HSE_P, @istensor0, sprintf('Y(%d).HSE_P',m) );        
    rqre_datatype( Y(m).HSE_Z, @istensor0, sprintf('Y(%d).HSE_Z',m) );        
    rqre_datatype( Y(m).YEAR, @istensor0, sprintf('Y(%d).YEAR',m) );          
    rqre_datatype( Y(m).MONTH, @istensor0, sprintf('Y(%d).MONTH',m) );        
    rqre_datatype( Y(m).DAY, @istensor0, sprintf('Y(%d).DAY',m) );            
    rqre_datatype( Y(m).Z_PLATFORM, @istensor1, ...                           
                                             sprintf('Y(%d).Z_PLATFORM',m) ); 
    rqre_datatype( Y(m).ZA, @istensor1, sprintf('Y(%d).ZA',m) );
    if length(Y(m).ZA) ~= length(Y(m).Z_PLATFORM)
      error( errid, ...
             'Y(%d).ZA and Y(%d).Z_PLATFORM must have the same length', m, m );
    end
    rqre_datatype( Y(m).F, @istensor1, sprintf('Y(%d).F',m) ); 
    if Q.ATMOSPHERE_DIM == 3
      rqre_datatype( Y(m).AA, @istensor1, sprintf('Y(%d).AA',m) );
      if length(Y(m).ZA) ~= length(Y(m).AA) 
        error( errid, ...
                     'Y(%d).AA and Y(%d).ZA must have the same length', m, m );
      end 
    end
  end

  %- Map ATMDATA (if set) to VMR_FIELD, Z_FIELD and T_FIELD, and apply HSE
  %
  Q.LAT_TRUE  = Y(m).LATITUDE;
  Q.LON_TRUE  = Y(m).LONGITUDE;
  %
  if qarts_isset( Y(m).HOUR )
    ho = Y(m).HOUR;
  else
    ho = 12;
  end
  if qarts_isset( Y(m).MINUTE )
    mi = Y(m).MINUTE;
  else
    mi = 0;
  end
  if qarts_isset( Y(m).SECOND )
    se = Y(m).SECOND;
  else
    se = 0;
  end
  %
  if do_checks
    rqre_datatype( ho, @istensor0, sprintf('Y(%d).HOUR',m) );
    rqre_datatype( mi, @istensor0, sprintf('Y(%d).MINUTE',m) );
    rqre_datatype( se, @istensor0, sprintf('Y(%d).SECOND',m) );
  end
  %
  mjd = date2mjd( Y(m).YEAR, Y(m).MONTH, Y(m).DAY, ho, mi, se );
  %
  if isfield( Q.ABS_SPECIES, 'ATMDATA' )
    Q.VMR_FIELD = qarts_vmr_field( Q, mjd, ho );
  end
  if isfield( Q.T, 'ATMDATA' )
    Q.T_FIELD   = qarts_atm_field( Q, 't', mjd, ho );
  end
  if isfield( Q.Z, 'ATMDATA' )
    Q.Z_FIELD   = qarts_atm_field( Q, 'z', mjd, ho );
  end
  if Q.HSE.ON
    Q.Z_FIELD   = qarts_hse( Q, Y(m).HSE_P, Y(m).HSE_Z );
  end
  %
  Q.HSE.P = Y(m).HSE_P;

  
  %- Wind components
  %
  if isfield( Q.WIND_U, 'ATMDATA' )
    Q.WIND_U_FIELD   = qarts_atm_field( Q, 'wind_u', mjd, ho );
  end
  if isfield( Q.WIND_V, 'ATMDATA' )
    Q.WIND_V_FIELD   = qarts_atm_field( Q, 'wind_v', mjd, ho );
  end
  if isfield( Q.WIND_W, 'ATMDATA' )
    Q.WIND_W_FIELD   = qarts_atm_field( Q, 'wind_w', mjd, ho );
  end


  %- Magnetic field
  %
  if isfield( Q.MAG_U, 'ATMDATA' )
    Q.MAG_U_FIELD   = qarts_atm_field( Q, 'mag_u', mjd, ho );
  end
  if isfield( Q.MAG_V, 'ATMDATA' )
    Q.MAG_V_FIELD   = qarts_atm_field( Q, 'mag_v', mjd, ho );
  end
  if isfield( Q.MAG_W, 'ATMDATA' )
    Q.MAG_W_FIELD   = qarts_atm_field( Q, 'mag_w', mjd, ho );
  end

  
  %- Sensor pos and los
  %
  nza = length( Y(m).ZA );
  %
  if Q.ATMOSPHERE_DIM == 1
    Q.SENSOR_POS  = Y(m).Z_PLATFORM;
    Q.SENSOR_LOS  = Y(m).ZA;
  elseif Q.ATMOSPHERE_DIM == 2
    Q.SENSOR_POS  = [ Y(m).Z_PLATFORM, repmat( [Y(m).LATITUDE], nza, 1 ) ];
    Q.SENSOR_LOS  = [ Y(m).ZA ];
  elseif Q.ATMOSPHERE_DIM == 3
    Q.SENSOR_POS  = [ Y(m).Z_PLATFORM, ...
                      repmat( [Y(m).LATITUDE,Y(m).LONGITUDE], nza, 1 ) ];
    Q.SENSOR_LOS  = [ Y(m).ZA, Y(m).AA ];
  end


  %- Set a dummy sensor_time, if not already defined
  %
  if ~qarts_isset( Q.SENSOR_TIME )
    Q.SENSOR_TIME = [ 1 : nza ]';
  end
  
  %- Se
  %
  if nargout == 2
    
    nnv = size( Y(m).TNOISE, 1 );  % Number of noise values
    nf  = length( Y(m).F );
    
    if do_checks
      rqre_datatype( Y(m).TNOISE, @istensor2, sprintf('Y(%d).TNOISE',m) );
      if nnv ~= 1  &&  nnv ~= nf
        error( errid, ...
         'Row size of Y(%d).TNOISE must be 1 or equal to length of Y.F.', m );
      end
      if size( Y(m).TNOISE, 2 ) ~= nza
        error( errid, ...
         'Column size of Y(%d).TNOISE must match length of Y(%d).ZA.', m, m );
      end
    end
    
    [i,j,s] = find( Q.TNOISE_C );
    ni      = length( i );
    [i2,j2,s2] = deal( zeros( ni*nza, 1 ) );

    for z = 1 : nza
      ind     = (z-1)*ni + (1:ni);
      i2(ind) = (z-1)*nf + i;
      j2(ind) = (z-1)*nf + j;
      %
      if nnv == 1
        s2(ind) = Y(m).TNOISE(1,z)^2 * s; 
      else
        for k = 1 : ni
          s2(ind(1)-1+k) = prod( Y(m).TNOISE([i(k) j(k)],z) ) * s(k);
        end
      end
    end
    %
    Se = sparse(i2,j2,s2);  
  end 
return

