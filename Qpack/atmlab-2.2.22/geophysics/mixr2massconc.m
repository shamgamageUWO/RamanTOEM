%=============================================================
% massconc = mixr2massconc( mixr, pres, temp)
%
% Calculates mass concentration from mass mixing ratio assuming
% a mixture of an atmospheric species and dry air.
%  
% Input:    mixr       mass mixing ratio vector of species [Kg/Kg]
%           pres       atmopsheric pressures [Pa]
%           temp       absolute temperature [K]
%
% Output:   massconc   mass concentration [Kg/m3]
%
% Carlos Jimenez 2014-02-12
%=============================================================

function massconc = mixr2massconc( mixr, pres, temp )
  
%= specific gas constant for dry air 
Re = constants('GAS_CONST_DRY_AIR'); % Pa * m3 /(kg·K)

%= density of dry air
rho =  airdensity( pres, temp ); % Kg / m3

%= mass concentration
massconc = rho .* mixr;  % Kg / m3

return


