% ice_psd_Heyms_84 returns the particle size distribution in cirrus clouds.
%    
%     Returns a vector with the particle size distribution 
%     for a given temperature, for a mid-latitude cirrus cloud.
%     This parameterisation is based on the temperature averaged 
%     distribution of maximum dimension of ice particles, and the
%     temperature averaged observed ice water content. The range 
%     of the dimension of the particles for this parameterization
%     is from 20*10^-6 m to 3*10^-3 m 
%
%     This parameterisation is taken from Heymsfield and Platt,
%     "A parameterization of the particle size spectrum of ice clouds
%     in terms of the ambient temperature and ice water content"
%     J. Atmos. Sci., vol.41, No.5, 846-855, 1984
%
% FORMAT   [y] = ice_psd_Heyms_84(T,D)     
%
% OUT      y is a vector with the particle size distribution [#/m^3/m]
%  
% IN       T    Temperature [Kelvin]
%          D    the vector with the maximum dimension of
%               the ice particles [m],
%               where the concentration will be calculated


% History: 2004-07-19  Created by Bengt Rydberg


function [y]=ice_psd_Heyms_84(T,D)

T=T-273.15;

if T>-20
   error('Only temperatures below or equal to -253.15  are allowed')
end
if T<-60
   error('Only temperatures larger than or equal to -213.15 K are allowed')
end
if D(1)<20*1e-6
   error('Only Dmin larger than 20*1e-6 m is allowed')
end
if D(end)>3*1e-3
   error('Only Dmax smaller that 3*1e-3 m is allowed')
end
if T<=-20 & T>-25
   IWCmean=0.027;
   N100_IWC=5.17*1e3;B1=-2.56;N1000_IWC=12.0;B2=-3.74;
   elseif T<=-25 & T>-30
      IWCmean=0.025;      
      N100_IWC=7.00*1e3;B1=-2.51;N1000_IWC=10.4;B2=-4.49;
   elseif T<=-30 & T>-35
      IWCmean=0.0175;
      N100_IWC=7.43*1e3;B1=-2.21;N1000_IWC=13.7;B2=-3.94;
   elseif T<=-35 & T>-40
      IWCmean=0.0126;
      N100_IWC=1.98*1e4;B1=-2.29;N1000_IWC=10.3;B2=-4.37;
   elseif T<=-40 & T>-45
      IWCmean=0.0034;
      N100_IWC=7.50*1e3;B1=-3.23;N1000_IWC=4.86;B2=-3.23;
   elseif T<=-45 & T>-50
      IWCmean=0.0025;
      N100_IWC=5.60*1e3;B1=-3.15;N1000_IWC=4.00;B2=-3.15;
   elseif T<=-50 & T>-55
      IWCmean=0.0018;
      N100_IWC=3.89*1e3;B1=-3.83;N1000_IWC=0.86;B2=-3.83;
   elseif T<=-55 &T>=-60
      IWCmean=0.0009;
      N100_IWC=5.58*1e3;B1=-3.85;N1000_IWC=8.06;B2=-3.85;
end

A1=N100_IWC/100^(B1);
A2=N1000_IWC/1000^(B2);
warning off
D0=(A2/A1)^(1/(B1-B2));
warning on
n=length(D);
if D0>20 & D0<3000
   A1=N100_IWC*1e6/(1e-4)^(B1);
   A2=N1000_IWC*1e6/(1e-3)^(B2);
   N2=A2.*D.^(B2)*IWCmean;
   N1=A1.*D.^(B1)*IWCmean;
   for i=1:1:n
       if N1(i)<=N2(i)
          N(i)=N1(i);
       else
          N(i)=N2(i);
       end
   end
 
elseif D0<=20
       A2=N1000_IWC*1e6/(1e-3)^(B2);
       N2=A2.*D.^(B2)*IWCmean;
       N=N2;

elseif D0>3000
       A1=N100_IWC*1e6/(1e-4)^(B1);
       N1=A1.*D.^(B1)*IWCmean;
       N=N1;
end

y=N;
