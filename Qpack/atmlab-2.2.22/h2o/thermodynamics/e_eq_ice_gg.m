% E_EQ_ICE_GG  Equilibrium water vapor pressure over ice
%
% Calculate the equilibrium water vapor pressure over a plane surface
% of ice according to http://en.wikipedia.org/wiki/Goff-Gratch_equation
% The formula (T in K, Ei in hPa converted):
% 
% 
% Similarly, the equation for the saturation water vapor pressure over ice is:
%
% Log10(ei) = -9.09718 (273.16/T - 1)                                          
%             - 3.56654 Log10(273.16/ T) 
%             + 0.876793 (1 - T/ 273.16) 
%             + Log10(ei0) 
% where:
% log stands for the logarithm in base 10
% ei is the saturation water vapor pressure over ice (hPa)
% T is the air temperature (K)
% T0 is the ice-point (triple point) temperature (273.16 K)
% ei0 is e* at the ice-point pressure (6.1173 hPa)
%
% References:
% http://en.wikipedia.org/wiki/Goff-Gratch_equation
% Goff, J. A., and S. Gratch (1946) Low-pressure properties of water from −160 
% to 212 °F, in Transactions of the American Society of Heating and Ventilating 
% Engineers, pp 95–122, presented at the 52nd annual meeting of the American
% Society of Heating and Ventilating Engineers, New York, 1946.
% Goff, J. A. (1957) Saturation pressure of water on the new Kelvin temperature 
% scale, Transactions of the American Society of Heating and Ventilating Engineers,
% pp 347–354, presented at the semi-annual meeting of the American Society of 
% Heating and Ventilating Engineers, Murray Bay, Que. Canada.
% World Meteorological Organization (1988) General meteorological standards and 
% recommended practices, Appendix A, WMO Technical Regulations, WMO-No. 49.
% World Meteorological Organization (2000) General meteorological standards and
% recommended practices, Appendix A, WMO Technical Regulations, WMO-No. 49, corrigendum.
% Murphy, D. M. and Koop, T. (2005): Review of the vapour pressures of ice
% and supercooled water for atmospheric applications, Quarterly Journal of the 
% Royal Meteorological Society 131(608): 1539–1565. doi:10.1256/qj.04.94
%
% FORMAT   e = e_eq_ice_gg(T)
%
% OUT	   e = Equilibrium water vapor pressure over ice in [Pa].
% IN       T = Temperature in [K].

% 2010-08-18 Created by Marston Johnston

function [esi] = e_eq_ice_gg(T)

if any(T <= 0), error('Temperatures must be greater than 0K!!'); end

T0  = 273.16;  % K
e0 = 6.1071; % hPa
a = -9.09718;
b = -3.56654;
c = 0.876793;

% Give the log of saturation vapor pressure over ice in hPa
X = a*((T0./T)-1) + b*log10(T0./T) + c*(1-(T/T0));

esi = (e0*10.^X)*1e2; % Converts to Pa
