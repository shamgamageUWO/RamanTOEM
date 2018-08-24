% QPACK2_T_DEMO2   A temperature retrieval demo
%
%    Similar to *qpack2_demo*, but used to test temperature retrievals. The
%    set-up is simplified and adoptions needed for real inversions. Performs
%    no plotting.
%
% FORMAT   L2 = qpack2_t_demo2
%        
% OUT      L2   L2 data output from *qpack2*.

% 2013-08-10   Created by Patrick Eriksson.

function L2 = qpack2_t_demo
  
errid = ['atmlab:' mfilename]; 

%- Qarts settings
%
Q    = q_demo;           % Local file, found below


%- Measurement data
%
Y = y_demo( Q );  


%- OEM variables
%
O              = qp2_l2( Q );
%
O.linear       = false;
%
if ~O.linear 
  O.itermethod = 'GN';
  O.stop_dx    = 0.01;
  O.maxiter    = 10;
end


%- Make inversion
%
L2 = qpack2( Q, O, Y );

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
Q.STOKES_DIM          = 4;
Q.J_DO                = true;
Q.CLOUDBOX_DO         = false;


%= Define agendas
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
Q.Z_SURFACE           = 50;


%- Absorption
%
Q.ABS_LINES_FORMAT    = 'None';
%
Q.ABSORPTION          = 'OnTheFly';
Q.ABS_NLS             = [];


%- Pressure grid
%
z_toa                 = 95e3;
%
Q.P_GRID              = z2p_simple( Q.Z_SURFACE-500 : 500 : z_toa )';



%- Spectrometer stuff
%
% A simple set-up, e.g. F_GRID too coarse around the transitions found
% inside the frequency range
%
Q.F_GRID              = [52.2e9 : 10e6 : 53.2e9 ]';
%
H                     = qartsSensor;
%
H.SENSOR_NORM         = true;
%
H.BACKEND_DO          = true;
df                    = 5e6;
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
H.SENSOR_POL          = { 6 };
%
Q.SENSOR_DO           = true;
Q.SENSOR_RESPONSE     = H;
%
Q.ANTENNA_DIM         = 1;
Q.MBLOCK_ZA_GRID      = 0;



%- Correlation of thermal noise 
%
Q.TNOISE_C     = covmat1d_from_cfun( H.F_BACKEND, [], 'drc' );
%
clear H



%- Define L2 structure (beside retrieval quantities below)
%
Q.L2_EXTRA     = { 'cost', 'dx', 'xa', 'y', 'yf', 'bl', 'ptz', ...
                   'mresp', 'A', 'e', 'eo', 'es', 'date', 'J' };


%- Temperature
%
Q.T.RETRIEVE   = true;
Q.T.ATMDATA    = gf_artsxml( fullfile( arts_xmldata_path, 'climatology', ...
                        'msis90', 'msis90.t.xml' ), 'Temperature', 't_field' );
Q.T.L2         = true;
Q.T.GRIDS      = { Q.P_GRID(1:4:end), [], [] };
Q.T.SX         = covmat1d_from_cfun( Q.T.GRIDS{1}, 4, 'lin', 0.5, 0, @log10 );


%- Determine altitudes through HSE
%
Q.HSE.ON       = true;
Q.HSE.P        = Q.P_GRID(1);
Q.HSE.ACCURACY = 0.1;


%- Species

%- Nitrogen
%
Q.ABS_SPECIES(1).TAG      = { 'N2' };
Q.ABS_SPECIES(1).RETRIEVE = false;
Q.ABS_SPECIES(1).ATMDATA  = gf_artsxml( fullfile( fascod, ...
      'midlatitude-summer', 'midlatitude-summer.N2.xml' ), 'N2', 'vmr_field' );

%- Oxygen
%
Q.ABS_SPECIES(2).TAG      = { 'O2-PWR93' };
Q.ABS_SPECIES(2).RETRIEVE = false;
Q.ABS_SPECIES(2).ATMDATA  = gf_artsxml( fullfile( fascod, ...
      'midlatitude-summer', 'midlatitude-summer.O2.xml' ), 'O2', 'vmr_field' );

%- Water vapour
%
Q.ABS_SPECIES(3).TAG      = { 'H2O' };
Q.ABS_SPECIES(3).RETRIEVE = false;
Q.ABS_SPECIES(3).ATMDATA  = gf_artsxml( fullfile( fascod, ...
    'midlatitude-summer', 'midlatitude-summer.H2O.xml' ), 'H2O', 'vmr_field' );

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
Y.MONTH = 5;
Y.DAY   = 25;

% Lat / lon
%
Y.LATITUDE  = 45;
Y.LONGITUDE = exp(1);


Y.Z_PLATFORM = 50;
Y.ZA         = 0;

% Reference point for hydrostatic equilibrium
%
Y.HSE_P = 1000e2;
Y.HSE_Z = 0;

% Set backend frequencies
%
Y.F = Q.SENSOR_RESPONSE.F_BACKEND;

% Thermal noise standard deviation
%
Y.TNOISE = 0.1;

% Use FASCOD as true T profile
fascod = fullfile( atmlab( 'ARTS_XMLDATA_PATH' ), ...
                                                'planets', 'Earth', 'Fascod' );
Q.T.ATMDATA  = gf_artsxml( fullfile( fascod, 'midlatitude-summer', ...
                      'midlatitude-summer.t.xml' ), 'Temperature', 't_field' );
  
% Simulate a measurement
%
Y0   = Y;
Y0.Y = []; 
%          
Y = qpack2( Q, oem, Y0 ); 

% Add thermal noise
%
Y.Y = Y.Y + Y.TNOISE .* make_noise( 1, Q.TNOISE_C );



