% ARTS_RADIOOCC_1D   Simulation of 1D radio occultation, no power
%
%    The function simulates an occultation measurement between two
%    satellites, denoted as transmitter and receiver, respectively.  
%    
%    For NWP radio occultation the transmitter is the GPS satellite and the
%    receiver the LEO satellite. The assumed geometry is explained using this
%    case. The occultation is considered to take place exactly in the LEO orbit
%    plane. Angular distances are denoted as "latitude" following the ARTS
%    nomenclature. The latitude gives here the angular distance from the GPS
%    satellite. The flight direction of both satellites can be adjusted.
%
%    If either receiver or transmitter is not in orbit around the planet,
%    but for example placed on Earth, use then the option for 'none'
%    movement. 
%
%    Defocusing is calculated inside the function (ie. not inside ARTS),
%    where in the ARTS nomenclature "method 2" is used (note the field
%    O.defoc_shift, that influences the result obtained). 
%
%    Settings and output are first described assuming that attenuation
%    variables are not considered.
%
%    The basic results are gathered into the structure R having fields
%       z_impact    : The impact altitude, ie. the non-refracted tangent 
%                     altitude. Returned as monotonously decreasing values.
%       z_tan       : Tangent altitude.
%       lat_tan     : Latitude of tangent point.
%       lat_distance: The latitude distance between the satellites.
%       bangle      : Bending angle.
%       slta        : Straight line tangent altitude.
%       l_geometric : The (straight line) geometrical distance between the 
%                     satellites.
%       l_optpath   : The optical path length.
%       l_proppath  : The propagation path length.
%       t           : Time relative to the occultation with max z_impact.
%   The data in *R* are for an equidistant *R.z_impact*.
%
%   The results are also returned as a function of time in the structure T. 
%   The field T.t is the time grid used. The spacing of this grid follows
%   O.f_sampling. The remaining fields of T are matrices (in contrast to R 
%   only having vector fields), where the columns represent "multi-pathing". 
%   That is, each column represents a path (not to be confused with the 
%   pencil beam paths used i ARTS). The limit between these paths correspond 
%   to discontinuities in the arrival time (for pencil beam paths).
%   This structure T contains the same fields as R. 
%
%   The occultation is specified by the structure O having the fields
%      tra_altitude : Altitude of transmitter orbit.
%      rec_altitude : Altitude of receiver orbit.
%      frequency    : Frequency of signal.
%      lmax         : As ARTS WSV *lmax*. This setting affects here mainly
%                     accuracy of tangent point.
%      lraytrace    : As ARTS WSV *lraytrace*. Determines the overall
%                     accuracy. A value in the order of 100 m should be OK.
%      z_surface    : Surface altitude.
%      z_impact_max : Start altitude of occultation.
%      z_impact_dz  : Vertical spacing between path calculations.
%      z_impact4t0  : The impact height used as time reference (t=0 here).
%      f_sampling   : Sampling frequency for data in T.
%   And optional fields
%      z_impact_min : End altitude of occultation. Default is to use z_surface.
%      rec_movement : String describing movement. Options are 'none',
%                     'approaching' or 'disappearing'. The last is default.
%      tra_movement : String describing movement. Options are 'none',
%                     'approaching' or 'disappearing'. The last is default.
%      r_planet     : Radius of reference ellipsoid. If set this replaces
%                     the default value, that varies with planet.
%      n_agenda     : Agenda for refractive index. If set this replaces
%                     the default value, that varies with planet.
%
%   If O.do_atten is set to true, R also has these fields
%      tr_atmos : Transmission due to attenuation of atmospheric
%                 constituents (absorption and scattering).
%      tr_defoc : Transmission due to defocusing.
%      tr_space : Transmission due to free space loss (defined as 1/(4*pi*l*l))
%      tr_total : Total transmission, the product of the terms above
%   If also O.do_absspecies is, R includes
%      tr_absspecies : The atmospheric attenuation for each absorption
%                      species separately. This field is ignored for T.
%   If also O.do_faraday is true, R includes
%      faraday  : Total Faraday rotation [deg].
%   Default for both O.do_atten and O.do_faraday is false. O.do_absspecies
%   and O.do_faraday only considered if O.do_atten is true. 
%   Additional settings when O.do_atten is true
%      defoc_shift  : Angular shift for defocusing. See iyRadioLInk.
%                     Default is 3e-3.
%
%   Finally, the atmosphere is specified by the structure A having at least
%   these fields
%      planet  : The planet to model, such as 'earth'.
%      atmfunc : Handle to function inserting an atmosphere, such as
%                @arts_include_fascode.
%   The structure A is passed on to the atmosphere function. That is, A
%   likely also includes fields required by the "atmfunc". See
%   *arts_include_fascode* for how such a function is assumed to work
%
% FORMAT   R = arts_radioocc_1D(Q,O,A[,workfolder])
%        
% OUT   R   Result structure, see above.
% IN    Q   Initial settings of Q. If empty: Q = qarts;   
%           Note that not all fields are considered, this including
%           WSMS_BEFORE_RTE and YCALC_WSMS.
%       O   Occultation structure, see above. If empty, some default 
%           values set that work as demonstration.
%       A   Atmospheric structure, see above. If empty, some planet specific
%           settings are applied. For example, for Earth Fascode tropical is
%           used. Free electrons are not included automatically for any planet.
% OPT   workfolder   Path to a folder where to place all files generated.
%                    Default is to create a temporary folder, following the
%                    general atmlab settings.

