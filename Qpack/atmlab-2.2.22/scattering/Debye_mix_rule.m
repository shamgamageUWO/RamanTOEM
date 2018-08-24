% Debye_mix_rule      Effective refractive index and effective density of 
%                     a two-medias mixture.
%                         
%
%                     This function uses the Debye formulation
%                     to calculate the effective refractive index and
%                     effective density of a mixture that includes two
%                     medias.
%
%                        
% 
% FORMAT     [n rho] = Debye_mix_rule(n1,n2,rho1,rho2,fraction2)
%        
% OUT  n            Complex dielectric constant          real or imaginary
%      rho          Uniform density of the mixture       [Kg/m3]
%
% IN   n1           refractive index of Matrix medium    real or imaginary
%      n2           refractive index of Inclusion        real or imaginary
%      rh1          Density of matrix medium             [Kg/m3]
%      rho2         Density of inclusion                 [Kg/m3]
%      fraction2    The volum fraction of the inclusion
       
% 2013-08-01        Created by Maryam Jamali




function [n rho]= Debye_mix_rule(n1,n2,rho1,rho2,fraction2)

emat=power(n1,2);
einc=power(n2,2);
x=(fraction2.*(einc-1)./(einc+2))+(((1-fraction2).*(emat-1))./(emat+2));

eeff=(2.*x+1)./(1-x);
n=power(eeff,.5);

rho=(1-fraction2)*rho1+fraction2*rho2;
