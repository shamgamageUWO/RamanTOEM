% ice_psd_Mitchell_99  returns the particle size distribution in cirrus clouds.
%    
%     Returns a vector with the particle size distribution 
%     for a given temperature and ice water content, 
%     for a tropical cirrus cloud. 
%     This parameterization is based on the distribution
%     of maximum dimension of planar polycrystals, and are based on 
%     measurements of ice crystals in the range 10^-6 m to 10^-3 m.
%     The particle size distribution is a bimodal exponential
%     distribution,  and with the input "mode" there is an option
%     of which mode that will be returned.
%         
%     The parameterization is taken from Mitchell et al.
%     "A GCM parameterization of bimodal size spectra for ice clouds"
%     In Proceedings of the Ninth Atmospheric Radiation Measurement 
%     (ARM) Science Team Meeting, U.S Department of Energy, 
%     Washington, D.C. Available URL: 
%     http://www.arm.gov/publications/proceedings/conf09/abstracts/
%     mitchell2-99.pdf
%     
% FORMAT   [y] = ice_psd_Mitchell_99(T,IWC,D,mode)     
%
% OUT      y is a vector with the particle size distribution [#/m^3/m]
%
% IN       T     Temperature [Kelvin]
%          IWC   Ice water content [g/m^3]
%          D     the vector with the maximum dimension of
%                the ice particles [m],
%                where the concentration will be calculated
%          mode  1=both large and small mode
%                2=only small mode
%                3=only large mode
%
% History: 2004-07-19  Created by Bengt Rydberg

function [y]=ice_psd_Mitchell_99(T,IWC,D,mode);

T=T-273.15;

if T>0
   error('Only temperatures smaller or equal to 273.15 K are allowed.')
end
if ((mode~=1) && (mode~=2) && (mode~=3))
   error('Only mode 1,2, or 3 are allowed.')
end


Dlg=1031*exp(0.05522*(T-4))*1e-6;
lambdalg=1/Dlg;
lambdasm=(1.49*lambdalg+583*1e2);
IWCsmn=0.025*(1-exp(-(Dlg*1e6/80)^2))+exp(-(Dlg*1e6/80)^2);
IWCsm=IWC*IWCsmn;
IWClg=IWC-IWCsm;

rhosi=0.92*1e6;
alfa1=1.21;alfa2=6.96;
betasm=2.897;betalg=2.45;

alfasm=alfa1*rhosi*1e-18*(1e6/2)^(betasm);
alfalg=alfa2*rhosi*1e-18*(1e6/2)^(betalg);

N0sm=IWCsm*lambdasm^(betasm+1)/(alfasm*gamma(betasm+1));
N0lg=IWClg*lambdalg^(betalg+1)/(alfalg*gamma(betalg+1));

Nsm=N0sm*exp(-lambdasm*D);
Nlg=N0lg*exp(-lambdalg*D);

if mode==1
   y=Nsm+Nlg;
end

if mode==2
   y=Nsm;
end

if mode==3
   y=Nlg;
end
