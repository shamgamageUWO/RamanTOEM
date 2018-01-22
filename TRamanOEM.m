function [X,R,Q,O,S_a,Se,xa,S_b]=TRamanOEM( date_in,time_in,flag)
tic
[O,Q,R,S_a,Se,xa] = InputsForOEM( date_in,time_in,flag);
xa = xa';
S_ainv=[];
Seinv=[];
m = length(Q.Zret);
n = Q.n1+Q.n2+Q.n3+Q.n4;
n1 = Q.n1;
n2 = Q.n2;
n3 = Q.n3;
n4= Q.n4;
y = Q.y;
% 
yJH = smooth(y(1:n1),100);
yJL = smooth(y(n1+1:n1+n2),100);
yJHa = smooth(y(n1+n2+1:n1+n2+n3),100);
yJLa = smooth(y(n1+n2+n3+1:end),100);



yvar = Q.yvar;


disp('starting oem.m ')
[X,R] = oem(O,Q,R,@makeJ,S_a,Se,S_ainv,Seinv,xa,y);
disp('Done running oem.m ')
toc

% R =bparameterjacobians (Q,X);

if ~O.linear
    if X.converged ~= 1
        'Stop, no convergence,pausing'
        X.converged
        pause
    end
end

CJL = X.x(m+3);
BJH = X.x(m+1);
BJL = X.x(m+2);
CJHa = Q.Ra.*X.x(end-2);
CJLa = X.x(end-2);
BJHa = X.x(end-4);
BJLa = X.x(end-3);
DT_JH = X.x(end-1);
DT_JL = X.x(end); % deadtimes

'X.cost'
X.cost

'OEM-BG-JH'
BJH

'real-BG-JH'
Q.BaJH

'OEM-BG-JL'
BJL

'real-BG-JL'
Q.BaJL

'OEM-CL'
CJL


'OEM-BG-JHa'
BJHa

'real-BG-JHa'
Q.BaJHa

'OEM-BG-JLa'
BJLa

'real-BG-JLa'
Q.BaJLa

'OEM-CLa'
CJLa

'OEM-CHa'
CJHa

'DT-JH'
DT_JH

'DT-JL'
DT_JL

%CJL = exp(logCJL)

% 'OEM-CH'
% X.x(end)

% R =makeParameterJacobians(Q,X.x);



% nmol = interp1(Q.Zmes,Q.Nmol,Q.Zret,'linear');
% 
% %                     %% plot counts
%                     figure;
%                     subplot(1,2,1)
%                     semilogx(Q.y(1:n1),Q.Zmes2./1000);
%                     hold on;
%                     semilogx(Q.y(n1+1:n1+n2),Q.Zmes2./1000);
%                     xlabel('Raw Counts Log scale')
%                     ylabel('Altitude( km)')
%                     legend('JH digital','JL digital')
%                     hold off;
% 
% 
%                     figure;
%                     subplot(1,2,1)
%                     semilogx(Q.y(n1+n2+1:n1+n2+n3),Q.Zmes1./1000);
%                     hold on;
%                     semilogx(Q.y(n1+n2+n3+1:end),Q.Zmes1./1000);
%                     xlabel('Raw Counts Log scale')
%                     ylabel('Altitude (km)')
%                     legend('JH analog','JL analog')
%                     hold off;
% % 
% % 
% %                     %% Plot Temperature Jacobians
% %                     figure;
% %                     subplot(2,1,1)
% %                     plot(X.J(1:n1,1:m),Q.Zmes./1000)
% %                     xlabel('Jacobian - JH')
% %                     ylabel('Altitude (km)')
% % 
% %                     subplot(2,1,2)
% %                     plot(X.J(n1+1:n1+n2,1:m),Q.Zmes./1000)
% %                     xlabel('Jacobian - JL')
%                     ylabel('Altitude (km)')
% 
%                     subplot(2,2,1)
%                     plot(X.J(n1+n2+1:n1+n2+n3,1:m),Q.Zmes./1000)
%                     xlabel('Jacobian - JHa')
%                     ylabel('Altitude (km)')
% 
%                     subplot(2,2,2)
%                     plot(X.J(n1+n2+n3+1:n,1:m),Q.Zmes./1000)
%                     xlabel('Jacobian - JLa')
%                     ylabel('Altitude (km)')
% 
% 
%                     %% Plot Avg Kenerl
% 
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
%                     %
                    err = X.e(1:m);
                    upper = err+ X.x(1:m);
                    lower =  X.x(1:m)-err;
                    
