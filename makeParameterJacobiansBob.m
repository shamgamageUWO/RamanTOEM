function R  = makeParameterJacobians(Q,x)
% makeParameterJacobians for Rayleigh T OEM
%   pulled this out of makeR.m to speed up code, only do b parameter jacobians
%   at end
%	current b parameters:
%       air density
%       Rayleigh scatter cross section uncertainty (magnitude)
%       ozone cross section & density
%       Rayeligh scatter cross section variation with height
%       gravity (HSEQ only)
%       Mean Molecular Mass (z) (HSEQ only)
%
% -Usage-
%	R = makeRarameterJacobians(Q,x)
%
% -Inputs-
%	Q retrieval a priori information
%	x retrieved parameters
%
% -Outputs-
%	R Jacobians for b parameters

tstring = strcmp(Q.model,'LE');
if tstring
    model = 0;
else
    model = 2;
end
m = length(Q.zRET);
[Nlo, Nhi] = forwardModelRayT(Q,x);
NloB = Nlo - x(end-1);
NhiB = Nhi - x(end);

% data structure
yf = [Nlo; Nhi];
mdata = length(yf);
m1 = length(Nlo);
m2 = length(Nhi);
n = m + 5; % 5 retrieval parameters

% pressure and temperature on data grid (required later)
TjA = interp1(Q.zRET,x(1:m),Q.zDATAa,'linear');
TjD = interp1(Q.zRET,x(1:m),Q.zDATAd,'linear');
[pHSEQa,p0A] = find_pHSEQ(Q.z_p0,Q.zDATAa,TjA,Q.pT_DATAa,0,Q.grav_DATAa,Q.MoR_DATAa);
[pHSEQd,p0D,pindeD] = find_pHSEQ(Q.z_p0,Q.zDATAd,TjD,Q.pT_DATAd,0,Q.grav_DATAd,Q.MoR_DATAd);
[pHSEQR,p0R] = find_pHSEQ(Q.z_p0,Q.zRET,x(1:m),Q.pT_RET,0,Q.grav_RET,Q.MoR_RET);

% Jacobians for T, acounding for retrieval grid interpolation
for j = 1:m %m
    [dNlodx,dNhidx] = derivCounts(Q,x,j,@forwardModelRayT);
    Kernel(1:m1,j) = dNlodx;
    Kernel(m1+1:mdata,j) = dNhidx;
end

% dead times
[dNlodx,dNhidx] = derivCounts(Q,x,n-4,@forwardModelRayT);
Kernel(m1+1:mdata,n-4) = dNhidx;

% Lidar constants, analytic for non-paralyzable, paralyzable is numerical
Kernel(1:m1,n-3) = NloB ./ x(n-3); %d1;
gNhi = x(n-4) .* Q.y2Hz .* Nhi;
mgNhi = 1 - gNhi;
dNodNt = (1 - gNhi).^2;
NhiBdt = (Nhi./(mgNhi) - x(n));

if Q.np
    Kernel(m1+1:mdata,n-2) = NhiBdt .* dNodNt ./ x(n-2); % non-paralyzable
else
    [d1,d2] = derivCounts(Q,x,n-2,@forwardModelRayT);
    Kernel(m1+1:mdata,n-2) = d2; % paralyzable, must be done numerically
end

% backgrounds - analytical
Kernel(1:m1,n-1) = ones(size(Q.zDATAa));
Kernel(m1+1:mdata,n) = ones(size(Q.zDATAd));

J = Kernel;

% Initialize for b jacobians (on data grid)
KernelO3 = zeros(mdata,mdata);
KernelRay = zeros(mdata,mdata);
KernelSigAlt = zeros(mdata,mdata);
KernelMoR = zeros(mdata,mdata);
Kernelgrav = zeros(mdata,mdata);
KernelSigO3 = zeros(mdata,mdata);
KernelSigRay = zeros(mdata,mdata);

% for O3 Jacobian
load O3data2.mat
O3denA = interp1(zO3den,O3den,Q.zDATAa,'linear');
O3denD = interp1(zO3den,O3den,Q.zDATAd,'linear');
dO3dzA = gradient(O3denA,Q.zDATAa);
dO3dzD = gradient(O3denD,Q.zDATAd);

% for Ray extinct Jacobian
[ZUS, Z_LUS, Z_UUS, Tus, Pus, rhoUS, cUS, gUS, muUS, nuUS, kUS, nUS, n_sumUS] = atmo(150,0.1,1);
boltz = 1.3806488e-23;  % m^2*kg*s^-2 K^-1
ndenUSA = Pus ./ (boltz.*Tus);
ndenA = interp1(ZUS*1000,ndenUSA,Q.zDATAa,'linear');
ndenD = interp1(ZUS*1000,ndenUSA,Q.zDATAd,'linear');
dndzA = gradient(ndenA,Q.zDATAa);
dndzD = gradient(ndenD,Q.zDATAd);

dsigdz = gradient(Q.sigAlt,Q.zDATAd);
dgdzA = gradient(Q.grav_DATAa,Q.zDATAa);
dgdzD = gradient(Q.grav_DATAd,Q.zDATAd);

'high jacobians for paralyzable now approximate, check if we can use non paral case for them'

dn = 1.e-6; % used for gravity, MoR
for i = 1:mdata
    if i < m1+1
