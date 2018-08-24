% QPACK2_DEMO2   Another demonstration of the Qpack2 retrieval system
%
%    Similar to *qpack2_demo*, but illustrates rudimentary treatment
%    tropospheric attenuation and shows how the polarisation response of the
%    sensor is included.
%
% FORMAT   L2 = qpack2_demo2
%        
% OUT      L2   L2 data output from *qpack2*.

% 2013-06-17   Created by Patrick Eriksson.

function L2 = qpack2_demo2
  
errid = ['atmlab:' mfilename]; 

%- Qarts settings
%
Q    = q_demo;           % Local file, found below


%- Measurement data
%
Y = y_demo( Q );         % Local file, found below



%- OEM variables
%
O = qp2_l2( Q );         % This ensures that OEM returns the variables needed 
%                          to fill the L2 structure, as defined in Q
O.linear = false;
%
if ~O.linear 
  O.itermethod       = 'GN';
  O.stop_dx          = 0.01;
  O.maxiter          = 10;
end


%- Make inversion
%
L2 = qpack2( Q, O, Y );


%- Convert from rel to vmr
%
L2 = qp2_rel2vmr( L2 );


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
  axis( [ 0 10 0 90 ] )
  legend( 'Retrieval 1', 'Retrieval 2', 'True and a priori' );

  % Spectra
  figure(2),clf
  h=plot( L2(1).f/1e9, L2(1).y, 'k.', L2(2).f/1e9, L2(2).y, 'k.', ...
          L2(1).f/1e9, L2(1).yf, 'b-', L2(2).f/1e9, L2(2).yf, 'r-' );
  xlabel( 'Frequency [GHz]' );
  ylabel( 'Tb [K]' );
%  axis( [ min(L2(1).f/1e9) max(L2(1).f/1e9) 0 18 ] )
  legend( h(3:end), 'Fitted 1', 'Fitted 2' );
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
Q.ABS_LINES           = fullfile( atmlab_example_data, 'o3line111ghz' );
Q.ABS_LINES_FORMAT    = 'Arts';
%
Q.ABSORPTION          = 'OnTheFly';
Q.ABS_NLS             = [];

%- Pressure grid (a finer grid here, to better represent the troposphere)
%
z_toa                 = 95e3;
%
Q.P_GRID              = z2p_simple( Q.Z_SURFACE-500 : 500 : z_toa )';



%- Frequency, polarisation, spectrometer and pencil beam antenna
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
% We assume a H polarisation response. A number coding is applied, see:
% arts -d sensor_pol 
H.SENSOR_POL          = { 6 };
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
% Note that grid below is a subset of Q.P_GRID
Q.ABS_SPECIES(1).GRIDS    = { Q.P_GRID(1:4:end), [], [] };
Q.ABS_SPECIES(1).ATMDATA  = gf_artsxml( fullfile( fascod, ...
      'midlatitude-winter', 'midlatitude-winter.O3.xml' ), 'O3', 'vmr_field' );
Q.ABS_SPECIES(1).UNIT     = 'rel';
Q.ABS_SPECIES(1).SX       = ...
                   covmat1d_from_cfun( Q.ABS_SPECIES(1).GRIDS{1}, 0.5, ...
                                             'lin', 0.2, 0.00, @log10 ) + ...
                   covmat1d_from_cfun( Q.ABS_SPECIES(1).GRIDS{1}, 0.1, ...
                                             'lin', 0.5, 0.00, @log10 );
Q.ABS_SPECIES(1).MINMAX  = 1e-6;
  
  
%- Water 
%
Q.ABS_SPECIES(2).TAG      = { 'H2O-PWR98' };
Q.ABS_SPECIES(2).RETRIEVE = true;
Q.ABS_SPECIES(2).L2       = false;
% Note that grid below is the first part of Q.P_GRID
Q.ABS_SPECIES(2).GRIDS    = { Q.P_GRID(1:21), [], [] };
Q.ABS_SPECIES(2).ATMDATA  = gf_artsxml( fullfile( fascod, ...
    'midlatitude-winter', 'midlatitude-winter.H2O.xml' ), 'H2O', 'vmr_field' );
