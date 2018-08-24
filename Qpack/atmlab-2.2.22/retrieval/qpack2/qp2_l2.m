% QP2_L2    Standardised L2 output for Qpack2
%
%    The function allows that a L2 structure is generated where the set of
%    fields can be controlled through Q. The fields of L2 are determined by the
%    settings of the L2 field of the retrieval quantities (such as
%    Q.POLYFIT.L2) and Q.L2_EXTRA. The naming and content of the L2 fields
%    are described further in the Qpack2 manual.
%
%    Possible choices for L2_EXTRA are:
%    ----------: These data are transferred from X, the output of *oem*
%         'dx' : Last value of X.dx. See qinfo(@oem,'dx')
%       'cost' : Last value of X.cost. See qinfo(@oem,'dx')
%          'e' : See qinfo(@oem,'e')
%         'eo' : See qinfo(@oem,'eo')
%         'es' : See qinfo(@oem,'es')
%         'ex' : See qinfo(@oem,'ex')
%         'yf' : See qinfo(@oem,'yf')
%      'Afull' : Full averaging kernel matrix.
%          'G' : See qinfo(@oem,'G')
%          'J' : See qinfo(@oem,'J')
%          'S' : See qinfo(@oem,'S')
%         'So' : See qinfo(@oem,'So')
%         'Ss' : See qinfo(@oem,'Ss')
%    ----------: Other data
%       'date' : Date of the measurement. Taken from Y. Gives fields 'year', 
%                'hour', 'day', 'hour', 'min' and 'sec'
%         'xa' : A priori state for each retrieval quantity.
%          'y' : Measured spectrum. Includes also the corresponding frequencies.
%         'yf' : Fitted spectrum.
%         'bl' : Baseline fit.
%      'mresp' : Measurement response.
%          'A' : Partial averaging kernel matrix.
%     'tnoise' : Thermal noise magnitude. A scalar. Overall mean of Y.TNOISE.
%        'ptz' : Includes 'p_grid', 'z_field' and 't_field' from corresponding
%                fields of Q. For higher atmospheric dimensionalities 
%                'lat_grid' and 'lon_grid* are also included.
%
%    The variables G, J S, So and Ss are stored as complete matrices. The the
%    vectors e, eo, es, ex and xa (as well as x and mr) are splitted, and are
%    stored separately for each retrieval quantity. The full averaging
%    kernal matrix is obtained by 'Afull', while this matrix splitted in
%    parts (for each part of x) is obatined by 'A'.
%
%    A field speciesX_vmr0 is added automatically when the retrieval unit is
%    rel or logrel.
%
%    It must be ensured that the output of *oem* includes the data to be
%    extracted here. This is most easily done by this function, following the
%    first format below. Instead of initiating as O = oem;, instead do:
%       O = qp2_l2(Q); 
%    And O will be initiated in a way that this function can be used for
%    producing the L2 data.
%
% FORMAT   O = qp2_l2( Q )
%
% OUT   O       OEM setting structure. 
% IN    Q       Qarts setting structure. 
%
%      or
%
% FORMAT   L2 = qp2_l2( Q, R, xa, O, X, Y, m )
%
% OUT   L2      Creaed L2 structure.
% IN    Q       Qarts setting structure. 
%       R       See *arts_oem_init*.
%       O       OEM setting structure. See *oem*.
%       xa      A priori state vector.
%       X       Output structure from *oem*
%       Y       Measurement structure. See qinfo(@qp2_y)
%       m       Index of retrieved measurement.

% 2009-07-01   Created by Patrick Eriksson.

function L2 = qp2_l2( Q, R, xa, O, X, Y, m )

if nargin == 1
  %
  L2 = oem;
  %
  if ~qarts_isset( Q.L2_EXTRA ) 
    return;           % --->
  end 
  Q.L2_EXTRA = qarts_get( Q.L2_EXTRA );
  rqre_datatype( Q.L2_EXTRA, @iscellstr, 'Q.L2_EXTRA' );                    %&%
  %
  for i = 1 : length( Q.L2_EXTRA )
    switch Q.L2_EXTRA{i} 
      case {'dx','cost','e','eo','es','ex','yf','A','G','J','S','So','Ss'}
        L2.(Q.L2_EXTRA{i})= true;
      case {'mresp','Afull'}
        L2.A = true;
      case {'date','xa','y','bl','tnoise','ptz'}
        %
      otherwise
        error( sprintf('Unknow out variable: %s', Q.L2_EXTRA{i} ) );
    end        
  end
  %
  return;           % --->
