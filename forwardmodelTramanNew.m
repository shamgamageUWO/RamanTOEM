% This code is to create synthetic data using the US standard data

function [JL,JH,A_Zi_d,B_Zi_d,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x)

m = length(Q.Zret);
x_a = x(1:m);
BJH = x(m+1);
BJL = x(m+2);
CJL = x(m+3);
OV = x(m+4:end-2);
DT_JH = x(end-1);
DT_JL = x(end); % deadtimes


% interpolation
Ti = interp1(Q.Zret,x_a,Q.Zmes,'linear'); % T on data grid (digital)
OV_Zi = interp1(Q.Zret,OV,Q.Zmes,'linear');

[Pdigi,p0A] = find_pHSEQ(Q.z0,Q.Zmes,Ti,Q.Pressi,0,Q.grav',Q.MoR);

%%
% Constants
kb = 1.38064852*10^-23;
% area = pi * (0.3^2);
% Transmission
R_tr_i = (Q.Tr);

A_Zi_d = ( OV_Zi .*R_tr_i .*Pdigi)./(kb * Q.Zmes2 .^2);
B_Zi_d = (R_tr_i .*Pdigi)./(kb * Q.Zmes2 .^2); % No overlap

%% loading cross sections
load('DiffCrossSections.mat');
Diff_JH_i = interp1(T,Diff_JH,Ti,'linear');
Diff_JL_i = interp1(T,Diff_JL,Ti,'linear');
% toc


CJH = (Q.R).* CJL;

JL = (CJL.* A_Zi_d .* Diff_JL_i)./(Ti);
JH = (CJH.* A_Zi_d .* Diff_JH_i)./(Ti);
       
%  % Add true background to the digital counts 
JL1 = JL  + BJL;
JH1 = JH  + BJH;

% figure;semilogx(JL1,Q.Zmes./1000,'r')
% hold on
% 
        %% Saturation correction is applied for the averaged count profile This is just for digital channel
        % 1. Make the Co added counts to avg counts
        JH_C = JH1./(Q.deltatime.*Q.coaddalt); % counts
        JL_C = JL1./(Q.deltatime.*Q.coaddalt);
        
        % 2. Convert counts to Hz
        JHHz = (JH_C.*Q.f);
        JLHz = (JL_C.*Q.f);
%         figure;semilogx(JLHz./1e6,Q.Zmes./1000,'r',JHHz./1e6,Q.Zmes./1000,'b')
        % 3. Apply DT
        JL_dtc = JL_C .*exp(-JLHz.* DT_JL); % non-paralyzable
%          figure;plot(JL_C-JL_dtc,Q.Zmes./1000,'b')
        JH_dtc = JH_C .*exp(-JHHz.*DT_JH);
        
%           % 4. Convert to counts
%            JL = JL_dtc.*(1./Q.f);
%            JH = JH_dtc.*(1./Q.f);
       % 5. Scale bacl to coadded signal    
       JL = JL_dtc.*(Q.deltatime.*Q.coaddalt);
       JH = JH_dtc.*(Q.deltatime.*Q.coaddalt);
       
% figure;plot(JL1-JL,Q.Zmes./1000,'b')
% hold off;

return

 


