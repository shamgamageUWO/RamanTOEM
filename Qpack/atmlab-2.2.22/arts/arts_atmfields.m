% ARTS_ATMFIELDS   Interpolates a raw atmosphere through ARTS
%
%    The function extracts the atmospheric fields corresponding to 
%    RAW_ATMOSPHERE.
%
%    Geoid and surface altitude variables are also returned.
%
%    Needed Qarts fields:
%       ABS_SPECIES
%       ATMOSPHERE_DIM
%       RAW_ATMOSPHERE
%       R_GEOID
%       Z_SURFACE
%    and
%       P_GRID
%       LAT_GRID
%       LON_GRID
%    if not corresponding optional arguments are used.
%
%    Dummy values must be set for (due to internal structure of qarts2cfile)
%       STOKES_DIM
%       F_GRID
%
% FORMAT [t_field,z_field,vmr_field,r_geoid,z_surface] = 
%                                          arts_atmfields( Q [, p, lat, lon ])
%        
% OUT   t_field     As the ARTS WSV with same name.
%       z_field     As the ARTS WSV with same name.
%       vmr_field   As the ARTS WSV with same name.
%       r_geoid     As the ARTS WSV with same name.
%       z_surface   As the ARTS WSV with same name.
%
% IN    Q           Qarts structure
% OPT   p           If given replaces Q.P_GRID
%       lat         If given replaces Q.LAT_GRID
%       lon         If given replaces Q.LON_GRID

% 2004-09-11   Created by Patrick Eriksson.


function [t_field,z_field,vmr_field,r_geoid,z_surface] = ...
                                                      arts_atmfields(Q,p,lat,lon)

%= Check input                                                   %&%
%                                                                %&%
rqre_nargin(1,nargin);                                           %&%
%                                                                %&%
rqre_datatype( Q, @isstruct );                                   %&%
% p,lat and lon checked inside qarts2cfile                       %&%
rqre_datatype( Q.RAW_ATMOSPHERE, @ischar, 'Q.RAW_ATMOSPHERE' );  %&%


if nargin >= 2
  Q.P_GRID = p;
end
if nargin >= 3
  Q.LAT_GRID = lat;
end
if nargin >= 4
  Q.LON_GRID = lon;
end


tmpfolder = create_tmpfolder;
cu = onCleanup( @()delete_tmpfolder( tmpfolder ) );


parts = qarts2cfile( 'GetAtmSrf' );
S = qarts2cfile( Q, parts, tmpfolder );
cfile = fullfile( tmpfolder, 'cfile.arts' );
strs2file( cfile, S );
arts( cfile );
t_field   = xmlLoad( fullfile( tmpfolder, 't_field.xml') );
z_field   = xmlLoad( fullfile( tmpfolder, 'z_field.xml') );
vmr_field = xmlLoad( fullfile( tmpfolder, 'vmr_field.xml') );
if nargout > 3
  r_geoid   = xmlLoad( fullfile( tmpfolder, 'r_geoid.xml') );
  z_surface = xmlLoad( fullfile( tmpfolder, 'z_surface.xml') );
end
end
