% plot Jacobians
function PlotJacobians(Q,x)
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


figure;
subplot(4,2,1)
plot(Jc(1:n1,1:m),Q.Zmes2./1000)
title('T Jacob JH')
subplot(4,2,2)
plot(Jc(1+n1:n1+n2,1:m),Q.Zmes2./1000)
title('T Jacob JL')
subplot(4,2,3)
plot(Jc(1+n1+n2:n1+n2+n3,1:m),Q.Zmes1./1000)
title('T Jacob JHa')
subplot(4,2,4)
plot(Jc(1+n1+n2+n3:n1+n2+n3+n4,1:m),Q.Zmes1./1000)
title('T Jacob JLa')
subplot(4,2,5)
plot(Jc(1+n1+n2+n3+n4:n1+n2+n3+n4+n5,1:m),Q.Zmes2./1000)
title('T Jacob WV')
subplot(4,2,6)
plot(Jc(1+n1+n2+n3+n4+n5:n1+n2+n3+n4+n5+n6,1:m),Q.Zmes2./1000)
title('T Jacob N2')
subplot(4,2,7)
plot(Jc(1+n1+n2+n3+n4+n5+n6:n1+n2+n3+n4+n5+n6+n7,1:m),Q.Zmes1./1000)
title('T Jacob WVa')
subplot(4,2,8)
plot(Jc(1+n1+n2+n3+n4+n5+n6+n7:n,1:m),Q.Zmes1./1000)
title('T Jacob N2a')

%% RH jacobian
JRH = zeros(n,m);

for j = 1:m 
   
   [dRHWV,dRHN2,dRHWVa,dRHN2a] = deriCountsRH(j,Q,x,@forwardmodelTraman);
   JRH(1:n1,j) = 0;
   JRH(n1+1:n1+n2,j) = 0;
   JRH(n1+n2+1:n1+n2+n3,j) = 0;
   JRH(n1+n2+n3+1:n1+n2+n3+n4,j) = 0;
   JRH(n1+n2+n3+n4+1:n1+n2+n3+n4+n5,j) = dRHWV;
   JRH(n1+n2+n3+n4+n5+1:n1+n2+n3+n4+n5+n6,j) = dRHN2;
   JRH(n1+n2+n3+n4+n5+n6+1:n1+n2+n3+n4+n5+n6+n7,j) = dRHWVa;
   JRH(n1+n2+n3+n4+n5+n6+n7+1:n,j) = dRHN2a;
end


figure;
subplot(2,2,1)
plot(JRH(1+n1+n2+n3+n4:n1+n2+n3+n4+n5,1:m),Q.Zmes2./1000)
title('RH Jacob WV')
subplot(2,2,2)
plot(JRH(1+n1+n2+n3+n4+n5:n1+n2+n3+n4+n5+n6,1:m),Q.Zmes2./1000)
title('RH Jacob N2')
subplot(2,2,3)
plot(JRH(1+n1+n2+n3+n4+n5+n6:n1+n2+n3+n4+n5+n6+n7,1:m),Q.Zmes1./1000)
title('RH Jacob WVa')
subplot(2,2,4)
plot(JRH(1+n1+n2+n3+n4+n5+n6+n7:n,1:m),Q.Zmes1./1000)
title('RH Jacob N2a')
