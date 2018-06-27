[O,Q,R,S_a,Se,x_a] = InputsForOEM( 20110909,23,2);
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
plot((X.x(2*m+8:3*m+7)),Q.Zret./1000)
hold on;
plot((Q.RHa),Q.Zret./1000)
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
plot(X.A(2*m+8:5:3*m+7,2*m+8:5:3*m+7),Q.Zret(1:5:m)./1000)
xlabel('RH - Averaging Kernels')
ylabel('Altitude ( km )')
set(gca,'fontsize',16)

X.cost