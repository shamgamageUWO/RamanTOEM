function [X,R,Q,O,S_a,Se,xa]=TRamanOEM( date_in,time_in,flag)
tic
[O,Q,R,S_a,Se,xa] = InputsForOEM( date_in,time_in,flag);
xa = xa';
S_ainv=[];
Seinv=[];
m = length(Q.Zret);
% n = Q.n3+Q.n4;
% n1 = Q.n1;
% n2 = Q.n2;
n3 = Q.n3;
y = Q.y;
% 
% yJH = smooth(y(1:n1),100);
% yJL = smooth(y(n1+1:n1+n2),100);
yJHa = smooth(y(1:n3),100);
yJLa = smooth(y(n3+1:end),100);



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

% CJL = X.x(m+3);
% BJH = X.x(m+1);
% BJL = X.x(m+2);
% CJHa = X.x(end-1);
CJLa = X.x(end);
BJHa = X.x(end-2);
BJLa = X.x(end-1);
% DT_JH = X.x(end-1);
% DT_JL = X.x(end); % deadtimes

'X.cost'
X.cost

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
% answ = (Q.Ra * CJLa)
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
% 
% 
% 
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
% 
                     [Tsonde,Zsonde,Psonde] = get_sonde_RS92(Q.date_in,Q.time_in);
                     Zsonde = Zsonde-491; % altitude correction
%                     lnQ = log(Q.y(1:Q.n1)./Q.y(Q.n1+1:end));
%                     Ttradi = real(Q.bb./(Q.aa-lnQ));
% 
                    Tsonde = interp1(Zsonde,Tsonde,Q.Zret);
                    figure;
%                     subplot(1,2,1)
                    plot(Q.Ta,Q.Zret./1000,'g',X.x(1:m),Q.Zret./1000,'r',Tsonde,Q.Zret./1000,'b')
                    grid on;
                    hold on
                    [fillhandle,msg]=jbfilly(Q.Zret./1000,upper',lower',rand(1,3),rand(1,3),0,0.5);
                    %  shadedErrorBar(X.x(1:m),Q.Zret./1000,err,'-r',1);
                    % jbfilly(Q.Zret./1000,upper',lower',rand(1,3),rand(1,3),0,rand(1,1))
                    xlabel('Temperature (K)')
                    ylabel('Altitude(km)')
                    legend('T a priori','T OEM','T sonde')
                    hold off;