Q.ABS_SPECIES(2).UNIT     = 'rel';
Q.ABS_SPECIES(2).SX       = ...
                   covmat1d_from_cfun( Q.ABS_SPECIES(2).GRIDS{1}, 0.5, ...
                                             'lin', 0.5, 0.00, @log10 );
Q.ABS_SPECIES(2).MINMAX  = [1e-6 10]';


%- Liquid clouds (non-precip)
%
% There is no possibility to distinguish vapour and liquid water in this
% example, and this part is included only for demonstration purpose.
% If you activate liquid cloud retrieval, don't expect stable retrievals in
% this demo case.
% Note that the Jacobian calculation not works if any "vmr" is zero, and we
% must set LWC to a small value if retrived.
% Unit for LWC in ARTS is kg/m3, but is flagged as 'vmr' in the retrieval part.
%
Q.ABS_SPECIES(3).TAG      = { 'liquidcloud-MPM93' };
Q.ABS_SPECIES(3).RETRIEVE = false;
Q.ABS_SPECIES(3).L2       = true;
% Note that grid below is the first part of Q.P_GRID
Q.ABS_SPECIES(3).GRIDS    = { Q.P_GRID(1:11), [], [] };
% Set LWC to zero at all altitudes
Q.ABS_SPECIES(3).ATMDATA      = atmdata_empty(0);
if Q.ABS_SPECIES(3).RETRIEVE
  Q.ABS_SPECIES(3).ATMDATA.DATA = 1e-10;
else
  Q.ABS_SPECIES(3).ATMDATA.DATA = 0;
end
%
Q.ABS_SPECIES(3).UNIT     = 'vmr';  % Yes 'vmr', even if unit is kg/m3
Q.ABS_SPECIES(3).SX       = ...
                   covmat1d_from_cfun( Q.ABS_SPECIES(3).GRIDS{1}, 0.02e-3, ...
                                             'drc', 0, 0.00, @log10 );
Q.ABS_SPECIES(3).MINMAX  = [1e-10 0.1e-3]';


%- Oxygen
%
Q.ABS_SPECIES(4).TAG      = { 'O2-PWR93' };
Q.ABS_SPECIES(4).RETRIEVE = false;
Q.ABS_SPECIES(4).ATMDATA  = gf_artsxml( fullfile( fascod, ...
      'midlatitude-winter', 'midlatitude-winter.O2.xml' ), 'O2', 'vmr_field' );

%- Nitrogen
%
Q.ABS_SPECIES(5).TAG      = { 'N2-SelfContStandardType' };
Q.ABS_SPECIES(5).RETRIEVE = false;
Q.ABS_SPECIES(5).ATMDATA  = gf_artsxml( fullfile( fascod, ...
      'midlatitude-winter', 'midlatitude-winter.N2.xml' ), 'N2', 'vmr_field' ); 



%- Polyfit
%
% Not active, but if you want to test ...
%
Q.POLYFIT.RETRIEVE        = false;
Q.POLYFIT.ORDER           = 1;
Q.POLYFIT.L2              = true;
Q.POLYFIT.SX0             = 1^2; 
Q.POLYFIT.SX1             = 0.5^2; 

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
% To test varying noise
%Y.TNOISE = linspace( 0.03, 0.07, length(Y.F) )';

% Simulate a measurement
%
Y0   = Y;
Y0.Y = [];                          % A flag to tell qpack2 to calculate the
%                                     spectrum ({} signifies undefined!).
Y = qpack2( Q, oem, Y0 );           % Dummy oem structure OK here 



% Add a second measurement with H2O disturbed, and higher za
%
fascod = fullfile( atmlab( 'ARTS_XMLDATA_PATH' ), ...
                                                'planets', 'Earth', 'Fascod' );
Q.ABS_SPECIES(2).ATMDATA  = gf_artsxml( fullfile( fascod, ...
    'midlatitude-summer', 'midlatitude-summer.H2O.xml' ), 'H2O', 'vmr_field' );
%
Y2 = qpack2( Q, oem, Y0 );


% Append and add thermal noise
%
Y(2) = Y2;
%
% The correlation specified in Q is included
%
for i = 1 : length(Y)
  Y(i).Y = Y(i).Y + Y(i).TNOISE .* make_noise(1,Q.TNOISE_C);
end


