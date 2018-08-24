function ew = r2e(r, p)  
%  R2E convert water vapor mixing ratio to water vapor pressure
%
%   Mixing ratio is the ratio of kilograms of water vapour, mw, 
%   per kilogram of dry air, md, at a given pressure. It can be expressed
%   using water vapor pressure and air pressure. 
%
% FORMAT    ew = r2e(r, p)
%        
% OUT   ew  water vapor pressure [Pa]
% IN    r   mixing ratio [], it can be a scalar or a vector
%       p   air pressure [Pa], it can be a scalar or a vector
%      
% EXAMPLE:
%       ew = r2e(0.0063, 100000)
%       ew = 1002.9
%
% ACCURACY: R2E calculates water vapor pressure according to thermodynamic
%           functions without any assumptions. 
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%             page: 17, Eq.:2.18
%
% 2009-08-15   Created by Isaac Moradi.

eps = constants('GAS_CONST_DRY_AIR') / constants('GAS_CONST_WATER_VAPOR'); 

ew = r .* p ./ (eps + r);