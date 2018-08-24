%=============================================================
  % vmr = mixr2vmr(mixr,molm)
%
% Calculates VMR-values from mass mixing ratio assuming
% a mixture of an atmospheric species and dry air.
%  
% Derivation 
%
%  mixr = mass_species/mass_dry-air
%      = n.moles species * molecular mass species / 
%        n.moles dry-air * molecular mass dry-air  
%  
%  vmr = n_w/n_d
%  
%     vmr = Md/Mw*mixr
%
%
% Input:    mixr   mass mixing ratio vector of species [Kg/Kg]
%           molm   species molecular mass  [Kg/mol]
%
% Output:   vmr vector of VMR-values [m3/m3]
%
% Carlos Jimenez 2013
%=============================================================

function vmr = mixr2vmr( mixr, molm )
  
%= molecular mass of dry air
molmd = 28.9661e-3; 

%= vmr
vmr = mixr * ( molmd / molm );

return


