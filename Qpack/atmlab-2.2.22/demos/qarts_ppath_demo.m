% QARTS_PPATH_DEMO   Example on how to calculate a propagation path
%
%    Calculates the (main) propagation path, using ARTS.
%
%    The atmosphere is set to be 1D, with the surface at 0 m. The Fascod
%    tropical scenario is used.
%
% FORMAT   ppath = qarts_ppath_demo( zplat, za [, refr, lmax, lraytrace] )
%        
% OUT   Q          Ppath data structure.
% IN    zplat      Platform altitude.
%       za         Zenith angle.
% OPT   refr       Flag to include refraction. Default is false.
%       lmax       Value for ppath_lmax. Default is -1.
%       lraytrace  Value for ppath_lraytrace. Default is 1e3.

% 2013-04-16   Created, Patrick Eriksson.

function ppath = qarts_ppath_demo(zplat,za,varargin)
%
[refr,lmax,lraytrace] = optargs( varargin, { false, -1, 1e3 } );

  
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
                            fullfile( 'ARTS_INCLUDES', 'planet_earth.arts' ) };
%
Q.CLOUDBOX_DO           = false;
%
Q.STOKES_DIM            = 1;
Q.F_GRID                = 100e9;  % Here a dummy value

%= Define agendas
%
Q.PPATH_AGENDA               = { 'ppath_agenda__FollowSensorLosPath' };
if refr
  Q.PPATH_STEP_AGENDA        = { 'ppath_step_agenda__RefractedPath'   };
  Q.REFR_INDEX_AIR_AGENDA    = { 'refr_index_air_agenda__GasThayer'      };
else
  Q.PPATH_STEP_AGENDA        = { 'ppath_step_agenda__GeometricPath'  };
end


%= Only H2O needed here (to get correct refractive index)
%
Q.ABS_SPECIES(1).TAG{1} = 'H2O';


%= Set-up atmosphere and surface
%
Q.ATMOSPHERE_DIM         = 1;
%
Q.P_GRID                 = z2p_simple( [-100:250:60e3]' );
%
Q.RAW_ATMOSPHERE        = fullfile( arts_xmldata_path, 'planets', 'Earth', ...
                                           'Fascod', 'tropical', 'tropical' );
Q.RAW_ATM_EXPAND_1D     = false;
%
Q.REFELLIPSOID          = ellipsoidmodels( 'SphericalEarth' );
Q.Z_SURFACE             = 0;


%= Set position and line-of-sight
%
Q.SENSOR_POS        = zplat;
Q.SENSOR_LOS        = za;    

%= ppath step lengths
%
Q.PPATH_LMAX        = lmax;
Q.PPATH_LRAYTRACE   = lraytrace;


%= Include call of ppathCalc
%
workfolder = create_tmpfolder;
%
Q.WSMS_AT_END           = { 
    'VectorExtractFromMatrix(rte_pos,sensor_pos,0,"row")', ...
    'VectorExtractFromMatrix(rte_los,sensor_los,0,"row")', ...
    'VectorSet(rte_pos2,[])', ...
    'ppathCalc', ...
    sprintf('ppathWriteXMLPartial("ascii",ppath,"%s/ppath.xml")',workfolder) };


%= Run ARTS and load result
%
% There is no dedicated high-level function for this ...
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
else
  ppath = xmlLoad( fullfile( workfolder, 'ppath.xml' ) );
end
%
delete_tmpfolder( workfolder );



