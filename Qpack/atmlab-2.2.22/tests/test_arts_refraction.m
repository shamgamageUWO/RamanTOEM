% TEST_ARTS_REFRACTION   Testing of ARTS ppaths with refraction
%
%   Makes 1D, 2D and 3D calculations with refraction and gives estimate
%   of the error. The correct value is estimated by making calculations 
%   with a 100 m step length, which makes the function slow.
%
% FORMAT   test_arts_refraction( [lrt,geomztan,switchaa] )
%        
% OPT   lrt        Ray tracing step length
%       geomztan   Geometrical tangent altitude
%       switchaa   Make calculations with negative za for 2D and with a 180 
%                  deg azimuth angle for 3D

% 2012-03-15   Created by Patrick.

function test_arts_refraction( varargin )
%
[lrt,geomztan,switchaa] = optargs( varargin, { 2e3, 10e3, false } );
  
  
%- Fixed settings
%
Q = qarts;
Q.INCLUDES              = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                            fullfile( 'ARTS_INCLUDES', 'agendas.arts' ) };
%
Q.PPATH_AGENDA          = { 'ppath_agenda__FollowSensorLosPath'   };
Q.PPATH_STEP_AGENDA     = { 'ppath_step_agenda__RefractedPath'    };
Q.REFR_INDEX_AIR_AGENDA = { 'refr_index_air_agenda__GasThayer'    };
%
Q.F_GRID                = 100e9;
Q.CLOUDBOX_DO           = false;
Q.ABS_SPECIES(1).TAG{1} = 'H2O';
refell                  = ellipsoidmodels( 'SphericalEarth' );
re_string               = 'refellipsoidEarth( refellipsoid, "Sphere" )';


%- Load a test atmosphere
%
atmtest =  fullfile( atmlab('ARTS_XMLDATA_PATH'), 'planets', 'Earth', ...
                                       'Fascod', 'tropical', 'tropical' );
Az      = xmlLoad( [ atmtest, '.z.xml' ] ); 
At      = xmlLoad( [ atmtest, '.t.xml' ] ); 
Ah2o    = xmlLoad( [ atmtest, '.H2O.xml' ] ); 


