% This code is to create synthetic data using the US standard data

function [JL,JH,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x)
% crosssection 
% DiffInput  = Diff_cross_fun;
m = length(Q.Zret);
 % temperature
x_a = x(1:m);
CJL = x(m+3);
OV = x(m+4:end-1);
BJL = x(m+2);
BJH = x(m+1);
DT = x(end);
Ti = interp1(Q.Zret,x_a,Q.Zmes,'linear'); % T on data grid (digital)
OV_Zi = interp1(Q.Zret,OV,Q.Zmes,'linear');

% Constants
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



R_tr_i = (Q.Tr);


% Define the first part of the equation 

A_Zi = ( OV_Zi .*R_tr_i .*Q.Pressi)./(kb * Q.Zmes .^2);
B_Zi = ( R_tr_i .*Q.Pressi)./(kb * Q.Zmes .^2); % No overlap

% % Differential cross section term 

%     [diff_O2Ls,diff_O2Las] = RR_differentialO2_JL(J_lowO2,Ti); % JL Oxygen 
%     [diff_O2Hs,diff_O2Has] = RR_differentialO2_JH(J_highO2,Ti);% JH Oxygen
%     [diff_N2Ls,diff_N2Las] = RR_differentialN2_JL(J_low,Ti);% JL Nitrogen
%     [diff_N2Hs,diff_N2Has] = RR_differentialN2_JH(J_high,Ti);% JH Nitrogen
%     Diff_JLN2 = nansum(diff_N2Ls') + nansum(diff_N2Las') ; % new unit is in m^2
%     Diff_JLO2 = nansum(diff_O2Ls') + nansum(diff_O2Las') ; % new unit is in m^2
%     Diff_JL_i =  Diff_JLO2 + Diff_JLN2;
%     Diff_JHN2 = nansum(diff_N2Hs') + nansum(diff_N2Has') ; % new unit is in m^2
%     Diff_JHO2 = nansum(diff_O2Hs') + nansum(diff_O2Has') ; % new unit is in m^2
%     Diff_JH_i =  Diff_JHO2 + Diff_JHN2; 

% tic
load('DiffCrossSections.mat');
Diff_JH_i = interp1(T,Diff_JH,Ti,'linear');
Diff_JL_i = interp1(T,Diff_JL,Ti,'linear');
% toc


CH = (Q.R).* CJL;
JL = (CJL.*A_Zi .* Diff_JL_i)./(Ti);
JH = (CH.* A_Zi .* Diff_JH_i)./(Ti);





Q.f = Q.Clight ./ (2.*(Q.Rate).*Q.altbinsize);


% 
        %% Saturation correction is applied for the averaged count profile
        % 1. Make the Co added counts to avg counts
        JH = JH./(Q.deltatime.*Q.coaddalt);
        JL = JL./(Q.deltatime.*Q.coaddalt);
        
        % 2. Convert counts to Hz
        JHnw = (JH.*Q.f);
        JLnw = (JL.*Q.f);
        
        % 3. Apply DT
        JL_dtc = JLnw ./ (1 + JLnw.*( DT )); % non-paralyzable
        % JL = JL .* exp(-JLnw.*(4e-9)); % paralyzable %units is counts
        JH_dtc = JHnw ./ (1 + JHnw.*( DT ));
          % 4. Convert to counts
           JL = JL_dtc.*(1./Q.f);
           JH = JH_dtc.*(1./Q.f);
       % 5. Scale bacl to coadded signal    
       JL = JL.*(Q.deltatime.*Q.coaddalt);
       JH = JH.*(Q.deltatime.*Q.coaddalt);
       
 % Add background to the counts 
JL = JL  + BJL;
JH = JH  + BJH;
 