% 2013-10-16   Created by Patrick Eriksson.

function [R,T] = arts_radioocc_1D(Q,O,A,workfolder)
%
if isempty(Q)
  Q = qarts;
end
%
if isempty(O)
  O.rec_altitude = 820e3;
  O.tra_altitude = 20200e3;
  O.tra_movement = 'disappearing';
  O.frequency    = 1575.42e6;
  O.lmax         = 2e3;
  O.lraytrace    = 100;
  O.z_surface    = 0;

  O.z_impact_max = 30e3;
  O.z_impact_dz  = 200;
  O.z_impact4t0  = 20e3;
  O.f_sampling   = 4;

end
%
if isempty(A)
  A.planet       = 'earth';
  A.atmfunc      = @qarts_add_fascode;
  A.fascode_atm  = 'tropical';
end
%
if nargin < 4, workfolder = []; end


% Check movements
%
rec_movement = safegetfield( O, 'rec_movement', 'disappearing' );
tra_movement = safegetfield( O, 'tra_movement', 'disappearing' );
%
if strcmp( rec_movement, 'none' )  &  strcmp( tra_movement, 'none' )
  error( 'Both O.rec_movement and O.tra_movement can not be ''none'',' );
end

% Get basic calculation options
%
do_atten      = safegetfield( O, 'do_atten', false );
do_absspecies = safegetfield( O, 'do_absspecies', [] );
do_faraday    = safegetfield( O, 'do_faraday', false );



%- Create a temporary workfolder
%
if isempty( workfolder )
  workfolder = create_tmpfolder;
  cu = onCleanup( @()delete_tmpfolder( workfolder ) );
end
%
cfile = fullfile( workfolder, 'cfile.arts' );


%- Set basic and observation related fields of Q
%
Q = q_basic_local( Q, O, workfolder, do_atten, do_faraday );


%- Set basic and ppath parts of Q, and get mass of planet
%
[Q,M] = q_planet_local( Q, A, workfolder, do_atten, do_faraday, do_absspecies );
%
if isfield(O,'r_planet') & ~isempty(O.r_planet)
  Q.REFELLIPSOID = [ O.r_planet, 0 ]';
end
%
if isfield(O,'n_agenda') & ~isempty(O.n_agenda)
  Q.REFR_INDEX_AIR_AGENDA = O.n_agenda;
end


%- Set up z_impact grid and R
%
R.z_impact = [ O.z_impact_max : -O.z_impact_dz : ...
                             safegetfield( O, 'z_impact_min', O.z_surface ) ]';
