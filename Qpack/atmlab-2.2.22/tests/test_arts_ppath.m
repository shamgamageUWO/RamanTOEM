% TEST_ARTS_PPATH   Testing of ARTS ppath calculations
%
%    Random test cases are generated. The following variables are
%    randomised:
%       length of p_grid
%       length of lat_grid
%       length of lon_grid
%       z_surface
%       z_field
%       sensor_pos
%       sensor_los
%
%    A ppath calculation for ARTS is performed for each test case. A basic check
%    of the ARTS calculations performed, by using atmlab functions. If any
%    error is found, "keyboard" is called. The work folder is then left for
%    debugging purposes.
%
% FORMAT   test_arts_ppath( atmosphere_dim, n, [unsphere, do_refr] )
%        
% IN    atmosphere_dim   Atmospheric dimensionality
%       n                Run n cases
% OPT   unsphere         Deviation from spherical geometry. Default is 0.
%                        Possible choices:
%                          0: 1D geometry
%                          1: z_field disturbed
%                          2: 1 + non-spherical ellipsoid
%       do_refr          Run with refraction ray tracing WSM (but with n=1).

% 2012-02-22   Created by Patrick.

function test_arts_ppath( atmosphere_dim, n, varargin  )
%
[unsphere,do_refr] = optargs( varargin, { 0, false } );

do_check = 1;
  
%- Fixed settings
%
Q = qarts;
%
Q.INCLUDES              = { fullfile( 'ARTS_INCLUDES', 'general.arts' ), ...
                            fullfile( 'ARTS_INCLUDES', 'agendas.arts' ) };
Q.ATMOSPHERE_DIM        = atmosphere_dim;
Q.CLOUDBOX_DO           = false;
Q.F_GRID                = 100e9;
Q.ABS_SPECIES(1).TAG{1} = 'H2O';
%
Q.PPATH_AGENDA          = { 'ppath_agenda__FollowSensorLosPath'   };
%
if do_refr
  Q.PPATH_LRAYTRACE     = 1e3;
  Q.PPATH_STEP_AGENDA   = { 'ppath_step_agenda__RefractedPath'    };
  Q.REFR_INDEX_AIR_AGENDA = { ...
                            'Ignore(f_grid)', ...
                            'Ignore(rtp_pressure)', ...
                            'Ignore(rtp_temperature)', ...
                            'Ignore(rtp_vmr)', ...
                            'NumericSet(refr_index_air,1.0)', ...
                            'NumericSet(refr_index_air_group,1.0)' };
else
  Q.PPATH_STEP_AGENDA   = { 'ppath_step_agenda__GeometricPath'    };
end

Q.PPATH_LMAX            = 10e3;
%
if atmosphere_dim == 1  ||  unsphere < 2
  refell                = ellipsoidmodels( 'SphericalEarth' );
  re_string             = 'refellipsoidEarth( refellipsoid, "Sphere" )';
else
  refell                = ellipsoidmodels( 'WGS84' );
  re_string             = 'refellipsoidEarth( refellipsoid, "WGS84" )'; 
end


%- Load a test atmosphere
%
atmtest =  fullfile( atmlab('ARTS_XMLDATA_PATH'), 'planets', 'Earth', ...
                        'Fascod', 'midlatitude-winter', 'midlatitude-winter' );
Az      = xmlLoad( [ atmtest, '.z.xml' ] ); 
At      = xmlLoad( [ atmtest, '.t.xml' ] ); 
Ah2o    = xmlLoad( [ atmtest, '.H2O.xml' ] ); 



%- Create a workfolder
%
workfolder = create_tmpfolder;


%- To avoid getting same random sequence between sessions:
% 
RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));


