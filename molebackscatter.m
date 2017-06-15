% aerosol backsactter 

function [beta_mol] = molebackscatter (Q)



J_tot = Q.JHnew + Q.JLnew;
L_aero = Q.Eb./(J_tot);



lambda_rec= 354.7;
lambda_em = 354.7;

Z = Q.alt;
P = Q.Pressi;
T = Q.Ti;

[alpha_mol,beta_mol,lidar_signal,beta_att,density]=get_rayleigh_v3(Z,P,T,lambda_rec,lambda_em);

be = L_aero.*beta_mol;
% figure; 
% plot(alpha_aero,Z./1000)
% xlabel('alpha _ aero')
% ylabel('alt (km)')