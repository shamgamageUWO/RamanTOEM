% This code is to create synthetic data using the US standard data

function [Diff_JH_i,Diff_JL_i,A_Zi,B_Zi]=synthetic(temp,press,alt)


% %  R = 0.1723.*4.5=0.77;
% % CL = H = 2.065152155995913e+18;
%Bg_JH_real =2.9989
%Bg_JL_real =3.4144


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




% Measurement grid
Zi = alt;
Pressi = press;
Ti = temp;
rho = Pressi./(Rsp*Ti);


% Functions needed in measurement grid

% Transmission 

exponent = 4+B+C*Lambda+D/Lambda;
sigma_Rcm2 = A / Lambda^(exponent);
sigmaNicolet = sigma_Rcm2*1e-4;%m2
Nmol = (NA/M).* rho ; % mol m-3
Tr = exp(-cumtrapz(Zi,Nmol*sigmaNicolet));

R_tr_i = Tr.^2;

%  figure;plot(Pressi,Zi./1000)
%  figure;plot(Ti,Zi./1000)
% Overlap

[epsi,z] = Overlap(Zi);
% figure;plot(z,epsi)
dis = length(Zi)-length(z);
NN = ones(1,dis);
KK = (epsi);
NK= [KK NN];
OV_Zi = NK;

% OV_Zi = 1;
% Define the first part of the equation 

A_Zi = (area .* OV_Zi .*R_tr_i .*Pressi)./(kb * Zi.^2);
B_Zi = (area .*R_tr_i .*Pressi)./(kb * Zi.^2); % No overlap function


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

% %  figure;plot(Diff_JH_i,Zi./1000)
% %  figure;plot(Diff_JL_i,Zi./1000)
% CL = 1.3250e+20;%1.449192680052850e+18;
% CH = R.*CL;

    %%Using Csum
    % Csum =  2.8077e+18;%6.8122e+20; % cALCULATED USING THE FINDCSUMANDR CODE
    % CL = (Csum.*(Diff_JL_i+Diff_JH_i))./(Diff_JL_i+ R.*Diff_JH_i);
    % y=CL(Zi>=4000&Zi<=7500);
    % CL = nanmean(y);
    % CH = R.*CL;
    % %%Using Cjl and R
%     CL = 1.2e+22;
%     CH = R.*CL;
% figure;
% subplot(1,2,1)
% plot(CL,Zi./1000,'r',CH,Zi./1000,'b'); 

% hold on;

% xmean1 = mean(CL);
% xmean2 = mean(CH);
% xstd1 = std(CL);
% xstd2 = std(CH);
% meanValue1 = [xmean1 xmean1];
% meanValue2 = [xmean2 xmean2];
% plot(meanValue1,'g');
% plot(meanValue2,Zi./1000,'y');
% legend('CL','CH')
% xlabel('Constant')
% ylabel('Alt (km)')

% Syntheic data for JL using US standard data

% JLL = (CL.*A_Zi .* Diff_JL_i)./(Ti) ;%+5.9895e+03; % Here I have to add background 
% JHH = (CH.*B_Zi .* Diff_JH_i)./(Ti);%+5.9895e+03; % Here I have to add background 

% Bg_JL_real= Q.Bg_JL_real;
% Bg_JH_real= Q.Bg_JH_real;



% 
%         % Saturation Correction
%         ScaleFactor = 150/3.75;
%         shots = 1800;
%         % 1. Convert counts to Hz
%         JHnw = (JHH.*ScaleFactor)./shots;
%         JLnw = (JLL.*ScaleFactor)./shots;
% 
%         % 2. Apply the correction
%  JL = JLL ./ (1 + JLnw.*(4e-9)); % non-paralyzable
% % JL = JL .* exp(-JLnw.*(4e-9)); % paralyzable %units is counts
%  JH = JHH ./ (1 + JHnw.*(4e-9));
%         JH = JHH .* exp(-JHnw.*(4e-9)); % paralyzable %units is counts
%         % newY1 = JH ./ (1 + JHnw.*(4e-9)); % non-paralyzable
%         JL = JLL .* exp(-JLnw.*(4e-9)); % paralyzable %units is counts
% subplot(1,2,2)
% semilogx(JLL,Zi./1000,'r',JHH,Zi./1000,'b')
% legend('JL','JH')
% xlabel('Log Counts')
% ylabel('Alt (km)')
% % Add background 

% JL = JL+ Bg_JL_real;
% JH = JH+ Bg_JH_real;
% 
%  JLreal = NoiseP((JL));
%  JHreal = NoiseP((JH));
% %  JLreal = JLreal./100;
% %  JHreal = JHreal./100;
% % JL = awgn(JL,1);
% % JH = awgn(JH,2);
% % JLreal(JLreal<=0) = 1;
% % JHreal(JHreal<=0) = 1;
% 
% %  figure;
% % subplot(1,2,1)
% %  plot(JLreal,Zi./1000,'r',JL,Zi./1000,'b',JHreal,Zi./1000,'r',JH,Zi./1000,'b')
% % subplot(1,2,2)
% %  plot((JLreal-JL),Zi./1000,'r',(JHreal-JH),Zi./1000,'b')
% 
% nijl=(JLreal-JL);
% nijh=(JHreal-JH);
% 
% 
% % Now here I want to remove the JH counts from altitudes above 3 km
% ind = alt_in>=100;
% JHreal = JHreal(ind);
% T_US = Ti;