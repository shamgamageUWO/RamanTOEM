function [R,yf,J] = makeJ(Q, R, x, iter)

m = length(Q.Zret);
% m1 = m+ 2; % background terms are retrieved too
% n = length(Q.Zmes);


[JL,JH,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x);
%  logCJL = x(end-Q.OVlength);
%  OV = x(end+1-(Q.OVlength):end);
%  B_JH = x(end-Q.OVlength-2);
%  B_JL=x(end-Q.OVlength-1);
 % Note A_Zi has OV_Zi in it
 
% figure;semilogx(JL,Q.Zmes./1000,JH,Q.Zmes./1000)

if ~isempty(find(isnan(x)) == 1)
    'after FM: Nans in retrieval vector (FMwv(n).m)'
    iter
    stop
end
% These are defined as there is a cutoff alitude for JH
% n1=length(JL);
% n2=length(JH);
n1=Q.n1; %length JH
n2=Q.n2; %length JL
n = n1+n2;
N = 2*m + 4;
yf = [JH JL]';

% Temperature Jacobian 
J = zeros(n,m);

for j = 1:m 
    [dJH,dJL] = deriCountsOEM(j,Q,x,@forwardmodelTraman);
    
   J(1:n1,j) = dJH;
   J(n1+1:n,j) = dJL;
% j
% disp('ok')
end

%% BG jacobians Analytical 
% ones need to be multiplied by the deadtime term: refer notes 
Kb_JH = (((1-x(end).*JL).^2))'; %ones(n1,1).* 
Kb_JL =  (((1-x(end).*JH).^2))'; %ones(n2,1).*
%zeros(n-n2,1)]; % fix the lengths

% Jacobian for CL
% Analytical Method Using R and the deadtime term should be included
% OV = x(end+1-(Q.OVlength):end);
%             KCL11 = ((A_Zi.*Diff_JL_i)./Ti).*((1-Q.deadtime.*JL).^2);
            KCL11 = ((A_Zi.*Diff_JL_i)./Ti).*((1-x(end).*JL).^2);%.*exp(logCJL);
            KCL22 = ((Q.R.*A_Zi.*Diff_JH_i)./Ti).*((1-x(end).*JH).^2);%.*exp(logCJL); %% Note I have applied the cutoff for JH here
            KCL= [KCL22 KCL11];
%             KCL = KCL .* exp(logCJL); % this is done as I'm retrieving log of CJL now CJL 

% Numerical

%  dCL = Q.CLfac .* x(end-1);
%  dCH = Q.CHfac .* x(end);
%  x(end-1) = x(end-1)+ dCL;
%  x(end) = x(end)+ dCH;
%  
% [y_JL_dCL,y_JH_dCH,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i]=forwardmodelTraman(Q,x);
% 
% KCL1 = (y_JL_dCL-JL)./dCL;
% KCL2 = (y_JH_dCH-JH)./dCH;
% KCL = [KCL1';zeros(length(KCL2),1)];
% KCH = [zeros(length(KCL1),1);KCL2'];


%% OV jacobians Analytical --- Interpolation need to be added here

% JOVJL = ((CJL.*B_Zi.*Diff_JL_i)./Ti).*((1-Q.deadtime.*JL).^2);
% JOVJH = ((Q.R.*CJL.*B_Zi.*Diff_JH_i)./Ti).*((1-Q.deadtime.*JL).^2);

% OV analytical
JOV = zeros(n,m);
% [dSHdxA,dSNdxA,dSHdx,dSNdx] = derivSHSN2(Q,x,n-5,@forwardModelWV);
for j = 1:m 
    [dOVJH,dOVJL] = deriCountsOV(N-1,Q,x,@forwardmodelTraman);
    
   JOV(1:n1,j) = dOVJH;
   JOV(n1+1:n,j) = dOVJL;
% j
% disp('ok')
end

%% Deadtime jacobian
% JDT = zeros(n,m);
% 
% for j = 1:m 
  [dDTJH,dDTJL] = deriCountsDT(N,Q,x,@forwardmodelTraman);
  JDT= [dDTJH dDTJL];
%    JDT(1:n1,j) = dDTJH;
%    JDT(n1+1:n,j) = dDTJL;
% j
% disp('ok')
% end
%% Final Jacobian
% JJ = [ J(1:n,1:m) Kb_JL zeros(n,1);J(n+1:2*n,1:m) zeros(n,1) Kb_JH];last
% working version
JJ = [ J(1:n1,1:m) Kb_JH zeros(n1,1);J(n1+1:n,1:m) zeros(n2,1) Kb_JL];

 J = [JJ KCL' JOV JDT'];

% figure;
% subplot(1,2,1)
% plot(J(1:n1,1:m),Q.Zmes./1000)
% subplot(1,2,2)
% plot(J(n1+1:end,1:m),Q.Zmes./1000)
% 
% figure;
% subplot(1,2,1)
% plot(JOV(1:n1,1:m),Q.Zmes./1000)
% subplot(1,2,2)
% plot(JOV(n1+1:end,1:m),Q.Zmes./1000)



