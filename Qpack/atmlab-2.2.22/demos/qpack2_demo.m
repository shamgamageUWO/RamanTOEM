% QPACK2_DEMO   Demonstration of the Qpack2 retrieval system
%
%    The main features of Qpack2 are demonstrated. The example case is airborne
%    measurements of ozone at 110.8 GHz. Synthetic measurement data are
%    generated internally. See the code and internal comments for details.
%
%    Everything is here put into a single file. For practical retrievals it
%    is probably better to put the definitions of Q (together with O?) in a
%    separate function (i.e. [Q,O] = q_mycase). A function to import
%    measurement data into the "Y format" (see *qp2_y*) is needed. The
%    retrieval result is returned in the L2 format produced by *qp2_l2*.
%
%    This script focuses on giving an introduction, indicating different
%    retrieval units and retrieval of other variables. See also *qpack2_demo2*.
%
% FORMAT   L2 = qpack2_demo
%        
% OUT      L2   L2 data output from *qpack2*.

% 2010-05-12   Created by Patrick Eriksson.

function L2 = qpack2_demo
  
errid = ['atmlab:' mfilename]; 

%- Qarts settings
%
Q    = q_demo;           % Local file, found below


%- Measurement data
%
Y = y_demo( Q );         % Local file, found below


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
O.linear = false;
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
  
  % Profiles
  figure(1),clf
  plot( L2(1).species1_x*1e6, p2z_simple(L2(1).species1_p)/1e3, 'b', ...
        L2(2).species1_x*1e6, p2z_simple(L2(2).species1_p)/1e3, 'r', ...
        L2(1).species1_xa*1e6, p2z_simple(L2(1).species1_p)/1e3, 'k-' );
  xlabel( 'Ozone [VMR]' );
  ylabel( 'Approximate altitude [km]' );
  axis( [ 0 8 10 90 ] )
  legend( 'Retrieval 1', 'Retrieval 2', 'True and a priori' );

  % Spectra
  figure(2),clf
  h=plot( L2(1).f/1e9, L2(1).y, 'k.', L2(2).f/1e9, L2(2).y, 'k.', ...
          L2(1).f/1e9, L2(1).yf, 'b-', L2(2).f/1e9, L2(2).yf, 'r-', ...
          L2(1).f/1e9, L2(1).bl, 'b-.', L2(2).f/1e9, L2(2).bl, 'r-.' );
  xlabel( 'Frequency [GHz]' );
  ylabel( 'Tb [K]' );
  axis( [ min(L2(1).f/1e9) max(L2(1).f/1e9) 0 18 ] )
  legend( h(3:end), 'Fitted 1', 'Fitted 2', 'Baseline 1', 'Baseline 2' );
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
Q.ATMOSPHERE_DIM      = 1;
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


%- Surface
%
Q.Z_SURFACE           = 1e3;          % Just a dummy value. A 10 km
                                      % observation altitude is assumed here


%- Absorption
%
Q.ABS_LINES           = fullfile( atmlab_example_data, 'o3line111ghz' );
Q.ABS_LINES_FORMAT    = 'Arts';
%
Q.ABSORPTION          = 'OnTheFly';
Q.ABS_NLS             = [];

%- Pressure grid
%
z_toa                 = 95e3;
%
Q.P_GRID              = z2p_simple( Q.Z_SURFACE-1e3 : 2e3 : z_toa )';



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
df                    = 0.5e6;
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
f              = H.F_BACKEND;
cl             = 1.4 * ( f(2) - f(1) );
cfun           = 'gau';
cco            = 0.05;
%
Q.TNOISE_C     = covmat1d_from_cfun( f, [], cfun, cl, cco );
%
clear H f


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
Q.ABS_SPECIES(1).GRIDS    = { Q.P_GRID, [], [] };
Q.ABS_SPECIES(1).ATMDATA  = gf_artsxml( fullfile( fascod, ...
      'midlatitude-winter', 'midlatitude-winter.O3.xml' ), 'O3', 'vmr_field' );
%
% If you don't apply a min value (by MINMAX), you could need to active this:
%Q.VMR_NEGATIVE_OK = true;
%
% For demonstration, setting for several units are provided:
switch 1
 case 1  % Constant VMR
  Q.ABS_SPECIES(1).UNIT     = 'vmr';
  Q.ABS_SPECIES(1).SX       = ...
                     covmat1d_from_cfun( Q.ABS_SPECIES(1).GRIDS{1}, 1.5e-6, ...
                                               'lin', 0.2, 0.00, @log10 ) + ...
                     covmat1d_from_cfun( Q.ABS_SPECIES(1).GRIDS{1}, 0.3e-6, ...
                                               'lin', 0.5, 0.00, @log10 );
   Q.ABS_SPECIES(1).MINMAX  = 1e-12;
 case 2 % Constant rel
  Q.ABS_SPECIES(1).UNIT     = 'rel';
  Q.ABS_SPECIES(1).SX       = ...
                     covmat1d_from_cfun( Q.ABS_SPECIES(1).GRIDS{1}, 0.5, ...
                                               'lin', 0.2, 0.00, @log10 ) + ...
                     covmat1d_from_cfun( Q.ABS_SPECIES(1).GRIDS{1}, 0.1, ...
                                               'lin', 0.5, 0.00, @log10 );
  Q.ABS_SPECIES(1).MINMAX  = 1e-6;
 case 3 % Mimic case 2 in vmr
  Q.ABS_SPECIES(1).UNIT     = 'vmr';
  Q.ABS_SPECIES(1).SX       = ...
                     covmat1d_from_cfun( Q.ABS_SPECIES(1).GRIDS{1}, ...
                                       [ Q.ABS_SPECIES(1).ATMDATA.GRID1,...
                                   0.5 * Q.ABS_SPECIES(1).ATMDATA.DATA ],...
                                               'lin', 0.2, 0.00, @log10 ) + ...
                     covmat1d_from_cfun( Q.ABS_SPECIES(1).GRIDS{1}, ...
                                       [ Q.ABS_SPECIES(1).ATMDATA.GRID1, ...
                                   0.1 * Q.ABS_SPECIES(1).ATMDATA.DATA ],...
                                               'lin', 0.5, 0.00, @log10 );
  Q.ABS_SPECIES(1).MINMAX  = 1e-12;
 case 4 % Constant logrel
  Q.ABS_SPECIES(1).UNIT     = 'logrel';
  Q.ABS_SPECIES(1).SX       = ...
                     covmat1d_from_cfun( Q.ABS_SPECIES(1).GRIDS{1}, 0.5, ...
                                               'lin', 0.2, 0.00, @log10 ) + ...
                     covmat1d_from_cfun( Q.ABS_SPECIES(1).GRIDS{1}, 0.1, ...
                                               'lin', 0.5, 0.00, @log10 );
  Q.ABS_SPECIES(1).MINMAX  = 1e-6;
