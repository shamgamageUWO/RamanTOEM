% QARTS_MCDOIT_DEMO
%
%   A demenstration / test of setting up MC and DOIT 
%
%   A satellite measurement is simulated, from 830 km and a zenith angle of
%   135 deg.
%
%   The frequency is set by the user. Cloud extends between zcloud +- 1km. 
%   Particles are set to be (solid) ice spheres, all with the same 
%   size (*dpart*).
% 
%   The surface reflectivi matrix is set to:
%     rsurf*[  1  0.1 0 0 
%             0.1  1  0 0   
%              0   0  1 0   
%              0   0  0 1 ]
%
% FORMAT [y0,yd,ym,ymerror] = qarts_mcdoit_demo( 
%                                    [CMdu,CMmu,iwp,zcloud,freq,dpart,rsurf] )
%
% OUT   y0           Clear-sky brightness temperature [K]
%       yd           DOIT result
%       ym           MC result
%       ymerror      Error estimate for *ym*
% OPT   CMdu         User DOIT settings for C.METHOD_PRMTRS. To see defaults
%                    look into the function, the defaulrs are set a few
%                    lines this text. CMd is the variable to check out.
%       CMdm         As above but refers to MC.
%       iwp          IWP. Default is 0.5 kg/m2
%       zcloud       Centre altitude of cloud. Default is 4 km.
%       freq         Frequency. Default is 89 GHz
%       dpart        Particle diameter. Default is 1 mm
%       rsurf        Surface reflectivity. Default is 0.1

function [y0,yd,ym,ymerror] = qarts_mcdoit_demo( varargin )
%
% Defaults for DOIT and MC
CMd.N_ZA_GRID            =  19;
CMd.N_AA_GRID            =  10;
CMd.ZA_GRID_OPT_FILE     = '';
CMd.EPSILON              = [ 0.1 0.01 0.01 0.01 ];
CMd.SCAT_ZA_INTERP       = 'polynomial';
CMd.ALL_F                = true;
CMd.NORMALIZE            = true;
CMd.NORM_ERROR_THRESHOLD = 0.5;
%
CMm.STD_ERR              = 1;
CMm.MAX_TIME             = 20;
CMm.MAX_ITER             = -1;
CMm.MIN_ITER             = 100;
%
[CMdu,CMmu,iwp,zcloud,freq,dpart,rsurf] = optargs( varargin, ...
                                       { [], [], 0.5, 4e3, 89e9, 1e-3, 0.1 } );
%
if zcloud<2e3, error( '*zcloud must be >= 2 km.' ); end

% Move settings in CMdu and CMmu to Cmd and CMm,respectively
%
CMd = optargs_struct( CMdu, CMd );
CMm = optargs_struct( CMmu, CMm );


%= Create a temporary workfolder
%
workfolder = create_tmpfolder;
cu = onCleanup( @()delete_tmpfolder( workfolder ) );
  
  
%= Init Q structure
%
Q  = qarts;


%= Overall settings
%
Q.CLOUDBOX_DO       = false;
Q.J_DO              = false;
Q.SENSOR_DO         = false;
%
Q.INCLUDES          = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                        fullfile( 'ARTS_INCLUDES', 'agendas.arts' ), ...
                        fullfile( 'ARTS_INCLUDES', 'continua.arts' ), ...
                        fullfile( 'ARTS_INCLUDES', 'planet_earth.arts' ) };


%= Set standard clear-sky agendas
%
Q.WSMS_AT_START{1} = 'Copy(iy_main_agenda,iy_main_agenda__Emission)';
Q.WSMS_AT_START{2} = 'Copy(ppath_agenda,ppath_agenda__FollowSensorLosPath)';
Q.WSMS_AT_START{3} = ...
                    'Copy(ppath_step_agenda,ppath_step_agenda__GeometricPath)';
Q.WSMS_AT_START{4} = ...
         'Copy(blackbody_radiation_agenda,blackbody_radiation_agenda__Planck)';
Q.WSMS_AT_START{5} = 'Copy(iy_space_agenda,iy_space_agenda__CosmicBackground)';
Q.WSMS_AT_START{6} = ...
                 'Copy(iy_surface_agenda,iy_surface_agenda__UseSurfaceRtprop)';


%= General part
%
Q.F_GRID            = freq;
Q.STOKES_DIM        = 4;
%
Q.ABS_SPECIES(1).TAG{1} = 'H2O-PWR98';
Q.ABS_SPECIES(2).TAG{1} = 'N2-SelfContStandardType';
Q.ABS_SPECIES(3).TAG{1} = 'O2-PWR93';


%= Define atmosphere
%
Q.ATMOSPHERE_DIM      = 1;
%
Q.P_GRID              = z2p_simple( [0:200:10e3 11e3:1e3:25e3] )';
%
arts_xmldata_path     = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
%
Q.RAW_ATMOSPHERE        = fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                     'Fascod', 'midlatitude-winter', 'midlatitude-winter' );
Q.RAW_ATM_EXPAND_1D   = false;


%= Surface
%
Q.REFELLIPSOID        = ellipsoidmodels( 'SphericalEarth' );
Q.Z_SURFACE           = text2cfile( 'Extract( z_surface, z_field, 0 )' );
%
R        = zeros( 1, Q.STOKES_DIM, Q.STOKES_DIM ); 
R(1,:,:) = rsurf*eye( Q.STOKES_DIM );

