function lv = latent_heat_vaporization(T)
% LATENT_HEAT_VAPORIZATION latent heat vaporization lv
%
%    Latent heat of vaporization is the energy required to 
%    transform a given quantity of water into vapor.
%
% FORMAT    Lwater = latent_heat_vaporization(T)
%        
% OUT   lv   latent heat of vaporization [K]
% IN    T   air temperature [K], it can be a scalar or a vector
%
% EXAMPLE:
%       Te = equivalent_temperature(50, 298, 100000)
%       Te = 322.6981
%
% ACCURACY: 
%           LATENT_HEAT_VAPORIZATION gives a very good approximation of lv
%
% Reference: An Introduction to Atmospheric Thermodynamics
%            A. A. Tsonis, Cambridge University Press, 2007
%            Page 87, Eq. 6.13
%
% 2009-08-15   Created by Isaac Moradi.

% set constants
lv0 = constants( 'LATENT_HEAT_VAPORIZATION'); 
cpv = constants( 'VAPOR_HEAT_CAPA_CONST_PRES');
cpw = constants( 'WATER_HEAT_CAPA_CONST_PRES');

% calculate latent heat
lv = lv0 + (cpv - cpw) .* (T - 273);