function R =bparameterjacobians (Q,X)
%%[X,R,Q,O,S_a,Se,xa]=TRamanOEM( date_in,time_in,flag)

% data structure
mdata = length(Q.y);
yJH = Q.JHnew;
yJL = Q.JLnew;
deltaZ = Q.JHnew(2) - Q.JHnew(1);
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

DTDJH = ((1-Q.deadtime.*yJH).^2);
DTDJL = ((1-Q.deadtime.*yJL).^2);
N0_JH = yJH./(1+Q.deadtime.*yJH);
N0_JL = yJL./(1+Q.deadtime.*yJL);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pressure Jacobian 
% JPress =zeros(mdata,n);
dSJHdP = ((yJH - X.x(end-Q.OVlength-2))./Q.Pressi') .* DTDJH;
dSJLdP = ((yJL - X.x(end-Q.OVlength-1))./Q.Pressi') .* DTDJL;

%     figure;
%     subplot(1,2,1)
%     plot(dSJHdP,Q.Zmes./1000)
%     xlabel('J- Pressure - JH')
%     ylabel('Alt (km)')
%     subplot(1,2,2)
%     plot(dSJLdP,Q.Zmes./1000)
%     xlabel('J- Pressure - JL')
%     ylabel('Alt (km)')

JPress = [dSJHdP;dSJLdP];
R.JPress = diag(JPress);

%%% R jacobian
% JR = zeros(mdata,n);
dSJHdR = ((yJH - X.x(end-Q.OVlength-2))./Q.R ) .* DTDJH;
dSJLdR = zeros(mdata/2,1);
JR = [dSJHdR;dSJLdR];
R.JR = diag(JR);

%     figure; 
%     plot(dSJHdR,Q.Zmes./1000)
%     xlabel('J- R - JH')
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

dSJHdnair = (-2.*deltaZ.* sigma.* (yJH - X.x(end-Q.OVlength-2))) .* DTDJH;
dSJLdnair = (-2.*deltaZ.* sigma.* (yJL - X.x(end-Q.OVlength-1))) .* DTDJL;
Jnair = [dSJHdnair;dSJLdnair];
R.Jnair  = diag(Jnair);

%     figure;
%     subplot(1,2,1)
%     plot(dSJHdnair,Q.Zmes./1000)
%     xlabel('J- nair - JH')
%     ylabel('Alt (km)')
%     subplot(1,2,2)
%     plot(dSJHdnair,Q.Zmes./1000)
%     xlabel('J- nair - JL')
%     ylabel('Alt (km)')


%%% aerosol scattering jacobian

dSJHdnaero = (-2.*deltaZ .* (yJH - X.x(end-Q.OVlength-2))) .* DTDJH;
dSJLdnaero = (-2.*deltaZ .* (yJL - X.x(end-Q.OVlength-1))) .* DTDJL;
Jaero = [dSJHdnaero ;dSJLdnaero ];
R.Jaero  = diag(Jaero);

%     figure;
%     subplot(1,2,1)
%     plot(dSJHdnaero,Q.Zmes./1000)
%     xlabel('J- aero - JH')
%     ylabel('Alt (km)')
%     subplot(1,2,2)
%     plot(dSJLdnaero,Q.Zmes./1000)
%     xlabel('J- aero - JL')
%     ylabel('Alt (km)')


%%% deadtime jacobian

dSJHdDT = (-(yJH).^2) ./ (1+ (Q.deadtime .* N0_JH));
dSJLdDT = (-(yJL).^2) ./ (1+ (Q.deadtime .* N0_JL));
JDT = [dSJHdDT ;dSJLdDT ];
R.JDT  = diag(JDT);
%     figure;
%     subplot(1,2,1)
%     plot(dSJHdDT,Q.Zmes./1000)
%     xlabel('J- DT - JH')
%     ylabel('Alt (km)')
%     subplot(1,2,2)
%     plot(dSJLdDT,Q.Zmes./1000)
%     xlabel('J- DT - JL')
%     ylabel('Alt (km)')