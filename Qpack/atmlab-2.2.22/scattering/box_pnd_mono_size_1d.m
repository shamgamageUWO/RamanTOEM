%-----------------------------------------------------------------------------
%  PND_MONO_SIZE_1D  Generates simple particle number density field
% 
%  This function generates the particle number density field for a 
%  very simple 1D cirrus cloud layer. It assumes that all particles are of 
%  the same size.  As input it requires the altitude of the cloud
%  layer, the ice mass content and the radius of the
%  particles.
% 
%  FORMAT pnd_field = box_pnd_mono_size_1d(z_limits, imc, r)
% 
%  OUT    pnd        particle number density (ARTS data format GField3) 
%  IN     z_limits   cloud altitude     [z1 z2]  [m]
%         imc        ice mass content   [kg/m^3]
%         r          radius             [m]
% 
%  Created by Claudia Emde
%
%-----------------------------------------------------------------------------

function pnd_field = box_pnd_mono_size_1d(z_limits, imc, r)

% Convert altitude to pressure
p_limits = z2p_simple(z_limits);

% Density of ice 917 kg/m^3
rho = 917;

% Calculation of particle number density for given IMC
% and radius
pnd = 3/(4*pi) * imc/(rho*r^3);

% Define pressure grid. Two points are sufficient for box cloud
% We need to pressures nearby the limits, to assure that the
% particle number density decreases steaply to, take 1Pa to both 
% sides. 
p_grid = [1000e2 p_limits(1)+10 p_limits(1) p_limits(2) p_limits(2)-10 1];
% Assign pnd values
data(:,1,1) = [0 0 pnd pnd 0 0];

% Create GField3
%
pnd_field.grids     = { p_grid, [0], [0] };
pnd_field.gridnames = { 'Pressure', 'Latitude', 'Longitude' };
%
pnd_field.data  = data;