n0         = length( R.z_impact );
%
[R.z_tan,R.lat_tan,R.bangle,R.lat_distance]     = deal( repmat( NaN, n0, 1 ) );
[R.slta,R.l_geometric,R.l_optpath,R.l_proppath] = deal( repmat( NaN, n0, 1 ) );
%
if do_atten
  [R.tr_defoc,R.tr_space,R.tr_atmos] = deal( repmat( NaN, n0, 1 ) );
  if do_faraday
    R.faraday                        = deal( repmat( NaN, n0, 1 ) );
  end
end


%- Radiii
%
r_tra = Q.REFELLIPSOID(1) + O.tra_altitude;
r_rec = Q.REFELLIPSOID(1) + O.rec_altitude;


%- Run ARTS
%
[za_tra] = deal( repmat( NaN, n0, 1 ) );
%
for i = 1 : n0

  % Zenith angle to use
  %
  za_tra(i) = geomztan2za( Q.REFELLIPSOID(1), O.tra_altitude, R.z_impact(i) );
  %
  Q.SENSOR_LOS = za_tra(i);

  % Run ARTS
  %
  S = qarts2cfile( Q, { 'Generl', 'AtmSrf', 'AbsrptSave', 'CldBox', ...
                        'RteSet', 'CloseF' }, workfolder );
  strs2file( cfile, S );  
  notok = arts( cfile, true );
  %
  if notok
    error('\n!!! Error while running ARTS !!!\n');
  end

  ppath = xmlLoad( fullfile( workfolder, 'ppath.xml' ) );   

  if strcmp( ppath.background, 'space' )  &  ppath.np > 1
  
    % Extract tangent point
    [u,j]        = min( ppath.pos(:,1) );
    R.z_tan(i)   = ppath.pos(j,1);
    R.lat_tan(i) = ppath.pos(j,2);

    % Bending angle
    R.bangle(i) = ppath.start_los(1) - ppath.end_los(1) + ppath.start_pos(2);

    % Calculate angular distance between transmitter and receiver
    c                 = ppath.r(end) * sind(ppath.start_los);
    za_rec            = asind(c/r_rec); 
    dlat              = ppath.start_los - za_rec;
    R.lat_distance(i) = ppath.start_pos(2) + dlat;

    % Path lenghts 
    % Part covered by ppath
    lppath = ppath.end_lstep + sum( ppath.lstep );
    lopt   = ppath.end_lstep + sum( ppath.lstep .* ( 0.5 * ...
                               (ppath.nreal(1:end-1)+ppath.nreal(2:end)) ) );
    % Add remaining part
    lext   = r_rec * sind(dlat) / sind(ppath.start_los); 
    lppath = lppath + lext;
    lopt   = lopt   + lext;
    
    % SLTA and geometrical distance
    lgeom        = sqrt( r_tra^2 + r_rec^2 - 2*r_tra*r_rec*...
                                                     cosd(R.lat_distance(i)) );
    R.slta(i)    = r_tra * r_rec * sind(R.lat_distance(i)) / lgeom - ...
                                                             Q.REFELLIPSOID(1);
    R.l_proppath(i)  = lppath;
    R.l_optpath(i)   = lopt;
    R.l_geometric(i) = lgeom;

    if do_atten
      
      iy     = xmlLoad( fullfile( workfolder, 'iy.xml' ) );   
      iy_aux = xmlLoad( fullfile( workfolder, 'iy_aux.xml' ) );   

      R.tr_space(i) = 1 / ( 4 * pi * lppath^2 );
      R.tr_atmos(i) = iy(1);            

      if do_faraday
        R.faraday(i) = iy_aux{1}; 
      end

      % Transmission for each abs_species
      if ~isempty(do_absspecies)
        nas = length(iy_aux) - do_faraday;
        if ~isfield( R, 'tr_absspecies' )
          R.tr_absspecies = deal( repmat( NaN, n0, nas ) );
        end
        %
        for j = 1 : nas
          ga = squeeze( iy_aux{j+do_faraday}(1,1,1,:) );
          R.tr_absspecies(i,j) = exp( -0.5 * sum( ppath.lstep .* ...
                                               ( ga(1:end-1) + ga(2:end) ) ) );
        end
      end
      
      % Remaining attenuation calculated as post-processing
    end
  end
