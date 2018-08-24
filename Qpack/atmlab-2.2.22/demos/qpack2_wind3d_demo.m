% QPACK2_WIND3D_DEMO   Demonstration of Qpack2 with scanning in azimuth
%
%    This file exemplifies how to set Qpack2 for an instrument scanning in
%    azimuth (and azimuth angle matters). The example treats a measurement
%    aimimg at retrieving both horisontal wind components.
%
% FORMAT   L2 = qpack2_wind3d_demo
%        
% OUT      L2   L2 data output from *qpack2*.

% 2010-05-12   Created by Patrick Eriksson.

function L2 = qpack2_wind3d_demo
  
errid = ['atmlab:' mfilename]; 

%- Qarts settings
%
Q    = q_demo;           % Local file, found below


%- Measurement data
%
u_wind = 60;
v_wind = -40;
%
Y = y_demo( Q, u_wind, v_wind );


%- Check that all frequencies are OK
%
if ~qp2_check_f( Q, Y, 1e3 );
  error( errid, ...
            'Some mismatch between Q.F_BACKEND and frequencies of spectra.' );
end


%- OEM variables
%
O = qp2_l2( Q );         % This ensures that OEM returns the variables needed 
%                          to fill the L2 structure, as defined in Q
O.linear = true;
%
if ~O.linear 
  O.itermethod = 'GN';
  O.stop_dx    = 0.01;
  O.maxiter    = 5;
end


%- Make inversion
%
L2 = qpack2( Q, O, Y );


%- Plot, if no output argument
%
if ~nargout

  % Wind profiles
  figure(1),clf  
  plot( [0 0], [10 90], 'k-', ...
        L2(1).wind_u_x, p2z_simple(L2(1).wind_u_p)/1e3, 'b', ...
        u_wind*[1 1], [10 90], 'm', ...
        L2(1).wind_v_x, p2z_simple(L2(1).wind_v_p)/1e3, 'r', ...
        v_wind*[1 1], [10 90], 'c' );
  xlabel( 'Wind components [m/s]' );
  ylabel( 'Approximate altitude [km]' );
  axis( [ -80 80 10 90 ] )
  legend( 'A priori, U and V', 'Retrieved U', 'True U', ...
                               'Retrieved V', 'True V' );

  % Ozone profile
  figure(2),clf
  plot( L2(1).species1_x*1e2, p2z_simple(L2(1).species1_p)/1e3, 'b', ...
        L2(1).species1_xa*1e2, p2z_simple(L2(1).species1_p)/1e3, 'k-' );
  xlabel( 'Ozone compared to a priori [%]' );
  ylabel( 'Approximate altitude [km]' );
  axis( [ 0 130 10 90 ] )
  legend( 'Retrieval', 'True and a priori' );

  % Spectra
  figure(3),clf
  plot( L2(1).y, 'k.' );
  hold on
  h(1) = plot( L2(1).yf, 'b-' );
  h(2) = plot( L2(1).bl, 'b-.');
  xlabel( 'Data index' );
  ylabel( 'Tb [K]' );
%  axis( [ min(L2(1).f/1e9) max(L2(1).f/1e9) 0 18 ] )
  legend( h, 'Fitted', 'Baseline' );
end


return
%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------





function Q = q_demo
 
errid = ['atmlab:' mfilename];
%- Atmlab settings
%
arts_xmldata_path = atmlab( 'ARTS_XMLDATA_PATH' );
arts_includes     = atmlab( 'ARTS_INCLUDES' );
if isnan( arts_xmldata_path ) 
  error( errid,'You need to set ARTS_XMLDATA_PATH to run this exmaple.' );
end
if isnan( arts_includes )
  error( erird,'You need to ARTS_INCLUDES to run this example.' );
end                                                      
%
fascod = fullfile( arts_xmldata_path, 'planets', 'Earth', 'Fascod' );


%- Init Q
%
Q = qarts;
%
Q.INCLUDES            = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                          fullfile( 'ARTS_INCLUDES', 'agendas.arts' ), ...
                          fullfile( 'ARTS_INCLUDES', 'continua.arts' ), ...
                          fullfile( 'ARTS_INCLUDES', 'planet_earth.arts' ) };
Q.ATMOSPHERE_DIM      = 3;
Q.STOKES_DIM          = 1;
Q.J_DO                = true;
Q.CLOUDBOX_DO         = false;


