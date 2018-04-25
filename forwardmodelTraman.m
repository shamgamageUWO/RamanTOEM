% This code is to create synthetic data using the US standard data

function [JL,JH,JLa,JHa,A_Zi_an,A_Zi_d,B_Zi_an,B_Zi_d,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x)
m = length(Q.Zret);
x_a = x(1:m);
BJH = x(m+1);
BJL = x(m+2);
CJL = x(m+3);
OV = x(m+4:2*m+3);
BJHa = x(2*m+4);
BJLa = x(2*m+5);
CJLa = x(2*m+6);
DT_JH = x(2*m+7);
DT_JL = x(2*m+8); % deadtimes
alpha_aero = x(2*m+9 :end);


% interpolation
% Td = interp1(Q.Zret,x_a,Q.Zmes2,'linear'); % T on data grid (digital)
% Ta = interp1(Q.Zret,x_a,Q.Zmes1,'linear');
Ti = interp1(Q.Zret,x_a,Q.Zmes,'linear');
Td= Ti(end-length(Q.JHnew)+1:end);
Ta= Ti(1:length(Q.JHnewa));

OV_Zi = interp1(Q.Zret,OV,Q.Zmes,'linear');

OV_Zid = OV_Zi(end-length(Q.JHnew)+1:end);%interp1(Q.Zret,OV,Q.Zmes2,'linear');
OV_Zia = OV_Zi(1:length(Q.JHnewa));%interp1(Q.Zret,OV,Q.Zmes1,'linear');

%%
% Constants
kb = 1.38064852*10^-23;

% Total calculation Transmission
alpha_aero1 = interp1(Q.Zret,alpha_aero,Q.Zmes,'linear');
sigma_tot = Q.alpha_mol + alpha_aero1;
R_tr_i  = exp(-2.*cumtrapz(Q.Zmes,sigma_tot)); % Molecular transmission


R_tr_id = R_tr_i(end-length(Q.JHnew)+1:end);%interp1(Q.Zmes,R_tr_i,Q.Zmes2,'linear');
R_tr_ia = R_tr_i(1:length(Q.JHnewa));%interp1(Q.Zmes,R_tr_i,Q.Zmes1,'linear');



Pd = Q.Pressi(end-length(Q.JHnew)+1:end);%exp(Pdigid);
Pa = Q.Pressi(1:length(Q.JHnewa));%exp(Pdigia);


A_Zi_an = ( OV_Zia .*R_tr_ia .*Pa)./(kb * Q.Zmes1 .^2);
B_Zi_an = (R_tr_ia .*Pa)./(kb * Q.Zmes1 .^2); % No overlap

A_Zi_d = (OV_Zid .*R_tr_id .*Pd)./(kb * Q.Zmes2 .^2);
B_Zi_d = (R_tr_id .*Pd)./(kb * Q.Zmes2 .^2); % No overlap

%% loading cross sections
load('DiffCrossSections.mat');
Diff_JH_i = interp1(T,Diff_JH,Ti,'linear');
Diff_JL_i = interp1(T,Diff_JL,Ti,'linear');


dJHd = Diff_JH_i(end-length(Q.JHnew)+1:end);%interp1(Q.Zmes,Diff_JH_i,Q.Zmes2,'linear');
dJLd = Diff_JL_i(end-length(Q.JHnew)+1:end);%interp1(Q.Zmes,Diff_JL_i,Q.Zmes2,'linear');

dJHa = Diff_JH_i(1:length(Q.JHnewa));%interp1(Q.Zmes,Diff_JH_i,Q.Zmes1,'linear');
dJLa = Diff_JL_i(1:length(Q.JHnewa));%interp1(Q.Zmes,Diff_JL_i,Q.Zmes1,'linear');


% toc


CJH = (Q.R).* CJL;
CJHa = (Q.Ra).* CJLa;
% 

JL = (CJL.* A_Zi_d .* dJLd)./(Td);
JH = (CJH.* A_Zi_d .* dJHd)./(Td);

JLa = (CJLa.* A_Zi_an .* dJLa )./(Ta );
JHa = (CJHa.* A_Zi_an .* dJHa )./(Ta );


       
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

%  % Add background to the analog signal

JLa = JLa  + BJLa;
JHa = JHa  + BJHa;

return

 


