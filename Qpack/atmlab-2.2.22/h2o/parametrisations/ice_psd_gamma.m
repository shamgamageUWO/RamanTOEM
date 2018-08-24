% ice_psd_gamma returns gamma particle size distribution
%
%    Returns a vector or matrix with a gamma particle size distribution
%    n(D)=N*D^(mu)*exp(-lambda*D) 
%    with the mass of the particles m(D)=alfa*D^beta.
%    The input can be either scalars or vectors.
%
%
% FORMAT   [y] = ice_psd_gamma(IWC1,IWC2,D,mu1,mu2,lambda1,lambda2,alfa,beta)
%  
%
% OUT      y is a vector or matrix depending on input with the particle 
%          size distribution calculated at D [#/m^3/m]
%
% IN       IWC1    Ice water content in mode 1 [g/m^3]
%          IWC2    Ice water content in mode 2 [g/m^3]
%          D       the size vector of the ice particles [m]
%                  where the concentration will be calculated  
%          mu1     gamma parameter mu1>=0 in mode 1
%          mu2     gamma parameter mu2>=0 in mode 2
%          lambda1 gamma parameter [m^-1] in mode 1
%          lambda2 gamma parameter [m^-1] in mode 2
%          alfa    m(D)=alfa*D^beta [g/m^beta]
%          beta    exponent in mass-dimension power law
%
% History: 2005-05-24  Created by Bengt Rydberg

function [y]=ice_psd_gamma(IWC1,IWC2,D,mu1,mu2,lambda1,lambda2,alfa,beta)

min_nargin( 9, nargin );       
IWC1=vec2col(IWC1);
D=vec2col(D);
mu1=vec2col(mu1);
lambda1=vec2col(lambda1);

l1=length(IWC1);
l2=length(mu1);
l3=length(lambda1);
if (l1~=l2 | l1~=l3 | l2~=l3)
  error('length of IWC1, mu1, and, lambda1 must be equal')
end 

w1=ones(length(mu1),1);
w2=ones(1,length(D));
rho=0.92*1e6;
N1=IWC1'.*(lambda1'.^(beta+mu1'+1)/alfa./gamma(beta+mu1'+1));
n=(N1'*w2).*((w1*D').^(mu1*w2).*exp(-lambda1*D'));


if (isempty(IWC2)==0 & isempty(lambda2)==0 & isempty(mu2)==0)
   IWC2=vec2col(IWC2);
   mu2=vec2col(mu2);
   lambda2=vec2col(lambda2);
   l1=length(IWC2);
   l2=length(mu2);
   l3=length(lambda2);
   if (l1~=l2 | l1~=l3 | l2~=l3)
      error('length of IWC2, mu2, and, lambda2 must be equal')
   end 
   N2=IWC2'.*(lambda2'.^(beta+mu2'+1)/alfa./gamma(beta+mu2'+1));
   n=n+(N2'*w2).*((w1*D').^(mu2*w2).*exp(-lambda2*D'));
end
y=vec2col(n);
         
