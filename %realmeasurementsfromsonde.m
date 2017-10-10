% This code is to create synthetic data using the US standard data

function [JLrealson,JHrealson,A_Zi,Diff_JL_i,Diff_JH_i,T_sonde,Pressi]=realmeasurementsfromsonde(alt_in)
date_in = 20110705;
time_in = 23;
% alt_in = 500:100:22000; % Measurement Resolution
kb = 1.38064852*10^-23;
Rsp = 287;

% Load US standard profiles
[Tsonde,Zsonde,Psonde] = get_sonde_RS92(date_in,time_in);
Ti = interp1(Zsonde,Tsonde,alt_in,'linear');
Pressi =interp1(Zsonde,Psonde,alt_in,'linear');
rho = Pressi./(Rsp.*Ti);

% Measurement grid
Zi = alt_in;


% Retrieval grid
% Zj = 500:100:22000; % Retrieval Resolution

% Constants
area = pi * (0.3^2);
 R = 0.17;
 CL = 1.449192680052850e+18;
CH = R.*CL;
% CL = 1.2e+22;
% CH = 9.4e+21;
% CH = 9.4e+21;

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
Nmol = (NA/M).* rho ; % mol m-3
Tr = exp(-cumtrapz(Zi,Nmol*sigmaNicolet));

R_tr_i = Tr.^2;

% Overlap
dz = Zi(2)-Zi(1);
[epsi,z] = Overlap(dz);
dis = length(Zi)-length(z);
NN = ones(1,dis);
KK = (epsi);
NK= [KK NN];
OV_Zi = NK;


% Define the first part of the equation 

A_Zi = (area .* OV_Zi .*R_tr_i .*Pressi)./(kb * Zi.^2);
B_Zi = (area .* OV_Zi .*R_tr_i .*Pressi)./(kb * Zi.^2);

% Differential cross section term 
% [diff_N2s_JL,diff_N2as_JL,diff_cross_N2_s_JLterm1,diff_cross_N2_anti_JLterm1,diff_cross_N2_s_JLterm2,diff_cross_N2_anti_JLterm2]= RR_differential_TestJL(J_low,Ti);
% [diff_O2s_JL,diff_O2as_JL,diff_cross_O2_s_JLterm1,diff_cross_O2_anti_JLterm1,diff_cross_O2_s_JLterm2,diff_cross_O2_anti_JLterm2]= RR_differentialO2_TestJL(J_lowO2,Ti);
% Diff_JLN2 = nansum(diff_N2s_JL') + nansum(diff_N2as_JL') ; % new unit is in m^2
% Diff_JLO2 = nansum(diff_O2s_JL') + nansum(diff_O2as_JL') ; % new unit is in m^2
% Diff_JL_i =  Diff_JLO2 + Diff_JLN2; 
% 
% % figure;plot(Diff_JL_i,Zi)
% 
% % JH %%%%%%
% [diff_N2s_JH,diff_N2as_JH,diff_cross_N2_s_JHterm1,diff_cross_N2_anti_JHterm1,diff_cross_N2_s_JHterm2,diff_cross_N2_anti_JHterm2]= RR_differential_TestJH(J_high,Ti);
% [diff_O2s_JH,diff_O2as_JH,diff_cross_O2_s_JHterm1,diff_cross_O2_anti_JHterm1,diff_cross_O2_s_JHterm2,diff_cross_O2_anti_JHterm2]= RR_differentialO2_TestJH(J_highO2,Ti);
% Diff_JHN2 = nansum(diff_N2s_JH') + nansum(diff_N2as_JH') ; % new unit is in m^2
% Diff_JHO2 = nansum(diff_O2s_JH') + nansum(diff_O2as_JH') ; % new unit is in m^2
% Diff_JH_i =  Diff_JHO2 + Diff_JHN2; 

% figure;plot(Diff_JH_i,Zi)
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

JLL = (CL.*A_Zi .* Diff_JL_i)./(Ti) ;%+5.9895e+03; % Here I have to add background 
JHH = (CH.*B_Zi .* Diff_JH_i)./(Ti);%+5.9895e+03; % Here I have to add background 
Bg_JL_real = 825.1867;
Bg_JH_real =  700.8660;



 % Saturation Correction
        ScaleFactor = 150/3.75;
        shots = 1800;
        % 1. Convert counts to Hz
        JHnw = (JHH.*ScaleFactor)./shots;
        JLnw = (JLL.*ScaleFactor)./shots;

        % 2. Apply the correction
 JL = JLL ./ (1 + JLnw.*(4e-9)); % non-paralyzable
% JL = JL .* exp(-JLnw.*(4e-9)); % paralyzable %units is counts
 JH = JHH ./ (1 + JHnw.*(4e-9));
%         JH = JHH .* exp(-JHnw.*(4e-9)); % paralyzable %units is counts
%         % newY1 = JH ./ (1 + JHnw.*(4e-9)); % non-paralyzable
%         JL = JLL .* exp(-JLnw.*(4e-9)); % paralyzable %units is counts
% subplot(1,2,2)
% semilogx(JLL,Zi./1000,'r',JHH,Zi./1000,'b')
% legend('JL','JH')
% xlabel('Log Counts')
% ylabel('Alt (km)')
JL = NoiseP((JL));
JH = NoiseP((JH));

JLrealson = JL+ Bg_JL_real;
JHrealson = JH+ Bg_JH_real;

% Now here I want to remove the JH counts from altitudes above 3 km
% ind = alt_in>=100;
% JHreal = JHreal(ind);
T_sonde = Ti;

% figure;subplot(1,3,1) 
% plot(Ti,Diff_JL_i,'r',Ti,Diff_JH_i,'b')
% subplot(1,3,2)
% plot(Ti,Diff_JL_i./Ti,'r',Ti,Diff_JH_i./Ti,'b')
% subplot(1,3,3)
% plot(Ti,Diff_JL_i./(Ti.*Zi.^2),'r',Ti,Diff_JH_i./(Ti.*Zi.^2),'b')




% JL = NoiseP((JLL));
% JH = NoiseP((JHH));
% 
% % Saturation Correction
% ScaleFactor = 150/3.75;
% shots = 1800;
% % 1. Convert counts to Hz
% JHnw = (JH.*ScaleFactor)./shots;
% JLnw = (JL.*ScaleFactor)./shots;
% 
% % 2. Apply the correction
% 
% JH = JH .* exp(-JHnw.*(4e-9)); % paralyzable %units is counts
% % newY1 = JH ./ (1 + JHnw.*(4e-9)); % non-paralyzable
% JL = JL .* exp(-JLnw.*(4e-9)); % paralyzable %units is counts
% 
% 
% 
% % JL(JL==0) = 1;
% % JH(JH==0) = 1;
% 
% % JL = JLL;
% % JH = JHH;
% 
% T_real = Ti;





