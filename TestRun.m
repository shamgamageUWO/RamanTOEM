[O,Q,R,S_a,Se,x_a] = InputsForOEM( 20110910,11,1);
xa = x_a';
S_ainv=[];
Seinv=[];
y=Q.y;
 disp('starting oem.m ')
[X,R] = oem(O,Q,R,@makeJ,S_a,Se,S_ainv,Seinv,xa,y);
disp('Done running oem.m ')

if ~O.linear
    if X.converged ~= 1
        'Stop, no convergence,pausing'
        X.converged
        pause
    end
end

m = length(Q.Zret);
figure;plot(X.x(1:m),Q.Zret./1000)
hold on
plot(Q.Tsonde2,Q.Zret./1000)
hold off

figure;
subplot(2,2,1)
plot(exp(X.x(2*m+9:3*m+7)),Q.Zret(2:end)./1000)
hold on;
plot(exp(Q.RHa),Q.Zret./1000)
plot(Q.RHsonde2,Q.Zret./1000)
hold off

subplot(2,2,2)
plot(X.x(m+4:2*m+3),Q.Zret./1000)
hold on;
plot(Q.OVa,Q.Zret./1000)
hold off

subplot (2,2,3)
plot(X.x(3*m+13:4*m+12),Q.Zret./1000)
hold on;
plot(Q.OVwva,Q.Zret./1000)
hold off

subplot (2,2,4)
plot(X.x(4*m+19:end),Q.Zret./1000)
hold on;
plot(Q.alpha_aero,Q.Zret./1000)
hold off


figure;
subplot(2,2,1)
plot(X.A(1:5:m,1:5:m),Q.Zret(1:5:m)./1000)
xlabel('Temperature - Averaging Kernels')
ylabel('Altitude ( km )')
set(gca,'fontsize',16)

subplot(2,2,2)
grid on;
plot(X.A(3*m+13:5:4*m+12,3*m+13:5:4*m+12),Q.Zret(1:5:m)./1000)
grid off;
xlabel('PRR Overlap - Averaging Kernels')
ylabel('Altitude ( km )')
set(gca,'fontsize',16)

subplot(2,2,3)
grid on;
plot(X.A(m+4:5:2*m+3,m+4:5:2*m+3),Q.Zret(1:5:m)./1000)
grid off;
xlabel('WV Overlap - Averaging Kernels')
ylabel('Altitude ( km )')
set(gca,'fontsize',16)

subplot(2,2,4)
plot(X.A(2*m+9:3*m+7,2*m+9:3*m+7),Q.Zret(2:m)./1000)
xlabel('RH - Averaging Kernels')
ylabel('Altitude ( km )')
set(gca,'fontsize',16)


       


n1 = Q.n1;
n2 = Q.n2;
n3 = Q.n3;
n4= Q.n4;
n5 = Q.n5;
n6 = Q.n6;
n7= Q.n7;
n8= Q.n8;

yJH = smooth(y(1:n1),100);
yJL = smooth(y(n1+1:n1+n2),100);
yWV = smooth(y(n1+n2+n3+n4+1:n1+n2+n3+n4+n5),100);
yN2 = smooth(y(n1+n2+n3+n4+n5+1:n1+n2+n3+n4+n5+n6),100);




figure;
subplot(4,2,1)
grid on;
plot(((y(1:n1) - X.yf(1:n1))./X.yf(1:n1)).*100 ,Q.Zmes2./1000)
hold on
plot(-(sqrt(yJH)./X.yf(1:n1)).*100,Q.Zmes2./1000,'r',(sqrt(yJH)./X.yf(1:n1)).*100,Q.Zmes2./1000,'r');
hold off
xlabel('JH digital counts residual(%)')
ylabel('Altitude (km)')
set(gca,'fontsize',16)



subplot(4,2,2)
grid on;
plot(((y(n1+1:n1+n2) - X.yf(n1+1:n1+n2))./X.yf(n1+1:n1+n2)).*100 ,Q.Zmes2./1000)
hold on;
plot(-(sqrt(yJL)./X.yf(n1+1:n1+n2)).*100,Q.Zmes2./1000,'r',(sqrt(yJL)./X.yf(n1+1:n1+n2)).*100,Q.Zmes2./1000,'r');
hold off
xlabel('JL digital counts residual(%)')
ylabel('Altitude (km)')
set(gca,'fontsize',16)



