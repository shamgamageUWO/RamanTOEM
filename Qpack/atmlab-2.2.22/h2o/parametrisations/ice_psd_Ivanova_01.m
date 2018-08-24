% ice_psd_Ivanova_01 returns the particle size distribution in cirrus clouds.
%    
%     Returns a vector with the particle size distribution 
%     for a given temperature, ice water content, and shape
%     for a mid-latitude cirrus cloud. 
%     This parameterization is based on the distribution
%     of maximum dimension of the particle shapes, and are based on 
%     measurements of ice crystals in the range 10^-6 m to 10^-3 m.  
%     The particle size distribution is a bimodal gamma distribution,
%     and with the input "mode" there is an option of which mode
%     that will be returned.
%    
%     The parameterization is taken from Ivanova et al.
%     "A GCM parameterization for bimodal size spectra and ice mass 
%     removal rates in mid-latitude cirrus clouds"
%     Atmospheric Research 59-60, 89-113, 2001
%     
% FORMAT   [y] = ice_psd_Ivanova_01(T,IWC,D,shape,mode)     
%
% OUT      y is a vector with the particle size distribution [#/m^3/m]
%
% IN       T     Temperature [Kelvin]
%          IWC   Ice water content [g/m^3]
%          D     the vector with the maximum dimension of
%                the ice particles [m],
%                where the concentration will be calculated
%          shape 1=planar polycrystals
%                2=bulett rosettes
%                3=hexagonal plates
%                4=hexagonal columns
%          mode  1=both large and small mode
%                2=only small mode
%                3=only large mode     
%
% History: 2004-07-19  Created by Bengt Rydberg

function [y]=ice_psd_Ivanova_01(T,IWC,D,shape,mode);

T=T-273.15;

if T>0
   error('Only temperatures smaller than 273.15 K are allowed.')
end

if ((shape~=1) && (shape~=2) && (shape~=3) && (shape~=4))
   error('Only shape 1,2,3,or 4 are allowed.')
end

if ((mode~=1) && (mode~=2) && (mode~=3))
   error('Only mode 1,2, or 3 are allowed.')
end

D=1e6*D; %micron

musm=3.24;
mulg=2.64;
Dsm=27.4; %micron
lambdasm=(musm+1)/Dsm;
Dlg=337.7*exp(0.01754*T); %micron
lambdalg=(mulg+1)/Dlg;

if shape==1
   %constants for planar polycrystals
   alfa1=36000;beta1=2.897;
   alfa2=587;beta2=2.45;
   IWCsmn=0.11+0.89*exp(-(Dlg/50)^2);
end

if shape==2
   %constants for bulett rosettes
   alfa1=8220;beta1=2.75;
   alfa2=alfa1;beta2=beta1;
   L=-0.00009524*Dlg+0.1200;
   IWCsmn=L+(1-L)*exp(-(Dlg/45)^2);
end

if shape==3
   %constants for hexagonal plates
   alfa1=587;beta1=2.45;
   alfa2=alfa1;beta2=beta1;   
   IWCsmn=0.11+0.89*exp(-(Dlg*1e6/50)^2);
end

if shape==4
   %constants for hexagonal columns
   alfa1=111000;beta1=2.91;
   alfa2=11.0;beta2=1.91;
   L=0.0009722*Dlg-0.05833;
   IWCsmn=L+(1-L)*exp(-(Dlg/85)^2);
end

IWClgn=1-IWCsmn;
IWCsm=IWC*IWCsmn; %g/m^3
IWClg=IWC*IWClgn; %g/m^3

Nosm=IWCsm*(lambdasm*1e6)^(beta1+musm+1)/(alfa1*gamma(beta1+musm+1)); 
Nolg=IWClg*(lambdalg*1e6)^(beta2+mulg+1)/(alfa2*gamma(beta2+mulg+1));

Nmsm=Nosm*(1e-6*D).^(musm).*exp(-lambdasm*D); %m^-4
Nmlg=Nolg*(1e-6*D).^(mulg).*exp(-lambdalg*D); %m^-4

if mode==1
   y=Nmsm+Nmlg;
end
if mode==2
   y=Nmsm;
end
if mode==3
   y=Nmlg;
end
