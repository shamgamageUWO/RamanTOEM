% E_EQ_WATER  Equilibrium water vapor pressure over liquid water
%
% Calculate the equilibrium water vapor pressure over a plane surface
% of liquid water according to Sonntag, 1994.
% 
% The coefficients for units of K for temperature and Pa for the partial
% pressure are quoted in Helten et al., 1999.  I have verified that
% these coefficients are consistent with the ones given in Leiterer et
% al., 1997, with the only difference that the ones in the Leiterer et
% al. paper are for partial pressure in units of hPa.
%
% The temperature of 0C corresponds to 273.15K. (Not 273.16K, as stated
% in the Leiterer paper.)
% 
% The formula (T in K, Ew in Pa):
% 
% Ew(T) = exp[ a/T + b + cT + dT^2 + e ln(T) ]
%
% References:
% 
% Sonntag, D., Advancements in the field of hygrometry, Meteorologische
% Zeitschrift, 3, 51-66, 1994.
% 
% Helten, M. et al, In-flight comparison of MOZAIC and POLINAT water
% vapor measurements, JGR, 104, 26.087-26.096, 1999.
% 
% Leiterer U. et al, Improvements in Radiosonde Humidity Profiles Using
% RS80/RS90 Radiosondes of Vaisala, Beitr. Phys. Atmosph., 70(4),
% 319-336, 1997. 
%
% FORMAT   ew = e_eq_water(T)
%
% OUT	   ew = Equilibrium water vapor pressure in [Pa].
% IN       T  = Temperature in [K].

% 2003-03-28 Created by Stefan Buehler

function ew = e_eq_water(T)

% Coefficients for Ew:
a = -6096.9385;
b = 21.2409642;
c = -2.711193e-2;
d = 1.673952e-5;
e = 2.433502;

ew = exp( a./T + b + c*T + d*T.^2 + e*log(T) );