% load traditional temperature profiles
date = Q.date_in;
time = Q.time_in;
[year,month,day] = getYMDFromDate(date);
yr = num2str(year);
datadirS3 = '/Users/sham/Downloads/OEM-Sham-Code-Jan-2017/QpackSham/TraditionalTemperature';
filename =[yr  sprintf('%02.f',month) sprintf('%02.f',day) sprintf('%02.f',time)];
folderpath = [datadirS3 filesep filename];
load(folderpath);

 T_an = interp1(H.alt_an,H.T_an,Q.Zret);
 T_dg = interp1(H.alt_digi,H.T_dg,Q.Zret);
 T_cm = interp1(H.alt_com,H.T_cm,Q.Zret);



                    figure;
%                     subplot(1,2,1)
                    plot(Q.Ta,Q.Zret./1000,'g',X.x(1:m),Q.Zret./1000,'r',Q.Tsonde2,Q.Zret./1000,'b');
                    hold on
                    plot(T_an(Q.Zret<=10000),Q.Zret(Q.Zret<=10000)./1000,'black',T_dg(Q.Zret<=30000),Q.Zret(Q.Zret<=30000)./1000,'y', T_cm(Q.Zret<=30000),Q.Zret(Q.Zret<=30000)./1000,'c')
                    grid on;
                    grid on;
                    [fillhandle,msg]=jbfilly(Q.Zret./1000,upper',lower',rand(1,3),rand(1,3),0,0.5);
                    %  shadedErrorBar(X.x(1:m),Q.Zret./1000,err,'-r',1);
                    % jbfilly(Q.Zret./1000,upper',lower',rand(1,3),rand(1,3),0,rand(1,1))
                    xlabel('Temperature (K)')
                    ylabel('Altitude(km)')
                    legend('T a priori','T OEM','T sonde','Traditionalanalog','TraditionalDigital','TraditionalCombined')
                    hold off;
