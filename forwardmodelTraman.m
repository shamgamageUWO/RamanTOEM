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
area = pi * (0.3^2);
% Transmission
R_tr_i = (Q.Tr);

A_Zi_d = (area .* OV_Zi .*R_tr_i .*Pdigi)./(kb * Q.Zmes2 .^2);
B_Zi_d = (area .*R_tr_i .*Pdigi)./(kb * Q.Zmes2 .^2); % No overlap

%% loading cross sections
load('DiffCrossSections.mat');
Diff_JH_i = interp1(T,Diff_JH,Ti,'linear');
Diff_JL_i = interp1(T,Diff_JL,Ti,'linear');
% toc


CJH = (Q.R).* CJL;

JL = (CJL.* A_Zi_d .* Diff_JL_i)./(Ti);
JH = (CJH.* A_Zi_d .* Diff_JH_i)./(Ti);
       
%  % Add true background to the digital counts 
JL = JL  + BJL;
JH = JH  + BJH;

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


return

 