end  
  
  
  
%- Water 
%
% This generates no absorption, as linefile has no H2O lines
%
Q.ABS_SPECIES(2).TAG      = { 'H2O' };
Q.ABS_SPECIES(2).RETRIEVE = false;
Q.ABS_SPECIES(2).ATMDATA  = gf_artsxml( fullfile( fascod, ...
    'midlatitude-winter', 'midlatitude-winter.H2O.xml' ), 'H2O', 'vmr_field' );



%- Wind
%
% Here demonstrated for v-component, that should the component of main
% concern for ground-based instruments. This component can be seen as the
% part of the horizontal wind going along the viewing direction, where
% positive values mean a movement away from the sensor.
%
Q.WIND_V_FIELD    = [];      % This is a short-cut for zero wind.
%
Q.WIND_V.RETRIEVE = false;   % Set to true to activate retrieval
Q.WIND_V.L2       = true;
Q.WIND_V.GRIDS    = { Q.P_GRID(1:2:end), [], [] };
Q.WIND_V.SX       = covmat1d_from_cfun( Q.WIND_V(1).GRIDS{1}, 40, ...
                                                    'lin', 0.5, 0.00, @log10 );
if Q.WIND_V.RETRIEVE
  Q.WSMS_AT_START{end+1} = 'IndexSet(abs_f_interp_order,3)';
end



%- Pointing
%
% Here just included for testing purposes, of little interest for ground-based
% spectrometers. 
%
Q.POINTING.RETRIEVE       = false;
Q.POINTING.DZA            = 0.1; 
Q.POINTING.POLY_ORDER     = 0;
Q.POINTING.CALCMODE       = 'recalc';
Q.POINTING.SX             = 1;  
Q.POINTING.L2             = true;


%- Frequency shift
%
Q.FSHIFTFIT.RETRIEVE      = true;
Q.FSHIFTFIT.DF            = 25e3; 
Q.FSHIFTFIT.SX            = 50e3^2;  
Q.FSHIFTFIT.L2            = true;

%- Frequency stretch
%
Q.FSTRETCHFIT.RETRIEVE    = false;   % Set to true to activate retrieval
Q.FSTRETCHFIT.DF          = 25e3; 
Q.FSTRETCHFIT.SX          = 50e3^2;  
Q.FSTRETCHFIT.L2          = true;


%- Polyfit
%
% A polynomial of order 3 is used for "baseline fit".
%
Q.POLYFIT.RETRIEVE        = true;
Q.POLYFIT.ORDER           = 3;
Q.POLYFIT.L2              = true;
Q.POLYFIT.SX0             = 1^2; 
Q.POLYFIT.SX1             = 0.5^2; 
Q.POLYFIT.SX2             = 0.2^2;
Q.POLYFIT.SX3             = 0.1^2; 


%- Sinefit
%
% Here demonstrated with two period lengths
%
Q.SINEFIT.RETRIEVE        = false;   % Set to true to activate retrieval
Q.SINEFIT.PERIODS         = [ 75e3 200e3 ]';
Q.SINEFIT.L2              = true;
Q.SINEFIT.SX1             = 0.2^2; 
Q.SINEFIT.SX2             = 0.4^2; 

return
%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------





function Y = y_demo(Q)

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
Y.Z_PLATFORM = 10.5e3;
Y.ZA         = 50;

% Reference point for hydrostatic equilibrium
%
Y.HSE_P = 100e2;
Y.HSE_Z = 16e3;

% Set backend frequencies
%
Y.F = Q.SENSOR_RESPONSE.F_BACKEND;

% Thermal noise standard deviation
%
Y.TNOISE = 0.1;
% To test varying noise
%Y.TNOISE = linspace( 0.03, 0.07, length(Y.F) )';

% Simulate a measurement
%
Y.Y = [];                           % A flag to tell qpack2 to calculate the
%                                     spectrum ({} signifies undefined!).

% Add a second measurement
%
Y(2) = Y(1);
%
Y(2).LONGITUDE = pi;
Y(2).ZA        = 45;


% Calculate simulated spectra
%
Y = qpack2( Q, oem, Y );            % Dummy oem structure OK here 

% Add thermal noise
%
% The correlation specified in Q is included
%
for i = 1 : length(Y)
  Y(i).Y = Y(i).Y + Y(i).TNOISE .* make_noise(1,Q.TNOISE_C);
end

% Add a constant "baseline shift" for measurement 2
%
Y(2).Y = Y(2).Y + 1;

