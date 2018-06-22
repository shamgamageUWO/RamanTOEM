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

figure;plot(exp(X.x(2*m+8:3*m+7)),Q.Zret./1000)
hold on;
plot(exp(Q.RHa),Q.Zret./1000)
plot(Q.RHsonde2./100,Q.Zret./1000)
hold off


figure;plot(X.x(m+4:2*m+3),Q.Zret./1000)
hold on;
plot(Q.OVa,Q.Zret./1000)
hold off


figure;plot(X.x(3*m+13:4*m+12),Q.Zret./1000)
hold on;
plot(Q.OVwva,Q.Zret./1000)
hold off