subplot(4,2,3)
grid on;
plot(((y(n1+n2+1:n1+n2+n3) - X.yf(n1+n2+1:n1+n2+n3))./X.yf(n1+n2+1:n1+n2+n3)).*100 ,Q.Zmes1./1000)
hold on
plot(-(sqrt(Q.YYYa')./y(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r',(sqrt(Q.YYYa')./y(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r');
hold off
xlabel('JH - analog counts residual(%)')
ylabel('Altitude (km)')
set(gca,'fontsize',16)


subplot(4,2,4)
grid on;
plot(((y(n1+n2+n3+1:n1+n2+n3+n4) - X.yf(n1+n2+n3+1:n1+n2+n3+n4))./X.yf(n1+n2+n3+1:n1+n2+n3+n4)).*100 ,Q.Zmes1./1000)
hold on;
plot(-(sqrt(Q.YYa')./y(n1+n2+n3+1:n1+n2+n3+n4)).*100,Q.Zmes1./1000,'r',(sqrt(Q.YYa')./y(n1+n2+n3+1:n1+n2+n3+n4)).*100,Q.Zmes1./1000,'r');
hold off
xlabel('JL - analog counts residual(%)')
ylabel('Altitude (km)')
set(gca,'fontsize',16)

subplot(4,2,5)
grid on;
plot(((y(n1+n2+n3+n4+1:n1+n2+n3+n4+n5) - X.yf(n1+n2+n3+n4+1:n1+n2+n3+n4+n5))./X.yf(n1+n2+n3+n4+1:n1+n2+n3+n4+n5)).*100 ,Q.Zmes3./1000)
hold on
plot(-(sqrt(yWV)./X.yf(n1+n2+n3+n4+1:n1+n2+n3+n4+n5)).*100,Q.Zmes3./1000,'r',(sqrt(yWV)./X.yf(n1+n2+n3+n4+1:n1+n2+n3+n4+n5)).*100,Q.Zmes3./1000,'r');
hold off
xlabel('WV digital counts residual(%)')
ylabel('Altitude (km)')
set(gca,'fontsize',16)



subplot(4,2,6)
grid on;
plot(((y(n1+n2+n3+n4+n5+1:n1+n2+n3+n4+n5+n6) - X.yf(n1+n2+n3+n4+n5+1:n1+n2+n3+n4+n5+n6))./X.yf(n1+n2+n3+n4+n5+1:n1+n2+n3+n4+n5+n6)).*100 ,Q.Zmes3./1000)
hold on;
plot(-(sqrt(yN2)./X.yf(n1+n2+n3+n4+n5+1:n1+n2+n3+n4+n5+n6)).*100,Q.Zmes3./1000,'r',(sqrt(yN2)./X.yf(n1+n2+n3+n4+n5+1:n1+n2+n3+n4+n5+n6)).*100,Q.Zmes3./1000,'r');
hold off
xlabel('N2 digital counts residual(%)')
ylabel('Altitude (km)')
set(gca,'fontsize',16)



subplot(4,2,7)
grid on;
plot(((y(n1+n2+n3+n4+n5+n6+1:n1+n2+n3+n4+n5+n6+n7) - X.yf(n1+n2+n3+n4+n5+n6+1:n1+n2+n3+n4+n5+n6+n7))./X.yf(n1+n2+n3+n4+n5+n6+1:n1+n2+n3+n4+n5+n6+n7)).*100 ,Q.Zmes1./1000)
hold on
plot(-(sqrt(Q.YYwva')./y(n1+n2+n3+n4+n5+n6+1:n1+n2+n3+n4+n5+n6+n7)).*100,Q.Zmes1./1000,'r',(sqrt(Q.YYwva')./y(n1+n2+n3+n4+n5+n6+1:n1+n2+n3+n4+n5+n6+n7)).*100,Q.Zmes1./1000,'r');


hold off
xlabel('WV - analog counts residual(%)')
ylabel('Altitude (km)')
set(gca,'fontsize',16)


subplot(4,2,8)
grid on;
plot(((y(n1+n2+n3+n4+n5+n6+n7+1:end) - X.yf(n1+n2+n3+n4+n5+n6+n7+1:end))./X.yf(n1+n2+n3+n4+n5+n6+n7+1:end)).*100 ,Q.Zmes1./1000)
hold on;
plot(-(sqrt( Q.YYYn2a')./y(n1+n2+n3+n4+n5+n6+n7+1:end)).*100,Q.Zmes1./1000,'r',(sqrt(Q.YYYn2a')./y(n1+n2+n3+n4+n5+n6+n7+1:end)).*100,Q.Zmes1./1000,'r');
hold off
xlabel('N2 - analog counts residual(%)')
ylabel('Altitude (km)')
set(gca,'fontsize',16)


X.cost