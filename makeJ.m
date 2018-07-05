function [R,yf,J] = makeJ(Q, R, x, iter)


[JL,JH,JLa,JHa,WV,N2,WVa,N2a]=forwardmodelTraman(Q,x);


if ~isempty(find(isnan(x)) == 1)
    'after FM: Nans in retrieval vector (FMwv(n).m)'
    iter
    stop
end



n1=Q.n1; %length JH
n2=Q.n2; %length JL
n3 =Q.n3; % length JHa
n4 =Q.n4;
n5=Q.n5;
n6=Q.n6;
n7=Q.n7;
n8=Q.n8;

n = n1+n2+n3+n4+n5+n6+n7+n8;
m = length(Q.Zret);
yf = [JH; JL; JHa; JLa; WV; N2; WVa; N2a];

% Temperature Jacobian 
Jc = zeros(n,m);

for j = 1:m 
    [dJH,dJL,dJHa,dJLa,dwv,dn2,dwva,dn2a] = deriCountsOEM(j,Q,x,@forwardmodelTraman);
    
   Jc(1:n1,j) = dJH;
   Jc(n1+1:n1+n2,j) = dJL;
   Jc(n1+n2+1:n1+n2+n3,j) = dJHa;
   Jc(n1+n2+n3+1:n1+n2+n3+n4,j) = dJLa;
  
   Jc(n1+n2+n3+n4+1:n1+n2+n3+n4+n5,j) = dwv;
   Jc(n1+n2+n3+n4+n5+1:n1+n2+n3+n4+n5+n6,j) = dn2;
   Jc(n1+n2+n3+n4+n5+n6+1:n1+n2+n3+n4+n5+n6+n7,j) = dwva;
   Jc(n1+n2+n3+n4+n5+n6+n7+1:n,j) = dn2a;
% j
% disp('ok')
end

Jaer = zeros(n,m);
for j = 1:m 
    [dJHaer,dJLaer,dJHaaer,dJLaaer,dwvaer,dn2aer,dwvaaer,dn2aaer] = deriCountsAero(j,Q,x,@forwardmodelTraman);
    
   Jaer(1:n1,j) = dJHaer;
   Jaer(n1+1:n1+n2,j) = dJLaer;
   Jaer(n1+n2+1:n1+n2+n3,j) = dJHaaer;
   Jaer(n1+n2+n3+1:n1+n2+n3+n4,j) = dJLaaer;
   
   Jaer(n1+n2+n3+n4+1:n1+n2+n3+n4+n5,j) = dwvaer;
   Jaer(n1+n2+n3+n4+n5+1:n1+n2+n3+n4+n5+n6,j) = dn2aer;
   Jaer(n1+n2+n3+n4+n5+n6+1:n1+n2+n3+n4+n5+n6+n7,j) = dwvaaer;
   Jaer(n1+n2+n3+n4+n5+n6+n7+1:n,j) = dn2aaer;
% j
% disp('ok')
end

%% OV for PRR
JOV = zeros(n,m);

for jj = 1:m 
   
   [dOVJH,dOVJL,dOVJHa,dOVJLa] = deriCountsOV(jj,Q,x,@forwardmodelTraman);
   JOV(1:n1,jj) = dOVJH;
   JOV(n1+1:n1+n2,jj) = dOVJL;
   JOV(n1+n2+1:n1+n2+n3,jj) = dOVJHa;
   JOV(n1+n2+n3+1:n1+n2+n3+n4,jj) = dOVJLa;
   
   JOV(n1+n2+n3+n4+1:n1+n2+n3+n4+n5,jj) = 0;
   JOV(n1+n2+n3+n4+n5+1:n1+n2+n3+n4+n5+n6,jj) = 0;
   JOV(n1+n2+n3+n4+n5+n6+1:n1+n2+n3+n4+n5+n6+n7,jj) = 0;
   JOV(n1+n2+n3+n4+n5+n6+n7+1:n,jj) = 0;
end


%% OV for wv
JOVwv = zeros(n,m);

for jj = 1:m 

   [dOVwv,dOVn2,dOVwva,dOVn2a] = deriCountsOVwv(jj,Q,x,@forwardmodelTraman);
   JOVwv(1:n1,jj) = 0;
   JOVwv(n1+1:n1+n2,jj) = 0;
   JOVwv(n1+n2+1:n1+n2+n3,jj) = 0;
   JOVwv(n1+n2+n3+1:n1+n2+n3+n4,jj) = 0;
   
   JOVwv(n1+n2+n3+n4+1:n1+n2+n3+n4+n5,jj) = dOVwv;
   JOVwv(n1+n2+n3+n4+n5+1:n1+n2+n3+n4+n5+n6,jj) = dOVn2;
   JOVwv(n1+n2+n3+n4+n5+n6+1:n1+n2+n3+n4+n5+n6+n7,jj) = dOVwva;
   JOVwv(n1+n2+n3+n4+n5+n6+n7+1:n,jj) = dOVn2a;
