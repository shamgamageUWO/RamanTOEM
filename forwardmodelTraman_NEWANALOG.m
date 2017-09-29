% This code is to create synthetic data using the US standard data

function [JL,JH,JLa,JHa,A_Zi_an,A_Zi_d,B_Zi_an,B_Zi_d,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman_NEWANALOG(Q,x)

m = length(Q.Zret);
% %     % retrieve CJH independtly 
x_a = x(1:m);
BJH = x(m+1);
BJL = x(m+2);
CJL = x(m+3);
OV = x(m+4:end-4);
BJHa = x(end-3);
BJLa = x(end-2);
% CJLa = x(end-2);
DT_JH = x(end-1);
DT_JL = x(end); % deadtimes


% interpolation
Ti = interp1(Q.Zret,x_a,Q.Zmes,'linear'); % T on data grid (digital)
OV_Zi = interp1(Q.Zret,OV,Q.Zmes,'linear');


%%
% Constants
kb = 1.38064852*10^-23;
area = pi * (0.3^2);
% Transmission
R_tr_i = (Q.Tr);

% Define the first part of the equation 
N1 = length(Q.Zmes1);
% NN1 = length();
% N2 = length(Q.JHnew); fr=OV_Zi(Q.d_alti_Diff+1:end);

 A_Zi_an = (area .* OV_Zi(1:N1) .*R_tr_i(1:N1) .*Q.Pressi(1:N1))./(kb * Q.Zmes1 .^2);
% A_Zi_an = (area .* OVa' .*R_tr_i(1:N1) .*Q.Pressi(1:N1))./(kb * Q.Zmes1 .^2);
B_Zi_an = (area .*R_tr_i(1:N1) .*Q.Pressi(1:N1))./(kb * Q.Zmes1 .^2); % No overlap

A_Zi_d = (area .* OV_Zi(Q.d_alti_Diff+1:end) .*R_tr_i(Q.d_alti_Diff+1:end) .*Q.Pressi(Q.d_alti_Diff+1:end))./(kb * Q.Zmes2 .^2);
% % A_Zi_an = (area .* OV_Zi(1:N1) .*R_tr_i(1:N1) .*Q.Pressi(1:N1))./(kb * Q.Zmes1 .^2);
% % % B_Zi_an = (area .*R_tr_i(1:N1) .*Q.Pressi(1:N1))./(kb * Q.Zmes1 .^2); % No overlap
% % 
% % A_Zi_d = (area .* OV_Zi(N1+1:end) .*R_tr_i(N1+1:end) .*Q.Pressi(N1+1:end))./(kb * Q.Zmes2 .^2);
B_Zi_d = (area .*R_tr_i(Q.d_alti_Diff+1:end) .*Q.Pressi(Q.d_alti_Diff+1:end))./(kb * Q.Zmes2 .^2); % No overlap

%% loading cross sections
load('DiffCrossSections.mat');
Diff_JH_i = interp1(T,Diff_JH,Ti,'linear');
Diff_JL_i = interp1(T,Diff_JL,Ti,'linear');
% toc


CJH = (Q.R).* CJL;
% CJHa = (Q.Ra).* CJLa;
% 

JL = (CJL.* A_Zi_d .* Diff_JL_i(Q.d_alti_Diff+1:end))./(Ti(Q.d_alti_Diff+1:end));
JH = (CJH.* A_Zi_d .* Diff_JH_i(Q.d_alti_Diff+1:end))./(Ti(Q.d_alti_Diff+1:end));

JLa = (CJL.* A_Zi_an .* Diff_JL_i(1:N1) )./(Ti(1:N1) );
JHa = (CJH.* A_Zi_an .* Diff_JH_i(1:N1) )./(Ti(1:N1) );



% Q.f = Q.Clight ./ (2.*(Q.Rate).*Q.altbinsize);
% 
%  % Add true background to the counts 
%  % Convert observed bg to true only for Digital, apply DS
% BJL_t = BJL./(1-BJL.*Q.f.*DT_JL);
% BJH_t = BJH./(1-BJH.*Q.f.*DT_JH);
JL = JL  + BJL;
JH = JH  + BJH;
% 

a_JL = 1.3e20;
b_JL = 8.6e3;
JLa = (JLa  + BJL - b_JL)./a_JL;
JHa = JHa  + BJH;
% 
        %% Saturation correction is applied for the averaged count profile This is just for digital channel
        % 1. Make the Co added counts to avg counts
        JH = JH./(Q.deltatime.*Q.coaddalt);
        JL = JL./(Q.deltatime.*Q.coaddalt);
        
        % 2. Convert counts to Hz
        JHnw = (JH.*Q.f);
        JLnw = (JL.*Q.f);
        
        % 3. Apply DT
        JL_dtc = JLnw ./ (1 + JLnw.*(DT_JL)); % non-paralyzable
        JH_dtc = JHnw ./ (1 + JHnw.*(DT_JH));
          % 4. Convert to counts
           JL = JL_dtc.*(1./Q.f);
           JH = JH_dtc.*(1./Q.f);
       % 5. Scale bacl to coadded signal    
       JL = JL.*(Q.deltatime.*Q.coaddalt);
       JH = JH.*(Q.deltatime.*Q.coaddalt);
       
%  % Add background to the counts 
% JL = JL  + BJL;
% JH = JH  + BJH;




return

 

