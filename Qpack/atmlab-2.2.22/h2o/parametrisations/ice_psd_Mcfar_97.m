% ice_psd_Mcfar_97 returns the particle size distribution in cirrus clouds.
%    
%     Returns a vector with the particle size distribution for
%     a given temperature and ice water content, for a tropical cirrus cloud.
%     The parameterization is based upon the distribution of mass equivalent
%     spheres with diameter Dm=(6M/(pi*rhoice))^(1/3), 
%     where rhoice is the density
%     of solid ice spheres, and M is the mass of the ice crystal. The
%     parameterization can be applied over all sizes. 
%     The particle size distribution is a bimodal distribution,
%     and with the input "mode" there is an option of which mode
%     that will be returned.
%
%     The parameterization is taken from G.M McFarquhar and A.J Heymsfield,
%     "Parameterization of tropical cirrus ice crystal size distribution
%     and implications for radiative transfer: results from CEPEX",
%     J. Atmos. Sci., 54, 2187-2200, 1997
%
% FORMAT   [y] = ice_psd_Mcfar_97(T,IWC,D,mode)     
%
% OUT      y is a vector with the particle size distribution [#/m^3/m]
%
% IN       T     Temperature [Kelvin]
%          IWC   Ice water content [g/m^3]
%          D     the size vector of the ice particles,
%                (the mass equivalent sphere diameter [m]),
%                where the concentration will be calculated  
%          mode  1=both small and large mode
%                2=only small mode
%                3=only large mode
%
% History: 2004-07-19  Created by Bengt Rydberg

function [y]=ice_psd_Mcfar_97(T,IWC,D,mode);


T=T-273.15;

if T>0
   error('Only temperatures less than 273.15 K are allowed.')
end
if ((mode~=1) && (mode~=2) && (mode~=3))
   error('Only mode 1,2, or 3 are allowed.')
end

D=1e6*D; %micron

a=0.252; %g/m^3
b=0.837;
IWC0=1; %g/m^3
IWCs100=min(IWC,a*(IWC/IWC0)^(b));
IWCl100=IWC-IWCs100;
rhoice=0.91*1e6; %g/m^3

%Gamma distribution component

b=-4.99*1e-3;m=0.0494;
alfas100=(b-m*log10(IWCs100/IWC0)); %miron^-1
Ns100=6*IWCs100*alfas100^(5)/(pi*rhoice*gamma(5)); %micron^-5
Nm1=Ns100*D.*exp(-alfas100*D); %micron^-4


%Log normal distribution component

aamu=5.20;
bamu=0.0013;
abmu=0.026;
bbmu=-1.2*1e-3;
amu=aamu+bamu*T; 
bmu=abmu+bbmu*T;
mul100=amu+bmu*log10(IWCl100/IWC0);

aasigma=0.47;
basigma=2.1*1e-3;
absigma=0.018;
bbsigma=-2.1*1e-4;
asigma=aasigma+basigma*T;
bsigma=absigma+bbsigma*T;
sigmal100=asigma+bsigma*log10(IWCl100/IWC0);

D0=1.0; %micron

a1=6*IWCl100; %g/m^3
a2=pi^(3/2)*rhoice*sqrt(2)*exp(3*mul100+9/2*sigmal100^(2))*sigmal100*D0^(3);
%g/m^3/micron^3
Nm2=a1/a2./D.*exp(-1/2*((log(D/D0)-mul100)/sigmal100).^(2)); %micron^-4

%convert to m^-4
Nm1=Nm1*1e24; 
Nm2=Nm2*1e24;

if mode==1
   y=Nm1+Nm2;
end

if mode==2
   y=Nm1;
end
 
if mode==3
   y=Nm2;
end

