% this is first get S3 file with asr content
function [Tr1,Tr2] = TransmissionFastCom(Q)
date = Q.date_in;
[year,month,day] = getYMDFromDate(date);
 yr = num2str(year);
 datadirS3 = '/Users/sham/Documents/MATLAB/RALMO_Data/RALMO';
% 
 cleanmacpollution(datadirS3); % this is to remove DS_store.dat files from the data folder
% 
 Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day)];
% 
filename = 'S3.mat';
folderpath = [datadirS3 filesep  Dateofthefolder filesep filename];
load(folderpath);

% now run the config file
config = setup('adt.conf');
 config.t0 = datenum (['20170921'], 'yyyymmdd'); % needto change daily
config = getCalibration(config);


asr =BackScatteringRatio03_local(S3,config );



%% 
% Load beta molecular values here 
% Max's Codes ( all are now in the same directory as QpackSham)
zN = Q.Zmes;
P = Q.Pdigi;%Q.Pressi;
T = Q.Ti;
lambda_rec= 354.7; % nm
lambda_em = 354.7;

[alpha_mol,beta_mol,lidar_signal,beta_att,density]=get_rayleigh_v3(zN,P,T,lambda_rec,lambda_em);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% These from BOB- WVOEM.m
LRfree = 50; % was 20 on 0305, 0308 50, 200905-6 50
LRpbl = 80; % 50 on 0305; was 80 on otherwise
LRtranHeight = 2300; % this is the height to the BL

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% These lines are from BOB - WV - makeQ.m

asrDATA = interp1(asr.z,asr.profile,zN,'linear');
figure;
subplot(1,2,1)
plot(asrDATA(zN<12000),zN(zN<12000)./1000)

flow = find(zN < asr.z(1));
if ~isempty(flow)
 asrDATA(flow) = asrDATA(flow(end)+1);
end
fhi = find(zN > asr.z(end));
if ~isempty(fhi)
  asrDATA(fhi) = 1;
end


LR = LRfree * ones(size(asrDATA));
fff = find(zN < LRtranHeight);
LR(fff) = LRpbl;
asrDATAs = smooth(asrDATA,20); %asrDATA; %smooth(asrDATA,90); %was 45



[fneg,I] = min(asrDATAs);
 diff = 1-fneg;
 fneg2 = find(asrDATAs < 1);
 fneg3 = find(asrDATAs >= 1);
 asrDATAs(fneg2) = 1;
asrDATAs(fneg3)  = asrDATAs(fneg3) + diff;
asrDATAnew =  asrDATAs;
d = find(zN > 6000); % was 3000 for 20130122
asrDATAnew(d) = 1;


subplot(1,2,2)
plot(asrDATAnew(zN<12000),zN(zN<12000)./1000)

alphaAer = LR' .* (beta_mol .* (asrDATAnew -1));
znoAer = find(zN > 8000); % was 3000 for 20130122
alphaAer(znoAer) = 1e-12;
'asr set to 0 > 8000'
    fl0 = find(alphaAer <= 0);
    alphaAer(fl0) = 1e-12;
    
    
 %% Bob WVOEM, makeQ 324
     alphaCorErr = 0;
     z0 = 0:.1:zN(1);
     alpha0=alphaAer(1).*ones(size(z0));
     odnorm = trapz(z0,alpha0);
    odaer = cumtrapz(zN,alphaAer) +odnorm;
    
    

Lambda = 354.7* (10^-3);

NA = 6.02214129 *(10^23) ;% Avergadro Number mol?1
M = 28.9645 * (10^-3); % molar mass - Mair	28.9645 g.mol-1 Molecular mass of dry air kg/mol
A = 4.02*10^(-28);
B = -0.3228;
C = 0.389;
D = 0.09426;
N0 = 2.504e25;%(m^-3)
ScaleHeight= 8.771e3;


% Molecular Transmission 

exponent = 4+B+C*Lambda+D/Lambda;
sigma_Rcm2 = A / Lambda^(exponent);
sigmaNicolet = sigma_Rcm2*1e-4;%m2
Nmol = (NA/M).* Q.rho ; % mol m-3

% alpha_aero = Q.alpha_aero';% m^-1 this is aerosol coefficient given in Povey etal
%  alpha_aero(isnan(alpha_aero))=0;
sigma_tot = Nmol*sigmaNicolet+ alphaAer';
Tr1 = exp(-2.*cumtrapz(Q.Zmes,sigma_tot)); % Molecular transmission
%  Q.alphaAer=alphaAer; 
 
 
 
 
 
 %%
% Molecular transmission
tauMol = exp(-2.*cumtrapz(Q.Zmes,Nmol*sigmaNicolet));
tauAer = exp(-2.*odaer);
Tr2 = tauMol.*tauAer';
% figure;plot(Q.Zmes./1000,Tr1,'r',Q.Zmes./1000,Tr,'b')


%% Method 2
% intnBaro = ScaleHeight .* N0 .* (1 - exp(-(zN(1)./ScaleHeight))); 
% tauMolBobn0 = exp(-2.*sigmaNicolet.*intnBaro);
% tauMolBob = tauMolBobn0 .* exp(-2.*cumtrapz(sigmaNicolet.*Nmol));
% Tr3 = tauMolBob.*tauAer';