% 
%                     %  Treal = interp1(Q.Zmes,Q.Treal,Q.Zret,'linear');
% % 
%                      subplot(1,2,2)
%                      plot(X.x(1:m) - (Q.Tsonde2'),Q.Zret./1000)
%                      hold on;
%                     plot(-X.eo(1:m),Q.Zret./1000,'r',X.eo(1:m),Q.Zret./1000,'r')
% %                     xlabel('Temperature Stat error (K)')
% %                     ylabel( ' Alt (km)')
%                      grid on;
%                      xlabel('Temperature residuals(T OEM - T sonde) (K)')
% %                     %  plot(((X.x(1:m) - (Treal'))./(Treal')).*100,Q.Zret./1000)
% %                     %  xlabel('Temperature Percent Error (%)')
%                      ylabel('Altitude(km)')%  ylabel('Altitude(km)')
% 
% 
                    figure;
                    subplot(1,2,1)
                    plot(Q.OVa,Q.Zret./1000,'g',X.x(m+4:end-5),Q.Zret./1000,'r')
                    grid on;
                    xlabel('OV')
                    ylabel('Altitude(km)')
                    legend('OV a priori','OV OEM')


                    %  Treal = interp1(Q.Zmes,Q.Treal,Q.Zret,'linear');

                    subplot(1,2,2)
                    plot((((-Q.OVa')+X.x(m+4:end-5) )./X.x(m+4:end-5)).*100,Q.Zret./1000)
                    grid on;
                    xlabel('OV residuals(OV OEM - OV a priori) (%)')
                    %  plot(((X.x(1:m) - (Treal'))./(Treal')).*100,Q.Zret./1000)
                    %  xlabel('Temperature Percent Error (%)')
                    ylabel('Altitude(km)')%  ylabel('Altitude(km)')
% 
%                     %  subplot(1,3,3)
%                     %  plot(Q.Ta - Treal,Q.Zret./1000)
%                     %  xlabel('Temperature residuals (T a priori - T real) (K)')
%                     %  ylabel('Altitude(km)')
% 
% %% Residual plots
                    figure;
                    subplot(2,2,1)
                    grid on;
                    % plot(((y(1:Q.n1) - X.yf(1:Q.n1))./y(1:Q.n1)).*100 ,Q.Zmes2(Q.ind)./1000)
                    plot(((y(1:n1) - X.yf(1:n1))./X.yf(1:n1)).*100 ,Q.Zmes2./1000)
                    hold on
                    plot(-(sqrt(yJH)./X.yf(1:n1)).*100,Q.Zmes2./1000,'r',(sqrt(yJH)./X.yf(1:n1)).*100,Q.Zmes2./1000,'r');
                    %plot(-(1./sqrt(yJH)).*100,Q.Zmes2./1000,'r',(1./sqrt(yJH)).*100,Q.Zmes2./1000,'r');

                    hold off
                    xlabel('JH digital counts residual(%)')
                    ylabel('Altitude (km)')

                    subplot(2,2,2)
                    grid on;
                    plot(((y(n1+1:n1+n2) - X.yf(n1+1:n1+n2))./X.yf(n1+1:n1+n2)).*100 ,Q.Zmes2./1000)
                    hold on;
                    plot(-(sqrt(yJL)./X.yf(n1+1:n1+n2)).*100,Q.Zmes2./1000,'r',(sqrt(yJL)./X.yf(n1+1:n1+n2)).*100,Q.Zmes2./1000,'r');
                    %plot(-(1./sqrt(yJL)).*100,Q.Zmes2./1000,'r',(1./sqrt(yJL)).*100,Q.Zmes2./1000,'r');

                    hold off
                    xlabel('JL digital counts residual(%)')
                    ylabel('Altitude (km)')


                    subplot(2,2,3)
                    grid on;
                    % plot(((y(1:Q.n1) - X.yf(1:Q.n1))./y(1:Q.n1)).*100 ,Q.Zmes1(Q.ind)./1000)
                    plot(((y(n1+n2+1:n1+n2+n3) - X.yf(n1+n2+1:n1+n2+n3))./X.yf(n1+n2+1:n1+n2+n3)).*100 ,Q.Zmes1./1000)
                    hold on
%                     plot(-(sqrt(yJHa)./X.yf(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r',(sqrt(yJHa)./X.yf(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r');
                    plot(-(Q.YYYa'./y(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r',(Q.YYYa'./y(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r');
                    
%plot(-(1./sqrt(yJHa)).*100,Q.Zmes1./1000,'r',(1./sqrt(yJHa)).*100,Q.Zmes1./1000,'r');

                    hold off
                    xlabel('JH - analog counts residual(%)')
                    ylabel('Altitude (km)')

                    subplot(2,2,4)
                    grid on;
                    plot(((y(n1+n2+n3+1:end) - X.yf(n1+n2+n3+1:end))./X.yf(n1+n2+n3+1:end)).*100 ,Q.Zmes1./1000)
                    hold on;
                    plot(-(Q.YYa'./y(n1+n2+n3+1:end)).*100,Q.Zmes1./1000,'r',(Q.YYa'./y(n1+n2+n3+1:end)).*100,Q.Zmes1./1000,'r');
                    %plot(-(1./sqrt(yJLa)).*100,Q.Zmes1./1000,'r',(1./sqrt(yJLa)).*100,Q.Zmes1./1000,'r');

                    hold off
                    xlabel('JL - analog counts residual(%)')
                    ylabel('Altitude (km)')
                    
                    
           in= Q.Zret<=25000;
          Toem= X.x(1:m);
          Toem_e=X.eo(1:m);
           
                    figure; 
                      subplot(1,3,1)
                     plot(Toem(in) - (Q.Tsonde2(in)'),Q.Zret(in)./1000)
                     hold on;
                     plot(Toem_e(in),Q.Zret(in)./1000,'r',-Toem_e(in),Q.Zret(in)./1000,'r')
                     hold off;
                     grid on;
                     xlabel('Temperature residuals(T OEM - T sonde) (K)')
                     ylabel('Altitude(km)')%  ylabel('Altitude(km)')
                     
%                      T = X.x(1:m);
                     
                    subplot(1,3,2)
                     plot(Toem(in) - T_dg(in)',Q.Zret(in)./1000)
                     hold on;
                     plot(Toem_e(in),Q.Zret(in)./1000,'r',-Toem_e(in),Q.Zret(in)./1000,'r')
                     hold off;
                     grid on;
                     xlabel('Temperature residuals(T OEM - T digital traditional) (K)')
                     ylabel('Altitude(km)')%  ylabel('Altitude(km)')
                     
                      subplot(1,3,3)
                     plot((T_dg(in)-Q.Tsonde2(in)),Q.Zret(in)./1000,'r',( T_dg(in)' - Toem(in)),Q.Zret(in)./1000,'b',(Toem(in) - Q.Tsonde2(in)'),Q.Zret(in)./1000,'g')
 
                     grid on;
                     xlabel('Temperature residuals (K)')
                     ylabel('Altitude(km)')%  ylabel('Altitude(km)')
                         legend('Traditional-Sonde','OEM - Traditional','OEM - Sonde') 

R1 =bparameterjacobians (Q,X);

S_b.degF1 = trace(X.A(1:m,1:m)); %DegF for Temperature 
S_b.degF2 = trace(X.A(m+4:end-5,m+4:end-5))%DegF for OV

%                     %% Percent difference of background, lidar calibration constant retrievals and the true
% 
%                     percent_BG_JH = ((Q.Bg_JH_real -BJH)./BJH).*100
%                     percent_BG_JL = ((Q.Bg_JL_real -BJL)./BJL).*100
%                     percent_CJL = ((Q.CL -CJL)./CJL).*100
%                     % e = cputime
%                     toc
% 
% 
%                     % %  %%
%                     % % % calculate error matrices
                    dfacP = 0.01; % ISSI recommend
                    dfacR = 0.01; % ISSI recommend
                    dfacRa = 0.01; % ISSI recommend
                    dfacAir = 0.01; % BOb code
                    dfacaero = 0.01;
%                     % % dfacDT = 0.1;
%                     % % Pressure error
                    SP1 = (dfacP.*Q.Pressi(n3+1:end)).^2;
                    SP2 = (dfacP.*Q.Pressi(1:n3)).^2;% for 2 digital channels
                    SP = [SP1 SP1 SP2 SP2];
                    S_P = diag(SP);
                    
%                     % % R  and Ra error
                    SR1 = (dfacR.*Q.R).^2;
                    SR1= SR1.*ones(n1,1);
                    SR2 = zeros(n2+n3+n4,1);
                    SR = [SR1 ;SR2];
                    S_R = diag(SR);
                    
                    SRa1 = (dfacRa.*Q.Ra).^2;
                    SRa1= SRa1.*ones(n3,1);
                    SRa2 = zeros(n4,1);
                    ss = zeros(n1+n2,1);
                    SRa = [ss ;SRa1;SRa2];
                    S_Ra = diag(SRa);
%                     % %
                    Sair1 = (dfacAir.*Q.Nmol(n3+1:end)).^2;
                    Sair2 = (dfacAir.*Q.Nmol(1:n3)).^2;
                    Sair = [Sair1 Sair1 Sair2 Sair2];
                    S_air = diag(Sair);
%                     % %
                    Saero1 = (dfacaero.*Q.alpha_aero(n3+1:end)').^2;
                    Saero2 = (dfacaero.*Q.alpha_aero(1:n3)').^2;
                    Saero = [Saero1 Saero1 Saero2 Saero2];
                    S_aero = diag(Saero);
%                     % %
%                     % % SDT = (dfacDT.*Q.deadtime).^2;
%                     % %
%                     % %
S_b.SxP = X.G*R1.JPress*S_P*R1.JPress'*X.G';
S_b.SxR = X.G*R1.JR*S_R*R1.JR'*X.G';
S_b.SxRa = X.G*R1.JRa*S_Ra*R1.JRa'*X.G';
S_b.SxAir = X.G*R1.Jnair*S_air*R1.Jnair'*X.G';
S_b.Sxaero = X.G*R1.Jaero*S_aero*R1.Jaero'*X.G';

% Errors

P = diag(S_b.SxP);
Rc = diag(S_b.SxR);
Ra = diag(S_b.SxRa);
Air = diag(S_b.SxAir);
Aero = diag(S_b.Sxaero);

total_err_T = sqrt( X.eo(1:m).^2 + P(1:m) + Rc(1:m)+ Ra(1:m) + Air(1:m) + Aero(1:m));

% Errors for Temperature
figure;
plot(X.eo(1:m),Q.Zret./1000,'r')
hold on;
plot(sqrt(P(1:m)),Q.Zret./1000,'--*')
plot(sqrt(Rc(1:m)),Q.Zret./1000,'--^')
plot(sqrt(Ra(1:m)),Q.Zret./1000,'--+')
plot(sqrt(Air(1:m)),Q.Zret./1000,'--o')
plot(sqrt(Aero(1:m)),Q.Zret./1000,'--s')
plot(total_err_T,Q.Zret/1000,'black')
xlabel('Uncertainty')
ylabel('Altitude (km)')
legend('Statistical','Pressure','R','Ra','Air density','Aerosol','Total Error')

