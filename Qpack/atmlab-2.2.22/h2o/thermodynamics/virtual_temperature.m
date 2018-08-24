function Tv = virtual_temperature(rh, T, p)
% VIRTUAL_TEMPERATURE virtual temperature
%
%   Temperature that dry air would have to attain in order to 
%   has the same density as the moist air at the same pressure
%
% FORMAT   Tv = virtual_temperature(rh, T, p)
%        
% OUT   Tv  virtual temperature [K]
% IN    rh  relative humidity [%, rh > 0], it can be a scalar or a tensor
%       T   air temperature [K], it can be a scalar or a tensor
%       p   air pressure [Pa], it can be a scalar or a tensor
% EXAMPLE:
%       Tv = virtual_temperature(50, 298, 110000)
%       Tv = 299.6178
%
% ACCURACY: VIRTUAL_TEMPERATURE estimates virtual temperature.
%          
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%             page: 17, Eq.: 2.21
%
% 2009-08-15   Created by Isaac Moradi.

% set constants
eps = constants('GAS_CONST_DRY_AIR') / constants('GAS_CONST_WATER_VAPOR'); 

% calculate mixing ratio
r = water_vapor_mixing_ratio(rh, T, p);

% calculate virtual temperature
Tv = T .* (1 + r ./ eps) ./ (1 + r);            

        
   