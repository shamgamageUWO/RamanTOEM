% This code is to create synthetic data using the US standard data

function [JL,JH,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i]=forwardmodelRTraman(Q,x)

 m = length(Q.Zret);
 x_a = x(1:m);
%  Ti = interp1(Q.Zret,x(1:m),Q.Zmes,'linear'); % T on data grid (digital)
Ti = interp1(Q.Zret,x_a,Q.Zmes,'linear'); % T on data grid (digital)



% Constants
kb = 1.38064852*10^-23;
CL = x(end);
CH = Q.R.*x(end);

% CH = 9.4e+21;
area = pi * (0.3^2);
Lambda = 354.7* (10^-3);

NA = 6.02214129 *(10^23) ;% Avergadro Number mol?1
M = 28.9645 * (10^-3); % molar mass - Mair	28.9645 g.mol-1 Molecular mass of dry air kg/mol
A = 4.02*10^(-28);
B = -0.3228;
C = 0.389;
D = 0.09426;
J_low = [3,4,5,6,7,8,9];
J_high = [10,11,12,13,14,15];
J_lowO2 = [5,7,9,11,13];
J_highO2 = [15,17,19,21];


% Functions needed in measurement grid

% Transmission 

exponent = 4+B+C*Lambda+D/Lambda;
sigma_Rcm2 = A / Lambda^(exponent);
sigmaNicolet = sigma_Rcm2*1e-4;%m2
Nmol = (NA/M).* Q.rho ; % mol m-3
Tr = exp(-cumtrapz(Q.Zmes,Nmol*sigmaNicolet));

R_tr_i = Tr.^2;

% Overlap
dz = Q.Zmes(2)-Q.Zmes(1);
[epsi,z] = Overlap(dz);
dis = length(Q.Zmes )-length(z);
NN = ones(1,dis);
KK = (epsi);
NK= [KK NN];
OV_Zi = NK;


% Define the first part of the equation 

A_Zi = (area .* OV_Zi .*R_tr_i .*Q.Pressi)./(kb * Q.Zmes .^2);
B_Zi = (area .* OV_Zi .*R_tr_i .*Q.Pressi)./(kb * Q.Zmes .^2);

% % Differential cross section term 

[diff_O2Ls,diff_O2Las,deri_diff_O2Ls,deri_diff_O2Las] = RR_differentialO2_JL(J_lowO2,Ti); % JL Oxygen 
[diff_O2Hs,diff_O2Has,deri_diff_O2Hs,deri_diff_O2Has] = RR_differentialO2_JH(J_highO2,Ti);% JH Oxygen
[diff_N2Ls,diff_N2Las,deri_diff_N2Ls,deri_diff_N2Las] = RR_differentialN2_JL(J_low,Ti);% JL Nitrogen
[diff_N2Hs,diff_N2Has,deri_diff_N2Hs,deri_diff_N2Has] = RR_differentialN2_JH(J_high,Ti);% JH Nitrogen
Diff_JLN2 = nansum(diff_N2Ls') + nansum(diff_N2Las') ; % new unit is in m^2
Diff_JLO2 = nansum(diff_O2Ls') + nansum(diff_O2Las') ; % new unit is in m^2
Diff_JL_i =  Diff_JLO2 + Diff_JLN2;
Diff_JHN2 = nansum(diff_N2Hs') + nansum(diff_N2Has') ; % new unit is in m^2
Diff_JHO2 = nansum(diff_O2Hs') + nansum(diff_O2Has') ; % new unit is in m^2
Diff_JH_i =  Diff_JHO2 + Diff_JHN2; 


% Syntheic data for JL using US standard data

JL = ((CL.*A_Zi .* Diff_JL_i)./(Ti)) ;%+5.9895e+03; % Here I have to add background 
JH = ((CH.*B_Zi .* Diff_JH_i)./(Ti));%+5.9895e+03; % Here I have to add background 

% Add background to the counts 
JL = JL + Q.BaJL;
JH = JH + Q.BaJH;
