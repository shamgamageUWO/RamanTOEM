function theta = potential_temperature(rh, T, p) 
% POTENTIAL_TEMPERATURE estimates potential temperature theta
%
%   theta The temperature that an unsaturated parcel of dry air would have
%   if brought adiabatically and reversibly from its initial state to a
%   standard pressure, p0, typically 100 kPa 
%   (REF: http://amsglossary.allenpress.com/glossary/)
%
% FORMAT    theta = potential_temperature(rh, T, p)
%        
% OUT   theta   potential temperature [K]
% IN    rh  relative humidity [%, rh > 0], it can be a scalar or a tensor
%       T   air temperature [K], it can be a scalar or a tensor
%       p   air pressure [Pa], it can be a scalar or a tensor
% EXAMPLE:
%       theta = potential_temperature(50, 298, 110000)
%       theta = 290.0127
%
% ACCURACY: 
%           POTENTIAL_TEMPERATURE gives a very good estimation of theta
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%              page 7, Eq., 1.23 but k is replaced with that in E. 2.27,
%              page 19.
%
% 2009-08-15   Created by Isaac Moradi.

% set constants
cp = constants('SPECIFIC_HEAT_CP_DRY_AIR');
cv = constants('SPECIFIC_HEAT_CV_DRY_AIR');
k = (cp - cv) / cp; % c is specific heat at constant pressure and volume

% calculate water vapor mixing ratio
r = water_vapor_mixing_ratio(rh, T, p);

% calculate potential temperature theta
k_m = k .* (1 - 0.2 .* r);
theta = T .* power((100 ./ (p ./ 1000)), k_m);      
        
