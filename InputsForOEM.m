% This is collects all the inputs requires for the oem.m code

function [O,Q,R,S_a,Se,x_a] = InputsForOEM( date_in,time_in,flag)


%set Q
 [Q] = makeQsham( date_in,time_in,flag);
% [Q,y,yvar] = makeQ( );
%set O 
O = defOreal;

%set R, retrieval structure
R = [];
R.jq = {};
R.ji = {};
iter = 1;


% %xa
 x_a = [Q.Ta Q.BaJH Q.BaJL Q.CL];
% S_a and S_ainv
[S_aT]=TestTempCov(Q.Zret,Q.Ta);
Sa_BG_JH = [zeros(1,length(S_aT)) Q.CovBJH  0 0]';
Sa_BG_JL = [zeros(1,length(S_aT)+1) Q.CovBJL 0]';
empTy= zeros(1,length(S_aT));
Sa_Tnew = [S_aT empTy' empTy' empTy'];
Sa_CL = [zeros(1,length(S_aT)+2) Q.CovCL ];
% Sa_CH = [zeros(1,length(S_aT)+3) Q.CovCH];
% Sa_CL = [zeros(1,length(S_aT)+2) Q.CovCsum];
S_a = [Sa_Tnew' Sa_BG_JH Sa_BG_JL Sa_CL'];
% S_ainv = S_a^(-1);

%Se and S_einv

Se = Q.yvar;
% Seinv = Se^(-1);

% %Jacobians
% x_i = interp1(Q.Zret,x_a,Q.Zmes,'linear');
  [R,yf,J] = makeJ(Q, R, x_a, iter);
 
  
% [R,yf,J]  = feval( @makeJ, Q, R, x_a, iter );


end 

%% [X,R] = oem(O,Q,R,@makeJ,S_a,Se,S_ainv,Seinv,x_a,Y.Y);