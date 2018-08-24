% ARTS_OEM_DEMO   Demonstration of inversions using ARTS and OEM
%
%    The example treats ground-based measurements of ozone at 110.8 GHz.
%
%    A figure with the inversion result is generated if the function is
%    called with no output arguments. Otherwise, the output from *oem* is
%    returned (work folder is deleted).
%
% FORMAT   [X,R] = arts_oem_demo
%
% OUT   X   As same output from *oem*.
%       R   As same output from *oem*.

% 2006-09-07   Created by Patrick Eriksson.

function [X,R] = arts_oem_demo


%- Check if needed atmlab settings are found
%
arts_xmldata_path = atmlab( 'ARTS_XMLDATA_PATH' );
if isnan( arts_xmldata_path )
  error('You need to ARTS_XMLDATA_PATH to run this example.');
end
%
arts_includes = atmlab( 'ARTS_INCLUDES' );
if isnan( arts_includes )
  error('You need to ARTS_INCLUDES to run this example.');
end



%----------------------------------------------------------------------------
%- Init control structures 
%----------------------------------------------------------------------------
%
Q      = qarts;
Q.J_DO = true;
O      = oem;


%----------------------------------------------------------------------------
%- OEM settings
%----------------------------------------------------------------------------
%
O.itermethod = 'GN';
O.stop_dx    = 0.01;
O.maxiter    = 20;
%
O.cost       = true;
O.e          = true; 
O.eo         = true;
O.es         = true;
O.yf         = true;



%----------------------------------------------------------------------------
%- Forward model parameters
%----------------------------------------------------------------------------

%- General 
%
Q.INCLUDES            = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                          fullfile( 'ARTS_INCLUDES', 'agendas.arts' ), ...
                          fullfile( 'ARTS_INCLUDES', 'continua.arts' ), ...
                          fullfile( 'ARTS_INCLUDES', 'planet_earth.arts' ) };
Q.ATMOSPHERE_DIM      = 1;
Q.STOKES_DIM          = 1;

%- Atmosphere
%
Q.Z_SURFACE           = 0;
Q.P_GRID              = z2p_simple( -250:250:90e3 )';
%
Q.RAW_ATMOSPHERE      = fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                        'Fascod', 'midlatitude-winter', 'midlatitude-winter' );
Q.CLOUDBOX_DO         = false;


%= Define agendas
%
Q.PPATH_AGENDA               = { 'ppath_agenda__FollowSensorLosPath'   };
Q.PPATH_STEP_AGENDA          = { 'ppath_step_agenda__GeometricPath'    };
Q.BLACKBODY_RADIATION_AGENDA = { 'blackbody_radiation_agenda__Planck'  };
Q.IY_SURFACE_AGENDA          = { 'iy_surface_agenda__UseSurfaceRtprop' };
Q.IY_MAIN_AGENDA             = { 'iy_main_agenda__Emission'            };


%- Exclude cosmic background radiation. A relative change of the spectrum
%- corresponds then to a relative change of the ozone profile.
%
Q.IY_SPACE_AGENDA     = { 'Ignore(rtp_los)',  'Ignore(rtp_pos)', ...
                          'nelemGet(nrows,f_grid)', ...
                          'Copy(ncols,stokes_dim)', ...
                          'MatrixSetConstant(iy,nrows,ncols,0)' };


%- RTE
%
Q.YCALC_WSMS          = { 'yCalc' };
%
Q.PPATH_LMAX          = 250;
Q.IY_UNIT              = 'RJBT';
%
Q.SENSOR_LOS          = 70;
Q.SENSOR_POS          = Q.Z_SURFACE;


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
df                    = 0.5e6;
H.F_BACKEND           = [ min(Q.F_GRID)+df : df : max(Q.F_GRID)-df ]';
%
B.name                = 'Spectrometer channel response function';
B.gridnames           = { 'Frequency' };
B.grids               = { [-df/2 df/2] };
B.dataname            = 'Response';
B.data                = [1 1];
%
H.BACKEND_CHANNEL_RESPONSE{1} = B;
H.BACKEND_DO = true;
clear B
%
Q.SENSOR_DO           = true;
Q.SENSOR_RESPONSE     = H;
%
Q.ANTENNA_DIM         = 1;
Q.MBLOCK_ZA_GRID      = 0;



