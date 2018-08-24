function Te = equivalent_temperature(rh, T, p)
% EQUIVALENT_TEMPERATURE   equivalent temperature Te
%
%    Temperature a sample of moist air would obtain if all
%    the moisture were condensed out at constant pressure
%    (i.e. latent heat converted to sensible heat). 
%
% FORMAT    Te = equivalent_temperature(T, w)
%        
% OUT   Te  equivalent temperature [K]
% IN    rh  relative humidity [%], rh > 0 and can be a scalar or a tensor
%       T   air temperature [K], it can be a scalar or a tensor
%       p   air pressure [Pa], it can be a scalar or a tensor
%
% EXAMPLE:
%       Te = equivalent_temperature(50, 298, 100000)
%       Te = 322.6981
%
% ACCURACY: 
%           EQUIVALENT_TEMPERATURE uses thermodynamic relations with no
%           assumption
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M.
%             Yau, page: 20, eq:2.32
%
% 2009-08-15   Created by Isaac Moradi.

% set constants
cp = constants( 'SPECIFIC_HEAT_CONST_PRES' ); % specific heat at constant pressure J.kg-1.K-1
L = latent_heat_vaporization(T);

% calculate mixing ratio
r = water_vapor_mixing_ratio(rh, T, p) ;

% calculate equivalent temperature
Te = T + L .* r ./ cp;            
