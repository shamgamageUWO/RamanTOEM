function [X,R,Q,O,S_a,Se,xa]=TRamanOEM( date_in,time_in,flag)

[O,Q,R,S_a,Se,xa] = InputsForOEM( date_in,time_in,flag);
xa = xa';
S_ainv=[];
Seinv=[];
y = Q.y;

[X,R] = oem(O,Q,R,@makeJ,S_a,Se,S_ainv,Seinv,xa,y);

if ~O.linear
    if X.converged ~= 1
        'Stop, no convergence,pausing'
        X.converged
        pause
    end
end

'X.cost'
X.cost

'OEM-BG-JH'
X.x(end-2)

'real-BG-JH'
Q.Bg_JH_real

'OEM-BG-JL'
X.x(end-1)

'real-BG-JL'
Q.Bg_JL_real

'OEM-CL'
X.x(end)

% 'OEM-CH'
% X.x(end)

% R =makeParameterJacobians(Q,X.x);

m = length(Q.Zret);
n = Q.n1+Q.n2;
% nmol = interp1(Q.Zmes,Q.Nmol,Q.Zret,'linear');

figure;
set(gca,'fontsize',18)
hold on
subplot(1,2,1)
plot(X.J(1:Q.n1,1:m),Q.Zmes./1000)
xlabel('Jacobian-JH','fontsize',18)
ylabel('Altitude (km)','fontsize',18)

subplot(1,2,2)
plot(X.J(Q.n1+1:n,1:m),Q.Zmes./1000)
xlabel('Jacobian-JL','fontsize',18)
ylabel('Altitude (km)','fontsize',18)

hold off;

response = sum(X.A(1:m,1:m));
% Vertical resolution
width = zeros(size(Q.Zret));
    for j = 1:m % fini
        width(j) = fwhmquiet(Q.Zret,X.A(1:m,j));
        if isnan(width(j))
            width(j) = 0;
        end
    end 



figure;
subplot(1,2,1)

plot(X.A(1:m,1:m),Q.Zret(1:m)./1000) 
hold on;
plot(response,Q.Zret./1000,'r') 
% plot(X.A(1:m,1:m).*unit,Q.Zret./1000) 
hold off;
xlabel('Avgeraging Kernels','fontsize',18)
ylabel('Altitude ( km )','fontsize',18)

subplot(1,2,2)
plot(width(2:end-2)./1000,Q.Zret(2:end-2)./1000)
xlabel('Vertical Resolution ( km )','fontsize',18)
ylabel('Altitude ( km )','fontsize',18)
% 
 err = X.e(1:m);
 upper = err+ X.x(1:m);
lower =  X.x(1:m)-err;

figure;
subplot(1,2,1)
plot(Q.Ta,Q.Zret./1000,'g',X.x(1:m),Q.Zret./1000,'r',Q.Treal,Q.Zret./1000,'b')
 hold on
 [fillhandle,msg]=jbfilly(Q.Zret./1000,upper',lower',rand(1,3),rand(1,3),0,0.5);
%  shadedErrorBar(X.x(1:m),Q.Zret./1000,err,'-r',1);
% jbfilly(Q.Zret./1000,upper',lower',rand(1,3),rand(1,3),0,rand(1,1))
xlabel('Temperature ( K )','fontsize',18)
ylabel('Altitude ( km )','fontsize',18)
 legend('T a priori','T OEM','T Real')
 hold off;
 
%  Treal = interp1(Q.Zmes,Q.Treal,Q.Zret,'linear');

 subplot(1,2,2)
 plot(X.x(1:m) - (Q.Treal'),Q.Zret./1000)
 xlabel('Temperature residuals(T OEM - T real) ( K )','fontsize',18)
%  plot(((X.x(1:m) - (Treal'))./(Treal')).*100,Q.Zret./1000)
%  xlabel('Temperature Percent Error (%)')
 ylabel('Altitude ( km )','fontsize',18)%  ylabel('Altitude(km)')


%  subplot(1,3,3)
%  plot(Q.Ta - Treal,Q.Zret./1000)
%  xlabel('Temperature residuals (T a priori - T real) (K)')
%  ylabel('Altitude(km)')
 
figure;
subplot(1,2,1)
grid on;
% plot(((y(1:Q.n1) - X.yf(1:Q.n1))./y(1:Q.n1)).*100 ,Q.Zmes(Q.ind)./1000)
plot(((y(1:Q.n1) - X.yf(1:Q.n1))./X.yf(1:Q.n1)).*100 ,Q.Zmes./1000)
hold on
plot(-sqrt(smooth(y(1:Q.n1),100))./X.yf(1:Q.n1).*100,Q.Zmes./1000,'r',sqrt(smooth(y(1:Q.n1),100))./X.yf(1:Q.n1).*100,Q.Zmes./1000,'r');
hold off
xlabel('JH counts residual (%)','fontsize',18)
ylabel('Altitude ( km )','fontsize',18)

subplot(1,2,2)
grid on;
plot(((y(Q.n1+1:end) - X.yf(Q.n1+1:end))./X.yf(Q.n1+1:end)).*100 ,Q.Zmes./1000)
hold on;
plot(-sqrt(smooth(y(Q.n1+1:end),100))./X.yf(Q.n1+1:end).*100,Q.Zmes./1000,'r',sqrt(smooth(y(Q.n1+1:end),100))./X.yf(Q.n1+1:end).*100,Q.Zmes./1000,'r');
hold off
xlabel('JL counts residual (%)','fontsize',18)
ylabel('Altitude ( km )','fontsize',18)


%% Percent difference of background, lidar calibration constant retrievals and the true

percent_BG_JH = ((Q.Bg_JH_real -X.x(end-2))./X.x(end-2)).*100
percent_BG_JL = ((Q.Bg_JL_real -X.x(end-1))./X.x(end-1)).*100
percent_CJL = ((Q.CL -X.x(end))./X.x(end)).*100
