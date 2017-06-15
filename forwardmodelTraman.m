% This code is to create synthetic data using the US standard data

function [JL,JH,JLa,JHa,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x)

m = length(Q.Zret);
% temperature
x_a = x(1:m);
BJH = x(m+1);
BJL = x(m+2);
CJL = x(m+3);
OV = x(m+4:end-3);
BJHa = x(end-2);
BJLa = x(end-1);
CJLa = x(end);

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

A_Zi = (area .* OV_Zi .*R_tr_i .*Q.Pressi)./(kb * Q.Zmes .^2);
B_Zi = (area .*R_tr_i .*Q.Pressi)./(kb * Q.Zmes .^2); % No overlap


%% loading cross sections
load('DiffCrossSections.mat');
Diff_JH_i = interp1(T,Diff_JH,Ti,'linear');
Diff_JL_i = interp1(T,Diff_JL,Ti,'linear');
% toc


CH = (Q.R).* CJL;
CHa = (Q.Ra).* CJLa;

JL = (CJL.*A_Zi .* Diff_JL_i)./(Ti);
JH = (CH.* A_Zi .* Diff_JH_i)./(Ti);

JLa = (CJLa.*A_Zi .* Diff_JL_i)./(Ti);
JHa = (CHa.* A_Zi .* Diff_JH_i)./(Ti);



Q.f = Q.Clight ./ (2.*(Q.Rate).*Q.altbinsize);


% 
        %% Saturation correction is applied for the averaged count profile This is just for digital channel
        % 1. Make the Co added counts to avg counts
        JH = JH./(Q.deltatime.*Q.coaddalt);
        JL = JL./(Q.deltatime.*Q.coaddalt);
        
        % 2. Convert counts to Hz
        JHnw = (JH.*Q.f);
        JLnw = (JL.*Q.f);
        
        % 3. Apply DT
        JL_dtc = JLnw ./ (1 + JLnw.*(Q.deadtime)); % non-paralyzable
        % JL = JL .* exp(-JLnw.*(4e-9)); % paralyzable %units is counts
        JH_dtc = JHnw ./ (1 + JHnw.*(Q.deadtime));
          % 4. Convert to counts
           JL = JL_dtc.*(1./Q.f);
           JH = JH_dtc.*(1./Q.f);
       % 5. Scale bacl to coadded signal    
       JL = JL.*(Q.deltatime.*Q.coaddalt);
       JH = JH.*(Q.deltatime.*Q.coaddalt);
       
 % Add background to the counts 
JL = JL  + BJL;
JH = JH  + BJH;


JLa = JLa  + BJLa;
JHa = JHa  + BJHa;

 


