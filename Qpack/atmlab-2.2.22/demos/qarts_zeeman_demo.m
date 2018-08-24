% QARTS_ZEEMAN_DEMO   A demonstration of including Zeeman in Qarts
%
%    Calculates a limb sounding spectrum at 118.75 GHz, with and without
%    activating the Zeeman part.
%
% FORMAT   [f,y0,y] = qarts_zeeman_demo( [ ztan ] )
%        
% OUT   f          Frequency grid
%       y0         Calculated spectrum without activating Zeeman.
%       y          Calculated spectrum with Zeeman.
% OPT   ztan       Tangent altitude. Default is 95 km.

% 2013-06-27   Created by Patrick Eriksson.


function [f,y0,y] = qarts_zeeman_demo( varargin )
%
[ztan] = optargs( varargin, { 95e3 } );


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
Q.SENSOR_DO             = false;


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
Q.ABS_SPECIES(1).TAG{1}  = 'O2';
Q.ABS_SPECIES(1).ATMDATA = gf_artsxml( fullfile( fascod, 'subarctic-summer', ...
                            'subarctic-summer.O2.xml' ), 'O2', 'vmr_field' ); 


%= Temperature and geoemtrical altitudes are taken from CIRA86
%
Q.T.ATMDATA              = gf_artsxml( fullfile( arts_xmldata_path, ...
         'climatology', 'cira86', 'cira86.t.xml' ), 'Temperature', 't_field' );
Q.Z.ATMDATA              = gf_artsxml( fullfile( arts_xmldata_path, ...
           'climatology', 'cira86', 'cira86.z.xml' ), 'Altitudes', 'z_field' );


%= Set-up atmosphere and surface
%
Q.ATMOSPHERE_DIM       = 3;
%
Q.P_GRID               = z2p_simple( [0:1e3:120e3]' );
%
Q.LAT_GRID             = [60:2:80]'; 
Q.LON_GRID             = [0:4:40]'; 
%
Q.REFELLIPSOID         = ellipsoidmodels( 'SphericalEarth' );
Q.Z_SURFACE            = repmat( 500, length(Q.LAT_GRID), length(Q.LON_GRID));
%
mjd                    = date2mjd( 2008, 2, 15 ); % A dummy date
%
Q.VMR_FIELD            = qarts_vmr_field( Q );
Q.T_FIELD              = qarts_atm_field( Q, 't', mjd );
Q.Z_FIELD              = qarts_atm_field( Q, 'z', mjd );


%= Absorption
%
Q.F_GRID               = 1.187503430e+11 + linspace( -5e6, 5e6, 201 )';
%
Q.ABS_LINES_FORMAT     = 'Hitran';
Q.ABS_LINES            = fullfile( atmlab_example_data , 'line118ghz.hit' );
%                                                   
Q.ABSORPTION           = 'OnTheFly';


%= Set RTE variables
%
Q.YCALC_WSMS           = { 'yCalc' };
%
Q.STOKES_DIM           = 4;
Q.PPATH_LMAX           = 5e3;
Q.IY_UNIT              = 'RJBT';
%
zplat                  = 600e3;
Q.SENSOR_POS           = [ zplat, 49, 12 ];
%
Q.SENSOR_LOS           = [ geomztan2za(Q.REFELLIPSOID(1),zplat,ztan), 5 ];


%= Make sure magnetic fields are zero
%
Q.MAG_U_FIELD          = [];
Q.MAG_V_FIELD          = [];
Q.MAG_W_FIELD          = [];


%= Calculate spectrum
%
y0 = arts_y( Q );
%
f = Q.F_GRID;


% Repeat with Zeeman activated
%
testdatafolder = fullfile( fileparts(atmlab('ARTS_INCLUDES')), 'testdata' );
magdatafolder  = fullfile( atmlab('ARTS_XMLDATA_PATH'), 'planets', ...
                                                          'Earth', 'IGRF' );

Q.ABS_SPECIES(1).TAG{1}   = 'O2-Z-66';
%
Q.PROPMAT_CLEARSKY_AGENDA = { 'propmat_clearsky_agenda__OnTheFly_Zeeman' };
%
Q.WSMS_AT_START{end+1} = [ 'ReadXML( isotopologue_quantum, "', ...
                          fullfile(testdatafolder,'isoquantum.xml'), '")' ];
%
Q.MAG_U.ATMDATA        = gf_artsxml( fullfile( magdatafolder, ...
                                'IGRF11_2010_200km-5deg-5deg.B_u.xml.gz' ),...
                                     'Magnetic u-component', 'mag_field' ); 
Q.MAG_V.ATMDATA        = gf_artsxml( fullfile( magdatafolder, ...
                                'IGRF11_2010_200km-5deg-5deg.B_v.xml.gz' ),...
                                     'Magnetic v-component', 'mag_field' ); 
Q.MAG_W.ATMDATA        = gf_artsxml( fullfile( magdatafolder, ...
                                'IGRF11_2010_200km-5deg-5deg.B_w.xml.gz' ),...
                                     'Magnetic w-component', 'mag_field' ); 
% Qpack2 makes this automatically:
Q.MAG_U_FIELD          = qarts_atm_field( Q, 'mag_u', mjd );
Q.MAG_V_FIELD          = qarts_atm_field( Q, 'mag_v', mjd );
Q.MAG_W_FIELD          = qarts_atm_field( Q, 'mag_w', mjd );
%
y = arts_y( Q );
  

%= Plot
%
if ~nargout
  i = 1 : Q.STOKES_DIM : length(y0);
  plot( Q.F_GRID/1e9, y0(i), Q.F_GRID/1e9, y(i) );
  xlabel( 'Frequency [GHz]' )
  ylabel( 'Brightness temperature [K]' )
  legend( 'I without Zeeman', 'I with Zeeman' )
end

