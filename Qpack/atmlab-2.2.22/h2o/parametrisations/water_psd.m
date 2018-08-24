% water_psd returns water clouds particle size distribution
%
%    Returns a vector with a particle size distribution
%    n(r)=A*r^c1*exp(-Br^c2)
%
%
% FORMAT   [y] = water_psd(LWC,r,rc,c1,c2)
%  
%
% OUT      y is a vector with the particle size distribution [#/m^3/m]
%
% IN       LWC     liquid water content [g/m^3]
%          r       the size vector of the ice particles [m]
%          c1      psd parameter
%          c2      psd parameter
%          rc      characteristic radius
%
% History: 2005-05-24  Created by Bengt Rydberg

function [y]=water_psd(LWC,r,rc,c1,c2)

%min_nargin( 5, nargin );       

B=c1/c2/rc^c2;
A=3*LWC*c2*B^((c1+4)/c2)*1e12/4/pi/gamma((c1+4)/c2);
n=A*((r*1e6).^c1.*exp(-B*(r*1e6).^c2))*1e6;

y=n;
         
