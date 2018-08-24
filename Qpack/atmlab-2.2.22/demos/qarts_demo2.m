% QARTS_DEMO2   A demonstration of Qarts
%
%    As *qarts_demo*, but with more advanced calculation options.
%    Pre-calculation of absorption and sensor characteristics is 
%    exemplified. VMR_FIELD is set through ABS_SPECIES.ATMDATA.
%    Further, pre-defined agendas are used.
%
%    Input temperature data are 2D, and it can not be expected that 
%    1D results shall be identical to 2D and 3D.
%
% FORMAT   [Q,f,y] = qarts_demo2( [ ztan, atmdim ] )
%        
% OUT   Q          Qarts setting structure.
%       f          Frequency grid
%       y          Calculated spectrum
% OPT   ztan       Tangent altitude. Default is 30 km.
%       atmdim     Atmospheric dimensionality. Default is 1.

% 2008-05-27   Updated to ARTS2 by Patrick Eriksson.
% 2007-08-23   Created by Patrick Eriksson (based qarts_demo).


function [Q,f,y] = qarts_demo2( varargin )
%
[ztan,atmdim] = optargs( varargin, { 30e3, 1 } );


%= Atmlab settings
%
arts_xmldata_path = atmlab( 'ARTS_XMLDATA_PATH' );
%
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
%
fascod = fullfile( arts_xmldata_path, 'planets', 'Earth', 'Fascod' );

  
%= Init Q structures
%
Q  = qarts;
%
Q.INCLUDES              = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                            fullfile( 'ARTS_INCLUDES', 'agendas.arts' ), ...
                            fullfile( 'ARTS_INCLUDES', 'continua.arts' ), ...
                            fullfile( 'ARTS_INCLUDES', 'planet_earth.arts' ) };


%= De-activate parts not used
%
Q.CLOUDBOX_DO           = false;
Q.J_DO                  = false;


%= Define agendas
%
% Here we do it by using the predefined agenda templates.
% This works only if the pre-defined agenda is names following the pattern:
%    name_of_agenda__(Something)
%
Q.PPATH_AGENDA               = { 'ppath_agenda__FollowSensorLosPath'   };
Q.PPATH_STEP_AGENDA          = { 'ppath_step_agenda__GeometricPath'    };
Q.BLACKBODY_RADIATION_AGENDA = { 'blackbody_radiation_agenda__Planck'  };
Q.IY_SPACE_AGENDA            = { 'iy_space_agenda__CosmicBackground'   };
Q.IY_SURFACE_AGENDA          = { 'iy_surface_agenda__UseSurfaceRtprop' };
Q.IY_MAIN_AGENDA             = { 'iy_main_agenda__Emission'            };


%= Atmospheric species
%
% Note that ATMDATA for nitrogen is set to a scalar
%
Q.ABS_SPECIES(1).TAG{1}  = 'ClO';
Q.ABS_SPECIES(1).ATMDATA = gf_artsxml( fullfile( fascod, 'tropical', ...
                            'tropical.ClO.xml' ), 'ClO', 'vmr_field' ); 
%
Q.ABS_SPECIES(2).TAG{1}  = 'O3';
Q.ABS_SPECIES(2).ATMDATA = gf_artsxml( fullfile( fascod, 'subarctic-summer',...
                              'subarctic-summer.O3.xml' ), 'O3', 'vmr_field' ); 
%
Q.ABS_SPECIES(3).TAG{1}  = 'N2O';
Q.ABS_SPECIES(3).ATMDATA = gf_artsxml( fullfile( fascod, 'tropical', ...
                            'tropical.N2O.xml' ), 'N2O', 'vmr_field' ); 
%
Q.ABS_SPECIES(4).TAG{1}  = 'H2O-*-490e9-510e9'; % Some local lines not in PWR98
Q.ABS_SPECIES(4).TAG{2}  = 'H2O-PWR98';
Q.ABS_SPECIES(4).ATMDATA = gf_artsxml( fullfile( fascod, 'tropical', ...
                            'tropical.H2O.xml' ), 'H2O', 'vmr_field' ); 
%
Q.ABS_SPECIES(5).TAG{1}  = 'N2-SelfContStandardType';
Q.ABS_SPECIES(5).ATMDATA = gf_set( atmdata_empty(0), 0.781, [] );


%= Temperature and geoemtrical altitudes are taken from CIRA86
%
Q.T.ATMDATA              = gf_artsxml( fullfile( arts_xmldata_path, ...
         'climatology', 'cira86', 'cira86.t.xml' ), 'Temperature', 't_field' );
