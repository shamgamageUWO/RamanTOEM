% ice_psd_ellipsoids  translates particle size distribution for a given
%                     particle size distribution into a distribution of
%                     mass equivalent ellipsoids in cirrus clouds,
%                     and returns the new distribution.
%    
%     Returns a vector with the particle size distribution 
%     for a given temperature, ice water content, and particle
%     size distribution, for a cirrus cloud.
%     The ellipsoids "diameters" are D,Da,Db, where D is the
%     major diameter,Da/D=a, and Db/D=b.   
%     This function takes a given exponential or gamma bimodal size 
%     distribution, which is based on the assumption of a certain
%     habit of the ice crystals, and by using mass - diameter relations,
%     translates the distribution into an exponential or gamma bimodal
%     size distribution of mass equivalent ellipsoids.
%     The particle size distributions are  bimodal distributions,
%     and with the input "mode" there is an option of which mode
%     that will be returned.
%     
% 
%     The mass - diameter relations are taken from Donovan 
%     "Ice cloud effective particle size parameterization based
%     on combined lidar, radar reflectivity, and mean Doppler
%     velocity measurements"
%     J. of Geophys. res., vol. 108, NO. D18, 4573, 2003
% 
%     and Mitchell
%     "Use of mass and area dimensional power laws for determining
%     precipitation particle terminal velocities"
%     J. of Atm. Sci., vol 53, No. 12, 1710-1723, 1996
%    
% FORMAT   [y] = ice_psd_ellipsoids(T,IWC,D,a,b,psd,mode)     
%
% OUT      y is a vector with the particle size distribution [#/m^3/m]
%
% IN       T     Temperature [Kelvin]
%          IWC   Ice water content [g/m^3]
%          D     the size vector of the ice particles,
%                (the mass equivalent ellipsoid diameter [m]),
%                where the concentration will be calculated        
%          a     Aspect ratio 0<a<=1 
%          b     Aspect ratio 0<b<=1 (a=b=1 for spheres)
%          psd   The specific particle size distribution
%                one wants to translate
%                1=ice_psd_Donovan_03(complex polycrystals) 
%                2=ice_psd_Donovan_03(compact polycrystals)
%                3=ice_psd_Ivanova_01(planar polycrystals)
%                4=ice_psd_Ivanova_01(bullet rosettes)
%                5=ice_psd_Ivanova_01(hexagonal plates)
%                6=ice_psd_Ivanova_01(hexagonal columns)
%                7=ice_psd_Mitchell_99(planar polycrystals)
%          mode  1=both small and large mode
%                2=only small mode
%                3=only large mode
% 
% History: 2004-07-19  Created by Bengt Rydberg

function [y]=ice_psd_ellipsoids(T,IWC,D,a,b,psd,mode);


if T>273.15
   error('Only temperatures smaller or equal to 273 K zero are allowed.')
end
if a<=0
error('Only aspect ratio a larger than zero is allowed.')
end
if a>1
   error('Only aspect ratio a equal or smaller to one is allowed.')
end
if b<=0
   error('Only aspect ratio b larger than zero is allowed.')
end
if b>1
   error('Only aspect ratio b equal or smaller to one is allowed.')
end
if ((psd~=1) && (psd~=2) && (psd~=3) && (psd~=4) && (psd~=5) && (psd~=6) && (psd~=7))
   error('Only psd 1,2,3,4,5,6, and 7 are allowed.')
end
if ((mode~=1) && (mode~=2) && (mode~=3))
   error('Only mode 1,2, or 3 are allowed.')
end

if psd==1
   %complex polycrystals
   alfa1=102400;beta1=2.88;
   alfa2=32900;beta2=2.88;
   alfap2=6.94;betap2=1.88;
end
if psd==2
   %compact polycrystals
   alfa1=88800;beta1=2.88;
   alfa2=20000;beta2=2.88;
   alfap2=6.90;betap2=1.88;
end
if (psd==3 | psd==7)
   %planar polycrystals
   alfa1=36000;beta1=2.897;
   alfa2=587;beta2=2.45;
   alfap2=0;betap2=0;
end
if psd==4
   %bullet rosettes
   alfa1=8220;beta1=2.75;
   alfa2=alfa1;beta2=beta1;
   alfap2=0;betap2=0;
end
if psd==5
   %hexagonal plates
   alfa1=587;beta1=2.45;
   alfa2=alfa1;beta2=beta1;
   alfap2=0;betap2=0;
end
if psd==6
   %hexagonal columns
   alfa1=111000;beta1=2.91;
   alfa2=11.0;beta2=1.91;
end

rho=0.91*1e6;

if (psd==1 | psd==2) 
   D11=linspace(1.01e-4,1e-3,1000);
   D22=(6/pi/rho/a/b*(alfa2*D11.^beta2+alfap2*D11.^betap2)).^(1/3);
   ypol=polyfit(D22,D11,2);
end

f1_D2= (rho*pi*a*b/6/alfa1*D.^3).^(1/beta1);

if (psd==1 | psd==2)
    f2_D2=ypol(3)+ypol(2)*D+ypol(1)*D.^2;
else 
    f2_D2= (rho*pi*a*b/6/alfa2*D.^3).^(1/beta2);
end

s=length(D);
for i=1:s
    if f2_D2(i)<0
       f2_D2(i)=0;
    end
end

if psd==1
   [y1]=ice_psd_Donovan_03(T,IWC,f1_D2,1,2);
   [y2]=ice_psd_Donovan_03(T,IWC,f2_D2,1,3);
end
if psd==2
   [y1]=ice_psd_Donovan_03(T,IWC,f1_D2,2,2);
   [y2]=ice_psd_Donovan_03(T,IWC,f2_D2,2,3);
end
if psd==3
   [y1]=ice_psd_Ivanova_01(T,IWC,f1_D2,1,2);
   [y2]=ice_psd_Ivanova_01(T,IWC,f2_D2,1,3);
end
if psd==4
   [y1]=ice_psd_Ivanova_01(T,IWC,f1_D2,2,2);
   [y2]=ice_psd_Ivanova_01(T,IWC,f2_D2,2,3);
end
if psd==5
   [y1]=ice_psd_Ivanova_01(T,IWC,f1_D2,3,2);
   [y2]=ice_psd_Ivanova_01(T,IWC,f2_D2,3,3);
end
if psd==6
   [y1]=ice_psd_Ivanova_01(T,IWC,f1_D2,4,2);
   [y2]=ice_psd_Ivanova_01(T,IWC,f2_D2,4,3);
end
if psd==7
   [y1]=ice_psd_Mitchell_99(T,IWC,f1_D2,2);
   [y2]=ice_psd_Mitchell_99(T,IWC,f2_D2,3);
end

df1_dD2=3/beta1*(pi*rho*a*b/6/alfa1)^(1/beta1)*D.^(3/beta1-1); 

if (psd==1 | psd==2)
   df2_dD2=ypol(2)+2*ypol(1)*D;
else
   df2_dD2=3/beta2*(pi*rho*a*b/6/alfa2)^(1/beta2)*D.^(3/beta2-1);
end

ya=y1.*df1_dD2;
yb=y2.*df2_dD2;

if mode==1
   y=ya+yb;
end

if mode==2
   y=ya;
end
 
if mode==3
   y=yb;
end






