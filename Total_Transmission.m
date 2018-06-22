
function [Tr_PRR,Tr_N2,Tr_WV] = Total_Transmission(Q)
kb = 1.38064852*10^-23;
area = pi * (0.3^2);

% For PRR
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

% Transmission 
exponent = 4+B+C*Lambda+D/Lambda;
sigma_Rcm2 = A / Lambda^(exponent);
sigmaNicolet = sigma_Rcm2*1e-4;%m2
Nmol = (NA/M).* Q.rho ; % mol m-3
alpha_aero = Q.alpha_aero;
odaer = Q.odaer';
sigma_tot = Nmol*sigmaNicolet+ alpha_aero;
Tr_PRR = exp(-2.*cumtrapz(Q.Zmes,sigma_tot)); % Molecular transmission

% For N2 and WV
% Molecular profile number density
ScaleHeight = 8.771;%e+3; % Approximative up to 10km
% Nmol = 2.56e25 .* exp(-z/ScaleHeight); % Molecular profile
LambdaN2 = 386.7* (10^-1); %micrometere
LambdaWV = 407.6* (10^-1);
exponentN2 = 4+B+(C*LambdaN2)+(D/LambdaN2);
sigma_Rcm2N2 = A / LambdaN2^(exponentN2);
sigmaNicoletN2 = sigma_Rcm2N2*1e-4; %m2
exponentWV = 4+B+C*LambdaWV+D/LambdaWV;
sigma_Rcm2WV = A / LambdaWV^(exponentWV);
sigmaNicoletWV = sigma_Rcm2WV*1e-4;%m2
sigma_totWV = Nmol*sigmaNicoletWV + alpha_aero + sigma_tot;
sigma_totN2 = Nmol*sigmaNicoletN2 + alpha_aero + sigma_tot;

Tr_N2 = exp(-cumtrapz(Q.Zmes,sigma_totN2)); % Molecular transmission
Tr_WV = exp(-cumtrapz(Q.Zmes,sigma_totWV)); % Molecular transmission

tr_N2 = exp(-cumtrapz(Q.Zmes,Nmol*sigmaNicoletN2)); % only n2
tr_WV = exp(-cumtrapz(Q.Zmes,Nmol*sigmaNicoletWV )); % only wv
%figure;plot(tr_N2./tr_WV,Q.Zmes./1000,'r',Tr_N2./Tr_WV,Q.Zmes./1000,'b')
% figure;plot(Tr_PRR,Q.Zmes./1000,'r',Tr_N2,Q.Zmes./1000,'b',Tr_WV,Q.Zmes./1000,'g')