% Ozone Absorption
        KernelO3(1:m1,i) = 2.*(NloB./exp(-2.*Q.tauO3_DATAa)).*(Q.sigO3.*O3denA(i))...
            .* exp(-2.*Q.tauO3_DATAa(i)) ./ dO3dzA(i);
        
        KernelSigO3(1:m1,i) = -2.*(NloB./exp(-2.*Q.tauO3_DATAa))...
            .*(exp(-2.*Q.tauO3_DATAa(i)).*Q.tauO3_DATAa(i)./Q.sigO3);
        
% Rayleigh Extinction
        KernelRay(1:m1,i) = 2.*(NloB./exp(-2.*Q.RayExA)).*(Q.sigmaNicolet.*ndenA(i))...
            .* exp(-2.*Q.RayExA(i)) ./ dndzA(i);
        
        KernelSigRay(1:m1,i) = -2.*(NloB./exp(-2.*Q.RayExA))...
            .*(exp(-2.*Q.RayExA(i)).*Q.RayExA(i)./Q.sigmaNicolet);
    else
        ii = i - m1;
% Ozone absorption - high
        true = 2.*(NhiBdt./exp(-2.*Q.tauO3_DATAd)).*(Q.sigO3.*O3denD(ii))...
            .* exp(-2*Q.tauO3_DATAd(ii)) ./ dO3dzD(ii);
        KernelO3(m1+1:mdata,i) = true .* dNodNt;
        
        true = -2.*(NhiBdt./exp(-2.*Q.tauO3_DATAd))...
            .*(exp(-2.*Q.tauO3_DATAd(ii)).*Q.tauO3_DATAd(ii)./Q.sigO3);
        KernelSigO3(m1+1:mdata,i) = true .* dNodNt;
% Rayleigh Extinction - high
        true = 2.*(NhiBdt./exp(-2.*Q.RayExD)).*(Q.sigmaNicolet.*ndenD(ii))...
            .* exp(-2.*Q.RayExD(ii)) ./ dndzD(ii);
        KernelRay(m1+1:mdata,i) = true .* dNodNt;
        
        true = -2.*(NhiBdt./exp(-2.*Q.RayExD))...
            .*(exp(-2.*Q.RayExD(ii)).*Q.RayExD(ii)./Q.sigmaNicolet);
        KernelSigRay(m1+1:mdata,i) = true .* dNodNt;
        
% Rayeleigh cross section due to composition change with height  
% note SigAlt error does NOT propagate through the elastic optical depth
%        if Q.np
            KernelSigAlt(m1+1:mdata,i) = (NhiBdt ./ Q.sigAlt(ii)) .* dsigdz(ii)...
                .* dNodNt;  % non-paralyzable
%        else
%            [d1,d2] = derivCounts(Q,x,n-2,@forwardModelRayT);
%            KernelSigAlt(m1+1:mdata,i) = d2; % paralyzable, must be done numerically
%        end
    end
% gravity/MoR: HSEQ only, not analytical because evaulation of definite integral
%               is not from 0 to z
    if model == 2
        if i < m1+1
            QQ = Q;
            dng = Q.grav_DATAa(i) .* dn;
            QQ.grav_DATAa(i) = QQ.grav_DATAa(i) + dng;
            [dNlodx,dNhidx] = bParmJacob(Q,QQ,x,dng,@forwardModelRayT);
            Kernelgrav(1:m1,i) = dNlodx;
        else
            ii = i - m1;
            QQ = Q;
            dng = Q.grav_DATAd(ii) .* dn;
            QQ.grav_DATAd(ii) = QQ.grav_DATAd(ii) + dng;
            [dNlodx,dNhidx] = bParmJacob(Q,QQ,x,dng,@forwardModelRayT);
            Kernelgrav(m1+1:mdata,i) = dNhidx;
            
            QQ = Q;
            dnMoR = Q.MoR_DATAd(ii) .* dn;
            QQ.MoR_DATAd(ii) = QQ.MoR_DATAd(ii) + dnMoR;
            [dNlodx,dNhidx] = bParmJacob(Q,QQ,x,dnMoR,@forwardModelRayT);
            KernelMoR(m1+1:mdata,i) = dNhidx;
        end
    end
end

% seed pressure is a constant so this is a vector
Kernelp = zeros(size(Q.zDATA));
mp0 = (p0A+p0D) ./ 2; %; p0 for both channels not identical, about 2% different
Kernelp(1:m1) = NloB ./ mp0;
if Q.np
    upstairs = Nhi./(mgNhi) - x(n); % non-paralyzable
    dstairs = mp0 .* (1 + (gNhi./mgNhi)).^2;
    Kernelp(m1+1:mdata) = upstairs./dstairs;   
else
    QQ = Q; % paralyzable, must be done numerically
    dnp = mp0 .* dn;
    QQ.pT_DATAd(pindeD) = QQ.pT_DATAd(pindeD) + dnp;
    [dNlodx,dNhidx] = bParmJacob(Q,QQ,x,dnp,@forwardModelRayT);
    Kernelp(m1+1:mdata) = dNhidx;
end

% Return structure
R.kernelp = Kernelp;
R.kernelO3 = KernelO3;
R.kernelRay = KernelRay;
R.kernelsigO3 = KernelSigO3;
R.kernelsigRay = KernelSigRay;
R.kernelSigAlt = KernelSigAlt;
R.kernelMoR = KernelMoR;
R.kernelgrav = Kernelgrav;
R.pHSEQ_DATAa = pHSEQa;
R.pHSEQ_DATAd = pHSEQd;
R.pHSEQ_RET = pHSEQR;
R.p0A = p0A;
R.p0D = p0D;

% 'redo all high Jacobians'
% stopppp

return