R(1,1,2) = rsurf*0.1; 
R(1,2,1) = rsurf*0.1; 

fname = fullfile(workfolder,'surface_reflectivity.xml');
xmlStore( fname, R, 'Tensor3' );
Q.WSMS_AT_START{end+1} = sprintf('ReadXML(surface_reflectivity,"%s")',fname);
%
Q.SURFACE_RTPROP_AGENDA{1} = 'specular_losCalc';
Q.SURFACE_RTPROP_AGENDA{2} = 'InterpAtmFieldToPosition( out=surface_skin_t';
Q.SURFACE_RTPROP_AGENDA{3} = '  , field=t_field )';
Q.SURFACE_RTPROP_AGENDA{4} = 'surfaceFlatReflectivity';


%= Create an absorption table
%
Q.ABS_LINES_FORMAT    = 'none';
%
Q.ABS_NLS             = [];
Q                     = qarts_abstable( Q );
arts_abstable( Q, workfolder );


%= Set RTE variables
%
Q.IY_UNIT             = 'RJBT';
Q.YCALC_WSMS          = { 'yCalc' };
%
Q.PPATH_LMAX          = 5e3/max([1,iwp/0.5]);
%
Q.SENSOR_POS          = 830e3;
Q.SENSOR_LOS          = 135;


% Calculate clearsky
%
y0 = arts_y( Q, workfolder );
%
if nargout < 2, return, end


%= Setting structure for cloudbox and scattering solution method
%
C               = qartsCloudbox;

%- Define 1D cloudbox and particles

C.LIMITS = [ -1e3 zcloud+2e3 ];

% Temperature for scattering data (if only one is given, no
% temperature interpolation is performed in ARTS calculation.
T_grid = [200 235 270];   % MC does not accept a single temperature!


% Create scattering properties for a simple cloud assumption
% (mono disperese particle distribution)

% Calculate refractive indices 
fgrid     = Q.F_GRID + [-1e6,1e6]';  
rfr_index = zeros( length(fgrid), length(T_grid) );
%
for i = 1 : length(T_grid)     % Note .' below. We do not want to conjugate
  rfr_index(:,i) = sqrt(eps_ice_matzler06(fgrid, T_grid(i) ) ).';
end

% Scattering angles
theta = 0:2:180;
% Particle size [m]
r = dpart/2;
% cloud altitude
alt = zcloud + [-1e3 1e3];

% Calculate scattering data using Mie
C.SCAT_DATA{1} = mie_arts_scat_data( fgrid,  T_grid, rfr_index, theta, r );

% Calculate a pnd field for a homogeneous cloud
C.PND_FIELD{1} = box_pnd_mono_size_1d( alt, iwp/diff(alt), r );

% Set up scattering method
%
C.METHOD                        = 'DOIT';
C.METHOD_PRMTRS                 = CMd;

% Need a trick here for setting RJ
Q.IY_UNIT                       = '1';
Q.WSMS_BEFORE_RTE{1}            = 'StringSet(iy_unit,"RJBT")';  

C.OPT_PROP_PART_AGENDA = { 'ext_matInit', 'abs_vecInit', 'ext_matAddPart', ...
                                                         'abs_vecAddPart' };
C.SPT_CALC_AGENDA = { 'opt_prop_sptFromMonoData' };


%- Activate cloudbox
%
Q.CLOUDBOX_DO = true;
Q.CLOUDBOX    = C;


%= DOIT
%
yd = arts_y( Q, workfolder );
%
if nargout < 3, return, end
  

%= Expand to 3D
%
latlon_grid = [-80:10:80]';
%
Q.ATMOSPHERE_DIM                = 3;
Q.RAW_ATM_EXPAND_1D             = true;
Q.LAT_GRID                      = latlon_grid;
Q.LON_GRID                      = latlon_grid;
%
C.LIMITS                        = [ C.LIMITS [-50 50 -50 50] ];
C.PND_FIELD{1}.grids{2}         = [ -90 -50 -40 40 50 90 ];
C.PND_FIELD{1}.grids{3}         = C.PND_FIELD{1}.grids{2};
p                               = C.PND_FIELD{1}.data;
C.PND_FIELD{1}.data             = zeros( length( C.PND_FIELD{1}.grids{1} ),...
                                         length( C.PND_FIELD{1}.grids{2} ),...
                                         length( C.PND_FIELD{1}.grids{3} ) );
C.PND_FIELD{1}.data(:,3:4,3:4)  = repmat(p,[1 2 2]);
%  
Q.SENSOR_POS(:,2)               = -5;
Q.SENSOR_POS(:,3)               = 1;
Q.SENSOR_LOS(:,2)               = 0;


%- Change settings to fit MC
%
C.METHOD                        = 'MC';
C.METHOD_PRMTRS                 = CMm;
%
Q.CLOUDBOX                      = C;
Q.IY_MAIN_AGENDA                = { 'Ignore( rte_pos2 )', 'iyMC', ...
                                    'Touch(ppath)' };
Q.IY_AUX_VARS                   = { 'Error (uncorrelated)' };
Q.IY_UNIT                       = 'RJBT';
Q.WSMS_BEFORE_RTE               = {};

  
%= MC
%
[ym,y_aux] = arts_y( Q );
ymerror    = y_aux{1};

