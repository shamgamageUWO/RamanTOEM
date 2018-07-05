function [X,R,Q,O,S_a,Se,xa,S_b,Error]=TRamanOEM_Paperversion_clear( date_in,time_in,flag)
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


BJH = X.x(m+1);
BJL = X.x(m+2);
CJL = X.x(m+3);
OV = X.x(m+4:2*m+3);
BJHa = X.x(2*m+4);
BJLa = X.x(2*m+5);
CJLa = X.x(2*m+6);
DT_JH = X.x(2*m+7);
DT_JL = X.x(2*m+8); % deadtimes
alpha_aero = X.x(2*m+9:end);


'X.cost'
X.cost(end)

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

% 'OEM-CHa'
% CJHa

'DT-JH'
DT_JH

'DT-JL'
DT_JL


  er = X.e;                  
     DT_JL_err = er(2*m+8)
     DT_JH_err = er(2*m+7)
     CJL_err = er(m+3)
     CJL_aerr = er(2*m+6)

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
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     %% Plot Avg Kenerl
%                     response = sum(X.A(1:m,1:m));
                    unit = ones(size(Q.Zret));
                    response = (X.A(1:m,1:m))*unit';

                    % Vertical resolution
                    width = zeros(size(Q.Zret));
                    for j = 1:m % fini
                        width(j) = fwhmquiet(Q.Zret,X.A(1:m,j));
                        if isnan(width(j))
                            width(j) = 0;
                        end
                    end


% Tavg and T vertical resolution
                    figure;
                    subplot(1,2,1)
                    %                     set(gca,'fontsize',20)
                    % hold on;
                    plot(X.A(1:5:m,1:5:m),Q.Zret(1:5:m)./1000)
                    grid on;
                    hold on;
                    plot(response,Q.Zret./1000,'r')
                    % plot(X.A(1:m,1:m).*unit,Q.Zret./1000)
                    hold off;
                    xlabel('Temperature Averaging Kernel')
                    ylabel('Altitude ( km )')
                    set(gca,'fontsize',20)
                    
                    subplot(1,2,2)

                plot(width(2:end-2),Q.Zret(2:end-2)./1000)
                grid on;
                xlabel('Vertical Resolution ( m )')
                ylabel('Altitude ( km )')
                set(gca,'fontsize',20)
                    
% OV, OV AVG and OV Uncertainty
%        Overlap
figure;
subplot(1,2,1)
plot(Q.OVa,Q.Zret./1000,'g',X.x(m+4:2*m+3),Q.Zret./1000,'r')
grid on;
xlabel('OV')
ylabel('Altitude ( km )')
legend('OV a priori','OV OEM')
set(gca,'fontsize',20)
ylim([0 12])


subplot(1,2,2)
plot(X.A(m+4:5:2*m+3,m+4:5:2*m+3),Q.Zret(1:5:m)./1000)
xlabel('OV Averaging Kernel')
ylabel('Altitude ( km )')
set(gca,'fontsize',20)
 
                    
                    
                    
                    
                    % Aerosol 
                    figure;
                    subplot(1,2,1)
                    %     semilogx(exp(Q.alpha_aero),Q.Zret./1000,'g',exp(X.x(2*m+9:end)),Q.Zret./1000,'r')
                    semilogx((Q.alpha_aero),Q.Zret./1000,'g',(X.x(2*m+9:end)),Q.Zret./1000,'r')
                    grid on;
                    xlabel('Extinction')
                    ylabel('Altitude ( km )')
                    legend('Aerosol Extinction a priori (m^-^1)','OEM aerosol extinction (m^-^1)')
                    set(gca,'fontsize',20)
                    ylim([0 20])
                    
                    subplot(1,2,2)
                    plot(X.A(2*m+9:5:end,2*m+9:5:end),Q.Zret(1:5:m)./1000)
                    xlabel('Aerosol Extinction - Averaging Kernels')
                    ylabel('Altitude ( km )')
                    set(gca,'fontsize',20)

                    
