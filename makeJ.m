function [R,yf,J] = makeJ(Q, R, x, iter)

m = length(Q.Zret);
% m1 = m+ 2; % background terms are retrieved too
% n = length(Q.Zmes);


[JL,JH,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x);
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

yf = [JH JL]';

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
Kb_JH = ((1-Q.deadtime.*JL).^2)'; %ones(n1,1).* 
Kb_JL =  ((1-Q.deadtime.*JH).^2)'; %ones(n2,1).*
%zeros(n-n2,1)]; % fix the lengths

% Jacobian for CL
% Analytical Method Using R and the deadtime term should be included
            KCL11 = ((A_Zi.*Diff_JL_i)./Ti).*((1-Q.deadtime.*JL).^2);
            KCL22 = ((Q.R .*B_Zi.*Diff_JH_i)./Ti).*((1-Q.deadtime.*JH).^2); %% Note I have applied the cutoff for JH here
            KCL= [KCL22 KCL11];

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

% figure;plot(KCL

%% Final Jacobian
% JJ = [ J(1:n,1:m) Kb_JL zeros(n,1);J(n+1:2*n,1:m) zeros(n,1) Kb_JH];last
% working version
JJ = [ J(1:n1,1:m) Kb_JH zeros(n1,1);J(n1+1:n,1:m) zeros(n2,1) Kb_JL];

J = [JJ KCL'];

% figure;
% subplot(1,2,1)
% plot(J(1:n1,1:m),Q.Zmes./1000)
% subplot(1,2,2)
% plot(J(n1+1:end,1:m),Q.Zmes./1000)