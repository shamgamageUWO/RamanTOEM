%Maxwell_Gar_mix_rule     Effective refractive index and effective density of 
%                         a two-medias mixture.
%
%
%                         This function uses the Maxwell Garnett formulation
%                         to calculate the effective refractive index and
%                         effective density of a mixture that includes two
%                         medias. 
% 
% FORMAT     [n rho] = Maxwell_Gar_mix_rule(n1,n2,rho1,rho2,fraction2)
%        
% OUT  n            Complex dielectric constant      real or imaginary
%      rho          Uniform density of the mixture   [Kg/m3]
%
% IN   n1           Matrix medium                    real or imaginary
%      n2           Inclusion                        real or imaginary
%      rh1          Density of matrix medium         [Kg/m3]
%      rho2         Density of inclusion             [Kg/m3]
%      fraction2    The volum fraction of the inclusion
       

% 2013-06-25        Created by Maryam Jamali


function [n rho]= Maxwell_Gar_mix_rule(n1,n2,rho1,rho2,fraction2)

emat=power(n1,2);
einc=power(n2,2);

eeff=emat+3.*fraction2.*emat.*(einc-emat)./(einc+2.*emat-(fraction2.*(einc-emat)));
n=power(eeff,.5);

rho=(1-fraction2)*rho1+fraction2*rho2;
