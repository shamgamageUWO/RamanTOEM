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

%%
% %xa
                   %%% x_a = [Q.Ta (Q.BaJH) (Q.BaJL) log(Q.CL) Q.OVa]; % now im retrieving log of CJL
x_a = [Q.Ta Q.OVa Q.BaJHa Q.BaJLa Q.CLa]; % now im retrieving log of CJL

% x_a = [Q.Ta Q.BaJH Q.BaJL Q.CL Q.OVa Q.BaJHa Q.BaJLa Q.CHa Q.CLa]; %  CJHa
m = length(Q.Ta);
% S_a and S_ainv

[S_aT]=TestTempCov(Q.Zret,Q.Ta);
% % %                 %%
% % %                 Sa_BG_JH = [zeros(1,m) (Q.CovBJH)  zeros(1,m+6)]';
% % %                 Sa_BG_JL = [zeros(1,m+1) (Q.CovBJL) zeros(1,m+5)]';
% % %                 Sa_BG_JHa = [zeros(1,2*m+3) (Q.CovBJHa)  0 0 0]';
% % %                 Sa_BG_JLa = [zeros(1,2*m+4) (Q.CovBJLa) 0 0]';
% % % 
% % %                 empTy= zeros(1,m+7);
% % %                 B = repmat(empTy',1,m);
% % %                 Sa_Tnew = [S_aT;B];
% % % 
% % % 
% % %                 %%
% % % 
% % % 
% % %                 Sa_CL = [zeros(1,m+2) Q.CovCL zeros(1,m+4)]; %% even here I have changed to the log version
% % %                 Sa_CHa = [zeros(1,2*m+5) Q.CovCHa 0]; %% even here I have changed to the log version
% % %                 Sa_CLa = [zeros(1,2*m+6) Q.CovCLa]; %% even here I have changed to the log version
% % % 
% % %                 empTya= zeros(1,m+3);
% % %                 empTyb= zeros(1,4);
% % %                 B1 = repmat(empTya',1,m);
% % %                 B2 = repmat(empTyb',1,m);
% % %                 % Tent function for OV cov
% % %                 Sa_OV = Q.COVa;
% % %                 Sa_OV = [B1;Sa_OV;B2];
% % % 
% % %                 S_a = [Sa_Tnew Sa_BG_JH Sa_BG_JL Sa_CL' Sa_OV Sa_BG_JHa Sa_BG_JLa Sa_CHa' Sa_CLa'];% S_ainv = S_a^(-1);
% % % 
% % %                 %Se and S_einv




%%
%%
% Sa_BG_JH = [zeros(1,m) (Q.CovBJH)  zeros(1,m+7)]';
% Sa_BG_JL = [zeros(1,m+1) (Q.CovBJL) zeros(1,m+6)]';
Sa_BG_JHa = [zeros(1,2*m) (Q.CovBJHa) 0 0]';
Sa_BG_JLa = [zeros(1,2*m+1) (Q.CovBJLa) 0]';

empTy= zeros(1,m+3);
B = repmat(empTy',1,m);
Sa_Tnew = [S_aT;B];


%%


% Sa_CL = [zeros(1,m+2) Q.CovCL zeros(1,m+5)]; %% even here I have changed to the log version
% Sa_CHa = [zeros(1,2*m+5) Q.CovCHa]; %% even here I have changed to the log version
Sa_CLa = [zeros(1,2*m+2) Q.CovCLa]; %% even here I have changed to the log version

% Sa_DT_JH = [zeros(1,2*m+6) Q.CovDTJH 0];
% Sa_DT_JL = [zeros(1,2*m+7) Q.CovDTJL];

empTya= zeros(1,m);
empTyb= zeros(1,3);
B1 = repmat(empTya',1,m);
B2 = repmat(empTyb',1,m);
% Tent function for OV cov
Sa_OV = Q.COVa;
Sa_OV = [B1;Sa_OV;B2];

S_a = [Sa_Tnew Sa_OV Sa_BG_JHa Sa_BG_JLa Sa_CLa'];% S_ainv = S_a^(-1);

%Se and S_einv

Se = Q.yvar;
% Seinv = Se^(-1);

% %Jacobians
% x_i = interp1(Q.Zret,x_a,Q.Zmes,'linear');
%   [R,yf,J] = makeJ(Q, R, x_a, iter);
 
%   [R,yf,J]  = feval( @makeJ, Q, R, x_a, iter );

disp('All inputs ready for OEM.m ')
end 

% %  [X,R] = oem(O,Q,R,@makeJ,S_a,Se,S_ainv,Seinv,x_a,Y.Y);