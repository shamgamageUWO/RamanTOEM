% ice_psd_Donovan_2003 returns the particle size distribution in cirrus clouds.
%    
%     Returns a vector with the particle size distribution for a 
%     given temperature, ice water content, and shape
%     for a midlatitude cirrus cloud.
%     The uncertainty regarding the habits of the ice crystals is large.
%     The parameterization here is based on the distribution of
%     maximum dimension of complex polycrystals or compact
%     polycrystals which are consistent with the average observed
%     behaviour from the measurements. 
%     The particle size distribution is a bimodal gamma distribution,
%     and with the input "mode" there is an option of which mode
%     that will be returned.
%
%     The parameterization is taken from Donovan.
%     "Ice cloud effective particle size parameterization based
%     on combined lidar, radar reflectivity, and mean Doppler
%     velocity measurements"
%     J. of Geophys. res., vol. 108, NO. D18, 4573, 2003
%
% FORMAT   [y] = ice_psd_Donovan_03(T,IWC,D,shape,mode)     
%
% OUT      y is a vector with the particle size distribution [#/m^3/m]
%
% IN       T     Temperature [Kelvin]
%          IWC   Ice water content [g/m^3]
%          D     the vector with the maximum dimension of
%                the ice particles [m],
%                where the concentration will be calculated
%          shape 1=complex polycrystals
%                2=compact polycrystals
%          mode  1=both small and large mode
%                2=small mode
%                3=large mode


% History: 2004-07-19  Created by Bengt Rydberg


function [y]=ice_psd_Donovan_03(T,IWC,D,shape,mode) 

T=T-273.15;

if T>0
   error('Only temperatures smaller than 273.15 K are allowed.')
end
if T<-70
   error('Only temperature larger or equal to 203.15 K are allowed.')
end
if IWC<0.001
   error('Only IWC larger than or equal to 0.001 are allowed.')
end
if IWC>1.0
   error('Only IWC smaller or equal to 1.0 are allowed.')
end
if ((shape~=1) && (shape~=2))
   error('Only shape 1 or 2 are allowed.')
end
if ((mode~=1) && (mode~=2) && (mode~=3))
   error('Only mode 1,2, or 3 are allowed.')
end

gammas=4.24;gammal=3.64;
Rms=20.1623*1e-6;rms=Rms/(gammas+2);

if shape==1
   %complex polycrystlas
   A0a=502.88;A1a=109.56;
   A0b=7.66;A1b=1.92;
   R0=A0a+A1a*log10(IWC);
   Ra=A0b+A1b*log10(IWC);
   Rml=(R0+Ra*T)*1e-6;
   rml=Rml/(gammal+2);
   Nl_Ns=[0.006409 0.007934 0.01089 0.01459 0.01851 0.02243 0.02625 0.02994;
          0.006119 0.007603 0.01222 0.01809 0.02402 0.02970 0.03510 0.04027;
          0.006078 0.007328 0.01350 0.02134 0.02894 0.03650 0.04279 0.04927;             0.006081 0.007068 0.01493 0.02478 0.03400 0.04256 0.05070 0.05859;             0.006000 0.006859 0.01627 0.02789 0.03851 0.04838 0.05783 0.06704;
          0.006000 0.006669 0.01773 0.03114 0.04321 0.05449 0.06536 0.07600;
          0.006000 0.006523 0.01909 0.03408 0.04747 0.06005 0.07226 0.08424];
   IWCv=[0.001 0.0033 0.01 0.033 0.10 0.33 1.0]';
   Tv=[-70:10:0];
   Nl_Ns=interp2(Tv,IWCv,Nl_Ns,T,IWC,'cubic');     
             
   alfa1=4.3;beta1=2.88;
   alfa2=1.38;beta2=2.88;
   alfap2=145.73;betap2=1.88;
end

if shape==2
   %compact polycrystlas
   A0a=718.74;A1a=164.49;
   A0b=10.56;A1b=2.74;
   R0=A0a+A1a*log10(IWC);
   Ra=A0b+A1b*log10(IWC);
   Rml=(R0+Ra*T)*1e-6;
   rml=Rml/(gammal+2);
   Nl_Ns=[0.003171 0.004194 0.005712 0.007455 0.009275 0.01110 0.01288 0.01461;
          0.002874 0.004195 0.006757 0.009670 0.01257  0.01534 0.01797 0.02050;
          0.002765 0.004196 0.007768 0.01172  0.01548  0.01901 0.0234  0.02555;          0.002739 0.004198 0.008876 0.01386  0.01846  0.02273 0.02681 0.03075;          0.002738 0.004199 0.009909 0.01577  0.02109  0.02605 0.03081 0.03546;
          0.002737 0.004200 0.01102  0.01776  0.02383  0.02953 0.03504 0.04043;
          0.002736 0.004201 0.01203  0.01955  0.02630  0.03269 0.03890 0.04497];
   IWCv=[0.001 0.0033 0.01 0.033 0.10 0.33 1.0]';
   Tv=[-70:10:0];
   Nl_Ns=interp2(Tv,IWCv,Nl_Ns,T,IWC,'cubic');     
             
   alfa1=3.73;beta1=2.88;
   alfa2=0.84;beta2=2.88;
   alfap2=144.96;betap2=1.88;
end

rho=0.91e-12;
d1=linspace(1e-6,1e-3,1000);
m1=rho*alfa1*(d1*1e6/2).^(beta1);
m2=rho*(alfa2*(d1*1e6/2).^(beta2)+alfap2*(d1*1e6/2).^(betap2));
N1=1/2/rms/gamma(gammas).*(d1/2/rms).^(gammas-1).*exp(-d1/2/rms);
N2=Nl_Ns/2/rml/gamma(gammal).*(d1/2/rml).^(gammal-1).*exp(-d1/2/rml);
Ntot=N1+N2;
Ns=IWC/(1e-6*N1(1:1000)*m1(1:1000)'+1e-6*N2(1:1000)*m2(1:1000)');
  
N1=(Ns/2/rms/gamma(gammas).*(D/2/rms).^(gammas-1).*exp(-D/2/rms));
N2=(Nl_Ns*Ns/2/rml/gamma(gammal).*(D/2/rml).^(gammal-1).*exp(-D/2/rml));

if mode==1
   y=N1+N2;
end

if mode==2
   y=N1;
end

if mode==3
   y=N2;
end
