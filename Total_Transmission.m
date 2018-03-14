
function [Tr] = Total_Transmission(Q)
kb = 1.38064852*10^-23;
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

%   CL = x(end-1);
%   CH = x(end);
% Functions needed in measurement grid

% Transmission 

exponent = 4+B+C*Lambda+D/Lambda;
sigma_Rcm2 = A / Lambda^(exponent);
sigmaNicolet = sigma_Rcm2*1e-4;%m2
Nmol = (NA/M).* Q.rho ; % mol m-3
alpha_aero = Q.alpha_aero';
odaer = Q.odaer';

tauMol = exp(-2.*cumtrapz(Q.Zmes,Nmol*sigmaNicolet));
tauAer = exp(-2.*odaer);
Tr1 = tauMol.*tauAer';
% m^-1 this is aerosol coefficient given in Povey etal
% alpha_aero(isnan(alpha_aero))=0;

sigma_tot = Nmol*sigmaNicolet+ alpha_aero;

% %  Tr1 = exp(-2.*cumtrapz(Q.Zmes,alpha_aero)); % Molecular transmission
%  Tr = exp(-2.*cumtrapz(Q.Zmes,Nmol*sigmaNicolet)); % Molecular transmission
 Tr = exp(-2.*cumtrapz(Q.Zmes,sigma_tot)); % Molecular transmission