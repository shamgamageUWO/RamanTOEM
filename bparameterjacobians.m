function R =bparameterjacobians (Q,X)
%%[X,R,Q,O,S_a,Se,xa]=TRamanOEM( date_in,time_in,flag)
m = length(Q.Zret);
x = X.x;
x_a = x(1:m);
BJH = x(m+1);
BJL = x(m+2);
CJL = x(m+3);
OV = x(m+4:end-2);
DT_JH = x(end-1);
DT_JL = x(end); % deadtimes

% b parameter Jacobians starts from here
% Note all the JAcobians need to be multiplied by the deadtime derivative

%%
% Dead Time derivative calculation
%%
% JH = X.yf(1:N/2);
% JL = X.yf(N/2+1:end);
% data structure
mdata = length(Q.y);
% FM 
[yJH,yJL] = forwardmodelTraman(Q,x);

% yJH = Q.JHnew;
% yJL = Q.JLnew;
% yJHA = Q.JHnewa;
% yJLA = Q.JLnewa;
 deltaZ = Q.Zmes(2) - Q.Zmes(1);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Pressure Jacobian 
% JPress =zeros(mdata,n);
dSJHdP = ((yJH - BJH )./Q.Pressi) .* DTDJH;
dSJLdP = ((yJL - BJL )./Q.Pressi) .* DTDJL;

    figure;
    subplot(1,3,1)
    semilogx(dSJHdP,Q.Zmes./1000)
    xlabel('J- Pressure - JH')
    ylabel('Alt (km)')
    subplot(1,3,2)
   semilogx(dSJLdP,Q.Zmes./1000)
    xlabel('J- Pressure - JL')
    ylabel('Alt (km)')

JPress = [dSJHdP dSJLdP];
R.JPress = diag(JPress);

%%% R jacobian
% JR = zeros(mdata,n);
dSJHdR = ((yJH -BJH)./Q.R ) .* DTDJH;
dSJLdR = zeros(mdata/2,1);
JR = [dSJHdR dSJLdR'];
R.JR = diag(JR);

    subplot(1,3,3)
    semilogx(dSJHdR,Q.Zmes./1000)
    xlabel('J- R - JH')
    ylabel('Alt (km)')


%%% Air density (in the transmission) jacobian
Lambda = 354.7* (10^-3); 
A = 4.02*10^(-28);
B = -0.3228;
C = 0.389;
D = 0.09426;
exponent = 4+B+C*Lambda+D/Lambda;
sigma_Rcm2 = A / Lambda^(exponent);
sigma = sigma_Rcm2*1e-4;%m2

dSJHdnair = (-2.*deltaZ.* sigma.* (yJH - BJH )) .* DTDJH;
dSJLdnair = (-2.*deltaZ.* sigma.* (yJL - BJL )) .* DTDJL;
Jnair = [dSJHdnair dSJLdnair];
R.Jnair  = diag(Jnair);

    figure;
    subplot(2,2,1)
   semilogx(dSJHdnair,Q.Zmes./1000)
    xlabel('J- nair - JH')
    ylabel('Alt (km)')
    subplot(2,2,2)
    semilogx(dSJHdnair,Q.Zmes./1000)
    xlabel('J- nair - JL')
    ylabel('Alt (km)')


%%% aerosol scattering jacobian

dSJHdnaero = (-2.*deltaZ .* (yJH - BJH )) .* DTDJH;
dSJLdnaero = (-2.*deltaZ .* (yJL - BJL )) .* DTDJL;
Jaero = [dSJHdnaero dSJLdnaero ];
R.Jaero  = diag(Jaero);

%     figure;
    subplot(2,2,3)
   semilogx(dSJHdnaero,Q.Zmes./1000)
    xlabel('J- aero - JH')
    ylabel('Alt (km)')
    subplot(2,2,4)
    semilogx(dSJLdnaero,Q.Zmes./1000)
    xlabel('J- aero - JL')
    ylabel('Alt (km)')


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