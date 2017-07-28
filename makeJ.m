function [R,yf,J] = makeJ(Q, R, x, iter)


[JL,JH,JLa,JHa,A_Zi_an,A_Zi_d,B_Zi_an,B_Zi_d,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x);


if ~isempty(find(isnan(x)) == 1)
    'after FM: Nans in retrieval vector (FMwv(n).m)'
    iter
    stop
end



n1=Q.n1; %length JH
n2=Q.n2; %length JL
n3 =Q.n3; % length JHa
n4 =Q.n4;

n = n1+n2+n3+n4;
m = length(Q.Zret);
yf = [JH JL JHa JLa]';

% Temperature Jacobian 
Jc = zeros(n,m);

for j = 1:m 
    [dJH,dJL,dJHa,dJLa] = deriCountsOEM(j,Q,x,@forwardmodelTraman);
    
   Jc(1:n1,j) = dJH;
   Jc(n1+1:n1+n2,j) = dJL;
   Jc(n1+n2+1:n1+n2+n3,j) = dJHa;
   Jc(n1+n2+n3+1:n,j) = dJLa;
% j
% disp('ok')
end

DT_JH = x(end-1);
DT_JL = x(end);
%% BG jacobians Analytical 
% ones need to be multiplied by the deadtime term: refer notes 
Kb_JH = (((1-DT_JH.*JH).^2))'; %ones(n1,1).* 
Kb_JL =  (((1-DT_JL.*JL).^2))'; %ones(n2,1).*
Kb_JHa =  ones(n3,1); 
Kb_JLa =  ones(n4,1);
%zeros(n-n2,1)]; % fix the lengths

% Jacobian for CL

% Analytical Method Using R and the deadtime term should be included
% OV = x(end+1-(Q.OVlength):end);

 
%% Note here first set of altitude dependent terms such as Ti, OV are related to the analog channel. don't get confused with the indices here.
%                 %% Digital
%                 KCL11 = ((A_Zi_d.*Diff_JL_i(n3+1:end))./Ti(n3+1:end)).*((1-Q.deadtime.*JL).^2);%.*exp(logCJL);
%                 KCL22 = ((Q.R.*A_Zi_d.*Diff_JH_i(n3+1:end))./Ti(n3+1:end)).*((1-Q.deadtime.*JH).^2);%.*exp(logCJL); %% Note I have applied the cutoff for JH here
%                 %             KCL = [KCL22 KCL11];
% 
% 
%                 %% Analog
%                 KCLa11 = ((A_Zi_an.*Diff_JL_i(1:n3))./Ti(1:n3));%.*exp(logCJL);
%                 KCLa22 = ((Q.Ra.*A_Zi_an.*Diff_JH_i(1:n3))./Ti(1:n3));%.*exp(logCJL); %% Note I have applied the cutoff for JH here
%                 %             KCLa = [KCLa22 KCLa11];
%                 %             KCL = KCL .* exp(logCJL); % this is done as I'm retrieving log of CJL now CJL



%% Digital    
            KCL11 = ((A_Zi_d.*Diff_JL_i(Q.d_alti_Diff+1:end))./Ti(Q.d_alti_Diff+1:end)).*((1-DT_JL.*JL).^2);%.*exp(logCJL);
            KCL22 = ((Q.R.*A_Zi_d.*Diff_JH_i(Q.d_alti_Diff+1:end))./Ti(Q.d_alti_Diff+1:end)).*((1-DT_JH.*JH).^2);%.*exp(logCJL); %% Note I have applied the cutoff for JH here
%             KCL = [KCL22 KCL11];
            
            
%% Analog            
            KCLa11 = ((A_Zi_an.*Diff_JL_i(1:Q.n3))./Ti(1:Q.n3));%.*exp(logCJL);
            KCLa22 = ((A_Zi_an.*Diff_JH_i(1:Q.n3))./Ti(1:Q.n3));


JOV = zeros(n,m);

