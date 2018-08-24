function theta_w = wet_bulb_potential_temp(rh, T, p) 
%  WET_BULB_POTENTIAL_TEMP wet bulb potential temperature
%
%   wet-bulb potential temperature—(Also called pseudo wet-bulb potential
%   temperature.) The temperature an air parcel would have if cooled from
%   its initial state adiabatically to saturation, and thence brought to 
%   1000 mb by a moist-adiabatic process. This temperature is conservative
%   with respect to reversible adiabatic changes. 
%   (REF: http://amsglossary.allenpress.com/glossary/)
%
% FORMAT   theta_w = wet_bulb_potential_temp(Tc, p, w) 
%        
% OUT   theta_w  wet bulb potential temperature [K]
% IN    rh  relative humidity [%], rh > 0 and it can be a scalar or a tensor
%       T   air temperature [K], a scalar or a tensor
%       p   air pressure [Pa], a scalar or a tensor
%
% EXAMPLE:
%       theta_w = wet_bulb_potential_temp(50, 298, 90000)
%       theta_w = 295.6460
%
% ACCURACY: WET_BULB_POTENTIAL_TEMP estimates water vapor pressure according
%           to thermodynamic functions without any assumptions. 
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%            its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%            page: 21
%
% 2009-08-15   Created by Isaac Moradi.

cp=constants('SPECIFIC_HEAT_CONST_PRES');
cv=constants('SPECIFIC_HEAT_CONST_VOL');
k = (cp - cv) / cp; % also equals constants('GAS_CONST_DRY_AIR') / cp

% calculate isentropic condensation temperature
Tc = isentr_conden_temp(rh, T, p) ;

% calculate mixing ratio
r = water_vapor_mixing_ratio(rh, T, p);

% calculate theta_w
k_m = k .* (1 - 0.2 .* r);
theta_w = Tc .* power((100 ./  (p ./ 1000)), k_m);

        