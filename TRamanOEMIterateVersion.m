function [X,R,Q,O,S_a,Se,xa,S_b,Error]=TRamanOEMIterateVersion( date_in,time_in,flag,Input)
tic
[O,Q,R,S_a,Se,xa] = InputsForOEMIterateVersion( date_in,time_in,flag,Input);
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
X.cost(end)

% 'OEM-BG-JH'
% BJH
% 
% 'real-BG-JH'
% Q.BaJH
% 
% 'OEM-BG-JL'
% BJL
% 
% 'real-BG-JL'
% Q.BaJL
% 
% 'OEM-CL'
% CJL
% 
% 
% 'OEM-BG-JHa'
% BJHa
% 
% 'real-BG-JHa'
% Q.BaJHa
% 
% 'OEM-BG-JLa'
% BJLa
% 
% 'real-BG-JLa'
% Q.BaJLa
% 
% 'OEM-CLa'
% CJLa
% 
% 'OEM-CHa'
% CJHa
% 
% 'DT-JH'
% DT_JH
% 
% 'DT-JL'
% DT_JL

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
%                     unit = ones(size(Q.Zret));
%                     response = (X.A(1:m,1:m))*unit';
% 
%                     % Vertical resolution
%                     width = zeros(size(Q.Zret));
%                     for j = 1:m % fini
%                         width(j) = fwhmquiet(Q.Zret,X.A(1:m,j));
%                         if isnan(width(j))
%                             width(j) = 0;
%                         end
%                     end
% 
% 
% 
%                     figure;
%                     subplot(1,2,1)
%                     %                     set(gca,'fontsize',16)
%                     % hold on;
%                     plot(X.A(1:5:m,1:5:m),Q.Zret(1:5:m)./1000)
%                     grid on;
%                     hold on;
%                     plot(response,Q.Zret./1000,'r')
%                     % plot(X.A(1:m,1:m).*unit,Q.Zret./1000)
%                     hold off;
%                     xlabel('Temperature - Averaging Kernels')
%                     ylabel('Altitude ( km )')
%                     title( Q.Dateofthefolder);
%                     set(gca,'fontsize',16)
%                     
%                     subplot(1,2,2)
%                     plot(X.A(m+4:5:end-5,m+4:5:end-5),Q.Zret(1:5:m)./1000)
%                     
%                     xlabel('Overlap - Averaging Kernels')
%                     ylabel('Altitude ( km )')
%                     title( Q.Dateofthefolder);
%                     set(gca,'fontsize',16)
% 
%                     
%                     
%                     
% %                     OVresponse = (X.A(m+4:end-5,m+4:end-5))*unit';
%                 figure;
%                 plot(width(2:end-2)./1000,Q.Zret(2:end-2)./1000)
%                 grid on;
%                 xlabel('Vertical Resolution ( km )')
%                 ylabel('Altitude ( km )')
%                 set(gca,'fontsize',16)
% %                     %
%                     err = X.e(1:m);
%                     upper = err+ X.x(1:m);
%                     lower =  X.x(1:m)-err;
% 
%                     
%                     
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                    
% % load traditional temperature profiles
% % % % date = Q.date_in;
% % % % time = Q.time_in;
% % % % [year,month,day] = getYMDFromDate(date);
% % % % yr = num2str(year);
% % % % datadirS3 = '/Users/sham/Downloads/OEM-Sham-Code-Jan-2017/QpackSham/TraditionalTemperature';
% % % % filename =[yr  sprintf('%02.f',month) sprintf('%02.f',day) sprintf('%02.f',time)];
% % % % folderpath = [datadirS3 filesep filename];
% % % % load(folderpath);
% % % % 
% % % % T_an = interp1(H.alt_an,H.T_an,Q.Zret);
% % % % T_dg = interp1(H.alt_digi,H.T_dg,Q.Zret);
% % % % T_cm = interp1(H.alt_com,H.T_cm,Q.Zret);
% 
% 
% Toem= X.x(1:m);
% 
% figure;
% subplot(1,2,1)
% % Create plot
% plot(Q.Ta(Q.Zret<=30000),Q.Zret(Q.Zret<=30000)./1000,'DisplayName','T a priori','LineWidth',1,...
%     'Color',[0 0.498039215803146 0]);
% 
% hold on;
% 
% % Create plot
% plot(Toem(Q.Zret<=30000),Q.Zret(Q.Zret<=30000)./1000,'DisplayName','T OEM','Color',[1 0 0]);
% 
% % Create plot
% plot(Q.Tsonde2(Q.Zret<=30000),Q.Zret(Q.Zret<=30000)./1000,'DisplayName','T sonde','Color',[0 0 1]);
% 
% % % Create plot
% % plot(T_an(Q.Zret<=6000),Q.Zret(Q.Zret<=6000)./1000,'DisplayName','Traditionalanalog','LineWidth',1,'Color',[0 0 0]);
% % 
% % % Create plot
% % plot(T_dg(Q.Zret<=25000),Q.Zret(Q.Zret<=25000)./1000,'DisplayName','TraditionalDigital','LineWidth',1,...
% %     'Color',[0.929411768913269 0.694117665290833 0.125490203499794]);
% % 
% % % Create plot
% % plot(T_cm(Q.Zret<=25000),Q.Zret(Q.Zret<=25000)./1000,'DisplayName','TraditionalCombined','LineWidth',1,...
% %     'Color',[0.854901969432831 0.701960802078247 1]);
% 
% % [fillhandle,msg]=jbfilly(Q.Zret./1000,upper',lower',rand(1,3),rand(1,3),0,0.5);
% jbfilly(Q.Zret(Q.Zret<=30000)./1000,upper(Q.Zret<=30000)',lower(Q.Zret<=30000)',[0.9 1 1],[0.94 0.87 0.87],0,0.5);
% 
% % Create xlabel
% xlabel('Temperature (K)');
% 
% % Create ylabel
% ylabel('Altitude(km)');
% 
% % box(axes1,'on');
% % grid(axes1,'on');
% % Create legend
% % legend(axes1,'show');
% legend ('T a priori','T OEM','T sonde')
%  title( Q.Dateofthefolder);
%   set(gca,'fontsize',16)
% 
% 
% hold off;
% 
% subplot(1,2,2)
% plot(Q.Ta(Q.Zret<=5000),Q.Zret(Q.Zret<=5000)./1000,'DisplayName','T a priori','LineWidth',1,...
%     'Color',[0 0.498039215803146 0]);
% hold on;
% plot(Toem(Q.Zret<=5000),Q.Zret(Q.Zret<=5000)./1000,'DisplayName','T OEM','Color',[1 0 0]);
% 
% 
% % Create plot
% plot(Q.Tsonde2(Q.Zret<=5000),Q.Zret(Q.Zret<=5000)./1000,'DisplayName','T sonde','Color',[0 0 1]);
% 
% 
% jbfilly(Q.Zret(Q.Zret<=5000)./1000,upper(Q.Zret<=5000)',lower(Q.Zret<=5000)',[0.9 1 1],[0.94 0.87 0.87],0,0.5);
% 
% % Create xlabel
% xlabel('Temperature (K)');
% 
% % Create ylabel
% ylabel('Altitude(km)');
% legend ('T a priori','T OEM','T sonde')
%   set(gca,'fontsize',16)
% 
% hold off;


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
%  title( Q.Dateofthefolder);
%    set(gca,'fontsize',16)
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
%   set(gca,'fontsize',16)
% 
% 
% subplot(1,3,3)
% plot((T_dg(in3)-Q.Tsonde2(in3)),Q.Zret(in3)./1000,'r',( T_dg(in3)' - Toem(in3)),Q.Zret(in3)./1000,'b',(Toem(in) - Q.Tsonde2(in)'),Q.Zret(in)./1000,'g')
% hold on
% plot(( T_an(in2)' - Toem(in2)),Q.Zret(in2)./1000,'y',(T_an(in2)-Q.Tsonde2(in2)),Q.Zret(in2)./1000,'black');
% grid on;
% hold off
% xlabel('Temperature residuals (K)')
% ylabel('Altitude(km)')%  ylabel('Altitude(km)')
% legend('Traditional digital-Sonde','OEM - Traditional digital','OEM - Sonde','OEM - Traditional analog','Traditional analog-Sonde')
%   set(gca,'fontsize',16)



% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%        Overlap
%                     figure;
% %                     subplot(1,2,1)
%                     plot(Q.OVa,Q.Zret./1000,'g',X.x(m+4:end-5),Q.Zret./1000,'r')
%                     grid on;
%                     xlabel('OV')
%                     ylabel('Altitude ( km )')
%                     legend('OV a priori','OV OEM')
%                                          title( Q.Dateofthefolder);
%                                            set(gca,'fontsize',16)




                    
                    
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Residual plots
%                     figure;
%                     subplot(2,2,1)
%                     grid on;
%                     % plot(((y(1:Q.n1) - X.yf(1:Q.n1))./y(1:Q.n1)).*100 ,Q.Zmes2(Q.ind)./1000)
%                     plot(((y(1:n1) - X.yf(1:n1))./X.yf(1:n1)).*100 ,Q.Zmes2./1000)
%                     hold on
%                     plot(-(sqrt(yJH)./X.yf(1:n1)).*100,Q.Zmes2./1000,'r',(sqrt(yJH)./X.yf(1:n1)).*100,Q.Zmes2./1000,'r');
%                     %plot(-(1./sqrt(yJH)).*100,Q.Zmes2./1000,'r',(1./sqrt(yJH)).*100,Q.Zmes2./1000,'r');
% 
%                     hold off
%                     xlabel('JH digital counts residual(%)')
%                     ylabel('Altitude (km)')
%                     title( Q.Dateofthefolder);
%                       set(gca,'fontsize',16)
% 
% 
% 
%                     subplot(2,2,2)
%                     grid on;
%                     plot(((y(n1+1:n1+n2) - X.yf(n1+1:n1+n2))./X.yf(n1+1:n1+n2)).*100 ,Q.Zmes2./1000)
%                     hold on;
%                     plot(-(sqrt(yJL)./X.yf(n1+1:n1+n2)).*100,Q.Zmes2./1000,'r',(sqrt(yJL)./X.yf(n1+1:n1+n2)).*100,Q.Zmes2./1000,'r');
%                     %plot(-(1./sqrt(yJL)).*100,Q.Zmes2./1000,'r',(1./sqrt(yJL)).*100,Q.Zmes2./1000,'r');
% 
%                     hold off
%                     xlabel('JL digital counts residual(%)')
%                     ylabel('Altitude (km)')
%                       set(gca,'fontsize',16)
% 
% 
% 
%                     subplot(2,2,3)
%                     grid on;
%                     % plot(((y(1:Q.n1) - X.yf(1:Q.n1))./y(1:Q.n1)).*100 ,Q.Zmes1(Q.ind)./1000)
%                     plot(((y(n1+n2+1:n1+n2+n3) - X.yf(n1+n2+1:n1+n2+n3))./X.yf(n1+n2+1:n1+n2+n3)).*100 ,Q.Zmes1./1000)
%                     hold on
% %                     plot(-(sqrt(yJHa)./X.yf(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r',(sqrt(yJHa)./X.yf(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r');
%                     plot(-(sqrt(Q.YYYa')./y(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r',(sqrt(Q.YYYa')./y(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r');
%                     
% 
%                     hold off
%                     xlabel('JH - analog counts residual(%)')
%                     ylabel('Altitude (km)')
%                       set(gca,'fontsize',16)
% 
% 
%                     subplot(2,2,4)
%                     grid on;
%                     plot(((y(n1+n2+n3+1:end) - X.yf(n1+n2+n3+1:end))./X.yf(n1+n2+n3+1:end)).*100 ,Q.Zmes1./1000)
%                     hold on;
%                     plot(-(sqrt(Q.YYa')./y(n1+n2+n3+1:end)).*100,Q.Zmes1./1000,'r',(sqrt(Q.YYa')./y(n1+n2+n3+1:end)).*100,Q.Zmes1./1000,'r');
%                     %plot(-(1./sqrt(yJLa)).*100,Q.Zmes1./1000,'r',(1./sqrt(yJLa)).*100,Q.Zmes1./1000,'r');
% 
%                     hold off
%                     xlabel('JL - analog counts residual(%)')
%                     ylabel('Altitude (km)')
%                       set(gca,'fontsize',16)

                     

                    
S_b.degF1 = trace(X.A(1:m,1:m)); %DegF for Temperature 
S_b.degF2 = trace(X.A(m+4:end-5,m+4:end-5));%DegF for OV            
 
Error = errorsIT(Q,X); 
close all;
fname = sprintf('%d_%d.mat', date_in,time_in);
save(fname,'X','Q','S_b','Error')