end


if do_atten
  
  % Defocusing
  %
  defoc_shift = safegetfield( O, 'defoc_shift', 3e-3 );
  ind         = find( ~isnan( R.bangle ) );
  %
  for i = 1 : n0
    if ~isnan( R.bangle(i) )
   
      r_tan = Q.REFELLIPSOID(1) + R.z_tan(i);
      l1    = sqrt( r_tra^2 - r_tan^2 );
      l2    = sqrt( r_rec^2 - r_tan^2 );
      fac   = pi/180 * (l1*l2)/(l1+l2); 
   
      za = za_tra(i) - defoc_shift;
      a1 = r_tra * sind( za );
      b1 = interp1( za_tra(ind), R.bangle(ind), za, 'linear', 'extrap' );
      za = za_tra(i) + defoc_shift;
      a2 = r_tra * sind( za );
      b2 = interp1( za_tra(ind), R.bangle(ind), za, 'linear', 'extrap' );

      R.tr_defoc(i) = 1 / ( 1 - fac*(b2-b1)/(a2-a1) );
    end
  end


  % Total transmission      
  R.tr_total = R.tr_space .* R.tr_atmos .* R.tr_defoc;
end

% Speed of increase in angular distance 
%
G         = constants( 'GRAVITATIONAL_CONSTANT' );
t_rec     = sqrt( (4*pi^2*r_rec^3) / (G*M) );
%
switch lower(rec_movement)
 case 'none'
  degpersec = 0;
 case 'approaching'
  degpersec = - 360 / t_rec;
 case 'disappearing'
  degpersec = + 360 / t_rec;
 otherwise
  error( 'Unrecognised choice for *O.rec_movement* (%s).', rec_movement );
end
%
t_tra     = sqrt( (4*pi^2*r_tra^3) / (G*M) );
%
switch lower(tra_movement)
 case 'none'
  ;
 case 'approaching'
  degpersec = degpersec - 360 / t_tra;
 case 'disappearing'
  degpersec = degpersec + 360 / t_tra;
 otherwise
  error( 'Unrecognised choice for *O.tra_movement* (%s).', tra_movement );
end


% Relative arrival time
%
ind = find( ~isnan( R.lat_distance ) );
%
R.t = ( R.lat_distance - interp1( R.z_impact(ind), R.lat_distance(ind), ...
                                                O.z_impact4t0 ) ) / degpersec;

if nargout == 1
  return;   % --->
end

% Create T
%
% Time grid to use
T.t   = [ min(R.t) : 1/O.f_sampling : max(R.t) ]';
%
% Find start and end of each time chunck
istart = [];
iend   = [];
i1     = NaN; % Start of present chunck%

for i = 1 : n0
  % If Nan, then we are inbetween chuncks
  if isnan( R.t(i) )
    i1 = NaN;

  else
    % If i1==NaN, this is the start of a new chunck
    if isnan(i1)
      i1 = i;
    end
    
    % End point if last point or next is NaN
    if i == n0 | isnan(R.t(i+1))
      if i > i1 % Ignore length-1 chuncks
        istart = [ istart i1 ];
        iend   = [ iend   i  ];
      end
      i1     = NaN;
    
    % Also end point if sign change of t-derivate
    elseif i>1  &  ~isnan(R.t(i-1))  &  ...
          sign(R.t(i+1)-R.t(i)) ~= sign(R.t(i)-R.t(i-1))
      istart = [ istart i1 ];
      iend   = [ iend   i  ];
      i1     = i;      
    end    
  end
end


% Allocate T
%
np    = length( istart );
nt    = length( T.t );
%
rfields = fieldnames( R );
%
for j = 1 : length( rfields )
  fname = rfields{j};
  if ~strcmp( fname, 't' )
    T.(fname) = repmat( NaN, nt, np );
  end
