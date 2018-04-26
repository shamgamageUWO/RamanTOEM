function R =bparameterjacobians (Q,X)
%%[X,R,Q,O,S_a,Se,xa]=TRamanOEM( date_in,time_in,flag)
m = length(Q.Zret);
x = X.x;
% x_a = x(1:m);
% BJH = x(m+1);
% BJL = x(m+2);
% CJL = x(m+3);
% OV = x(m+4:end-5);
% BJHa = x(end-4);
% BJLa = x(end-3);
% CJLa = x(end-2);
% DT_JH = x(end-1);
% DT_JL = x(end); % deadtimes

x_a = x(1:m);
BJH = x(m+1);
BJL = x(m+2);
CJL = x(m+3);
OV = x(m+4:2*m+3);
BJHa = x(2*m+4);
BJLa = x(2*m+5);
CJLa = x(2*m+6);
DT_JH = x(2*m+7);
DT_JL = x(2*m+8); % deadtimes
alpha_aero = x(2*m+9 :end);


% interpolation
% Td = interp1(Q.Zret,x_a,Q.Zmes2,'linear'); % T on data grid (digital)
% Ta = interp1(Q.Zret,x_a,Q.Zmes1,'linear');
Ti = interp1(Q.Zret,x_a,Q.Zmes,'linear');
Td= Ti(end-length(Q.JHnew)+1:end);
Ta= Ti(1:length(Q.JHnewa));

OV_Zi = interp1(Q.Zret,OV,Q.Zmes,'linear');

OV_Zid = OV_Zi(end-length(Q.JHnew)+1:end);%interp1(Q.Zret,OV,Q.Zmes2,'linear');
OV_Zia = OV_Zi(1:length(Q.JHnewa));%interp1(Q.Zret,OV,Q.Zmes1,'linear');

%%
% Constants
kb = 1.38064852*10^-23;
% area = pi * (0.3^2);
% Transmission
alpha_aero1 = interp1(Q.Zret,alpha_aero,Q.Zmes,'linear');
sigma_tot = Q.alpha_mol + alpha_aero1;
R_tr_i  = exp(-2.*cumtrapz(Q.Zmes,sigma_tot)); % Molecular transmission


R_tr_id = R_tr_i(end-length(Q.JHnew)+1:end);%interp1(Q.Zmes,R_tr_i,Q.Zmes2,'linear');
R_tr_ia = R_tr_i(1:length(Q.JHnewa));%interp1(Q.Zmes,R_tr_i,Q.Zmes1,'linear');

Pd = Q.Pressi(end-length(Q.JHnew)+1:end);%exp(Pdigid);
Pa = Q.Pressi(1:length(Q.JHnewa));%exp(Pdigia);



A_Zi_an = ( OV_Zia .*R_tr_ia .*Pa)./(kb * Q.Zmes1 .^2);
A_Zi_d = (OV_Zid .*R_tr_id .*Pd)./(kb * Q.Zmes2 .^2);

%% loading cross sections
load('DiffCrossSections.mat');
Diff_JH_i = interp1(T,Diff_JH,Ti,'linear');
Diff_JL_i = interp1(T,Diff_JL,Ti,'linear');


dJHd = Diff_JH_i(end-length(Q.JHnew)+1:end);%interp1(Q.Zmes,Diff_JH_i,Q.Zmes2,'linear');
dJLd = Diff_JL_i(end-length(Q.JHnew)+1:end);%interp1(Q.Zmes,Diff_JL_i,Q.Zmes2,'linear');

dJHa = Diff_JH_i(1:length(Q.JHnewa));%interp1(Q.Zmes,Diff_JH_i,Q.Zmes1,'linear');
dJLa = Diff_JL_i(1:length(Q.JHnewa));%interp1(Q.Zmes,Diff_JL_i,Q.Zmes1,'linear');


% toc


CJH = (Q.R).* CJL;
CJHa = (Q.Ra).* CJLa;
% 

JL = (CJL.* A_Zi_d .* dJLd)./(Td);
JH = (CJH.* A_Zi_d .* dJHd)./(Td);

JLa = (CJLa.* A_Zi_an .* dJLa )./(Ta );
JHa = (CJHa.* A_Zi_an .* dJHa )./(Ta );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% data structure
mdata = length(Q.y);
n1=length(Q.JLnew);
n2=length(Q.JLnewa);






% FM 
% yJH = X.yf(1:n1)';
% yJL = X.yf(n1+1:2*n1)';
% yJHA = X.yf(2*n1+1:end-n2)';
% yJLA = X.yf(end-n2+1:end)';

% [yJH,yJL,yJHA,yJLA] = forwardmodelTraman(Q,x);

yJH = Q.JHnew;
yJL = Q.JLnew;
yJHA = Q.JHnewa;
yJLA = Q.JLnewa;
 deltaZ = Q.Zmes1(2) - Q.Zmes1(1);
% oem retrievals
n = length(X.x);
N = length(X.yf);

% b parameter Jacobians starts from here
% Note all the JAcobians need to be multiplied by the deadtime derivative

%%
% Dead Time derivative calculation
%%
% JH = X.yf(1:N/2);
% JL = X.yf(N/2+1:end);

DTDJH = ((1-DT_JH.*yJH).^2);
DTDJL = ((1-DT_JL.*yJL).^2);
% N0_JH = yJH./(1+DT_JH.*yJH);
% N0_JL = yJL./(1+DT_JL.*yJL);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pressure Jacobian 
%  JPress =zeros(mdata,n);
% Pressure = Q.Pressi;
%  Pd = Q.Pressi(end-length(Q.JHnew)+1:end);%exp(Pdigid);
%  Pa = Q.Pressi(1:length(Q.JHnewa));%exp(Pdigia);
% P0=Q.P0;