%= Define agendas
%
% Here we do it by using the predefined agenda templates 
%   (found in arts/controlfiles/general/agendas.arts)
% This works only if the pre-defined agenda is names following the pattern:
%   name_of_agenda__(Something)
%
Q.PPATH_AGENDA               = { 'ppath_agenda__FollowSensorLosPath'   };
Q.PPATH_STEP_AGENDA          = { 'ppath_step_agenda__GeometricPath'    };
Q.BLACKBODY_RADIATION_AGENDA = { 'blackbody_radiation_agenda__Planck'  };
Q.IY_SPACE_AGENDA            = { 'iy_space_agenda__CosmicBackground'   };
Q.IY_SURFACE_AGENDA          = { 'iy_surface_agenda__UseSurfaceRtprop' };
Q.IY_MAIN_AGENDA             = { 'iy_main_agenda__Emission'            };


%- Radiative transfer
%
Q.IY_UNIT             = 'RJBT'; 
Q.YCALC_WSMS          = { 'yCalc' };
%
Q.PPATH_LMAX          = 250;


%- Absorption
%
Q.ABS_LINES           = fullfile( atmlab_example_data, 'o3line111ghz' );
Q.ABS_LINES_FORMAT    = 'Arts';
%
Q.ABSORPTION          = 'OnTheFly';
Q.ABS_NLS             = [];

%- Atmospheric grids
%
z_toa                 = 95e3;
z_surf                = 1e3;
%
Q.P_GRID              = z2p_simple( z_surf-1e3 : 2e3 : z_toa )';
Q.LAT_GRID            = [ 30 : 10 : 60 ]';
Q.LON_GRID            = [ -20 : 20 : 20 ]';


%- Surface
%
Q.Z_SURFACE           = repmat( z_surf, length(Q.LAT_GRID), ...
                                        length(Q.LON_GRID) );


%- Frequency, spectrometer and pencil beam antenna
%
% The hypothetical spectrometer has rectangular response functions
%
Q.F_GRID              = qarts_get( fullfile( atmlab_example_data , ...
                                                      'f_grid_111ghz.xml' ) );
%
H                     = qartsSensor;
%
H.SENSOR_NORM         = true;
%
H.BACKEND_DO          = true;
df                    = 0.05e6;
H.F_BACKEND           = ( min(Q.F_GRID)+df : df : max(Q.F_GRID)-df )';
%
B.name                = 'Spectrometer channel response function';
B.gridnames           = { 'Frequency' };
B.grids               = { [-df/2 df/2] };
B.dataname            = 'Response';
B.data                = [1 1];
%
H.BACKEND_CHANNEL_RESPONSE{1} = B;
clear B
%
Q.SENSOR_DO           = true;
Q.SENSOR_RESPONSE     = H;
%
Q.ANTENNA_DIM         = 1;
Q.MBLOCK_ZA_GRID      = 0;



%- Correlation of thermal noise 
%
Q.TNOISE_C = speye( length(H.F_BACKEND) );
%
clear H 


%- Define L2 structure (beside retrieval quantities below)
%
Q.L2_EXTRA     = { 'cost', 'dx', 'xa', 'y', 'yf', 'bl', 'ptz', ...
                   'mresp', 'A', 'e', 'eo', 'es', 'date' };


%- Temperature
%
Q.T.RETRIEVE   = false;
Q.T.ATMDATA    = gf_artsxml( fullfile( arts_xmldata_path, 'climatology', ...
                        'msis90', 'msis90.t.xml' ), 'Temperature', 't_field' );

%- Determine altitudes through HSE
%
Q.HSE.ON       = true;
Q.HSE.P        = Q.P_GRID(1);
Q.HSE.ACCURACY = 0.1;


%- Species

% Ozone, only species is retrieved here
Q.ABS_SPECIES(1).TAG      = { 'O3' };
Q.ABS_SPECIES(1).RETRIEVE = true;
Q.ABS_SPECIES(1).L2       = true;
Q.ABS_SPECIES(1).GRIDS    = { Q.P_GRID, mean(Q.LAT_GRID), mean(Q.LON_GRID)};
Q.ABS_SPECIES(1).ATMDATA  = gf_artsxml( fullfile( fascod, ...
      'midlatitude-winter', 'midlatitude-winter.O3.xml' ), 'O3', 'vmr_field' );
%
Q.ABS_SPECIES(1).UNIT     = 'rel';
Q.ABS_SPECIES(1).SX       = ...
                     covmat1d_from_cfun( Q.ABS_SPECIES(1).GRIDS{1}, 0.5, ...
                                               'lin', 0.2, 0.00, @log10 ) + ...
                     covmat1d_from_cfun( Q.ABS_SPECIES(1).GRIDS{1}, 0.1, ...
                                               'lin', 0.5, 0.00, @log10 );