end  


% Interpolate in T.t
for i = 1 : np

  % Interpolate over time of chunk
  ir = istart(i) : iend(i);
  tmin = min( [ R.t(ir([1,end])) ] );
  tmax = max( [ R.t(ir([1,end])) ] );
  it = find( T.t >= tmin  &  T.t < tmax );  

  for j = 1 : length( rfields )
    fname = rfields{j};
    if ~strcmp( fname, { 't', 'tr_absspecies'} )
      T.(fname)(it,i) = interp1( R.t(ir), R.(fname)(ir), T.t(it) );
    end
  end
end


R = orderfields( R );
T = orderfields( T );

return


%----------------------------------------------------------------------------
function Q = q_basic_local(Q,O,workfolder,do_atten,do_faraday)
  %
  Q.INCLUDES{end+1}       = fullfile( 'ARTS_INCLUDES', 'general.arts' );
  Q.INCLUDES{end+1}       = fullfile( 'ARTS_INCLUDES', 'agendas.arts' ); 
  Q.INCLUDES{end+1}       = fullfile( 'ARTS_INCLUDES', 'continua.arts' );
  %
  Q.ATMOSPHERE_DIM        = 1;
  Q.STOKES_DIM            = 1;   % Can be changed below
  Q.F_GRID                = O.frequency;
  Q.PPATH_LMAX            = O.lmax;
  Q.PPATH_LRAYTRACE       = O.lraytrace;
  %
  Q.CLOUDBOX_DO           = false;
  %
  Q.PPATH_AGENDA          = { 'ppath_agenda__FollowSensorLosPath'   };
  Q.PPATH_STEP_AGENDA     = { 'ppath_step_agenda__RefractedPath'    };
  %
  Q.SENSOR_POS            = O.tra_altitude;
  %
  Q.Z_SURFACE             = O.z_surface;
  %
  Q.WSMS_AT_END{end+1} = 'VectorExtractFromMatrix(rte_pos,sensor_pos,0,"row")';
  Q.WSMS_AT_END{end+1} = 'VectorExtractFromMatrix(rte_los,sensor_los,0,"row")';
  Q.WSMS_AT_END{end+1} = 'VectorSet(rte_pos2,[])';
  %
  if ~do_atten
    Q.WSMS_AT_END{end+1} = 'ppathCalc';
  else
    %
    Q.WSMS_AT_END{end+1} = 'jacobianOff';
    %
    Q.ABSORPTION         = 'OnTheFly';
    Q.ABS_LINES_FORMAT   = 'None';
    %
    if do_faraday
      Q.STOKES_DIM              = 3; 
      Q.PROPMAT_CLEARSKY_AGENDA = { ...
                                 'propmat_clearsky_agenda__OnTheFly_Faraday' };
    else
      Q.PROPMAT_CLEARSKY_AGENDA = { 'propmat_clearsky_agenda__OnTheFly' };
    end
    %
    Q.IY_TRANSMITTER_AGENDA = { 'iy_transmitter_agenda__UnitUnpolIntensity' };
    %
    Q.WSMS_AT_END{end+1} = 'AgendaSet(iy_main_agenda){iyTransmissionStandard}';                    
    %
    Q.WSMS_AT_END{end+1} = 'iyCalc';
    Q.WSMS_AT_END{end+1} = ...
                      sprintf('WriteXML("ascii",iy,"%s/iy.xml")',workfolder);
    Q.WSMS_AT_END{end+1} = ...
                sprintf('WriteXML("ascii",iy_aux,"%s/iy_aux.xml")',workfolder);
  end
  %
  Q.WSMS_AT_END{end+1} = ...
      sprintf('ppathWriteXMLPartial("ascii",ppath,"%s/ppath.xml")',workfolder);
  %
return


