% MPM_IWC93_LWC93_RAIN89   Complex refractivity for IWC, LWC and rain.
%
%    Returns the complex refractivity following MPM93 for ice water and
%    liquid water, and MPM89 for rain. 
%
%    Parameter values for rain rates > 25 mm/h are derived by Christian
%    Melsheimer from the Olsen 1978 paper.
%
% FORMAT   [nr,alpha] = mpm_iwc93_lwc93_rain89(iwc,lwc,rain,v,t)
%
% OUT      nr     Real part of refractivity [-] (a value just above 1).
%          alpha  Absorption [1/m]
% IN       iwc    Ice water content [g/m3]
%          lwc    Liquid water content [g/m3]
%          rain   Rain rate [mm/h]    
%          v      Frequency [Hz]
%          t      Temperature [K]

% HISTORY: 2003-03-09  Created by Patrick Eriksson


function [nr,alpha] = mpm_iwc93_lwc93_rain89(iwc,lwc,rain,v,t)


if v < 1e9  |  v > 1000e9
  error('This function is only valid for 1 -1000 GHz.');
end


%=== Local variables
%
theta = 300 / t;
v_ghz = v/1e9;


N = 0;


%=== Ice water
%
if iwc < 0
  error('Negativ IWC is not allowed.');
elseif iwc > 10
  error('IWC > 10 g/m3 is not allowed.');
elseif iwc > 0
  eps = eps_ice_liebe93(v,t);
  N   = N + iwc*(1.5/0.916)*(eps-1)/(eps+2);
end



%=== Liquid water
%
if lwc < 0
  error('Negativ LWC is not allowed.');
elseif lwc > 5
  error('LWC > 5 g/m3 is not allowed.');
elseif lwc > 0
  eps = eps_water_liebe93(v,t);
  N   = N + lwc*1.5*(eps-1)/(eps+2);
end



%=== Rain
%
if rain < 0
  error('Negativ rain rate is not allowed.');
elseif rain > 0
  %
  if rain <= 25
    %
    if v_ghz <= 2.9
      x1 = 3.51e-4;   y1 = 1.03;
    elseif v_ghz <= 54
      x1 = 2.31e-4;   y1 = 1.42;
    elseif v_ghz <= 180
      x1 = 0.225;     y1 = -0.301;
    else
      x1 = 18.6;      y1 = -1.151;
    end
    %
    if v_ghz <= 8.5
      x2 = 0.851;     y2 = 0.158;
    elseif v_ghz <= 25
      x2 = 1.41;      y2 = -0.0779;
    elseif v_ghz <= 164
      x2 = 2.63;      y2 = -0.272;
    else
      x2 = 0.616;     y2 = 0.0126;
    end
    %
  else   % rain rate > 25 mm/h
    if v > 100e9
      error('Frequencies > 100 GHz and rain rates > 25 mm/h are not handled.');
    end
    %
    if v_ghz <= 4.9
      x1 = 2.91e-4;   y1 = 0.871;
    elseif v_ghz <= 10.7
      x1 = 2.76e-5;   y1 = 2.349;
    elseif v_ghz <= 40.1
      x1 = 1.39e-4;   y1 = 1.668;
    elseif v_ghz <= 59.1
      x1 = 1.96e-2;   y1 = 0.326;
    else
      x1 = 0.785;     y1 = -0.578;
    end
    %
    if v_ghz <= 6.2
      x2 = 0.911;     y2 = 0.190;
    elseif v_ghz <= 23.8
      x2 = 1.71;      y2 = -0.156;
    elseif v_ghz <= 48.4
      x2 = 3.08;      y2 = -0.342;
    elseif v_ghz <= 68.2
      x2 = 1.28;      y2 = -0.116;
    else
      x2 = 0.932;     y2 = -4.08e-2;
    end
    %    
  end

  fr  = 53 - rain * ( 0.37 - 0.0015 * rain );
  y25 = (v_ghz/fr)^2.5;
  %
  N = N + ...
          rain * ( 3.7 - 0.012*rain ) * ( 1- y25/( 1 + y25 ) ) / fr +...
          i*x1*v_ghz^y1 * rain^( x2*v_ghz^y2 );
end



%=== Unit conversions
%
nr = 1 + 1e-6 * real( N );  % ppm -> -
%
alpha = 0.182 * v_ghz * imag( N );   % dB/km
alpha = 1e-4 * log(10) * alpha;      % 1/m


%alpha = 4 * pi * v * nc/1e6 / constants('SPEED_OF_LIGHT');


