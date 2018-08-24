% QARTS_ABSTABLE_DEMO   A simple demonstration calculation of abs. table
%
%    An absorption table is created. This example case gives the absorption
%    for the centre channel of the SSM/I channels. Absorption for N2, O2 and
%    H2O is provided, where some well known complete absorption models are
%    used. The table covers rougly 0 to 25 km, in steps of 250 m. The
%    temperature covers +-35K (in steps of 10K) around the Fascod sub-arctic
%    winter scenario. 
%
% FORMAT   A = qarts_abstable_demo
%        
% OUT   A  Absorption table.

% 2010-04-15   Created by Patrick Eriksson.


function A = qarts_abstable_demo

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


%= Atmospheric species and absorption models
%
Q.ABS_SPECIES(1).TAG{1}  = 'N2-SelfContStandardType';
Q.ABS_SPECIES(2).TAG{1}  = 'O2-PWR93';
Q.ABS_SPECIES(3).TAG{1}  = 'H2O-PWR98';


%= Set-up atmosphere and surface
%
Q.ATMOSPHERE_DIM         = 1;
%
Q.P_GRID                 = z2p_simple( [0:250:40e3]' );


%= Reference atmosphere
%
Q.RAW_ATMOSPHERE         = fullfile( fascod, 'subarctic-winter', ...
                                             'subarctic-winter' );
%
% Needed, but dummy variables
Q.REFELLIPSOID           = ellipsoidmodels( 'SphericalEarth' );
Q.Z_SURFACE              = 500;


%= Absorption settings
%
% For 22 GHz channel, the centre of the H2O transition is avoided by taking
% a frequency half way to band edge.
Q.F_GRID                 = [19.35 22.235-0.06 37.0 85.5]'*1e9;
Q.STOKES_DIM             = 1;
%
Q.ABS_LINES_FORMAT       = 'None';
Q.ABS_LINES              = [];
Q.ABS_NLS                = [];


%= Calculate absorption
%
Q                        = qarts_abstable( Q, 8, 35 ); 
A                        = arts_abstable( Q );         