S_b.degF1 = trace(X.A(1:m,1:m)); %DegF for Temperature 
S_b.degF2 = trace(X.A(m+4:2*m+3,m+4:2*m+3));%DegF for OV    
S_b.degF3 = trace(X.A(2*m+9:end,2*m+9:end))%DegF for Aerosol 

% S_b.CutoffheightT = Q.Zret(response==0.9)
% S_b.CutoffheightOV = Q.Zret(round(S_b.degF2))                   
                    
%                     OVresponse = (X.A(m+4:end-5,m+4:end-5))*unit';

%                     %
                    err = X.e(1:m);
                    upper = real(err+ X.x(1:m));
                    lower =  real(X.x(1:m)-err);


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                    


% H = traditionalTraman(Q);
% T_an = interp1(Q.Zmes1,H.T_an,Q.Zret);
% T_dg = interp1(Q.Zmes2,H.T_dg,Q.Zret);
% load('201109092330.mat');
% load('201109101130.mat');
load('201107052359.mat');
T_tr = interp1(Temp.z,Temp.profile,Q.Zret);

Toem= X.x(1:m);

figure;
subplot(1,2,1)
% Create plot
plot(Q.Ta(Q.Zret<=28000),Q.Zret(Q.Zret<=28000)./1000,'DisplayName','T a priori','LineWidth',1,...
    'Color',[0 0.498039215803146 0]);

hold on;

% Create plot
plot(Toem(Q.Zret<=28000),Q.Zret(Q.Zret<=28000)./1000,'DisplayName','T OEM','Color',[1 0 0]);

% Create plot
plot(Q.Tsonde2(Q.Zret<=28000),Q.Zret(Q.Zret<=28000)./1000,'DisplayName','T sonde','Color',[0 0 1]);

% Create plot
plot(T_tr(Q.Zret<=28000),Q.Zret(Q.Zret<=28000)./1000,'DisplayName','T Traditional','LineWidth',1,'Color',[0 0 0]);

% % Create plot
% plot(T_dg(Q.Zret<=25000),Q.Zret(Q.Zret<=25000)./1000,'DisplayName','TraditionalDigital','LineWidth',1,...
%     'Color',[0.929411768913269 0.694117665290833 0.125490203499794]);
 jbfilly(Q.Zret(Q.Zret<=28000)./1000,upper(Q.Zret<=28000)',lower(Q.Zret<=28000)',[0.9 1 1],[0.94 0.87 0.87],0,0.5);

xlim([150 320])
% Create xlabel
xlabel('Temperature (K)');

% Create ylabel
ylabel('Altitude (km)');

% box(axes1,'on');
% grid(axes1,'on');
% Create legend
% legend(axes1,'show');
legend ('T a priori','T OEM','T sonde','Traditional')
set(gca,'fontsize',20)

hold off;
Tdiff = Toem-Q.Tsonde2';
Toem_e=X.eo(1:m);

subplot(1,2,2)
plot(Tdiff(Q.Zret<=28000),Q.Zret(Q.Zret<=28000)./1000,'b');
hold on
plot(Toem_e(Q.Zret<=28000),Q.Zret(Q.Zret<=28000)./1000,'r',-Toem_e(Q.Zret<=28000),Q.Zret(Q.Zret<=28000)./1000,'r')

xlabel('Temperature Difference (K)');
% Create ylabe
ylabel('Altitude (km)');
% legend ('T a priori','T OEM','T sonde','Traditional Analog','Traditional Digital')
set(gca,'fontsize',20)
 hold off;


% in= Q.Zret<=25000;
% Toem_e=X.eo(1:m);
% in2 = Q.Zret<=6000;
% in3= Q.Zret>=4000 & Q.Zret<=25000;

