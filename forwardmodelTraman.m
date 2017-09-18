% This code is to create synthetic data using the US standard data

function [JLa,JHa,A_Zi_an,B_Zi_an,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x)

m = length(Q.Zret);

x_a = x(1:m);
OV = x(m+1:2*m);
BJHa = x(end-2);
BJLa = x(end-1);
CJLa = x(end);



% interpolation
Ti = interp1(Q.Zret,x_a,Q.Zmes1,'linear'); % T on data grid (digital)
OV_Zi = interp1(Q.Zret,OV,Q.Zmes1,'linear');


%%
% Constants
kb = 1.38064852*10^-23;
area = pi * (0.3^2);
% Transmission
R_tr_i = (Q.Tr);

% Define the first part of the equation 
% N1 = length(Q.JHnewa);
% NN1 = length();
% N2 = length(Q.JHnew); fr=OV_Zi(Q.d_alti_Diff+1:end);

A_Zi_an = (area .* OV_Zi .*R_tr_i .*Q.Pressi)./(kb * Q.Zmes1 .^2);
B_Zi_an = (area .*R_tr_i .*Q.Pressi)./(kb * Q.Zmes1 .^2); % No overlap


%% loading cross sections
load('DiffCrossSections.mat');
Diff_JH_i = interp1(T,Diff_JH,Ti,'linear');
Diff_JL_i = interp1(T,Diff_JL,Ti,'linear');

CHa = (Q.Ra).* CJLa;


JLa = (CJLa.* A_Zi_an .* Diff_JL_i )./(Ti );
JHa = (CHa.* A_Zi_an .* Diff_JH_i )./(Ti );

JLa = JLa  + BJLa;
JHa = JHa  + BJHa;

return

 


