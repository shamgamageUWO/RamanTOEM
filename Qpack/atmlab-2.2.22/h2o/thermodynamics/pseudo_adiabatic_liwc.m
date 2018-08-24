%PSEUDO_ADIABATIC_LIWC   Calculate pseudo-adabatic liquid
%                       water content and temperature
%
%          Calculates pseudo-adiabatic lwc or iwc
%          content and pseudo-adiabatic 
%          temperature following eq. 2.34
%          in R.R. Rodgers, "A short course
%          in cloud physics"  
%    
% FORMAT   [T1,xwc]=pseudo_adiabatic_liwc(T0,P0,P1,flag)
%
% IN    T0  temperature at   (scalar) [K]
%           cloudbase
%       P0  pressure at      (scalar) [Pa]
%           cloudbase
%       P1  pressure levels  (vector) [Pa]
%           above cloud-base
%       fLag tell whether to calculate the icw (1) or lwc (0)
%
% OUT   T1  temperature at   (vector) [K] 
%           P1 levels
%       lwc adiabatic liquid (vector) [kg/m3]
%           water content at
%           P1 levels
%       iwc adiabatic ice (vector) [kg/m3]
%           water content at
%           P1 levels

% example usage: 
%               T0=273;P0=87e3;
%               P1=logspace(log10(870e2),log10(300e2),20);
%               [T1,xwc]=pseudo_adiabatic_liwc(T0,P0,P1,flag)

% 2009-03-30 Created by Bengt Rydberg, Marston Johnston 

% Assumptions:
%   1. The release of latent heat when supercooled water freezes onto
%       ice is ignored. 
%   2. The process where by the liquid water evaporates is not considered
%   3. The exact point at where ice is formed is assumed to exist below 0
%       degrees. In the atmosphere this may or may not be true


function [T1,xwc]=pseudo_adiabatic_liwc(T0,P0,P1,flag)

%some checks
if length(T0)~=1
 error('T0 must be a scalar')
end
if length(P0)~=1
 error('P0 must be a scalar')
end
if ~any(size(P1)==1)
 error('P1 must be a vector')
end

Rp  = 287;               % individual gas constant for dry air
cp  = 1005;             % specific heat capacity at constant pressure 
k   = Rp/cp;
ep  = 0.622; 
Rv  = 461.5;            % individual gas constant for water vapor
Lv  = 2.5*1e6;     % Latent heat of condensation/evaporation @ 0 deg
Ls  = 2.85*1e6;       % Latent heat of sublimation/deposition
Lf  = 3.34*1e5;       % Latent heat of fusion/melting   
dp  = -10;                % small pressure change
P   = P0:dp:min(P1)+dp; % pressure grid
T   = zeros(size(P));   % temperature vector
T(1)=T0;

for i=1:length(P)

 % saturation water vapor pressure
 if flag == 0 
     es    =  e_eq_water(T(i));
 elseif flag == 1
     es    = e_eq_ice(T(i));
 else
     error('Variable for LWC/IWC flag not set');
 end
     
 % saturation mixing ratio
 ws(i) = ep*es/(P(i)-es);
 % ambient temperature change 
 if T(i) > 273 
     L = Lv; 
 else
     L = Ls; 
 end

 dT    = (k/P(i)+2*L*ws/T(i)/cp/(P(i)-es))/...
         (1/T(i)+L^2*ws*P(i)/(Rv*T(i)^3*cp*(P(i)-es)))*dp;
 T(i+1) = T(i) + dT;
end

% weight of humid air 
rho_air = (P - e_eq_water(T(1:end-1)))./Rp./T(1:end-1)+...
           e_eq_water(T(1:end-1))/Rv./T(1:end-1);

% adiabatic liquid/ice water content

awc = rho_air(1)*ws(1)-rho_air.*ws;
if flag == 1 % too warm for ice development
    awc(T>273) = 0;
end

% interpolate temperature and adaiabatic liquid water content
% on desired output levels
xwc     = interp1(log(P),awc,log(P1));
T1      = interp1(log(P),T(1:end-1),log(P1));