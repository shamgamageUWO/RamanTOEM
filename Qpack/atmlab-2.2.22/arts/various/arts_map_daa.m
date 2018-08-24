% ARTS_MAP_DAA   Maps MBLOCK_AA_GRID values to correct ZA and AA
%
%   Sensor LOS azimuth angles and mblock_aa_grid values can not be added in a
%   straightforward way due to properties of the polar coordinate system used to
%   define line-of-sights. This function performs a "mapping" ensuring that the
%   pencil beam directions specified by mblock_za_grid and mblock_aa_grid form
%   a rectangular grid (on the unit sphere) for any za.
%
%   *za* and *aa0* match the angles of the ARTS WSV sensor_los.
%   *aa* shall hold values "close" to 0. The limit is here set to 5 degrees.
%
% FORMAT   [za,aa] = arts_map_daa( za, aa0, aa )
%        
% OUT   za   Zenith angles matching aa0+aa.
%       aa   Azimuth angles matching aa0+aa.
%       dz   LOS component in z dimension.
% IN    za   Zenith angle (a scalar).
%       aa0  Centre azimuth angle (a scalar). 
%       aa   MBLOCK_AA_GRID values.

% 2009-09-23   Created by Patrick Eriksson.

function [za,aa] = arts_map_daa( za, aa0, aa )

if any( abs(aa) > 5 )
  error( 'Values in *aa* must be inside [-5,5].' );
end

% Unit vector towards aa0 at za=90
%
[x,y,z] = arts_zaaa2cart( 90, aa0 );
  
% Find vector around which rotation shall be performed
%  
vrot = cross( [0 0 1], [x;y;z] );

% Unit vectors towards aa0+aa at za=90
%
[x,y,z] = arts_zaaa2cart( 90, aa0 + aa );

% Apply rotation
%
u = rotationmat3D( (za-90)*pi/180, vrot) * [vec2row(x);vec2row(y);vec2row(z)];

% Calculate za and aa for rotated u
%
[za,aa] = arts_cart2zaaa( u(1,:), u(2,:), u(3,:) );
