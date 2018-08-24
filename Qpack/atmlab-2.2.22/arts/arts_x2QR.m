% ARTS_x2QR   Maps an x state to Q and R fields
%
%    The function updates *Q* and *R* to match the present state of *x*.
%
%    No forward model calculations are performed.
%
% FORMAT   [Q,R] = arts_x2QR( Q, R, x )
%        
% OUT   Q      Modified Q structure.
%       R      Modified R structure.
% IN    Q      Qarts structure.
%       R      Retrieval data structure. 
%       x      State vector.

% 2010-01-11   Started by Patrick Eriksson.


function [Q,R] = arts_x2QR(Q,R,x)


%- General variables
%
nq       = length( R.jq );                  % Number of retrieval quantities.
%
i_asj    = find([Q.ABS_SPECIES.RETRIEVE]);  % Index of retrieval absorption
%                                             species.
any_gas  = false;                           % Any gas species among rq
% 
bl       = 0;                               % Sum of all baseline terms
%  
j_loaded = false;                           % To avoid repeated loading of J
%
do_sensor = false;                          % Recalculation of sensor needed


%- Limit to set min and max values
%
ind    = find( x < R.minmax(:,1) );
x(ind) = R.minmax(ind,1);
ind    = find( x > R.minmax(:,2) );
x(ind) = R.minmax(ind,2);
  

%- Loop retrieval quantities
%
for i = 1 : nq

  ind = R.ji{i}{1} : R.ji{i}{2};

  switch R.jq{i}.maintag

   case 'Absorption species'   %----------------------------------------------
    %
    if ~any_gas
      vmr = R.vmr_field0;    % Will be filled with latest VMR for all species
    end                      % that are retrieved
    any_gas   = true;
    ig        = i_asj(i);    % Gas species index
    %
    X = x2field( Q.ATMOSPHERE_DIM, R.jq{i}.grids, x(ind) );
    X = arts_regrid( Q.ATMOSPHERE_DIM, R.jq{i}.grids, X, Q );
    %
    if strcmp( R.jq{i}.mode, 'rel' )
      vmr(ig,:,:,:) = getdims( vmr(ig,:,:,:), 2:Q.ATMOSPHERE_DIM+1 ) .* X;
    elseif strcmp( R.jq{i}.mode, 'vmr' )
      vmr(ig,:,:,:) = X;
    elseif strcmp( R.jq{i}.mode, 'nd' )
      vmr(ig,:,:,:) = nd2vmr( X, repmat(R.p_grid,[1 size2(X,2:3)]), ...
                             qarts_get(fullfile(R.workfolder,'t_field.xml')) );
    elseif strcmp( R.jq{i}.mode, 'logrel' )
      vmr(ig,:,:,:) = getdims( vmr(ig,:,:,:), 2:Q.ATMOSPHERE_DIM+1 ) .* exp(X);
    else 
      assert( false );
    end
    %
    clear X
    
   case 'Atmospheric temperatures'   %----------------------------------------
    %
    X = x2field( Q.ATMOSPHERE_DIM, R.jq{i}.grids, x(ind) );
    X = arts_regrid( Q.ATMOSPHERE_DIM, R.jq{i}.grids, X, Q );
    xmlStore( fullfile(R.workfolder,'t_field.xml'), X, 'Tensor3' );
    %
    clear X

   case 'Wind'   %------------------------------------------------------------
    %
    X = x2field( Q.ATMOSPHERE_DIM, R.jq{i}.grids, x(ind) );
    X = arts_regrid( Q.ATMOSPHERE_DIM, R.jq{i}.grids, X, Q );
    if strcmp( R.jq{i}.subtag, 'u' )
      xmlStore( fullfile(R.workfolder,'wind_u_field.xml'), X, 'Tensor3' );
    elseif strcmp( R.jq{i}.subtag, 'v' )
      xmlStore( fullfile(R.workfolder,'wind_v_field.xml'), X, 'Tensor3' );
    elseif strcmp( R.jq{i}.subtag, 'w' )
      xmlStore( fullfile(R.workfolder,'wind_w_field.xml'), X, 'Tensor3' );
    else
      assert( false );
    end
    %
    clear X
    
   case 'Sensor pointing'   %-------------------------------------------------
    %
    assert( strcmp( R.jq{i}.subtag, 'Zenith angle off-set' ) );
    %
    sensor_los      = R.los;
    sensor_los(:,1) = R.los(:,1) + arts_polybasis_func( Q.SENSOR_TIME, ...
                                                    R.jq{i}.grids{1} )* x(ind); 
    xmlStore( fullfile(R.workfolder,'sensor_los.xml'), sensor_los, 'Matrix' );
   
   case 'Frequency'   %-------------------------------------------------------
    %
    assert( length(ind) == 1 );
    if ~do_sensor
      Q.SENSOR_RESPONSE = R.sensor_response;
    end    
    %
    fb = qarts_get(Q.SENSOR_RESPONSE.F_BACKEND);
    %   
    if strcmp( R.jq{i}.subtag, 'Shift' )
      df = x(ind(1));
    elseif strcmp( R.jq{i}.subtag, 'Stretch' )
      df = arts_polybasis_func( fb, 1 ) * x(ind(1));
    else
      assert( false );
    end
    %
    Q.SENSOR_RESPONSE.F_BACKEND = fb + df;
    do_sensor                   = true;
    clear   fb;
      
   case 'Polynomial baseline fit'   %-----------------------------------------
    %
    if ~j_loaded
      J        = xmlLoad( fullfile( R.workfolder, 'jacobian.xml' ) );
      j_loaded = 1;
    end
    %
    bl = bl + J(:,ind) * x(ind);

   case 'Sinusoidal baseline fit'   %-----------------------------------------
    %
    if ~j_loaded
      J        = xmlLoad( fullfile( R.workfolder, 'jacobian.xml' ) );
      j_loaded = 1;
    end
    %
    bl = bl + J(:,ind) * x(ind);
    
    otherwise   %--------------------------------------------------------------
      error('Unknown retrieval quantitity.'); 
  end 
end 


%- Data to save ?
%
if any_gas
  xmlStore( fullfile(R.workfolder,'vmr_field.xml'), vmr, 'Tensor4' );
end


%- Update sensor characteristics
%
if do_sensor
  arts_sensor( Q, R.workfolder );
end


%- Total baseline
%
R.bl = bl;

return



%--- Internal sub-functions ----------------------------------------------------

function X = x2field( dim, rgrids, x )
  %
  map = ones( 1, 3 );
  for i = 1 : dim
    map(i) = length( rgrids{i} );
  end
  X = reshape( x, map );
return
