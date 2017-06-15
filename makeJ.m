function [R,yf,J] = makeJ(Q, R, x, iter)


[JL,JH,JLa,JHa,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x);


if ~isempty(find(isnan(x)) == 1)
    'after FM: Nans in retrieval vector (FMwv(n).m)'
    iter
    stop
end



n1=Q.n1; %length JH
n2=Q.n2; %length JL
n3 =Q.n3;
n4 =Q.n4;

n = n1+n2+n3+n4;
m = length(Q.Zret);
yf = [JH JL JHa JLa]';

% Temperature Jacobian 
J = zeros(n,m);

for j = 1:m 
    [dJH,dJL,dJHa,dJLa] = deriCountsOEM(j,Q,x,@forwardmodelTraman);
    
   J(1:n1,j) = dJH;
   J(n1+1:n1+n2,j) = dJL;
   J(n1+n2+1:n1+n2+n3,j) = dJHa;
   J(n1+n2+n3+1:n,j) = dJLa;
% j
% disp('ok')
end

%% BG jacobians Analytical 
% ones need to be multiplied by the deadtime term: refer notes 
Kb_JH = (((1-Q.deadtime.*JL).^2))'; %ones(n1,1).* 
Kb_JL =  (((1-Q.deadtime.*JH).^2))'; %ones(n2,1).*
Kb_JHa =  ones(n3,1); 
Kb_JLa =  ones(n4,1);
%zeros(n-n2,1)]; % fix the lengths

% Jacobian for CL

% Analytical Method Using R and the deadtime term should be included
% OV = x(end+1-(Q.OVlength):end);
%             KCL11 = ((A_Zi.*Diff_JL_i)./Ti).*((1-Q.deadtime.*JL).^2);
            KCL11 = ((A_Zi.*Diff_JL_i)./Ti).*((1-Q.deadtime.*JL).^2);%.*exp(logCJL);
            KCL22 = ((Q.R.*A_Zi.*Diff_JH_i)./Ti).*((1-Q.deadtime.*JH).^2);%.*exp(logCJL); %% Note I have applied the cutoff for JH here
            KCL= [KCL22 KCL11];
            
            
            
            KCLa11 = ((A_Zi.*Diff_JL_i)./Ti);%.*exp(logCJL);
            KCLa22 = ((Q.Ra.*A_Zi.*Diff_JH_i)./Ti);%.*exp(logCJL); %% Note I have applied the cutoff for JH here
            KCLa= [KCLa22 KCLa11];
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

for j = 1:m 
    [dOVJH,dOVJL,dOVJHa,dOVJLa] = deriCountsOV(j,Q,x,@forwardmodelTraman);
    
   JOV(1:n1,j) = dOVJH;
   JOV(n1+1:n1+n2,j) = dOVJL;
   JOV(n1+n2+1:n1+n2+n3,j) = dOVJHa;
   JOV(n1+n2+n3+1:n,j) = dOVJLa;
% j
% disp('ok')
end

%% Final Jacobian
% JJ = [ J(1:n,1:m) Kb_JL zeros(n,1);J(n+1:2*n,1:m) zeros(n,1) Kb_JH];last
% working version
JJJH = [ J(1:n1,1:m) Kb_JH zeros(n1,1) KCL22' JOV(1:n1,1:m) zeros(n1,3)];
JJJL = [J(n1+1:n1+n2,1:m) zeros(n2,1) Kb_JL KCL11' JOV(n1+1:n1+n2,1:m) zeros(n1,3) ];
JJJHa = [ J(n1+n2+1:n1+n2+n3,1:m) zeros(n2,3) JOV(n1+n2+1:n1+n2+n3,1:m) Kb_JHa zeros(n1,1) KCLa22'];
JJJLa = [J(n1+n2+n3+1:n,1:m) zeros(n3,3) JOV(n1+n2+n3+1:n,1:m) zeros(n1,1) Kb_JLa KCLa11'];

J = [JJJH;JJJL;JJJHa;JJJLa];



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



