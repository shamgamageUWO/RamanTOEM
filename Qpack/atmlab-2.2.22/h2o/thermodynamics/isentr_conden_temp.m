function Tc = isentr_conden_temp(rh, T, p) 
% ISENTR_CONDEN_TEMP   isentropic condensation temperature Tc
%
%    isentropic condensation temperature (Tc) is the temperature
%    at which saturation is reached when moist air is cooled
%    adiabatically with mixing ration (r) held constant.
%
% FORMAT    Tc = isentr_conden_temp(rh, T, p)
%        
% OUT   Tc  isentropic condensation temperature [K]
% IN    rh  relative humidity [%], rh > 0 and can be a scalar or a tensor
%       T   air temperature [K], it can be a scalar or a tensor
%       p   air pressure [Pa], it can be a scalar or a tensor
%
% EXAMPLE:
%       Tc = isentr_conden_temp(50, 298, 100000)
%       Tc = 286.8752
%
% ACCURACY: 
%           ISENTR_CONDEN_TEMP gives a good estimation of Tc
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%            its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%            page: 21, Eq.: 2.33
%
% 2009-06-08   Created by Isaac Moradi.

% set constants
A = 2.53e8; % in kPa
B = 5.42e3; % in K
cp=constants('SPECIFIC_HEAT_CONST_PRES');
cv=constants('SPECIFIC_HEAT_CONST_VOL');
k = (cp - cv) / cp; % c is specific heat at constant pressure and volume
eps = constants('GAS_CONST_DRY_AIR') / ...
    constants('GAS_CONST_WATER_VAPOR'); 

% calculate mixing ratio
r = water_vapor_mixing_ratio(rh, T, p)  ;
var1 = A .* eps ./ (r .* (p ./ 1000));

% set intial values 
T1 = T;
Tc = T1;
Tc0 = Tc - 10;
inv_k = 1 ./ k;

% Tc exists in both side of Eq. 2.33 so we must solve the equation in an
% iteration. Tc is less than T. So the iteration start from Tc = T - 0.5
% and put the current value of Tc (Tc0) into left side and calculate new Tc.
% It will continue until abs(Tc0 - Tc) > 0.5
while abs(Tc0 - Tc) > 0.5
    T1 = T1 - 0.5;
    Tc0 = Tc;               
    var2 = T ./ T1;
    Tc = B ./ log(var1 .* power(var2, inv_k));
end
        
