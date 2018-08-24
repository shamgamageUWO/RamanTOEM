%SPHERE_PART_FALLSPEED   Calculate spherical particle fallspeed in air
%
%          Calculates spherical particles fallspeed
%          according to R.R. Rogers, "A short course
%          in cloud physics"
%    
% FORMAT   [u]=sphere_part_fallspeed(r,T,P)
%
% IN    r   particle radius  (vector) [m]
%       T   temperature      (scalar) [K], allowed range is [233.15,303.15]
%       P   pressure         (scalar) [Pa]
%
% OUT   u   fallspeed       [m/s]
%         
% example usage: 
%               r=[30 50 100 1000]*1e-6;
%               T=290;P=1e5;
%               [u]=sphere_part_fallspeed(r,T,P)

% 2009-03-30 Created by Bengt Rydberg 

function [u]=sphere_part_fallspeed(r,T,P)

%some checks
if T<-40+273.15 | T>273.15+30 & min(r)<=40e-6 
  error('Temperature out of range!!!T must be inside (233.15-303.15)') 
end

if length(T)>1
  error('T must be a scalar!!!')
end

if length(P)>1
  error('P must be a scalar!!!')
end

%dynamic viscosity of air (variation with temperature)
muvec  = [1.512 1.564 1.616 1.667 1.717 1.766 1.815 1.862]*1e-5;
Tvec   = [-40:10:30]+273.15;
mu     = interp1(Tvec,muvec,T);

rhol   = 1e3;    %density of water
Rp     = 287;    %individual gas constant of dry air  
rho_air= P/Rp/T; %density of air 
rho0=1.2;        %reference density of air

%loop over particle sizes
for i=1:length(r)

 if r<=40e-6
  u(i)=2/9*9.81*rhol/mu*r(i)^2;
 elseif r>40e-6 & r<=0.6e-3
  u(i)=8e3*r(i);
 else
  u(i)=2.2e3*sqrt(rho0/rho_air*r(i)*1e2)/1e2;
 end

end