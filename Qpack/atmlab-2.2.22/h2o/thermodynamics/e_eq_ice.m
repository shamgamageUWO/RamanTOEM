% E_EQ_ICE  Equilibrium water vapor pressure over ice
%
% Calculate the equilibrium water vapor pressure over a plane surface
% of ice according to Sonntag, 1994.
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
% The formula (T in K, Ei in Pa):
% 
% Ei(T) = exp[ a/T + b + cT + dT^2 + e ln(T) ]
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
% FORMAT   ei = e_eq_ice(T)
%
% OUT	   ei = Equilibrium water vapor pressure in [Pa].
% IN       T  = Temperature in [K].

% 2003-03-28 Created by Stefan Buehler

function ei = e_eq_ice(T)

% Coefficients for Ei:
a = -6024.5282;
b = 29.32707;
c = 1.0613868e-2;
d = -1.3198825e-5;
e = -0.49382577;

ei = exp( a./T + b + c*T + d*T.^2 + e*log(T) );
