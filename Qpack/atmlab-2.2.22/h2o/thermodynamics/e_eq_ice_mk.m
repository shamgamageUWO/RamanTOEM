% E_EQ_ICE_MK  Equilibrium water vapor pressure over ice using Murphy and
% Koop 2005 parameterization formula.
%
% Calculate the equilibrium water vapor pressure over a plane surface
% of ice according to http://cires.colorado.edu/~voemel/vp.html
% The formula (T in K, Ei in hPa converted) for saturation vapor pressure over water is:
% 
% (Murphy and Koop, 2005)
% Log(ew) = 54.842763 
%                - 6763.22 / T 
%                - 4.21 Log(T) 
%                + 0.000367*T 
%                + Tanh{0.0415 (T - 218.8)} 
%                *  (53.878 - 1331.22 / T - 9.44523 Log(T) + 0.014025*T
% with T in [K] and ew in [Pa]
% 
% Similarly, the equation for the saturation water vapor pressure over ice is:
% Murphy and Koop, 2005
%
% Log10(ei) = 9.550426 
%             - 5723.265/T 
%             + 3.53068 Log10(T) 
%             - 0.00728332*T
% with T in [K] and ei in [Pa]
% where:
% log stands for the logarithm in base 10
% ei is the saturation water vapor pressure over ice (hPa)
% T is the air temperature (K)
%
% References:
% Murphy, D. M. and Koop, T. (2005): Review of the vapour pressures of ice
% and supercooled water for atmospheric applications, Quarterly Journal of the 
% Royal Meteorological Society 131(608): 1539–1565. doi:10.1256/qj.04.94
%
% FORMAT   e = e_eq_ice_mk(T)
%
% OUT	   e = Equilibrium water vapor pressure over ice in [Pa].
% IN       T = Temperature in [K].

% 2011-02-16 Created by Marston Johnston

function [e] = e_eq_ice_mk(T)

if any(T <= 0), error('Temperatures must be greater than 0K!!'); end

% Give the natural log of saturation vapor pressure over ice in Pa
 e = 9.550426... 
     - 5723.265./T... 
     + 3.53068*log(T)... 
     - 0.00728332*T;

e = exp(e);

