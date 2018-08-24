function vmr = relhum_to_vmr(rh, T, p)  
% relhum_to_vmr converts relative humidity to volume mixing ratio vmr
%
%   vmr mixing ratio is the volume mixing ratio of particles of water vapour,  
%   per particles of dry air at a given pressure. It can be expressed
%   using water vapor pressure and air pressure.
%
% FORMAT    vmr = relhum_to_vmr(rh, T, p)
%        
% OUT   vmr volume mixing ratio []
% IN    rh  relative humidity [%, rh > 0], it can be a scalar or a tensor
%       T   air temperature [K], it can be a scalar or a tensor
%       p   air pressure [Pa], it can be a scalar or a tensor
% EXAMPLE:
%       vmr = relhum_to_vmr(50, 298, 100000)
%       vmr = 0.0157
%
% ACCURACY: WATER_VAPOR_MIXING_RATIO calculates water vapor mixing ratio
%           according to thermodynamic functions without any assumptions.
%
% Reference: PhD thesis Mathis Milz, p 9 
%
% 2012-10-02   Created by Mathias Milz

es = e_eq_water(T);
e = rh .* es ./ 100;
vmr = e ./ p;
  