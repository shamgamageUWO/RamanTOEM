% Bruggeman_mix_rule     Effective refractive index and effective density of 
%                        a two-medias mixture.
%                         
%
%                        This function uses the Bruggeman formulation
%                        to calculate the effective refractive index and
%                        effective density of a mixture that includes two
%                        medias.
%
%                        
% 
% FORMAT     [n rho] = Bruggeman_mix_rule(n1,n2,rho1,rho2,fraction2)
%        
% OUT  n            Complex dielectric constant           real or imaginary
%      rho          Uniform density of the mixture        [Kg/m3]
%
% IN   n1           refractive index of Matrix medium     real or imaginary
%      n2           refractive index of Inclusion         real or imaginary
%      rh1          Density of matrix medium              [Kg/m3]
%      rho2         Density of inclusion                  [Kg/m3]
%      fraction2    The volum fraction of the inclusion
       
% 2013-08-01        Created by Maryam Jamali




function [n rho]= Bruggeman_mix_rule(n1,n2,rho1,rho2,fraction2)

% eeff is calculated by solving the following equation
%A=solve('(fraction2.*(einc-x)./(einc+2.*x))+(((1-fraction2).*(emat-x))./(emat+2.*x))==0');

emat=power(n1,2);
einc=power(n2,2);

eeff=emat./2 - einc./4 + (3.*einc.*fraction2)./4 - (3.*emat.*fraction2)./4 +...
     (9.*einc.^2.*fraction2.^2 - 6.*einc.^2.*fraction2 + einc.^2 - 18.*einc.*emat.*fraction2.^2 +...
     18.*einc.*emat.*fraction2 + 4.*einc.*emat + 9.*emat.^2.*fraction2.^2 - 12.*emat.^2.*fraction2 +...
     4.*emat.^2).^(1/2)/4;

n=power(eeff,.5);

rho=(1-fraction2)*rho1+fraction2*rho2;
