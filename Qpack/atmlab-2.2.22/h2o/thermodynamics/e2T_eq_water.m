function T = e2T_eq_water(ew)
% E2T_EQ_WATER  estimates temperature from equilibrium water vapor pressure
%               over liquid water
%
% Calculate the temperature from equilibrium water vapor pressure over
% a plane surface of liquid water according to Sonntag, 1994. For details
% see the <e_eq_water>.
% 
% The temperature of 0C corresponds to 273.15K. (Not 273.16K, as stated
% in the Leiterer paper.)
% 
% The Sonntag method is to estimate ew from temperaure as follows:
% ei(T) = exp[ a/T + b + cT + dT^2 + e Ln(T) ]
% for the temperatures range between -100 and 100 C, Ln(T) ranges
% between 5.1542 and 5.922. The mean value of Ln(T) which is for T = 273.15
% is equal to 5.61. First, the mean value of Ln(T) is used to help to solve
% the equation analytically. Matlab function 'toots' is used to calculate
% roots of the resulted function. 
% In normal range of the temperature, estimated T differs about 5 K but
% outside this range the difference is much more. In the next step, a loop 
% is used to adjust T.
%
% FORMAT   T = e2T_eq_water(ew)
%
% OUT	T  = Temperature in [K]. 
% IN    ew = Equilibrium water vapor pressure in [Pa].
%            It must be a scalar.
%
% EXAMPLE:
%       T = e2T_eq_water(1500)
%       Te = 286.1712
%
% ACCURACY: The accuracy was checked using e_eq_water(T). I calculated ew
% using e_eq_water for a given T then used ew as input of this function and
% afterwards compared the output of this function to the original T:
% T1 = [150:0.1:370]
% ew = e_eq_water(T1)
% for i=1:1:length(T1), T2(i) = e2T_eq_water(ew(i)); end
% max(abs(T2 - T1)) = 0.0086
% min(abs(T2 - T1)) = 3.6522e-04
% mean(abs(T2 - T1)) = 0.0027
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
% 2009-08-27 Created by Isaac Moradi

% Coefficients for Ew:
a = -6096.9385;
b = 21.2409642;
c = -2.711193e-2;
d = 1.673952e-5;
e = 2.433502;

% set initial temperature as 273.15
T = 273.15;
T1 = T - 100; % just to allow loop to start

% continue the loop until the difference between the temperatures calculated
% at two consequent steps is less than 0.05 K
while abs(T1 - T) > 0.05    
    T1 = T;
    % calculate coefficients of the cubic function
    f = e .* log(T1) + b - log(ew);

    % coefficients for the cubic function which is
    % d .* ew^3 + c  .* ew^2 + f .* ew + a
    p = [d c f a];

    % roots of the mentioned cubic function
    T = roots(p);

    % pick the real number
    T = T(3);
end