% 
%                     %  Treal = interp1(Q.Zmes,Q.Treal,Q.Zret,'linear');
% 
%                      subplot(1,2,2)
%                      plot(X.x(1:m) - (Tsonde'),Q.Zret./1000)
%                      hold on;
%                      plot(X.eo(1:m),Q.Zret./1000,'r',-X.eo(1:m),Q.Zret./1000,'r')
%                      hold off;
%                      grid on;
%                      xlabel('Temperature residuals(T OEM - T sonde) (K)')
% %                     %  plot(((X.x(1:m) - (Treal'))./(Treal')).*100,Q.Zret./1000)
% %                     %  xlabel('Temperature Percent Error (%)')
%                      ylabel('Altitude(km)')%  ylabel('Altitude(km)')
% 
% 
                    figure;
                    subplot(1,2,1)
                    plot(Q.OVa,Q.Zret./1000,'g',X.x(m+1:end-3),Q.Zret./1000,'r')
                    grid on;
                    xlabel('OV')
                    ylabel('Altitude(km)')
                    legend('OV a priori','OV OEM')


                    %  Treal = interp1(Q.Zmes,Q.Treal,Q.Zret,'linear');

                    subplot(1,2,2)
                    plot((((-Q.OVa')+X.x(m+1:end-3) )./X.x(m+1:end-3)).*100,Q.Zret./1000)
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


                    subplot(1,2,1)
                    grid on;
                    % plot(((y(1:Q.n1) - X.yf(1:Q.n1))./y(1:Q.n1)).*100 ,Q.Zmes1(Q.ind)./1000)
                    plot(((y(1:n3) - X.yf(1:n3))./X.yf(1:n3)).*100 ,Q.Zmes1./1000)
                    hold on
%                     plot(-(sqrt(yJHa)./X.yf(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r',(sqrt(yJHa)./X.yf(n1+n2+1:n1+n2+n3)).*100,Q.Zmes1./1000,'r');
                    plot(-(Q.YYYa'./y(1:n3)).*100,Q.Zmes1./1000,'r',(Q.YYYa'./y(1:n3)).*100,Q.Zmes1./1000,'r');
                    
%plot(-(1./sqrt(yJHa)).*100,Q.Zmes1./1000,'r',(1./sqrt(yJHa)).*100,Q.Zmes1./1000,'r');

                    hold off
                    xlabel('JH - analog counts residual(%)')
                    ylabel('Altitude (km)')

                    subplot(1,2,2)
                    grid on;
                    plot(((y(n3+1:end) - X.yf(n3+1:end))./X.yf(n3+1:end)).*100 ,Q.Zmes1./1000)
                    hold on;
                    plot(-(Q.YYa'./y(n3+1:end)).*100,Q.Zmes1./1000,'r',(Q.YYa'./y(n3+1:end)).*100,Q.Zmes1./1000,'r');
                    %plot(-(1./sqrt(yJLa)).*100,Q.Zmes1./1000,'r',(1./sqrt(yJLa)).*100,Q.Zmes1./1000,'r');

                    hold off
                    xlabel('JL - analog counts residual(%)')
                    ylabel('Altitude (km)')
                    
                    
                    
                    figure; 
%                      subplot(1,3,1)
                     plot(X.x(1:m) - (Tsonde'),Q.Zret./1000)
                     hold on;
                     plot(X.eo(1:m),Q.Zret./1000,'r',-X.eo(1:m),Q.Zret./1000,'r')
                     hold off;
                     grid on;
                     xlabel('Temperature residuals(T OEM - T sonde) (K)')
                     ylabel('Altitude(km)')%  ylabel('Altitude(km)')
                     
%                     subplot(1,3,2)
%                      plot(X.x(1:m) - (Q.Ttradi),Q.Zret./1000)
%                      hold on;
%                      plot(X.eo(1:m),Q.Zret./1000,'r',-X.eo(1:m),Q.Zret./1000,'r')
%                      hold off;
%                      grid on;
%                      xlabel('Temperature residuals(T OEM - T traditional) (K)')
%                      ylabel('Altitude(km)')%  ylabel('Altitude(km)')
%                      
%                       subplot(1,3,2)
%                      plot((Q.Ttradi)-(Tsonde'),Q.Zret./1000)
% %                      hold on;
% %                      plot(X.eo(1:m),Q.Zret./1000,'r',-X.eo(1:m),Q.Zret./1000,'r')
% %                      hold off;
%                      grid on;
%                      xlabel('Temperature residuals(T OEM - T traditional) (K)')
%                      ylabel('Altitude(km)')%  ylabel('Altitude(km)')
%                      
% (mchanA+1:2*mchanA))./y(mchanA+1:2*mchanA)
%                     %% Percent difference of background, lidar calibration constant retrievals and the true
% 
%                     percent_BG_JH = ((Q.Bg_JH_real -BJH)./BJH).*100
%                     percent_BG_JL = ((Q.Bg_JL_real -BJL)./BJL).*100
%                     percent_CJL = ((Q.CL -CJL)./CJL).*100
%                     % percent_CJLTrue = ((Q.CL*(1.05) -CJL)./CJL).*100
%                     Degree_of_freedom_Temperature = trace(X.A(1:m,1:m))
%                     % e = cputime
%                     toc
% 
% 
%                     % %  %%
%                     % % % calculate error matrices
%                     % % dfacP = 0.1; % ISSI recommend
%                     % % dfacR = 0.1; % ISSI recommend
%                     % % dfacAir = 0.01; % BOb code
%                     % % dfacaero = 0.01;
%                     % % dfacDT = 0.1;
%                     % %
%                     % % SP = (dfacP.*Q.Pressi).^2;
%                     % % SP = [SP SP];
%                     % % SP = diag(SP);
%                     % %
%                     % % SR = (dfacR.*Q.R).^2;
%                     % %
%                     % % Sair = (dfacAir.*Q.Nmol).^2;
%                     % % Sair = [Sair Sair];
%                     % % Sair = diag(Sair);
%                     % %
%                     % % Saero = (dfacaero.*Q.alpha_aero').^2;
%                     % % Saero = [Saero Saero];
%                     % % Saero = diag(Saero);
%                     % %
%                     % % SDT = (dfacDT.*Q.deadtime).^2;
%                     % %
%                     % %
%                     % % SxP = X.G*R.JPress*SP*R.JPress'*X.G';
%                     % % SxR = X.G*R.JR*SR*R.JR'*X.G';
%                     % % SxAir = X.G*R.Jnair*Sair*R.Jnair'*X.G';
%                     % % Sxaero = X.G*R.Jaero*Saero*R.Jaero'*X.G';
%                     % % SxDT = X.G*R.JDT*SDT*R.JDT'*X.G';
