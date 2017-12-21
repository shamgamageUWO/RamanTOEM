function [R,yf,J] = makeJ(Q, R, x, iter)


[JL,JH,A_Zi_d,B_Zi_d,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x);


if ~isempty(find(isnan(x)) == 1)
    'after FM: Nans in retrieval vector (FMwv(n).m)'
    iter
    stop
end



n1=Q.n1; %length JH
n2=Q.n2; %length JL
% n3 =Q.n3; % length JHa
% n4 =Q.n4;

n = n1+n2;
m = length(Q.Zret);
yf = [JH JL]';

% Temperature Jacobian 
Jc = zeros(n,m);

for j = 1:m 
    [dJH,dJL] = deriCountsOEM(j,Q,x,@forwardmodelTraman);
    
   Jc(1:n1,j) = dJH;
   Jc(n1+1:n,j) = dJL;
% j
% disp('ok')
end

% DT_JH = x(end-1);
% DT_JL = x(end);
%% BG jacobians Analytical 
% ones need to be multiplied by the deadtime term: refer notes 
Kb_JH = zeros(n,1);
Kb_JL = zeros(n,1);

    [dJHdbg,dJLdbg] = deriBg(Q,x,@forwardmodelTraman);
    
   Kb_JH(1:n1) = dJHdbg;
   Kb_JH(n1+1:n) = 0;
   Kb_JL(1:n1) = 0;
   Kb_JL(n1+1:n) = dJLdbg;


% Jacobian for CL


[dJHdc,dJLdc] =  deriC(Q,x,@forwardmodelTraman);
    
KCL1(1:n1) = dJHdc;
KCL1(n1+1:n) = dJLdc;


JOV = zeros(n,m);

for jj = 1:m 
   
   [dOVJH,dOVJL] = deriCountsOV(jj,Q,x,@forwardmodelTraman);
   JOV(1:n1,jj) = dOVJH;
   JOV(n1+1:n1+n2,jj) = dOVJL;
%    JOV(n1+n2+1:n1+n2+n3,jj) = dOVJHa;
%    JOV(n1+n2+n3+1:n,jj) = dOVJLa;

end

% %% Deadtime jacobian
% Jdt1 = zeros(n,1);
% Jdt2 = zeros(n,1);
% 
%     [dJHdt,dJLdt] = deridt(Q,x,@forwardmodelTraman);
%     
%    Jdt1(1:n1) = dJHdt;
%    Jdt1(n1+1:n) = 0;
% %    Jdt1(n1+n2+1:n1+n2+n3) = 0;
% %    Jdt1(n1+n2+n3+1:n) = 0;
%    
%    Jdt2(1:n1) = 0;
%    Jdt2(n1+1:n) = dJLdt;
% %    Jdt2(n1+n2+1:n) = 0;
% %    Jdt2(n1+n2+n3+1:n) = 0;
% % j
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

% J_JH = [Kb_JH;zeros(n2,1)];
% 
% J_JL = [zeros(n1,1);Kb_JL];

% KCL1 = [KCL22 KCL11];
% KCL = [KCL1 zeros(1,n3+n4)];

J_OV = JOV;

% J_JHa = [zeros(n1+n2,1);Kb_JHa;zeros(n4,1)];
% 
% J_JLa = [zeros(n1+n2+n3,1);Kb_JLa];

% KCLa1 = [KCLa22 KCLa11];
% KCLa = [zeros(1,n1+n2) KCLa1];

% KCHa = [zeros(1,n1+n2) KCLa22 zeros(1,n4)];
% KCLa = [zeros(1,n1+n2+n3) KCLa11];
 
J = [J_counts Kb_JH Kb_JL KCL1' J_OV];


