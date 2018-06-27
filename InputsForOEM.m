% This is collects all the inputs requires for the oem.m code

function [O,Q,R,S_a,Se,x_a] = InputsForOEM( date_in,time_in,flag)
%set Q
[Q] = makeQsham( date_in,time_in,flag);
%set O 
O = defOreal;

%set R, retrieval structure
R = [];
R.jq = {};
R.ji = {};
iter = 1;

%
% %xa
                   %%% x_a = [Q.Ta (Q.BaJH) (Q.BaJL) log(Q.CL) Q.OVa]; % now im retrieving log of CJL
x_a = [Q.Ta Q.BaJH Q.BaJL Q.CL Q.OVa Q.BaJHa Q.BaJLa Q.CLa Q.deadtimeJH Q.deadtimeJL Q.RHa Q.BaWV Q.BaN2 Q.CWV Q.CN2 Q.OVwva Q.BaWVa Q.BaN2a Q.CWVa Q.CN2a Q.deadtimeWV Q.deadtimeN2 Q.alpha_aero];

m = length(Q.Ta);

% S_a and S_ainv
[S_aT]=TestTempCov(Q.Zret,Q.Ta);
[S_rh]= RHCov(Q.Zret,Q.RHa);
[S_aer]= AeroCov(Q.Zret,Q.alpha_aero,Q.cutoffOV);

%%
Sa_BG_JH = [zeros(1,m) (Q.CovBJH)  zeros(1,4*m+17)]';
Sa_BG_JL = [zeros(1,m+1) (Q.CovBJL) zeros(1,4*m+16)]';
Sa_CL = [zeros(1,m+2) Q.CovCL zeros(1,4*m+15)]; %% even here I have changed to the log version
Sa_BG_JHa = [zeros(1,2*m+3) (Q.CovBJHa)  zeros(1,3.*m+14)]';
Sa_BG_JLa = [zeros(1,2*m+4) (Q.CovBJLa) zeros(1,3.*m+13)]';
Sa_CLa = [zeros(1,2*m+5) Q.CovCLa zeros(1,3.*m+12)]; %% even here I have changed to the log version
Sa_DT_JH = [zeros(1,2*m+6) Q.CovDTJH zeros(1,3.*m+11)];
Sa_DT_JL = [zeros(1,2*m+7) Q.CovDTJL zeros(1,3.*m+10)];

Sa_BG_WV = [zeros(1,3*m+8) (Q.CovBWV)  zeros(1,2*m+9)]';
Sa_BG_N2 = [zeros(1,3*m+9) (Q.CovBN2) zeros(1,2*m+8)]';
Sa_CWV = [zeros(1,3*m+10) Q.CovWV zeros(1,2*m+7)]; %% even here I have changed to the log version
Sa_CN2 = [zeros(1,3*m+11) Q.CovN2 zeros(1,2*m+6)]; %% even here I have changed to the log version

Sa_BG_WVa = [zeros(1,4*m+12) (Q.CovBWVa) zeros(1,m+5)]';
Sa_BG_N2a = [zeros(1,4*m+13) (Q.CovBN2a) zeros(1,m+4)]';

Sa_CWVa = [zeros(1,4*m+14) Q.CovWVa zeros(1,m+3)]; %% even here I have changed to the log version
Sa_CN2a = [zeros(1,4*m+15) Q.CovN2a zeros(1,m+2)]; %% even here I have changed to the log version

Sa_DT_WV = [zeros(1,4*m+16) Q.CovDTWV zeros(1,m+1)];
Sa_DT_N2 = [zeros(1,4*m+17) Q.CovDTN2 zeros(1,m)];


%%

empTy= zeros(1,4*m+18);
B = repmat(empTy',1,m);
Sa_Tnew = [S_aT;B];

empTy1= zeros(1,2*m+8);
empTy2= zeros(1,2*m+10);
Bk = repmat(empTy1',1,m);
Br = repmat(empTy2',1,m);
Sa_RHnew = [Bk;S_rh;Br];


empTya= zeros(1,m+3);
empTyb= zeros(1,3*m+15);
B1 = repmat(empTya',1,m);
B2 = repmat(empTyb',1,m);
Sa_OV = Q.COVa;
Sa_OV = [B1;Sa_OV;B2];



empTyaa= zeros(1,3*m+12);
empTybb= zeros(1,m+6);
B1a = repmat(empTyaa',1,m);
B2a = repmat(empTybb',1,m);
Sa_OVwv = Q.COVwva;
Sa_OVwv = [B1a;Sa_OVwv;B2a];


empTycc= zeros(1,4*m+18);
B1aa = repmat(empTycc',1,m);
Sa_aer = [B1aa;S_aer];



S_a = [Sa_Tnew Sa_BG_JH Sa_BG_JL Sa_CL' Sa_OV Sa_BG_JHa Sa_BG_JLa Sa_CLa' Sa_DT_JH' Sa_DT_JL' Sa_RHnew Sa_BG_WV Sa_BG_N2 Sa_CWV' Sa_CN2' Sa_OVwv Sa_BG_WVa Sa_BG_N2a Sa_CWVa' Sa_CN2a' Sa_DT_WV' Sa_DT_N2' Sa_aer];% S_ainv = S_a^(-1);

%Se and S_einv

Se = Q.yvar;
% Seinv = Se^(-1);

% %Jacobians
% x_i = interp1(Q.Zret,x_a,Q.Zmes,'linear');
%    [R,yf,J] = makeJ(Q, R, x_a, iter);
 
%  [R,yf,J]  = feval( @makeJ, Q, R, x_a, iter );

disp('All inputs ready for OEM.m ')
end 

% %  [X,R] = oem(O,Q,R,@makeJ,S_a,Se,S_ainv,Seinv,x_a,Y.Y);