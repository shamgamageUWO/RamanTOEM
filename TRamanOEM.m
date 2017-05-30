function [X,R,Q,O,S_a,Se,xa]=TRamanOEM( date_in,time_in,flag)

[O,Q,R,S_a,Se,xa] = InputsForOEM( date_in,time_in,flag);
xa = xa';
S_ainv=[];
Seinv=[];
n1 = Q.n1;
y = Q.y;
yJH = smooth(y(1:n1),100);
yJL = smooth(y(n1+1:end),100);
% yvar = Q.yvar;

[X,R] = oem(O,Q,R,@makeJ,S_a,Se,S_ainv,Seinv,xa,y);

if ~O.linear
    if X.converged ~= 1
        'Stop, no convergence,pausing'
        X.converged
        pause
    end
end

CJL = X.x(end-Q.OVlength);
 BJH = (X.x(end-Q.OVlength-2));
 BJL = (X.x(end-Q.OVlength-1));
  
'X.cost'
X.cost

'OEM-BG-JH'
BJH

'real-BG-JH'
Q.Bg_JH_real

'OEM-BG-JL'
BJL

'real-BG-JL'
Q.Bg_JL_real

'OEM-CL'
CJL
%CJL = exp(logCJL)

% 'OEM-CH'
% X.x(end)

% R =makeParameterJacobians(Q,X.x);

m = length(Q.Zret);
n = Q.n1+Q.n2;
% nmol = interp1(Q.Zmes,Q.Nmol,Q.Zret,'linear');

figure;
subplot(1,2,1)
semilogx(Q.y(1:Q.n1),Q.Zmes./1000);
xlabel('Raw Counts JH- Log scale')
ylabel('Altitude(km)')
subplot(1,2,2)
semilogx(Q.y(Q.n1+1:end),Q.Zmes./1000);
xlabel('Raw Counts JL- Log scale')
ylabel('Altitude(km)')

figure;
subplot(1,2,1)
plot(X.J(1:Q.n1,1:m),Q.Zmes./1000)
xlabel('Jacobian-JH')
ylabel('Altitude(km)')

subplot(1,2,2)
plot(X.J(Q.n1+1:n,1:m),Q.Zmes./1000)
xlabel('Jacobian-JL')
ylabel('Altitude(km)')

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
set(gca,'fontsize',16)
% hold on;
plot(X.A(1:m,1:m),Q.Zret(1:m)./1000) 
grid on;
hold on;
plot(response,Q.Zret./1000,'r') 
% plot(X.A(1:m,1:m).*unit,Q.Zret./1000) 
hold off;
xlabel('Avgeraging Kernels')
ylabel('Altitude(km)')

subplot(1,2,2)
plot(width(2:end-2)./1000,Q.Zret(2:end-2)./1000)
grid on;
xlabel('Vertical Resolution (km)')
ylabel('Altitude(km)')
% 
 err = X.e(1:m);
 upper = err+ X.x(1:m);
lower =  X.x(1:m)-err;

 [Tsonde,Zsonde,Psonde] = get_sonde_RS92(Q.date_in,Q.time_in);
 lnQ = log(Q.y(1:Q.n1)./Q.y(Q.n1+1:end));
 Ttradi = real(Q.bb./(Q.aa-lnQ));

Tsonde = interp1(Zsonde,Tsonde,Q.Zret);
figure;
subplot(1,2,1)
plot(Q.Ta,Q.Zret./1000,'g',X.x(1:m),Q.Zret./1000,'r',Tsonde,Q.Zret./1000,'b',Ttradi(Q.Zmes>=2000 & Q.Zmes<=20000),Q.Zmes(Q.Zmes>=2000 & Q.Zmes<=20000)./1000,'black')
grid on;
 hold on
 [fillhandle,msg]=jbfilly(Q.Zret./1000,upper',lower',rand(1,3),rand(1,3),0,0.5);
%  shadedErrorBar(X.x(1:m),Q.Zret./1000,err,'-r',1);
% jbfilly(Q.Zret./1000,upper',lower',rand(1,3),rand(1,3),0,rand(1,1))
xlabel('Temperature (K)')
ylabel('Altitude(km)')
 legend('T a priori','T OEM','T sonde')
 hold off;
 
%  Treal = interp1(Q.Zmes,Q.Treal,Q.Zret,'linear');

 subplot(1,2,2)
 plot(X.x(1:m) - (Tsonde'),Q.Zret./1000)
 grid on;
 xlabel('Temperature residuals(T OEM - T sonde) (K)')
%  plot(((X.x(1:m) - (Treal'))./(Treal')).*100,Q.Zret./1000)
%  xlabel('Temperature Percent Error (%)')
 ylabel('Altitude(km)')%  ylabel('Altitude(km)')

 
 figure;
subplot(1,2,1)
plot(Q.OVa,Q.Zret./1000,'g',X.x(end+1-Q.OVlength:end),Q.Zret./1000,'r')
grid on;
xlabel('OV')
ylabel('Altitude(km)')
legend('OV a priori','OV OEM')

 
%  Treal = interp1(Q.Zmes,Q.Treal,Q.Zret,'linear');

 subplot(1,2,2)
 plot((((-Q.OVa')+X.x(end+1-Q.OVlength:end) )./X.x(end+1-Q.OVlength:end)).*100,Q.Zret./1000)
 grid on;
 xlabel('OV residuals(OV OEM - OV a priori) (%)')
%  plot(((X.x(1:m) - (Treal'))./(Treal')).*100,Q.Zret./1000)
%  xlabel('Temperature Percent Error (%)')
 ylabel('Altitude(km)')%  ylabel('Altitude(km)')
 
%  subplot(1,3,3)
%  plot(Q.Ta - Treal,Q.Zret./1000)
%  xlabel('Temperature residuals (T a priori - T real) (K)')
%  ylabel('Altitude(km)')
 

figure;
subplot(1,2,1)
grid on;
% plot(((y(1:Q.n1) - X.yf(1:Q.n1))./y(1:Q.n1)).*100 ,Q.Zmes(Q.ind)./1000)
plot(((y(1:n1) - X.yf(1:n1))./X.yf(1:n1)).*100 ,Q.Zmes./1000)
hold on
plot(-(sqrt(yJH)./X.yf(1:n1)).*100,Q.Zmes./1000,'r',(sqrt(yJH)./X.yf(1:n1)).*100,Q.Zmes./1000,'r');
hold off
xlabel('JH counts residual(%)')
ylabel('Altitude(km)')

subplot(1,2,2)
grid on;
plot(((y(n1+1:end) - X.yf(n1+1:end))./X.yf(n1+1:end)).*100 ,Q.Zmes./1000)
hold on;
plot(-(sqrt(yJL)./X.yf(n1+1:end)).*100,Q.Zmes./1000,'r',(sqrt(yJL)./X.yf(n1+1:end)).*100,Q.Zmes./1000,'r');
hold off
xlabel('JL counts residual(%)')
ylabel('Altitude(km)')


%% Percent difference of background, lidar calibration constant retrievals and the true

percent_BG_JH = ((Q.Bg_JH_real -BJH)./BJH).*100
percent_BG_JL = ((Q.Bg_JL_real -BJL)./BJL).*100
percent_CJL = ((Q.CL -CJL)./CJL).*100
% percent_CJLTrue = ((Q.CL*(1.05) -CJL)./CJL).*100

% e = cputime

