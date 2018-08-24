function r = water_vapor_mixing_ratio(rh, T, p)  
% WATER_VAPOR_MIXING_RATIO water vapor mixing ratio r
%
%   r mixing ratio is the ratio of kilograms of water vapour, mw, 
%   per kilogram of dry air, md, at a given pressure. It can be expressed
%   using water vapor pressure and air pressure.
%
% FORMAT    r = water_vapor_mixing_ratio(rh, T, p)
%        
% OUT   r   mixing ratio []
% IN    rh  relative humidity [%, rh > 0], it can be a scalar or a tensor
%       T   air temperature [K], it can be a scalar or a tensor
%       p   air pressure [Pa], it can be a scalar or a tensor
% EXAMPLE:
%       r = water_vapor_mixing_ratio(50, 298, 100000)
%       r = 0.0099
%
% ACCURACY: WATER_VAPOR_MIXING_RATIO calculates water vapor mixing ratio
%           according to thermodynamic functions without any assumptions.
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%             page: 17, Eq.:2.18
%
% 2009-08-15   Created by Isaac Moradi.

eps = constants('GAS_CONST_DRY_AIR') / constants('GAS_CONST_WATER_VAPOR'); 

es = e_eq_water(T);
e = rh .* es ./ 100;
r = eps .* e ./ (p - e);
  