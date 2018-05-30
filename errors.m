% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   b parameters and errors
function Error = errors (Q,X)              
R1 =bparameterjacobians (Q,X);
n1 = Q.n1;
n2 = Q.n2;
n3 = Q.n3;
n4= Q.n4;
m = length(Q.Zret);

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
                    dfacP1 = 30; %0.3hPa sonde error
                    dfacP2 = 30;% Sonde error
                    dfacR = Q.GR; % ISSI recommend
                    dfacRa = Q.GRa; % ISSI recommend
                    dfacAir = 0.01; % BOb code
%                     dfacaero = 0.5;
%                     % % dfacDT = 0.1;

%                     % % Pressure error
Pd = Q.Pressi(end-length(Q.JHnew)+1:end);%exp(Pdigid);
Pa = Q.Pressi(1:length(Q.JHnewa));%exp(Pdigia);
                    SP1 = (dfacP1.*ones(n1,1)).^2;
                    SP2 = (dfacP2.*ones(n3,1)).^2;% for 2 digital channels
                    SP = [SP1; SP1; SP2; SP2];
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
                    
%                     % % air
                    Sair1 = (dfacAir.*Q.sigmaNicolet.*ones(n1,1)).^2;
                    Sair2 = (dfacAir.*Q.sigmaNicolet.*ones(n3,1)).^2;
                    Sair = [Sair1 ;Sair1 ;Sair2 ;Sair2];
                    S_air = diag(Sair);
%                     % % aerosol

%                     Saero1 = (dfacaero.*Q.alpha_aero(end-n1+1:end)').^2;
%                     Saero2 = (dfacaero.*Q.alpha_aero(1:n3)').^2;
%                     Saero = [Saero1 Saero1 Saero2 Saero2];
%                     S_aero = diag(Saero);
%                  

S_b.SxP = X.G*R1.JPress*S_P*R1.JPress'*X.G';
S_b.SxR = X.G*R1.JR*S_R*R1.JR'*X.G';
S_b.SxRa = X.G*R1.JRa*S_Ra*R1.JRa'*X.G';
S_b.SxAir = X.G*R1.Jnair*S_air*R1.Jnair'*X.G';
% S_b.Sxaero = X.G*R1.Jaero*S_aero*R1.Jaero'*X.G';

% Errors

P = diag(S_b.SxP);
Rc = diag(S_b.SxR);
Ra = diag(S_b.SxRa);
Air = diag(S_b.SxAir);
% Aero = diag(S_b.Sxaero);


total_err_T = sqrt( X.eo(1:m).^2 + P(1:m)  + Rc(1:m)+ Ra(1:m) + Air(1:m));

Error.P_ErrorT = sqrt(P(1:m));
Error.R_ErrorT =sqrt(Rc(1:m));
Error.Ra_ErrorT =sqrt(Ra(1:m));
Error.Air_ErrorT =sqrt(Air(1:m));
% Error.Aero_ErrorT =sqrt(Aero(1:m));
Error.Total_ErrorT =total_err_T;

% Errors for Temperature
figure;
semilogx(X.eo(1:m),Q.Zret./1000,'r')
hold on;
semilogx(sqrt(P(1:m)),Q.Zret./1000,'--*')
semilogx(sqrt(Rc(1:m)),Q.Zret./1000,'--^')
semilogx(sqrt(Ra(1:m)),Q.Zret./1000,'--+')
semilogx(sqrt(Air(1:m)),Q.Zret./1000,'--o')
% semilogx(sqrt(Aero(1:m)),Q.Zret./1000,'--s')
semilogx(total_err_T,Q.Zret/1000,'black')
xlabel('Temperature Uncertainty (K)')
ylabel('Altitude (km)')
legend('Statistical','Pressure','R','Ra','Sigma Rayleigh','Total Error')
%  title( Q.Dateofthefolder);
  set(gca,'fontsize',20)


  %%% This needs to be edited and add errors for aerosol
% Errors for Overlap
total_err_OV = sqrt( X.eo(m+4:2*m+3).^2 + P(m+4:2*m+3) + Rc(m+4:2*m+3)+ Ra(m+4:2*m+3) + Air(m+4:2*m+3));


Error.P_ErrorOV = sqrt(P(m+4:2*m+3)).*1e2;
Error.R_ErrorOV =sqrt(Rc(m+4:2*m+3)).*1e2;
Error.Ra_ErrorOV =sqrt(Ra(m+4:2*m+3)).*1e2;
Error.Air_ErrorOV =sqrt(Air(m+4:2*m+3)).*1e2;
% Error.Aero_ErrorOV =sqrt(Aero(m+4:2*m+3)).*1e2;
Error.Total_ErrorOV =total_err_OV.*1e2;

figure;
subplot(1,2,1)
plot(X.eo(m+4:2*m+3).*1e2,Q.Zret./1000,'r')
hold on;
 plot(sqrt(P(m+4:2*m+3)).*1e2,Q.Zret./1000,'--*')
plot(sqrt(Rc(m+4:2*m+3)).*1e2,Q.Zret./1000,'--^')
plot(sqrt(Ra(m+4:2*m+3)).*1e2,Q.Zret./1000,'--+')
plot(sqrt(Air(m+4:2*m+3)).*1e2,Q.Zret./1000,'--o')
% plot(sqrt(Aero(m+4:2*m+3)).*1e2,Q.Zret./1000,'--s')
plot(total_err_OV.*1e2,Q.Zret/1000,'black')
hold off
xlabel('Overlap Uncertainty (%)')
ylabel('Altitude (km)')
legend('Statistical','Pressure','R','Ra','Sigma Rayleigh','Total Error')
% title( Q.Dateofthefolder);
set(gca,'fontsize',20)





% Aerosol Error
total_err_ae = sqrt( X.eo(2*m+9:end).^2 + P(2*m+9:end) + Rc(2*m+9:end)+ Ra(2*m+9:end) + Air(2*m+9:end));


Error.P_Errorae = sqrt(P(2*m+9:end)).*1e2;
Error.R_Errorae =sqrt(Rc(2*m+9:end)).*1e2;
Error.Ra_Errorae =sqrt(Ra(2*m+9:end)).*1e2;
Error.Air_Errorae =sqrt(Air(2*m+9:end)).*1e2;
% Error.Aero_Errorae =sqrt(Aero(2*m+9:end)).*1e2;
Error.Total_Errorae =total_err_ae.*1e2;

subplot(1,2,2)
semilogx(X.eo(2*m+9:end).*1e2,Q.Zret./1000,'r')
hold on;
semilogx(sqrt(P(2*m+9:end)).*1e2,Q.Zret./1000,'--*')
semilogx(sqrt(Rc(2*m+9:end)).*1e2,Q.Zret./1000,'--^')
semilogx(sqrt(Ra(2*m+9:end)).*1e2,Q.Zret./1000,'--+')
semilogx(sqrt(Air(2*m+9:end)).*1e2,Q.Zret./1000,'--o')
% semilogx(sqrt(Aero(2*m+9:end)).*1e2,Q.Zret./1000,'--s')
semilogx(total_err_ae.*1e2,Q.Zret/1000,'black')
hold off;
xlabel('Aerosol Extinction Uncertainty (%)')
ylabel('Altitude (km)')
legend('Statistical','Pressure','R','Ra','Sigma Rayleigh','Total Error')
% title( Q.Dateofthefolder);
set(gca,'fontsize',20)