Q.ABS_SPECIES(1).MINMAX  = 1e-6;
  
  
%- Water 
%
% This generates no absorption, as linefile has no H2O lines
%
Q.ABS_SPECIES(2).TAG      = { 'H2O' };
Q.ABS_SPECIES(2).RETRIEVE = false;
Q.ABS_SPECIES(2).ATMDATA  = gf_artsxml( fullfile( fascod, ...
    'midlatitude-winter', 'midlatitude-winter.H2O.xml' ), 'H2O', 'vmr_field' );



%- Horsontal wind components vind
%
Q.WIND_V_FIELD    = [];      % This is a short-cut for zero wind.
%
Q.WIND_V.RETRIEVE = true;   % Set to true to activate retrieval
Q.WIND_V.L2       = true;
Q.WIND_V.GRIDS    = { Q.P_GRID(1:2:end), mean(Q.LAT_GRID), mean(Q.LON_GRID) };
Q.WIND_V.SX       = covmat1d_from_cfun( Q.WIND_V(1).GRIDS{1}, 50, ...
                                                    'lin', 0.8, 0.00, @log10 );
if Q.WIND_V.RETRIEVE
  Q.WSMS_AT_START{end+1} = 'IndexSet(abs_f_interp_order,3)';
end
%
% Exactly same for u-component
Q.WIND_U_FIELD    = Q.WIND_V_FIELD;
Q.WIND_U          = Q.WIND_V;


%- Frequency shift
%
Q.FSHIFTFIT.RETRIEVE      = true;
Q.FSHIFTFIT.DF            = 25e3; 
Q.FSHIFTFIT.SX            = 50e3^2;  
Q.FSHIFTFIT.L2            = true;


%- Polyfit
%
Q.POLYFIT.RETRIEVE        = true;
Q.POLYFIT.ORDER           = 0;
Q.POLYFIT.L2              = true;
Q.POLYFIT.SX0             = 1.0^2 * speye(5); 


return
%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------





function Y = y_demo(Q,u_wind,v_wind)

% The data should be loaded from one or several files, but are here genereted
% by a forward model call to show how qpack2 can also be used to generate
% simulaled measurements (matching a priori assumptions).

% The simulated data model airborn measurements at two different zenith
% angles, from two nearby positions. 
  
% Init Y
%
Y = qp2_y;

% Set a date
%
Y.YEAR  = 2008;
Y.MONTH = 2;
Y.DAY   = 25;

% Lat / lon
%
Y.LATITUDE  = 45;
Y.LONGITUDE = exp(1);

% An airborn measurement assumed here
%
Y.AA         = [ 0 -135 -45 45  135 ]';
naa          = length( Y.AA );
Y.Z_PLATFORM = repmat( 10.5e3, naa, 1 );
Y.ZA         = [ 0; repmat( 70, naa-1, 1 ) ];

% Reference point for hydrostatic equilibrium
%
Y.HSE_P = 100e2;
Y.HSE_Z = 16e3;

% Set backend frequencies
%
Y.F = qarts_get( Q.SENSOR_RESPONSE.F_BACKEND );
nf  = length( Q.SENSOR_RESPONSE.F_BACKEND );

% Thermal noise standard deviation
%
Y.TNOISE = repmat( 0.05, 1, naa );
% To test varying noise
%Y.TNOISE = repmat( linspace( 0.03, 0.07, length(Y.F) )', 1, naa );


% Include winds, constant with altitude
%
Q.WIND_U_FIELD = repmat( u_wind, [ length(Q.P_GRID), length(Q.LAT_GRID), ...
                                                     length(Q.LON_GRID) ] );
Q.WIND_V_FIELD = repmat( v_wind, [ length(Q.P_GRID), length(Q.LAT_GRID), ...
                                                     length(Q.LON_GRID) ] );

% Simulate a measurement
%
Y.Y = [];                           % A flag to tell qpack2 to calculate the
%                                     spectrum ({} signifies undefined!).

% Calculate simulated spectra
%
Y = qpack2( Q, oem, Y );            % Dummy oem structure OK here 


% Add thermal noise and baseline off-set
%
% The correlation specified in Q is included
%
for i = 1 : length(Y)
  for j = 1 : length( Y.ZA )
    ind = (j-1)*nf + [1:nf];
    Y(i).Y(ind) = Y(i).Y(ind) + ...   % Noise free spectrum
                  2*randn(1)  + ...   % A constant off-set
                  Y(i).TNOISE(:,j) .* make_noise(1,Q.TNOISE_C); % Thermal noise
  end
end