for jj = 1:m 
   
   [dOVJH,dOVJL,dOVJHa,dOVJLa] = deriCountsOV(jj,Q,x,@forwardmodelTraman);
   JOV(1:n1,jj) = dOVJH;
   JOV(n1+1:n1+n2,jj) = dOVJL;
   JOV(n1+n2+1:n1+n2+n3,jj) = dOVJHa;
   JOV(n1+n2+n3+1:n,jj) = dOVJLa;

end

%% Deadtime jacobian
Jdt1 = zeros(n,1);
Jdt2 = zeros(n,1);

    [dJHdt,dJLdt] = deridt(Q,x,@forwardmodelTraman);
    
   Jdt1(1:n1) = dJHdt;
   Jdt1(n1+1:n) = 0;
%    Jdt1(n1+n2+1:n1+n2+n3) = 0;
%    Jdt1(n1+n2+n3+1:n) = 0;
   
   Jdt2(1:n1) = 0;
   Jdt2(n1+1:n1+n2) = dJLdt;
   Jdt2(n1+n2+1:n) = 0;
%    Jdt2(n1+n2+n3+1:n) = 0;
% j
% disp('ok')

%%

%% Final Jacobian
% JJ = [ J(1:n,1:m) Kb_JL zeros(n,1);J(n+1:2*n,1:m) zeros(n,1) Kb_JH];last
% working version
% JJJH = [ Jc(1:n1,1:m) Kb_JH zeros(n1,1) KCL22' JOV(1:n1,1:m) zeros(n1,3)];
% JJJL = [Jc(n1+1:n1+n2,1:m) zeros(n2,1) Kb_JL KCL11' JOV(n1+1:n1+n2,1:m) zeros(n1,3) ];
% JJJHa = [ Jc(n1+n2+1:n1+n2+n3,1:m) zeros(n2,3) JOV(n1+n2+1:n1+n2+n3,1:m) Kb_JHa zeros(n1,1) KCLa22'];
% JJJLa = [Jc(n1+n2+n3+1:n,1:m) zeros(n3,3) JOV(n1+n2+n3+1:n,1:m) zeros(n1,1) Kb_JLa KCLa11'];
% 
% J = [JJJH;JJJL;JJJHa;JJJLa];


 % When retrieving CJH independtly
 
% % % %     J_counts = Jc;
% % % % 
% % % %     J_JH = [Kb_JH;zeros(n2+n3+n4,1)];
% % % % 
% % % %     J_JL = [zeros(n1,1);Kb_JL;zeros(n3+n4,1)];
% % % % 
% % % %     KCL1 = [KCL22 KCL11];
% % % %     KCL = [KCL1 zeros(1,n3+n4)];
% % % % 
% % % %     J_OV = JOV;
% % % % 
% % % %     J_JHa = [zeros(n1+n2,1);Kb_JHa;zeros(n4,1)];
% % % % 
% % % %     J_JLa = [zeros(n1+n2+n3,1);Kb_JLa];
% % % % 
% % % %     % KCLa1 = [KCLa22 KCLa11];
% % % % 
% % % %     KCHa = [zeros(1,n1+n2) KCHa zeros(1,n4)];
% % % %     KCLa = [zeros(1,n1+n2+n3) KCLa];
% % % % 
% % % %     J = [J_counts J_JH J_JL KCL' J_OV J_JHa J_JLa KCHa' KCLa'];

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

%% coupled analog
J_counts = Jc;

J_JH = [Kb_JH;zeros(n2+n3+n4,1)];

J_JL = [zeros(n1,1);Kb_JL;zeros(n3+n4,1)];

KCL1 = [KCL22 KCL11];
KCL = [KCL1 zeros(1,n3+n4)];

J_OV = JOV;

J_JHa = [zeros(n1+n2,1);Kb_JHa;zeros(n4,1)];

J_JLa = [zeros(n1+n2+n3,1);Kb_JLa];

% KCLa1 = [KCLa22 KCLa11];
% KCLa = [zeros(1,n1+n2) KCLa1];

KCHa = [zeros(1,n1+n2) KCLa22 zeros(1,n4)];
KCLa = [zeros(1,n1+n2+n3) KCLa11];
 
J = [J_counts J_JH J_JL KCL' J_OV J_JHa J_JLa KCHa' KCLa' Jdt1 Jdt2];