Q.Z.ATMDATA              = gf_artsxml( fullfile( arts_xmldata_path, ...
           'climatology', 'cira86', 'cira86.z.xml' ), 'Altitudes', 'z_field' );


%= Set-up atmosphere and surface
%
Q.ATMOSPHERE_DIM         = atmdim;
%
Q.P_GRID                 = z2p_simple( [0:500:45e3 46e3:1e3:100e3]' );
%
if atmdim == 1
  Q.LAT_TRUE             = 0;    
  Q.LON_TRUE             = 80;    
elseif atmdim == 2
  Q.LAT_GRID             = [-10:10]'; 
  Q.LAT_TRUE             = Q.LAT_GRID; 
  Q.LON_TRUE             = repmat( 0, size( Q.LAT_GRID ) );
else
  Q.LAT_GRID             = [-10:10]'; 
  Q.LON_GRID             = [-10:10]'; 
end
%
Q.REFELLIPSOID           = ellipsoidmodels( 'SphericalEarth' );
if atmdim < 3
  Q.Z_SURFACE            = repmat( 500, length(Q.LAT_TRUE), length(Q.LON_TRUE));
else
  Q.Z_SURFACE            = repmat( 500, length(Q.LAT_GRID), length(Q.LON_GRID));
end

%= Set-up VMR_FIELD, T_FIELD and Z_FIELD
% A dummy date
mjd = date2mjd( 2008, 2, 15 );
%
Q.VMR_FIELD              = qarts_vmr_field( Q );
Q.T_FIELD                = qarts_atm_field( Q, 't', mjd );
Q.Z_FIELD                = qarts_atm_field( Q, 'z', mjd );


%= Absorption
%
Q.F_GRID                 = linspace( 501.18e9, 501.58e9, 201 )';
Q.STOKES_DIM             = 1;
%
% Absorption is here precalculated. The look-up table is here loaded (into
% Q.ABS_LOOKUP), which will be followed by a saving of data. This
% unnecessary loading/saving can be avoided by giving *arts_abstable* a
% folder where the look-up can be saved: Q.ABS_LOOKUP = arts_abstable(Q,folder);
%
Q.ABS_LINES_FORMAT       = 'Arts';
Q.ABS_LINES              = fullfile( atmlab_example_data , 'lines501.4' );
Q.ABS_NLS                = [];
%
Q                        = qarts_abstable( Q, 8, 15 );
Q.ABS_LOOKUP             = arts_abstable( Q );        
%                                                     
Q.ABSORPTION             = 'LoadTable';


%= Sensor
%
% Simple example, only including a narrow antenna pattern.
%
% Sensor reponse is here pre-calculated. Considerations around
% loading/saving are identical to absorption, commented above.
%
if 1                  % Commit only with 1 here, to make *make_check* to work
  Q.SENSOR_DO = false;
else
  H                      = qartsSensor;
  %
  H.SENSOR_NORM          = true;
  %
  Q.ANTENNA_DIM          = 1;
  Q.MBLOCK_ZA_GRID       = [-0.04:0.02:0.04]';
  H.ANTENNA_DO           = true;
  H.ANTENNA_LOS          = 0;
  H.ANTENNA_RESPONSE     = fullfile( atmlab_example_data, 'antenna.xml' );
  %
  Q.SENSOR_DO            = true;
  Q.SENSOR_RESPONSE      = H;
  %
  % Calculate:
  Q = arts_sensor( Q );
end


%= Set RTE variables (refraction is here neglected)
%
Q.YCALC_WSMS             = { 'yCalc' };
%
Q.PPATH_LMAX             = 20e3;
Q.IY_UNIT                = 'RJBT';
%
zplat                    = 600e3;
Q.SENSOR_POS             = [ zplat, -23, 0 ];
Q.SENSOR_POS             = Q.SENSOR_POS(1:atmdim);
%
Q.SENSOR_LOS             = geomztan2za( Q.REFELLIPSOID(1), zplat, ztan );
if atmdim == 3
  Q.SENSOR_LOS           = [ Q.SENSOR_LOS, 5 ];
end



if nargout == 1
  return
end



%= Calculate spectrum/spectra
%
y = arts_y( Q );
%
f = Q.F_GRID;



%= Plot
%
if ~nargout
  plot( Q.F_GRID/1e9, y, 'LineWidth', 2 );
  xlabel( 'Frequency [GHz]' )
  ylabel( 'Brightness temperature [K]' )
  title( sprintf( 'Odin-SMR ClO band (tangent altitude = %.1f km)', ztan/1e3));
end

