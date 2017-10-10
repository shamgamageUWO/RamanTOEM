% This code is to create synthetic data using the US standard data

function [JLreal,JHreal,T_US,CL,CH,Diff_JH_i,Diff_JL_i,A_Zi,Pressi,noisejl,noisejh]=realmeasurements(Q)

date_in = Q.date_in;
time_in = Q.time_in;
alt_in = Q.Zmes;

% Constants
kb = 1.38064852*10^-23;
area = pi * (0.3^2);
Lambda = 354.7* (10^-3);
Rsp = 287; %J K-1 mol-1
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
%  R = 0.76;%0.17; % Im chaning this here inorder to change the forward model


% Load US standard profiles
[temp, press, dens, alt] = US1976(date_in, time_in, alt_in); 
% Measurement grid
Zi = alt;
Pressi = press;
Ti = temp;
rho = Pressi./(Rsp.*Ti);


% Functions needed in measurement grid

% Transmission 

exponent = 4+B+C*Lambda+D/Lambda;
sigma_Rcm2 = A / Lambda^(exponent);
sigmaNicolet = sigma_Rcm2*1e-4;%m2
Nmol = (NA/M).* rho ; % mol m-3
Tr = exp(-cumtrapz(Zi,Nmol*sigmaNicolet));

R_tr_i = Tr.^2;

% Overlap
[epsi,z] = Overlap(Zi);
% figure;plot(z,epsi)
dis = length(Zi)-length(z);
NN = ones(1,dis);
KK = (epsi);
NK= [KK NN];
OV_Zi = NK;


% Define the first part of the equation 

A_Zi = (area .* OV_Zi .*R_tr_i .*Pressi)./(kb * Zi.^2);
% B_Zi = (area .* OV_Zi .*R_tr_i .*Pressi)./(kb * Zi.^2);


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

%  figure;plot(Diff_JH_i,Zi./1000)
%  figure;plot(Diff_JL_i,Zi./1000)

CL = Q.CL;
CH = Q.R *CL;

% Syntheic data for JL using US standard data

JLL = (CL.*A_Zi .* Diff_JL_i)./(Ti) ;%+5.9895e+03; % Here I have to add background 
JHH = (CH.*A_Zi .* Diff_JH_i)./(Ti);%+5.9895e+03; % Here I have to add background 
% 
% Bg_JL_real= Q.Bg_JL_real;
% Bg_JH_real= Q.Bg_JH_real;

JL = JLL+ Q.Bg_JL_real;
JH = JHH+ Q.Bg_JH_real;



        % Saturation Correction
        ScaleFactor = 150/3.75;
        shots = 1800;
        % 1. Convert counts to Hz
        JHnw = (JH.*ScaleFactor)./shots;
        JLnw = (JL.*ScaleFactor)./shots;

        % 2. Apply the correction
 JLR = JL ./ (1 + JLnw.*(4e-9)); % non-paralyzable
% JL = JL .* exp(-JLnw.*(4e-9)); % paralyzable %units is counts
 JHR = JH ./ (1 + JHnw.*(4e-9));
%         JH = JHH .* exp(-JHnw.*(4e-9)); % paralyzable %units is counts
%         % newY1 = JH ./ (1 + JHnw.*(4e-9)); % non-paralyzable
%         JL = JLL .* exp(-JLnw.*(4e-9)); % paralyzable %units is counts

%add noise
% JLreal = NoiseP((JLR));
% JHreal = NoiseP((JHR));
JLreal = JLR;
JHreal = JHR;
% make noise vectors
noisejl=(JLreal-JLR);
noisejh=(JHreal-JHR);

T_US = Ti;