dSJHdPD = ((JH)./Pd) .* DTDJH; %digital
dSJLdPD = ((JL)./Pd) .* DTDJL;
dSJHdPA = ((JHa)./Pa); %analog
dSJLdPA = ((JLa )./Pa);

%     figure;
%     subplot(2,2,1)
%     plot(dSJHdPD,Q.Zmes2./1000)
%     xlabel('J- Pressure - JH')
%     ylabel('Alt (km)')
%     subplot(2,2,2)
%     plot(dSJLdPD,Q.Zmes2./1000)
%     xlabel('J- Pressure - JL')
%     ylabel('Alt (km)')
%     subplot(2,2,3)
%     plot(dSJHdPA,Q.Zmes1./1000)
%     xlabel('J- Pressure - JHa')
%     ylabel('Alt (km)')
%     subplot(2,2,4)
%     plot(dSJLdPA,Q.Zmes1./1000)
%     xlabel('J- Pressure - JLa')
%     ylabel('Alt (km)')

JPress = [dSJHdPD';dSJLdPD';dSJHdPA';dSJLdPA'];
R.JPress = diag(JPress);

%%% R jacobian
% JR = zeros(mdata,n);
dSJHdR = ((JH)./Q.R ) .* DTDJH;
dSJLdR = zeros(n1+2*n2,1);
JR = [dSJHdR';dSJLdR];
R.JR = diag(JR);

dSJHdRa = ((JHa)./Q.Ra );
dSJLdRa = zeros(n2,1);
dss = zeros(2*n1,1);
JRa = [dss;dSJHdRa';dSJLdRa];
R.JRa = diag(JRa);

%     figure; 
% subplot(1,2,1)
%     plot(dSJHdR,Q.Zmes2./1000)
%     xlabel('J- R - JH')
%     ylabel('Alt (km)')
% subplot(1,2,2)
%     plot(dSJHdRa,Q.Zmes1./1000)
%     xlabel('J- R - JHa')
%     ylabel('Alt (km)')



%%% Air density (in the transmission) jacobian


% dSJHdnair = (-2.*deltaZ.* sigma.* (JH)) .* DTDJH;
% dSJLdnair = (-2.*deltaZ.* sigma.* (JL)) .* DTDJL;
% dSJHdnairA = (-2.*deltaZ.* sigma.* (JHa));
% dSJLdnairA = (-2.*deltaZ.* sigma.* (JLa));
dSJHdnair = (-2.*(Q.Nmol(end-n1+1:end).*JH)) .* DTDJH;
dSJLdnair = (-2.*(Q.Nmol(end-n1+1:end).*JL)) .* DTDJL;
dSJHdnairA = (-2.*(Q.Nmol(1:n2).*JHa));
dSJLdnairA = (-2.*(Q.Nmol(1:n2).*JLa));

Jnair = [dSJHdnair';dSJLdnair';dSJHdnairA';dSJLdnairA'];

R.Jnair  = diag(Jnair);

%     figure;
%     subplot(2,2,1)
%     plot(dSJHdnair,Q.Zmes2./1000)
%     xlabel('J- nair - JH')
%     ylabel('Alt (km)')
%     subplot(2,2,2)
%     plot(dSJHdnair,Q.Zmes2./1000)
%     xlabel('J- nair - JL')
%     ylabel('Alt (km)')
%     subplot(2,2,3)
%     plot(dSJHdnairA,Q.Zmes1./1000)
%     xlabel('J- nair - JHa')
%     ylabel('Alt (km)')
%     subplot(2,2,4)
%     plot(dSJHdnairA,Q.Zmes1./1000)
%     xlabel('J- nair - JLa')
%     ylabel('Alt (km)')


%%% aerosol scattering jacobian

% dSJHdnaero = (-2.*(JH)) .* DTDJH;
% dSJLdnaero = (-2.*(JL)) .* DTDJL;
% dSJHdnaeroA = (-2.*(JHa));
% dSJLdnaeroA = (-2.* (JLa));


% Jaero = [dSJHdnaero' ;dSJLdnaero';dSJHdnaeroA';dSJLdnaeroA'];
% R.Jaero  = diag(Jaero);

%     figure;
%     subplot(2,2,1)
%     plot(dSJHdnaero,Q.Zmes2./1000)
%     xlabel('J- aero - JH')
%     ylabel('Alt (km)')
%     subplot(2,2,2)
%     plot(dSJLdnaero,Q.Zmes2./1000)
%     xlabel('J- aero - JL')
%     ylabel('Alt (km)')
%     subplot(2,2,3)
%     plot(dSJHdnaeroA,Q.Zmes1./1000)
%     xlabel('J- aero - JHa')
%     ylabel('Alt (km)')
%     subplot(2,2,4)
%     plot(dSJLdnaeroA,Q.Zmes1./1000)
%     xlabel('J- aero - JLa')
%     ylabel('Alt (km)')

%%% deadtime jacobian

% dSJHdDT = (-(yJH).^2) ./ (1+ (Q.deadtime .* N0_JH));
% dSJLdDT = (-(yJL).^2) ./ (1+ (Q.deadtime .* N0_JL));
% JDT = [dSJHdDT ;dSJLdDT ];
% R.JDT  = diag(JDT);
%     figure;
%     subplot(1,2,1)
%     plot(dSJHdDT,Q.Zmes./1000)
%     xlabel('J- DT - JH')
%     ylabel('Alt (km)')
%     subplot(1,2,2)
%     plot(dSJLdDT,Q.Zmes./1000)
%     xlabel('J- DT - JL')
%     ylabel('Alt (km)')