%- 1D atmosphere
%
Q.P_GRID              = z2p_simple( linspace( 0, 80e3, 320 )' );
Q.Z_FIELD             = interpp( Az.grids{1}, Az.data, Q.P_GRID );
Q.T_FIELD             = interpp( At.grids{1}, At.data, Q.P_GRID );
Q.VMR_FIELD           = interpp( Ah2o.grids{1}, Ah2o.data, Q.P_GRID );
Q.VMR_FIELD           = reshape( Q.VMR_FIELD, [1 length(Q.P_GRID) 1 1 ] );
  
%- Surface altitude
%
Q.Z_SURFACE           = 500;
  
%- Sensor pos/los
Q.SENSOR_POS          = 600e3;
Q.SENSOR_LOS          = geomztan2za( refell(1), Q.SENSOR_POS, geomztan );


%- Determine expected tangent altitude
%
eh2o = Q.P_GRID .* Q.VMR_FIELD(1,:)';
n    = 1 + ( 77.6e-8 * ( Q.P_GRID - eh2o ) + ...
                    ( 64.8e-8 + 3.776e-3 ./ Q.T_FIELD ) .* eh2o ) ./ Q.T_FIELD;
x    = n .* (refell(1)+Q.Z_FIELD);
ztan = interp1( x, Q.Z_FIELD, (refell(1)+Q.SENSOR_POS)*sind(Q.SENSOR_LOS), ...
                'cubic' );
% Cubic interpolation was found best in comparison to ppath0 result below,
% closely followed by spline.


%- Create a workfolder
%
workfolder = create_tmpfolder;


%- Define calculation part
%
Q.WSMS_AT_START       = { 'IndexSet(stokes_dim,1)', re_string };
Q.WSMS_AT_END         = { 
    'VectorExtractFromMatrix(rte_pos,sensor_pos,0,"row")', ...
    'VectorExtractFromMatrix(rte_los,sensor_los,0,"row")', ...
    'VectorSet(rte_pos2,[])', ...
    'ppathCalc', ...
    sprintf('ppathWriteXMLPartial("ascii",ppath,"%s/ppath.xml")',workfolder) };


%- Run ARTS for 1D, with short step length
%
Q.ATMOSPHERE_DIM      = 1;
Q.PPATH_LRAYTRACE     = 5;
Q.PPATH_LMAX          = Q.PPATH_LRAYTRACE;
%
S = qarts2cfile( Q, { 'Generl', 'AtmSrf', 'AbsrptSave', 'CldBox', ...
                      'RteSet', 'CloseF' }, workfolder );
cfile = fullfile( workfolder, 'cfile.arts' );
strs2file( cfile, S );
notok = arts( cfile, true );
%
if notok
  fprintf('\n!!! Error while running ARTS for 1D !!!\n');
  keyboard
end
%
ppath0 = xmlLoad( fullfile( workfolder, 'ppath.xml' ) );
%
[ztan0,imin] = min(ppath0.pos(:,1));
lat0         = ppath0.pos(imin,2);
if switchaa
  lat0 = -lat0;
end
fprintf( '\nGeometrical tangent altitude : %8.3f km\n', geomztan/1e3 );
fprintf( '  Refracted tangent altitude : %8.3f km\n', ztan0/1e3 );
fprintf( 'Rough error estimate of ztan : %8.3f m\n',  ztan0-ztan );
fprintf( '     Ray tracing step length : %8.3f km\n', lrt/1e3 );
  


%- Run ARTS for 1D
%
Q.ATMOSPHERE_DIM      = 1;
Q.PPATH_LRAYTRACE     = lrt;
Q.PPATH_LMAX          = Q.PPATH_LRAYTRACE;
%
S = qarts2cfile( Q, { 'Generl', 'AtmSrf', 'AbsrptSave', 'CldBox', ...
                      'RteSet', 'CloseF' }, workfolder );
cfile = fullfile( workfolder, 'cfile.arts' );
strs2file( cfile, S );
notok = arts( cfile, true );
%
if notok
  fprintf('\n!!! Error while running ARTS for 1D !!!\n');
  keyboard
end
%
ppath1 = xmlLoad( fullfile( workfolder, 'ppath.xml' ) );
%
if switchaa
  ppath1.pos(:,2) = -ppath1.pos(:,2);
end
%
[zmin1,imin] = min(ppath1.pos(:,1));
lat1         = ppath1.pos(imin,2);
%
fprintf( '       Altitude error for 1D : %8.3f m\n', zmin1-ztan0 );
fprintf( '       Latitude error for 1D : %8.3f m\n', (lat1-lat0)*111e3 );
  

%- 2D
%
Q.ATMOSPHERE_DIM      = 2;
% 
Q.SENSOR_POS(2)       = 0; 
Q.LAT_GRID            = [ 10 : 35 ]';
if switchaa
  Q.SENSOR_LOS(1)     = -Q.SENSOR_LOS(1);
  Q.LAT_GRID          = sort( -Q.LAT_GRID );
end
nlat                  = length( Q.LAT_GRID );
Q.Z_FIELD             = repmat( Q.Z_FIELD, 1 , nlat );
Q.T_FIELD             = repmat( Q.T_FIELD, 1 , nlat );
Q.VMR_FIELD           = repmat( Q.VMR_FIELD, [ 1, 1 , nlat] );
Q.Z_SURFACE           = repmat( Q.Z_SURFACE, nlat, 1 );
%
S = qarts2cfile( Q, { 'Generl', 'AtmSrf', 'AbsrptSave', 'CldBox', ...
                      'RteSet', 'CloseF' }, workfolder );
cfile = fullfile( workfolder, 'cfile.arts' );
strs2file( cfile, S );
notok = arts( cfile, true );
%
if notok
  fprintf('\n!!! Error while running ARTS for 2D !!!\n');
  keyboard
end
%
ppath2 = xmlLoad( fullfile( workfolder, 'ppath.xml' ) );
%
[zmin2,imin] = min(ppath2.pos(:,1));
lat2         = ppath2.pos(imin,2);
fprintf( '       Altitude error for 2D : %8.3f m\n', zmin2-ztan0 );
fprintf( '       Latitude error for 2D : %8.3f m\n', (lat2-lat0)*111e3 );



%- 3D
%
Q.ATMOSPHERE_DIM      = 3;
% 
Q.SENSOR_POS(3)       = 10; 
Q.SENSOR_LOS(2)       = 0; 
if switchaa
  Q.SENSOR_LOS(1)     = -Q.SENSOR_LOS(1);
  Q.SENSOR_LOS(2)     = 180;   
end
Q.LON_GRID            = Q.SENSOR_POS(3) + [ -5 : 2 : 5 ]';
nlon                  = length( Q.LON_GRID );
Q.Z_FIELD             = repmat( Q.Z_FIELD, [ 1 , 1, nlon ] );
Q.T_FIELD             = repmat( Q.T_FIELD, [ 1 , 1, nlon ] );
Q.VMR_FIELD           = repmat( Q.VMR_FIELD, [ 1, 1 , 1, nlon] );
Q.Z_SURFACE           = repmat( Q.Z_SURFACE, [ 1, nlon ] );

%
S = qarts2cfile( Q, { 'Generl', 'AtmSrf', 'AbsrptSave', 'CldBox', ...
                      'RteSet', 'CloseF' }, workfolder );
cfile = fullfile( workfolder, 'cfile.arts' );
strs2file( cfile, S );
notok = arts( cfile, true );
%
if notok
  fprintf('\n!!! Error while running ARTS for 3D !!!\n');
  keyboard
end
%
ppath3 = xmlLoad( fullfile( workfolder, 'ppath.xml' ) );
%
[zmin3,imin] = min(ppath3.pos(:,1));
lat3         = ppath3.pos(imin,2);
lon3         = ppath3.pos(imin,3)-Q.SENSOR_POS(3);
fprintf( '       Altitude error for 3D : %8.3f m\n', zmin3-ztan0 );
fprintf( '       Latitude error for 3D : %8.3f m\n', (lat3-lat0)*111e3 );
fprintf( '      Longitude error for 3D : %8.3f m\n\n', lon3*111e3 );
  


%- Remove workfolder
%
delete_tmpfolder( workfolder );