end

%- To handle ase when no putput is selected
%
L2 = [];


%- Set up some do-variables to avoid repetition of any(strcmp))
%
do_mresp = any( strcmp( Q.L2_EXTRA, 'mresp' ) );
do_A     = any( strcmp( Q.L2_EXTRA, 'A' ) ) ;
do_xa    = any( strcmp( Q.L2_EXTRA, 'xa' ) );
do_e     = any( strcmp( Q.L2_EXTRA, 'e' ) );
do_eo    = any( strcmp( Q.L2_EXTRA, 'eo' ) );
do_es    = any( strcmp( Q.L2_EXTRA, 'es' ) ) ;   
do_ex    = any( strcmp( Q.L2_EXTRA, 'ex' ) ) ;   


% Date and position
%
if any( strcmp( Q.L2_EXTRA, 'date' ) )
  L2.year   = Y(m).YEAR;
  L2.month  = Y(m).MONTH;
  L2.day    = Y(m).DAY;
  L2.hour   = Y(m).HOUR;
  L2.minute = Y(m).MINUTE;
  L2.second = Y(m).SECOND;
end


% Retrieval diagnostics 
%
L2.converged = X.converged;
%
if ~O.linear
  if any( strcmp( Q.L2_EXTRA, 'dx' ) )
    L2.dx = X.dx(end);
  end
end 
%
if any( strcmp( Q.L2_EXTRA, 'cost' ) )
  L2.cost   = X.cost(end);
  L2.cost_x = X.cost_x(end);
  L2.cost_y = X.cost_y(end);
end


% Measurement and fits
%  
if any( strcmp( Q.L2_EXTRA, 'y' ) )
  if qarts_isset( Y(m).F )
    L2.f  = Y(m).F;
  elseif Q.SENSOR_DO
    L2.f  = qarts_get( Q.SENSOR_RESPONSE_F );
  else
    L2.f  = qarts_get( Q.F_GRID );    
  end
  L2.y  = Y(m).Y;
end
if any( strcmp( Q.L2_EXTRA, 'yf' ) )
  L2.yf = X.yf;
end
if any( strcmp( Q.L2_EXTRA, 'bl' ) )
  L2.bl = R.bl;
end
if any( strcmp( Q.L2_EXTRA, 'tnoise' ) )
  L2.tnoise = mean( mean( Y(m).TNOISE ) );
end


% PTZ (last forward model fields)
%
if any( strcmp( Q.L2_EXTRA, 'ptz' ) )
  L2.p_grid = R.p_grid;
  if Q.ATMOSPHERE_DIM >= 2
    L2.lat_grid = R.lat_grid;
    if Q.ATMOSPHERE_DIM == 3
      L2.lon_grid = R.lon_grid;
    end
  end
  L2.t_field = qarts_get( Q.T_FIELD );
  L2.z_field = qarts_get( Q.Z_FIELD );
end


% Optional matrices
%
if any( strcmp( Q.L2_EXTRA, 'J' ) )
  L2.J = X.J;
end
if any( strcmp( Q.L2_EXTRA, 'Afull' ) )
  L2.A = X.A;
end
if any( strcmp( Q.L2_EXTRA, 'G' ) )
  L2.G = X.G;
end
if any( strcmp( Q.L2_EXTRA, 'S' ) )
  L2.S = X.S;
end
if any( strcmp( Q.L2_EXTRA, 'So' ) )
  L2.So = X.So;
end
if any( strcmp( Q.L2_EXTRA, 'Se' ) )
  L2.Se = X.Se;
end
if any( strcmp(Q.L2_EXTRA,'J') | strcmp(Q.L2_EXTRA,'Afull') | ...
        strcmp(Q.L2_EXTRA,'G') | strcmp(Q.L2_EXTRA,'S') | ...
        strcmp(Q.L2_EXTRA,'Se') | strcmp(Q.L2_EXTRA,'So') )
  L2.jq = R.jq;  
  L2.ji = R.ji;  
