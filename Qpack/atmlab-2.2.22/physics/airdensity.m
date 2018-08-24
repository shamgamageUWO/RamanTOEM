%=============================================================
% vmr = mixr2vmr(mixr,molm)
%
% Calculates air density by trivial application of the
% ideal gas law 
%  
% Input:    p      atmospheric pressure [Pa]
%           t      absolute temperature [K]
%
% Output:   rho    air density  [Kg/m3]
%
% Carlos Jimenez 2014-02-12
%=============================================================


function rho = airdensity(p,t);

Rsp = constants('GAS_CONST_DRY_AIR');  % Jkg^{-1}K^{-1}

rho = p ./ ( Rsp * t );   %  

return
