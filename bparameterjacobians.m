function R =bparameterjacobians (Q,X)
%%[X,R,Q,O,S_a,Se,xa]=TRamanOEM( date_in,time_in,flag)
m = length(Q.Zret);
x = X.x;
x_a = x(1:m);
BJH = x(m+1);
BJL = x(m+2);
CJL = x(m+3);
OV = x(m+4:end-5);
BJHa = x(end-4);
BJLa = x(end-3);
CJLa = x(end-2);
DT_JH = x(end-1);
DT_JL = x(end); % deadtimes


% data structure
mdata = length(Q.y);
n1=length(Q.JLnew);
n2=length(Q.JLnewa);
% FM 
yJH = X.yf(1:n1)';
yJL = X.yf(n1+1:2*n1)';
yJHA = X.yf(2*n1+1:end-n2)';
yJLA = X.yf(end-n2+1:end)';

% [yJH,yJL,yJHA,yJLA] = forwardmodelTraman(Q,x);

% yJH = Q.JHnew;
% yJL = Q.JLnew;
% yJHA = Q.JHnewa;
% yJLA = Q.JLnewa;
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
% JPress =zeros(mdata,n);
% Pressure = Q.Pressi;
% Pd = Q.Pressi(end-length(Q.JHnew)+1:end);%exp(Pdigid);
% Pa = Q.Pressi(1:length(Q.JHnewa));%exp(Pdigia);
% 
% dSJHdPD = ((yJH - BJH)./Pd) .* DTDJH; %digital
% dSJLdPD = ((yJL - BJL)./Pd) .* DTDJL;
% dSJHdPA = ((yJHA - BJHa)./Pa); %analog
% dSJLdPA = ((yJLA - BJLa)./Pa);

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

% JPress = [dSJHdPD';dSJLdPD';dSJHdPA';dSJLdPA'];
% R.JPress = diag(JPress);

%%% R jacobian
% JR = zeros(mdata,n);
dSJHdR = ((yJH - BJH)./Q.R ) .* DTDJH;
dSJLdR = zeros(n1+2*n2,1);
JR = [dSJHdR';dSJLdR];
R.JR = diag(JR);

dSJHdRa = ((yJHA - BJHa)./Q.Ra );
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
Lambda = 354.7* (10^-3); 
A = 4.02*10^(-28);
B = -0.3228;
C = 0.389;
D = 0.09426;
exponent = 4+B+C*Lambda+D/Lambda;
sigma_Rcm2 = A / Lambda^(exponent);
sigma = sigma_Rcm2*1e-4;%m2

dSJHdnair = (-2.*deltaZ.* sigma.* (yJH - BJH)) .* DTDJH;
dSJLdnair = (-2.*deltaZ.* sigma.* (yJL - BJL)) .* DTDJL;
dSJHdnairA = (-2.*deltaZ.* sigma.* (yJHA - BJHa));
dSJLdnairA = (-2.*deltaZ.* sigma.* (yJLA - BJLa));

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

dSJHdnaero = (-2.*deltaZ .* (yJH - BJH)) .* DTDJH;
dSJLdnaero = (-2.*deltaZ .* (yJL - BJL)) .* DTDJL;
dSJHdnaeroA = (-2.*deltaZ .* (yJHA - BJHa));
dSJLdnaeroA = (-2.*deltaZ .* (yJLA - BJLa));


Jaero = [dSJHdnaero' ;dSJLdnaero';dSJHdnaeroA';dSJLdnaeroA'];
R.Jaero  = diag(Jaero);

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