%----------------------------------------------------------------------------
%- Species
%----------------------------------------------------------------------------

% Water vapour has to be inluded (needed by absorption part)
%
Q.ABS_SPECIES(1).TAG      = { 'H2O' };
Q.ABS_SPECIES(1).RETRIEVE = false;

% Ozone, retrieved
%
Q.ABS_SPECIES(2).TAG      = { 'O3' };
Q.ABS_SPECIES(2).RETRIEVE = true;
Q.ABS_SPECIES(2).GRIDS    = { z2p_simple( 0e3:1e3:90e3 )', [], [] };
Q.ABS_SPECIES(2).UNIT     = 'vmr';
Q.ABS_SPECIES(2).MINMAX   = 1e-12;
Q.ABS_SPECIES(2).SX       = covmat1d_from_cfun( Q.ABS_SPECIES(2).GRIDS{1}, ...
                                    2e-6, 'lin', 0.2, 0.00, @log10 ) + ...
                            covmat1d_from_cfun( Q.ABS_SPECIES(2).GRIDS{1}, ...
                                  0.5e-6, 'lin', 0.5, 0.00, @log10 );


%----------------------------------------------------------------------------
%- Set-up/create absorption look-up table
%----------------------------------------------------------------------------

Q.ABS_LINES_FORMAT         = 'Arts';
Q.ABS_LINES                = fullfile( atmlab_example_data , 'o3line111ghz' );
Q.ABS_NLS                  = [];
%
Q                          = qarts_abstable( Q ); 
% The absorption table will with the settings above be calculated
% automatically. If you want to pre-calculate the table, for later re-usage, 
% do: 
%Q.ABS_LOOKUP               = arts_abstable( Q ); 



%----------------------------------------------------------------------------
%- Init retrieval variables (such as xa) and create Sx
%----------------------------------------------------------------------------
  
workfolder = create_tmpfolder;
cu = onCleanup( @()delete_tmpfolder( workfolder ) );
%  
[Qoem,O,R,xa] = arts_oem_init( Q, O, workfolder );
%
Sx = arts_sx( Q, R );



%----------------------------------------------------------------------------
%- Create a measurement
%----------------------------------------------------------------------------

%- Noise statistics
%
si = 0.01;
%
SE.FORMAT    = 'param';
SE.SI        = si;
SE.CCO       = 0;  
SE.CFUN1     = 'drc';
SE.CL1       = 0; 

%- Create Se
%
Se = covmat3d( 1, SE, Q.SENSOR_RESPONSE.F_BACKEND );

%- Calculate a spectrum matching a priori
%
y = arts_y( Q );

%- Crate a test measurement
%
y = 1.1 * y + si*randn(size(Se,1),1);




%----------------------------------------------------------------------------
%- Calculations
%----------------------------------------------------------------------------

%- Perform retrieval
%
X = oem( O, Qoem, R, @arts_oem, Sx, Se, [], [], xa, y );
%
clear Qoem 


%- Plot
%
if ~nargout
  %
  z = p2z_simple( Q.ABS_SPECIES(2).GRIDS{1} );
  %
  if O.e & O.eo
    h= plot( 1e6*X.x, z/1e3, 'k-', ...
             1e6*(repmat(X.x,1,2)+[-X.e X.e]), z/1e3, 'b:', ...
             1e6*(repmat(X.x,1,2)+[-X.eo X.eo]), z/1e3, 'r--' );
    legend( h([1 4 2]), 'Retrieved profile', 'Observation error', ...
                                                               'Total error' );
  else
    plot( 1e6*X.x, z/1e3 )
  end
  xlabel( 'Ozone [ppm]' )
  ylabel( 'Approximative altitude [km]' );
end