%- Run through n random cases
%
emaxatm  = 0;
emaxsurf = 0;
%
for c = 1 : n

  fprintf(' > Doing %d/%d\r',c,n)

  %- Pressure grid
  %
  np                    = 30 + round( 170*rand );
  Q.P_GRID              = z2p_simple( linspace( 0, 80e3, np )' );

  %- Number of latitude and longitude grid points
  %
  nlat                = 1;
  nlon                = 1;
  %
  if atmosphere_dim == 2
    nlat                = 10 + round( 531*rand );
    Q.LAT_GRID          = linspace( -135, 135, nlat )';
    nlon                = 1;
  elseif atmosphere_dim == 3
    nlat                = 10 + round( 190*rand );
    nlon                = 10 + round( 190*rand );
    Q.LAT_GRID          = linspace( -80, 80, nlat )';
    Q.LON_GRID          = linspace( -90, 90, nlon )';
  end

  % Atmospheric fields
  Q.Z_FIELD = repmat( interpp( Az.grids{1}, Az.data, Q.P_GRID ), ...
                                                           [ 1, nlat, nlon ] ); 
  if unsphere
    Q.Z_FIELD = Q.Z_FIELD + 5*randn( size(Q.Z_FIELD) );
  end
  Q.T_FIELD = repmat( interpp( At.grids{1}, At.data, Q.P_GRID ), ...
                                                           [ 1, nlat, nlon ] ); 
  Q.VMR_FIELD = repmat( interpp( Ah2o.grids{1}, Ah2o.data, Q.P_GRID ), ...
                                                           [ 1, nlat, nlon ] ); 
  Q.VMR_FIELD = reshape( Q.VMR_FIELD, [1 np nlat nlon ] );
  %
  if atmosphere_dim == 3
    % Fix border conditions
    Q.Z_FIELD(:,:,end) = Q.Z_FIELD(:,:,1);
    Q.Z_FIELD(:,1,:)   = repmat(Q.Z_FIELD(:,1,1),[1 1 nlon]);
    Q.Z_FIELD(:,end,:) = repmat(Q.Z_FIELD(:,end,1),[1 1 nlon]);
  end
  
  %- Surface altitude
  %
  if ~unsphere
    Q.Z_SURFACE           = repmat( 500, nlat, nlon );
  else
    Q.Z_SURFACE           = 500*rand + 5e3*rand( nlat, nlon );
    if atmosphere_dim == 3
      % Avoid strong topography at the poles:
      Q.Z_SURFACE        = Q.Z_SURFACE .* repmat(cosd(Q.LAT_GRID),1,nlon);
      % Fix border conditions
      Q.Z_SURFACE(:,end) = Q.Z_SURFACE(:,1);
    end
    Q.Z_SURFACE = Q.Z_SURFACE + 500;  
  end
  
  %- Sensor pos/los
  %
  lat0                  = 0;
  lon0                  = 0;
  aa0                   = 0;
  %
  if rand < 0.33
    Q.SENSOR_POS        = 7e3 + 40e3*rand;
    Q.SENSOR_LOS        = 180*rand;    
  else
    Q.SENSOR_POS        = 700e3 + 50e3*randn;
    if rand < 0.5
      Q.SENSOR_LOS      = 140  + 40*rand;    
    else
      Q.SENSOR_LOS      = 111 + 5*rand;    
    end
  end
  %
  if atmosphere_dim == 2
    lat0                = -90 + 180*rand;
    Q.SENSOR_POS(2)     = lat0;
    if rand < 0.5
      Q.SENSOR_LOS      = -Q.SENSOR_LOS;
      aa0               = 180;
    end
  elseif atmosphere_dim == 3
    lat0                = -45 + 90*rand;    
    lon0                = -15 + 30*rand;    
    Q.SENSOR_POS(2)     = lat0;
    Q.SENSOR_POS(3)     = lon0;
    aa0                 = -180 + 360*rand;
%    aa0 = 0
    Q.SENSOR_LOS(2)     = aa0;
  end

  %- Define calculation part
  %
  Q.WSMS_AT_START{end+1} = 'IndexSet(stokes_dim,1)';
  Q.WSMS_AT_START{end+1} = re_string;
  Q.WSMS_AT_END         = { 
    'VectorExtractFromMatrix(rte_pos,sensor_pos,0,"row")', ...
    'VectorExtractFromMatrix(rte_los,sensor_los,0,"row")', ...
    'VectorSet(rte_pos2,[])', ...
    'ppathCalc', ...
    sprintf('ppathWriteXMLPartial("ascii",ppath,"%s/ppath.xml")',workfolder) };


  %- Run ARTS and load result
  %
  S = qarts2cfile( Q, { 'Generl', 'AtmSrf', 'AbsrptSave', 'CldBox', ...
                        'RteSet', 'CloseF' }, workfolder );
  cfile = fullfile( workfolder, 'cfile.arts' );
  strs2file( cfile, S );
  notok = arts( cfile, true );
  %
  if notok
    fprintf('\n!!! Error while running ARTS !!!\n');
    keyboard
  end

  if do_check
  
    ppath = xmlLoad( fullfile( workfolder, 'ppath.xml' ) );


    %- Check result
    %
    if ppath.np > 1
      
      if atmosphere_dim == 1  ||  ~unsphere
        re = refell(1);
      else
        re = interp1( Q.LAT_GRID, ellipsoidradii(refell,Q.LAT_GRID), lat0 );
      end
      
      [x0,y0,z0,dx,dy,dz] = geocentricposlos2cart( re+Q.SENSOR_POS(1), ...
                                         lat0, lon0, abs(Q.SENSOR_LOS(1)), aa0 );

      % Check ppath points
      lt    = ppath.end_lstep + [ 0; cumsum(ppath.lstep) ];
      e     = zeros( size(ppath.pos,1), 1 );
      for i = 1 : size(ppath.pos,1)
              
        if atmosphere_dim == 3
          lons = ppath.pos(i,3);
        else
          lons = 0;
        end
        
        [xt,yt,zt] = geocentric2cart( ppath.r(i), ppath.pos(i,2), lons );
        dd = norm( [ xt-(x0+lt(i)*dx), yt-(y0+lt(i)*dy), zt-(z0+lt(i)*dz) ] );
        e(i) = dd;
        if dd > 10
          fprintf('\n!!! Deviating ppath point found !!!\n');
          [rt,latt,lont,zat,aat] = cartposlos2geocentric( x0+lt(i)*dx, ...
                           y0+lt(i)*dy, z0+lt(i)*dz, dx, dy, dz, ...
                           (re+Q.SENSOR_POS(1))*sind(abs(Q.SENSOR_LOS(1))), ...
                           lat0, lon0, abs(Q.SENSOR_LOS(1)), aa0);
          keyboard
        end
      end
      
      if strcmp( ppath.background, 'surface' )
        if max(e(end)) > emaxsurf, emaxsurf = e(end); end
        e(end) = 0;
      end
      %
      if max(e) > emaxatm, emaxatm = max(e); end
    end
  end
end
%
if do_check
  fprintf( '\n' );
  fprintf( 'Max atmospheric deviation: %.1e m\n', emaxatm );
  fprintf( '    Max surface deviation: %.1e m\n', emaxsurf );
else
  fprintf( '\n' );
end


%- Remove workfolder
%
delete_tmpfolder( workfolder );


return
for i = 1:122
  [x0,y0,z0] = geocentric2cart( ppath0.r(i), ppath0.pos(i,2), ppath0.pos(i,3) );
  [x,y,z] = geocentric2cart( ppath.r(i), ppath.pos(i,2), ppath.pos(i,3) );
  s = norm( [ x0-x, y0-y, z0-z ] );
  fprintf( '%3d: %.2e\n', i, s );
end

  