%----------------------------------------------------------------------------
function [Q,M] = q_planet_local(Q,A,workfolder,do_atten,do_faraday, ...
                                                        do_absspecies)
  %
  rqre_field( A, 'planet' );
  rqre_field( A, 'atmfunc' );
  %
  if ~isa( A.atmfunc, 'function_handle' )
    error( 'The field *A.atmfunc* must be a function handle' ); 
  end
  if ~exist( func2str(A.atmfunc), 'file' )
    error( 'The function *%s* is not found (selected by A.atmfunc).', ...
                                                        func2str(A.atmfunc) ); 
  end

  % Set basics and default for planet:
  %
  switch upper( A.planet )

   case 'VENUS'
    %
    M = 4.8676e24;
    %
    Q.INCLUDES{end+1} = fullfile( 'ARTS_INCLUDES', 'planet_venus.arts' );
    Q.REFELLIPSOID    = ellipsoidmodels( 'SphericalVenus' );
   
   case 'EARTH'
    %
    M = constants( 'EARTH_MASS' );
    %
    Q.INCLUDES{end+1} = fullfile( 'ARTS_INCLUDES', 'planet_earth.arts' );
    Q.REFELLIPSOID    = ellipsoidmodels( 'SphericalEarth' );
    %
    if ~isfield( A, 'ABS_SPECIES' )
      A.ABS_SPECIES(1).TAG{1} = 'N2-SelfContStandardType';
      A.ABS_SPECIES(2).TAG{1} = 'O2-PWR98';
      A.ABS_SPECIES(3).TAG{1} = 'H2O-PWR98';
      A.ABS_SPECIES(4).TAG{1} = 'free_electrons';
    end

   case 'MARS'
    %
    M = 6.4185e23;
    %
    Q.INCLUDES{end+1} = fullfile( 'ARTS_INCLUDES', 'planet_mars.arts' );
    Q.REFELLIPSOID    = ellipsoidmodels( 'SphericalMars' );
    
   case 'JUPITER'
    %
    M = 1.8986e27;
    %
    Q.INCLUDES{end+1} = fullfile( 'ARTS_INCLUDES', 'planet_jupiter.arts' );
    Q.REFELLIPSOID    = ellipsoidmodels( 'SphericalJupiter' );
   
   otherwise
    error( 'Unrecognised choice for A.planet (%s).', A.planet );
  end

  switch upper( A.planet )
   case 'EARTH'
    %
    Q.REFR_INDEX_AIR_AGENDA = { 
        'NumericSet( refr_index_air, 1.0 )', ...
        'NumericSet( refr_index_air_group, 1.0 )',...
        'refr_index_airThayer', ...
        'refr_index_airFreeElectrons( demand_vmr_value = 0 )' };
    %
   otherwise 
    %
    Q.REFR_INDEX_AIR_AGENDA = { 
        'NumericSet( refr_index_air, 1.0 )', ...
        'NumericSet( refr_index_air_group, 1.0 )',...
        'refr_index_airMWgeneral', ...
        'refr_index_airFreeElectrons( demand_vmr_value = 0 )' };
    %
  end
  
  % Include atmospheric specific data
  Q = A.atmfunc( A, Q, workfolder );
  
  if 0   % Set to 1 if you want to test without refraction
    Q.REFR_INDEX_AIR_AGENDA = { 'refr_index_air_agenda__NoRefrac' };
  end

  % Set iy_aux_vars
  saux = [];
  if do_atten
    if do_faraday
      if isempty(do_absspecies)
        saux = '"Faraday rotation"';
      else
        saux = '"Faraday rotation",';        
      end
    end
    if ~isempty(do_absspecies)
      n = length( do_absspecies );
      for i = 1 : n
        k = do_absspecies(i) - 1;
        if i < n
          saux = [ saux, sprintf('"Absorption, species %d",', k ) ];
        else
          saux = [ saux, sprintf('"Absorption, species %d"', k ) ];
        end
      end
    end
    Q.WSMS_AT_START{end+1} = [ 'ArrayOfStringSet(iy_aux_vars,[',saux,'])' ];    
  end
  
return