end



%% RH jacobian
JRH = zeros(n,m);

for j = 1:m 
   
   [dRHWV,dRHN2,dRHWVa,dRHN2a] = deriCountsRH(j,Q,x,@forwardmodelTraman);
   JRH(1:n1,j) = 0;
   JRH(n1+1:n1+n2,j) = 0;
   JRH(n1+n2+1:n1+n2+n3,j) = 0;
   JRH(n1+n2+n3+1:n1+n2+n3+n4,j) = 0;
   
   JRH(n1+n2+n3+n4+1:n1+n2+n3+n4+n5,j) = dRHWV;
   JRH(n1+n2+n3+n4+n5+1:n1+n2+n3+n4+n5+n6,j) = 0;
   JRH(n1+n2+n3+n4+n5+n6+1:n1+n2+n3+n4+n5+n6+n7,j) = dRHWVa;
   JRH(n1+n2+n3+n4+n5+n6+n7+1:n,j) = 0;
end



% bg PRR & WV
[Kb_JH,Kb_JL,Kb_JHa,Kb_JLa,Kb_WV,Kb_N2,Kb_WVa,Kb_N2a] = deriBg(Q,x,@forwardmodelTraman);





[dJHdc,dJLdc,dJHadc,dJLadc,dWVdc,dN2dc,dWVadc,dN2adc] = deriC(Q,x,@forwardmodelTraman);

KCL1 = [dJHdc' dJLdc'];
KCL = [KCL1 zeros(1,n3+n4+n5+n6+n7+n8)];

KCLa1 = [dJHadc' dJLadc'];
KCLa = [zeros(1,n1+n2) KCLa1 zeros(1,n5+n6+n7+n8)];

% KC11 = [dWVdc' dN2dc'];
KC1 = [zeros(1,n1+n2+n3+n4) dWVdc' zeros(1,n6+n7+n8)];
KC2 = [zeros(1,n1+n2+n3+n4+n5) dN2dc' zeros(1,n7+n8)];
% KC22 = [dWVadc' dN2adc'];
KC3 = [zeros(1,n1+n2+n3+n4+n5+n6) dWVadc' zeros(1,n8)];
KC4 = [zeros(1,n1+n2+n3+n4+n5+n6+n7) dN2adc'];


% Need analytical
%% Deadtime jacobian for PPP
Jdt1 = zeros(n,1);
Jdt2 = zeros(n,1);
Jdt3 = zeros(n,1);
Jdt4 = zeros(n,1);

    [dJHdt,dJLdt,dWVdt,dN2dt] = deridt(Q,x,@forwardmodelTraman);
    
    Jdt1(1:n1) = dJHdt;
    Jdt1(n1+1:n) = 0;
    
    
    Jdt2(1:n1) = 0;
    Jdt2(n1+1:n1+n2) = dJLdt;
    Jdt2(n1+n2+1:n) = 0;
    
    Jdt3(1:n1+n2+n3+n4) = 0;
    Jdt3(n1+n2+n3+n4+1:n1+n2+n3+n4+n5) = dWVdt;
    Jdt3(n1+n2+n3+n4+n5+1:n) = 0;
    
    Jdt4(1:n1+n2+n3+n4+n5) = 0;
    Jdt4(n1+n2+n3+n4+n5+1:n1+n2+n3+n4+n5+n6) = dN2dt;
    Jdt4(n1+n2+n3+n4+n5+n6+1:n) = 0;
   
   
  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% coupled analog
J_counts = Jc;
J_JH = [Kb_JH; zeros(n2+n3+n4+n5+n6+n7+n8,1)];
J_JL = [zeros(n1,1);Kb_JL;zeros(n3+n4+n5+n6+n7+n8,1)];
J_JHa = [zeros(n1+n2,1);Kb_JHa;zeros(n4+n5+n6+n7+n8,1)];
J_JLa = [zeros(n1+n2+n3,1);Kb_JLa;zeros(n5+n6+n7+n8,1)];


J_WV = [zeros(n1+n2+n3+n4,1); Kb_WV; zeros(n6+n7+n8,1)];
J_N2 = [zeros(n1+n2+n3+n4+n5,1); Kb_N2; zeros(n7+n8,1)];
J_WVa = [zeros(n1+n2+n3+n4+n5+n6,1); Kb_WVa; zeros(n8,1)];
J_N2a = [zeros(n1+n2+n3+n4+n5+n6+n7,1); Kb_N2a];




J = [J_counts J_JH J_JL KCL' JOV J_JHa J_JLa KCLa' Jdt1 Jdt2 JRH J_WV J_N2 KC1' KC2' JOVwv J_WVa J_N2a KC3' KC4' Jdt3 Jdt4 Jaer];


