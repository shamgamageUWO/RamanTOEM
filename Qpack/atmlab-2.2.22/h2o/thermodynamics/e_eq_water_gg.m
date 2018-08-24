% E_EQ_WATER_GG  Equilibrium water vapor pressure over ice
%
% Calculate the equilibrium water vapor pressure over a plane surface
% of ice according to http://en.wikipedia.org/wiki/Goff-Gratch_equation
% The formula (T in K, Ei in hPa):
%
% The original Goff–Gratch (1946) equation reads as follows:
%  
% Log10(ew) = -7.90298 (Tst/T-1)
%             + 5.02808 Log10(Tst/T) 
%             - 1.3816 10-7 (1011.344 (1-T/Tst)  -1) 
%             + 8.1328 10-3 (10-3.49149 (Tst/T-1)  -1) 
%             + Log10(e_st) 	
%	
% where:
% Log10 refers to the logarithm in base 10
% ew is the saturation water vapor pressure (hPa)
% T is the absolute air temperature in kelvins
% Tst is the steam-point (i.e. boiling point at 1 atm.) temperature (373.16 K)
% e_st is ew at the steam-point pressure (1 atm = 1013.25 hPa)
%
% References:
% http://en.wikipedia.org/wiki/Goff-Gratch_equation
% Goff, J. A., and S. Gratch (1946) Low-pressure properties of water from −160 
% to 212 °F, in Transactions of the American Society of Heating and Ventilating
% Engineers, pp 95–122, presented at the 52nd annual meeting of the American 
% Society of Heating and Ventilating Engineers, New York, 1946.
% Goff, J. A. (1957) Saturation pressure of water on the new Kelvin temperature scale,
% Transactions of the American Society of Heating and Ventilating Engineers, pp 
% 347–354, presented at the semi-annual meeting of the American Society of Heating 
% and Ventilating Engineers, Murray Bay, Que. Canada.
% World Meteorological Organization (1988) General meteorological standards and 
% recommended practices, Appendix A, WMO Technical Regulations, WMO-No. 49.
% World Meteorological Organization (2000) General meteorological standards and 
% recommended practices, Appendix A, WMO Technical Regulations, WMO-No. 49, corrigendum.
% Murphy, D. M. and Koop, T. (2005): Review of the vapour pressures of ice
% and supercooled water for atmospheric applications, Quarterly Journal of the 
% Royal Meteorological Society 131(608): 1539–1565. doi:10.1256/qj.04.94
%
% FORMAT   e = e_eq_water_gg(T)
%
% OUT	   e = Equilibrium water vapor pressure over water in [Pa].
% IN       T = Temperature in [K].

% 2010-08-18 Created by Marston Johnston

function [es] = e_eq_water_gg(T)

if any(T <= 0), error('Temperatures must be greater than 0K!!'); end

Tst  = 373.16;  % K
est = 1013.25; % hPa
a = -7.90298;
b = 5.02808;
c = -1.3816*10^(-7);
d = 11.344;
f = 8.1328*10^(-3);
h = -3.49149;

% Gives the log of saturation vapor pressure over water in hPa
Z = a*((Tst./T)-1) + b*log10(Tst./T) + c*((10.^(d*(1-(T/Tst))))-1) + f*((10.^(h*((Tst./T)-1)))-1);
es = (est*10.^Z)*1e2; % convert to Pa
