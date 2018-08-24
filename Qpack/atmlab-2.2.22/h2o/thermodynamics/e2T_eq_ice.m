function T = e2T_eq_ice(ei)
% E2T_EQ_ICE estimates temperature from equilibrium water vapor pressure
%            over ice
%
% Calculate the equilibrium water vapor pressure over a plane surface
% of ice according to Sonntag, 1994. For details see the <e_eq_ice>.
% 
% The temperature of 0C corresponds to 273.15K. (Not 273.16K, as stated
% in the Leiterer paper.)
%  
% The Sonntag method is to estimate ei from temperaure as follows:
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
% FORMAT   T = e2T_eq_ice(ei)
%
% OUT	T  = Temperature in [K]. 
% IN    ei = Equilibrium water vapor pressure in [Pa].
%            It must be a scalar.
%
% EXAMPLE:
%       T = e2T_eq_ice(1500)
%       Te = 284.5150
%
% ACCURACY: The accuracy was checked using e_eq_ice(T). I calculated ei
%           using e_eq_ice for a given T then used ei as input of e2T_eq_ice and
%           afterwards compared the output of this function to the original T:
%           T1 = [150:0.1:370]
%           ei = e_eq_ice(T1)
%           for i=1:1:length(T1), T2(i) = e2T_eq_ice(ei(i)); end
%           max(abs(T2 - T1)) = 0.0014
%           min(abs(T2 - T1)) = 2.3542e-05
%           mean(abs(T2 - T1)) = 2.9150e-04
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

% Coefficients for Ei:
a = -6024.5282;
b = 29.32707;
c = 1.0613868e-2;
d = -1.3198825e-5;
e = -0.49382577;

% set initial temperature as 273.15
T = 273.15;
T1 = T - 100; % just to allow loop to start

% continue the loop until the difference between the temperatures calculated
% at two consequent steps is less than 0.05 K
while abs(T1 - T) > 0.05    
    T1 = T;
    % calculate coefficients of the cubic function
    f = e .* log(T1) + b - log(ei);

    % coefficients for the cubic function which is
    % d .* ei^3 + c  .* ei^2 + f .* ei + a
    p = [d c f a];

    % roots of the mentioned cubic function
    T = roots(p);

    % pick the real number
    T = T(3);
end

