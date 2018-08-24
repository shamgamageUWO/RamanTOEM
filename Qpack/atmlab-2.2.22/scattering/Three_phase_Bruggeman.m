% Three_phase_Bruggeman     Effective refractive index and effective density of 
%                           a three-phase mixture.
%                         
%
%                           Material 2 (matrix) and material 3(inclusion)
%                           are first mixed; this mixture is then taken to be
%                           inclusion in a matrix of material 1. 
%                           Note that this function uses *Bruggeman_mix_rule*
%                           function.

%                        
% 
% FORMAT     [n rho] = Three_phase_Bruggeman(n1,n2,n3,rho1,rho2,rho3,fraction1, fraction2, fraction3)
%        
% OUT  n            Complex dielectric constant      real or imaginary
%      rho          Uniform density of the mixture   [Kg/m3]
%
% IN   n1           Refractive index of material 1          real or imaginary
%      n2           Refractive index of material 2          real or imaginary
%      n3           Refractive index of material 3          real or imaginary
%      rh1          Density of material 1                   [Kg/m3]
%      rho2         Density of material 2                   [Kg/m3]
%      rho3         Density of material 3                   [Kg/m3]
%      fraction1    The volum fraction of material 1
%      fraction2    The volum fraction of material 2
%      fraction3    The volum fraction of material 3

% 2013-08-05        Created by Maryam Jamali






function [n rho]=Three_phase_Bruggeman(n1,n2,n3,rho1,rho2,rho3,fraction1,fraction2,fraction3)

% 2,3
% 2= matrix media
% 3= inclusion media

fraction=fraction3./(fraction2+fraction3);

if fraction2==0 && fraction3==0
    fraction=0;
end

[n rho]=Bruggeman_mix_rule(n2,n3,rho2,rho3,fraction);

% 1,2_3
% 1=matrix media
% mixture of 2_3= inclusion media

fraction=(fraction2+fraction3)./(fraction1+fraction2+fraction3);

[n rho]=Bruggeman_mix_rule(n1,n,rho1,rho,fraction);