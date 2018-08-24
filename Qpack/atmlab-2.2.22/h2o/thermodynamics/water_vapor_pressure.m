function ew = water_vapor_pressure(rh,T,p)
% WATER_VAPOR_PRESSURE water vapor pressure ew
%
% FORMAT    ew =  water_vapor_pressure(rh, T, p)
%        
% OUT   ew  water vapor pressure [Pa]
% IN    rh  relative humidity [%], a scalar or a tensor
%       T   air temperature [K], a scalar or a tensor
%       p   air pressure [Pa], a scalar or a tensor
%
% EXAMPLE:
%       ew = water_vapor_pressure(50, 298, 100000)
%       ew = 1.5959e+03
%
% ACCURACY: WATER_VAPOR_PRESSURE calculates water vapor pressure
%           according to thermodynamic functions without any assumptions.
%           The accuracy is decreased if air pressure is not provided.
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%             page: 17, Eq.:2.20
%
% 2009-08-15   Created by Isaac Moradi.

es = e_eq_water(T);

% use simply e/es if p isnt given
if nargin < 3
    ew = rh .* es ./ 100;    
else
    ew = rh .* es .* p ./ (100 .* (p - es) + rh .* es);
end