end


% Start and stop index for each retrieval quantity  
I = zeros( length(R.jq), 2 );
for q = 1 : length(R.jq)
  I(q,:) = [ R.ji{q}{1}  R.ji{q}{2} ];
end


% Measurement response and averaging kernel
%
if do_A & do_mresp 
  [mresp,As] = mrespA( X.A, I );
elseif do_A
  As = splitA( X.A, I );
elseif do_mresp
  mresp = mrespA( X.A, I );
end


% Retrieval quantities
%
i_asj    = find([Q.ABS_SPECIES.RETRIEVE]); 
%
for q = 1 : length(R.jq)

  atmfield = false;
  ind      = I(q,1) : I(q,2);
  siz      = [ length(ind), 1 ];   % Modified below for 2D and 3D variables
  
  if strcmp( R.jq{q}.maintag, 'Absorption species' )
    %--------------------------------------------------------------------------
    % It is assumed that abs. species are included first among the ret. quant.
    %--------------------------------------------------------------------------
    ispecies = i_asj(q);
    vname = sprintf( 'Q.ABS_SPECIES(%d)', ispecies );                       %&%
    rqre_field( Q.ABS_SPECIES(ispecies), 'L2', vname );                     %&%
    out = qarts_get( Q.ABS_SPECIES(ispecies).L2 );
    rqre_datatype( out, @isboolean, sprintf('%s.L2',vname) );               %&%
    %    
    if out 
      s        = sprintf( 'species%d', q );
      atmfield = true;
      Astruct  = Q.ABS_SPECIES(ispecies);
      %
      L2.([s,'_name'])  = R.jq{q}.subtag;
    end
    
  elseif strcmp( R.jq{q}.maintag, 'Atmospheric temperatures' )
    %--------------------------------------------------------------------------
    rqre_field( Q.T, 'L2', 'Q.T' );                                         %&%
    out = qarts_get( Q.T.L2 );
    rqre_datatype( out, @isboolean, 'Q.T.L2' );                             %&%
    %
    if out
      s        = 'temperature';
      atmfield = true;
      Astruct  = Q.T;
    end

  elseif strcmp( R.jq{q}.maintag, 'Wind' )
    %--------------------------------------------------------------------------
    if strcmp( R.jq{q}.subtag, 'u' )
      rqre_field( Q.WIND_U, 'L2', 'Q.WIND_U' );                             %&%
      out = qarts_get( Q.WIND_U.L2 );
      rqre_datatype( out, @isboolean, 'Q.WIND_U.L2' );                      %&%
      %
      if out
        s        = 'wind_u';
        atmfield = true;
        Astruct  = Q.WIND_U;
      end
    elseif strcmp( R.jq{q}.subtag, 'v' )
      rqre_field( Q.WIND_V, 'L2', 'Q.WIND_V' );                             %&%
      out = qarts_get( Q.WIND_V.L2 );
      rqre_datatype( out, @isboolean, 'Q.WIND_V.L2' );                      %&%
      %
      if out
        s        = 'wind_v';
        atmfield = true;
        Astruct  = Q.WIND_V;
      end
    elseif strcmp( R.jq{q}.subtag, 'w' )
      rqre_field( Q.WIND_W, 'L2', 'Q.WIND_W' );                             %&%
      out = qarts_get( Q.WIND_W.L2 );
      rqre_datatype( out, @isboolean, 'Q.WIND_W.L2' );                      %&%
      %
      if out
        s        = 'wind_w';
        atmfield = true;
        Astruct  = Q.WIND_W;
      end
    else                                                                    %&%
      error( 'Unknown wind subtag.' );                                      %&%
    end
    
  elseif strcmp( R.jq{q}.maintag, 'Sensor pointing' )
    %--------------------------------------------------------------------------
    rqre_field( Q.POINTING, 'L2', 'Q.POINTING' );                           %&%
    out = qarts_get( Q.POINTING.L2 );
    rqre_datatype( out, @isboolean, 'Q.POINTING.L2' );                      %&%
    %    
    if out
      s = 'pointing';
    end
  
  elseif strcmp( R.jq{q}.maintag, 'Frequency' )
    %--------------------------------------------------------------------------
    if strcmp( R.jq{q}.subtag, 'Shift' )
      rqre_field( Q.FSHIFTFIT, 'L2', 'Q.FSHIFTFIT' );                       %&%
      out = qarts_get( Q.FSHIFTFIT.L2 );
      rqre_datatype( out, @isboolean, 'Q.FSHIFTFIT.L2' );                   %&%
      if out
        s = 'fshift';
      end
    elseif strcmp( R.jq{q}.subtag, 'Stretch' )
      rqre_field( Q.FSTRETCHFIT, 'L2', 'Q.FSTRETCHFIT' );                   %&%
      out = qarts_get( Q.FSTRETCHFIT.L2 );
      rqre_datatype( out, @isboolean, 'Q.FSTRETCHFIT.L2' );                 %&%
      if out
        s = 'fstretch';
      end
    else                                                                    %&%
      error( 'Unknown frequency subtag' );                                  %&%
    end
    
  elseif strcmp( R.jq{q}.maintag, 'Polynomial baseline fit' )
    %--------------------------------------------------------------------------
    rqre_field( Q.POLYFIT, 'L2', 'Q.POLYFIT' );                             %&%
    out = qarts_get( Q.POLYFIT.L2 );
    rqre_datatype( out, @isboolean, 'Q.POLYFIT.L2' );                       %&%
    %
    if out
      s = sprintf( 'polyfit%d', sscanf(R.jq{q}.subtag(end+[-1:0]),'%d') );
    end

  elseif strcmp( R.jq{q}.maintag, 'Sinusoidal baseline fit' )
    %--------------------------------------------------------------------------
    rqre_field( Q.SINEFIT, 'L2', 'Q.SINEFIT' );                             %&%
    out = qarts_get( Q.SINEFIT.L2 );
    rqre_datatype( out, @isboolean, 'Q.SINEFIT.L2' );                       %&%
    %
    if out
      s = sprintf( 'sinefit%d', sscanf(R.jq{q}.subtag(end+[-1:0]),'%d')+1 );
    end
    
  else
    error( sprintf( 'Unknown retrieval quantity: %s', R.jq{q}.maintag ) );
  end

  if out

    %--- Special stuff for atmospheric fields
    if atmfield

      % Output follows strictly retrieval range (empty L2_RANGE)
      if ~isfield( Astruct, 'L2_RANGE' )  
        %
        % Fill special L2 fields
        L2.([s,'_p'])     = Astruct.GRIDS{1};
        %
        if Q.ATMOSPHERE_DIM >= 2
          L2.([s,'_lat']) = Astruct.GRIDS{2};
          siz(2)          = length( Astruct.GRIDS{2} );
          %
          if Q.ATMOSPHERE_DIM == 3
            L2.([s,'_lon']) = Astruct.GRIDS{3};
            siz(3)          = length( Astruct.GRIDS{3} );
          end
        end      
      
      % Modify range?
      else
        %- Check that L2_RANGE is OK
        range = qarts_get( Astruct.L2_RANGE );
        rqre_datatype( range, @isvector, sprintf('L2 range for %s',s) );    %&%
        if length(range) < Q.ATMOSPHERE_DIM*2                               %&%
          error( sprintf('L2 range for %s is too short.',s) );              %&%
        end                                                                 %&%
        if range(1) >= range(2)                                             %&%
          error( sprintf( ...                                               %&%
             'Pressure limits in L2 range (for %s) in wrong order? .',s) ); %&%
        end                                                                 %&%

        % Pressure dimension
        [ngrid,ip]    = r2g_local( Astruct.GRIDS{1}, R.p_grid, range(1:2) );
        siz(1)        = length(ngrid);    
        L2.([s,'_p']) = ngrid;
        %
        % Latitude dimension
        if Q.ATMOSPHERE_DIM == 1
          ind              = ind( ip );
          Astruct.GRIDS{1} = ngrid;     % Used to get VMR0 below
        elseif Q.ATMOSPHERE_DIM >= 2
          [ngrid,ilat] = r2g_local( Astruct.GRIDS{2}, R.lat_grid, range(3:4) );
          siz(2)       = length(ngrid);    
          L2.([s,'_lat']) = ngrid;
          %
          if Q.ATMOSPHERE_DIM == 2
            ind = ind( matvec( repmat( ip, 1, length(ilat) ) + ...
                               repmat( (ilat'-1)*length(Astruct.GRIDS{1}), ...
                                       length(ip), 1 ) ) );
            Astruct.GRIDS{2} = ngrid;
          else
            [ngrid,ilon] = r2g_local( Astruct.GRIDS{3}, R.lon_grid, ...
                                                                  range(5:6) );
            siz(3)       = length(ngrid);    
            L2.([s,'_lon']) = ngrid;
            ind = ind( matvec( repmat( ip, [1 length(ilat) length(ilon)] ) + ...
                               repmat( (ilat'-1)*length(Astruct.GRIDS{1}), ...
                                       [length(ip) 1 length(ilon)] ) + ...
                               repmat( (reshape(ilon,[1 1 length(ilon)])-1)*...
                                          length(Astruct.GRIDS{1}) * ...
                                          length(Astruct.GRIDS{2}), ...
                                       [1 length(ilat) length(ilon)] ) ) );
            Astruct.GRIDS{3} = ngrid;
          end
        end
        clear ngrid ip ilat ilon
      end
    end
  
    %--- Fill L2
    %
    L2.([s,'_x'])  = reshape( X.x(ind), siz );
    %
    if any( strcmp( Q.L2_EXTRA, 'xa' ) )
      L2.([s,'_xa']) = reshape( xa(ind), siz );
    end
    %
    if any( strcmp( Q.L2_EXTRA, 'e' ) )
      L2.([s,'_e'])  = reshape( X.e(ind), siz );
    end
    if any( strcmp( Q.L2_EXTRA, 'eo' ) )
      L2.([s,'_eo']) = reshape( X.eo(ind), siz );
    end
    if any( strcmp( Q.L2_EXTRA, 'es' ) )    
      L2.([s,'_es']) = reshape( X.es(ind), siz );  
    end
    if any( strcmp( Q.L2_EXTRA, 'ex' ) )    
      L2.([s,'_ex']) = reshape( X.ex(ind), siz );  
    end
    %
    if any( strcmp( Q.L2_EXTRA, 'mresp' ) )
      L2.([s,'_mr']) = reshape( mresp(ind), siz );
    end
    if any( strcmp( Q.L2_EXTRA, 'A' ) )
      L2.([s,'_A']) = As{q};
    end
    
    % If ABS_SPECIES + rel or logrel, save also vmr0
    if strcmp( R.jq{q}.maintag, 'Absorption species' )
      if any( strcmp( R.jq{q}.mode, { 'rel', 'logrel' } ) )
        vmr0 = arts_regrid( Q.ATMOSPHERE_DIM, Q, getdims( ...
                     R.vmr_field0(ispecies,:,:,:), 2:Q.ATMOSPHERE_DIM+1 ), ...
                            Astruct.GRIDS );
        L2.([s,'_vmr0']) = reshape( vmr0, siz );  
      end    
    end
  end
end





function [newgrid,ii] = r2g_local( retgrid, fmgrid, range )
  %
  np    = length( retgrid );
  %
  if range(1) >= retgrid(end)  &  range(2) <= retgrid(1)
    ii      = find( retgrid >= range(1)  &  retgrid <= range(2) );
    newgrid = retgrid(ii);     
  elseif range(1) < retgrid(end)  &  range(2) > retgrid(1)
    newgrid = [ min([range(2),fmgrid(1)]); 
                retgrid; 
                max([range(1),fmgrid(end)]) ];     
    ii      = [ 1 1:np np ]';
  elseif range(1) < retgrid(end) 
    ii      = find( retgrid <= range(2) );
    newgrid = [ retgrid(ii); max([range(1),fmgrid(end)]) ];     
    ii      = [ ii; np ];
  else
    ii      = find( retgrid >= range(1) );
    newgrid = [ min([range(2),fmgrid(1)]); retgrid(ii) ];     
    ii      = [ 1; ii ];
  end
return