% figure;
% subplot(1,3,1)
% plot(Toem(in) - (Q.Tsonde2(in)'),Q.Zret(in)./1000)
% hold on;
% plot(Toem_e(in),Q.Zret(in)./1000,'r',-Toem_e(in),Q.Zret(in)./1000,'r')
% hold off;
% grid on;
% xlabel('(T OEM - T sonde) (K)')
% ylabel('Altitude(km)')%  ylabel('Altitude(km)')
%    set(gca,'fontsize',20)
% 
% 
% 
% %                      T = X.x(1:m);
% 
% subplot(1,3,2)
% plot(Toem(in3) - T_dg(in3)',Q.Zret(in3)./1000,'b')
% hold on;
% plot(Toem(in2) - T_an(in2)',Q.Zret(in2)./1000,'black')
% plot(Toem_e(in3),Q.Zret(in3)./1000,'r',-Toem_e(in3),Q.Zret(in3)./1000,'r')
% plot(Toem_e(in2),Q.Zret(in2)./1000,'r',-Toem_e(in2),Q.Zret(in2)./1000,'r')
% hold off;
% grid on;
% xlabel('(T OEM - T digital traditional) (K)')
% ylabel('Altitude(km)')%  ylabel('Altitude(km)')
%   set(gca,'fontsize',20)
% 
% 
% subplot(1,3,3)
% plot((T_dg(in3)-Q.Tsonde2(in3)),Q.Zret(in3)./1000,'r',( T_dg(in3)' - Toem(in3)),Q.Zret(in3)./1000,'b',(Toem(in) - Q.Tsonde2(in)'),Q.Zret(in)./1000,'g')
% hold on
% plot(( T_an(in2)' - Toem(in2)),Q.Zret(in2)./1000,'y',(T_an(in2)-Q.Tsonde2(in2)),Q.Zret(in2)./1000,'black');
% grid on;
% hold off
% xlabel('Temperature residuals (K)')
% ylabel('Altitude (km)')%  ylabel('Altitude(km)')
% legend('Traditional digital-Sonde','OEM - Traditional digital','OEM - Sonde','OEM - Traditional analog','Traditional analog-Sonde')
%   set(gca,'fontsize',20)



% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 



%                     subplot(1,2,2)
%                     plot((((-Q.OVa')+X.x(m+4:end-5) )./X.x(m+4:end-5)).*100,Q.Zret./1000)
%                     grid on;
%                     xlabel('OV residuals(OV OEM - OV a priori) (%)')
%                     %  plot(((X.x(1:m) - (Treal'))./(Treal')).*100,Q.Zret./1000)
%                     %  xlabel('Temperature Percent Error (%)')
%                     ylabel('Altitude ( km )')%  ylabel('Altitude(km)')

                    
                    
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Residual plots
                    figure;
                    subplot(2,2,1)
                    grid on;
                    % plot(((y(1:Q.n1) - X.yf(1:Q.n1))./y(1:Q.n1)).*100 ,Q.Zmes2(Q.ind)./1000)
                    plot(((y(1:n1) - X.yf(1:n1))./X.yf(1:n1)).*100 ,Q.Zmes2./1000)
                    hold on
                    plot(-(sqrt(yJH)./X.yf(1:n1)).*100,Q.Zmes2./1000,'r',(sqrt(yJH)./X.yf(1:n1)).*100,Q.Zmes2./1000,'r');
                    %plot(-(1./sqrt(yJH)).*100,Q.Zmes2./1000,'r',(1./sqrt(yJH)).*100,Q.Zmes2./1000,'r');
                   ylim([2 30])
                   grid off
                    hold off
                    xlabel('JH digital (%)')
                    ylabel('Altitude (km)')
                    set(gca,'fontsize',20)
                    
                    
                    
                    subplot(2,2,2)
                    grid on;
                    plot(((y(n1+1:n1+n2) - X.yf(n1+1:n1+n2))./X.yf(n1+1:n1+n2)).*100 ,Q.Zmes2./1000)
                    hold on;
                    plot(-(sqrt(yJL)./X.yf(n1+1:n1+n2)).*100,Q.Zmes2./1000,'r',(sqrt(yJL)./X.yf(n1+1:n1+n2)).*100,Q.Zmes2./1000,'r');
                    %plot(-(1./sqrt(yJL)).*100,Q.Zmes2./1000,'r',(1./sqrt(yJL)).*100,Q.Zmes2./1000,'r');
                    ylim([2 30])
                    grid off;
                    hold off
                    xlabel('JL digital (%)')
                    ylabel('Altitude (km)')
                    set(gca,'fontsize',20)



                    subplot(2,2,3)
                    grid on;
                    % plot(((y(1:Q.n1) - X.yf(1:Q.n1))./y(1:Q.n1)).*100 ,Q.Zmes1(Q.ind)./1000)
                    plot(((y(n1+n2+1:n1+n2+n3) - X.yf(n1+n2+1:n1+n2+n3))./X.yf(n1+n2+1:n1+n2+n3)).*100 ,Q.Zmes1./1000)
                    hold on
                    %                     plot(-(sqrt(yJHa)./X.yf(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r',(sqrt(yJHa)./X.yf(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r');
                    plot(-(sqrt(Q.YYYa')./y(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r',(sqrt(Q.YYYa')./y(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r');
                    
                    grid off
                    hold off
                    xlabel('JH analog (%)')
                    ylabel('Altitude (km)')
                    set(gca,'fontsize',20)
                    
                    
                    subplot(2,2,4)
                    grid on;
                    plot(((y(n1+n2+n3+1:end) - X.yf(n1+n2+n3+1:end))./X.yf(n1+n2+n3+1:end)).*100 ,Q.Zmes1./1000)
                    hold on;
                    plot(-(sqrt(Q.YYa')./y(n1+n2+n3+1:end)).*100,Q.Zmes1./1000,'r',(sqrt(Q.YYa')./y(n1+n2+n3+1:end)).*100,Q.Zmes1./1000,'r');
                    %plot(-(1./sqrt(yJLa)).*100,Q.Zmes1./1000,'r',(1./sqrt(yJLa)).*100,Q.Zmes1./1000,'r');
                    grid off
                    hold off
                    xlabel('JL analog (%)')
                    ylabel('Altitude (km)')
                    set(gca,'fontsize',20)

                     

                    

 Error = errors(Q,X);  % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %   b parameters and errors
%                     
% R1 =bparameterjacobians (Q,X);
% 
% S_b.degF1 = trace(X.A(1:m,1:m)); %DegF for Temperature 
% S_b.degF2 = trace(X.A(m+4:end-5,m+4:end-5))%DegF for OV
% 
% %                     %% Percent difference of background, lidar calibration constant retrievals and the true
% % 
% %                     percent_BG_JH = ((Q.Bg_JH_real -BJH)./BJH).*100
% %                     percent_BG_JL = ((Q.Bg_JL_real -BJL)./BJL).*100
% %                     percent_CJL = ((Q.CL -CJL)./CJL).*100
% %                     % e = cputime
% %                     toc
% % 
% % 
% %                     % %  %%
% %                     % % % calculate error matrices
%                     dfacP1 = 0.1;
%                     dfacP2 = 0.1;% ISSI recommend
%                     dfacR = 0.01; % ISSI recommend
%                     dfacRa = 0.01; % ISSI recommend
%                     dfacAir = 0.01; % BOb code
%                     dfacaero = 0.01;
% %                     % % dfacDT = 0.1;
% 
% %                     % % Pressure error
%                     SP1 = (dfacP1.*Q.P0.*ones(n1,1)).^2;
%                     SP2 = (dfacP2.*Q.P0.*ones(n3,1)).^2;% for 2 digital channels
%                     SP = [SP1 SP1 SP2 SP2];
%                     S_P = diag(SP);
%                     
% %                     % % R  and Ra error
%                     SR1 = (dfacR.*Q.R).^2;
%                     SR1= SR1.*ones(n1,1);
%                     SR2 = zeros(n2+n3+n4,1);
%                     SR = [SR1 ;SR2];
%                     S_R = diag(SR);
%                     
%                     SRa1 = (dfacRa.*Q.Ra).^2;
%                     SRa1= SRa1.*ones(n3,1);
%                     SRa2 = zeros(n4,1);
%                     ss = zeros(n1+n2,1);
%                     SRa = [ss ;SRa1;SRa2];
%                     S_Ra = diag(SRa);
%                     
% %                     % % air
%                     Sair1 = (dfacAir.*Q.sigmaNicolet.*ones(n1,1)).^2;
%                     Sair2 = (dfacAir.*Q.sigmaNicolet.*ones(n3,1)).^2;
%                     Sair = [Sair1 Sair1 Sair2 Sair2];
%                     S_air = diag(Sair);
% %                     % % aerosol
%                     Saero1 = (dfacaero.*Q.alpha_aero(n3+1:end)').^2;
%                     Saero2 = (dfacaero.*Q.alpha_aero(1:n3)').^2;
%                     Saero = [Saero1 Saero1 Saero2 Saero2];
%                     S_aero = diag(Saero);
% %                  
% 
% S_b.SxP = X.G*R1.JPress*S_P*R1.JPress'*X.G';
% S_b.SxR = X.G*R1.JR*S_R*R1.JR'*X.G';
% S_b.SxRa = X.G*R1.JRa*S_Ra*R1.JRa'*X.G';
% S_b.SxAir = X.G*R1.Jnair*S_air*R1.Jnair'*X.G';
% S_b.Sxaero = X.G*R1.Jaero*S_aero*R1.Jaero'*X.G';
% 
% % Errors
% 
% P = diag(S_b.SxP);
% Rc = diag(S_b.SxR);
% Ra = diag(S_b.SxRa);
% Air = diag(S_b.SxAir);
% Aero = diag(S_b.Sxaero);
% 
% 
% total_err_T = sqrt( X.eo(1:m).^2 + P(1:m)  + Rc(1:m)+ Ra(1:m) + Air(1:m) + Aero(1:m));
% 
% % Errors for Temperature
% figure;
% plot(X.eo(1:m),Q.Zret./1000,'r')
% hold on;
%  plot(sqrt(P(1:m)),Q.Zret./1000,'--*')
% plot(sqrt(Rc(1:m)),Q.Zret./1000,'--^')
% plot(sqrt(Ra(1:m)),Q.Zret./1000,'--+')
% plot(sqrt(Air(1:m)),Q.Zret./1000,'--o')
% plot(sqrt(Aero(1:m)),Q.Zret./1000,'--s')
% plot(total_err_T,Q.Zret/1000,'black')
% xlabel('Temperature Uncertainty')
% ylabel('Altitude (km)')
% legend('Statistical','Pressure - P0','R','Ra','Air density','Aerosol','Total Error')
% 
% % Errors for Overlap
% total_err_OV = sqrt( X.eo(m+4:end-5).^2 + P(m+4:end-5) + Rc(m+4:end-5)+ Ra(m+4:end-5) + Air(m+4:end-5) + Aero(m+4:end-5));
% 
% figure;
% plot(X.eo(m+4:end-5),Q.Zret./1000,'r')
% hold on;
%  plot(sqrt(P(m+4:end-5)),Q.Zret./1000,'--*')
% plot(sqrt(Rc(m+4:end-5)),Q.Zret./1000,'--^')
% plot(sqrt(Ra(m+4:end-5)),Q.Zret./1000,'--+')
% plot(sqrt(Air(m+4:end-5)),Q.Zret./1000,'--o')
% plot(sqrt(Aero(m+4:end-5)),Q.Zret./1000,'--s')
% plot(total_err_OV,Q.Zret/1000,'black')
% xlabel('Overlap Uncertainty')
% ylabel('Altitude (km)')
% legend('Statistical','Pressure - P0','R','Ra','Air density','Aerosol','Total Error')