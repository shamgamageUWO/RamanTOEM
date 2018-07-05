% this is first get S3 file with asr content
function [alphaAer,odaer,cutoffOV] = angstram(Q)
% first load S3.mat 
 date = Q.date_in;
[year,month,day] = getYMDFromDate(date);
 yr = num2str(year);

datadirS3 = '/Volumes/Sham_RALMO/RALMO_DATA/RALMO_Data/RALMO';
file = 'S3';
 Dateofthefolder = Q.Dateofthefolder;
 folderpath = [datadirS3 filesep  Dateofthefolder filesep  file];
load(folderpath);
tin =Q.time_in;
% now run the config file
config = setup('ralmo.conf');
config.t0 = datenum ([num2str(date)], 'yyyymmdd');
config = getCalibration(config);
% Now run the aerosol code
asr =AerosolScatteringRatio03(Q,S3,config,tin );
figure;
plot(asr.profile,(asr.z)./1000); hold on
% Load beta molecular values here 
% Max's Codes ( all are now in the same directory as QpackSham)
zN = Q.Zret;
P = Q.Psonde2;
T = Q.Tsonde2;
lambda_rec= 354.7; % nm
lambda_em = 354.7;
lambda_emwv = 407.6;
lambda_emn2 = 386.7;


[alpha_mol,beta_mol,lidar_signal,beta_att,density]=get_rayleigh_v3(zN,P,T,lambda_rec,lambda_em);
[alpha_molwv,beta_molwv,lidar_signalwv,beta_attwv,densitywv]=get_rayleigh_v3(zN,P,T,lambda_emwv,lambda_em);
[alpha_moln2,beta_moln2,lidar_signaln2,beta_attn2,densityn2]=get_rayleigh_v3(zN,P,T,lambda_emn2,lambda_em);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% These lines are from BOB - WV - makeQ.m
asrDATA = interp1(asr.z,asr.profile,zN,'linear');
flow = find(zN < asr.z(1));
if ~isempty(flow)
    asrDATA(flow) = asrDATA(flow(end)+1);
end
fhi = find(zN > asr.z(end));
if ~isempty(fhi)
    asrDATA(fhi) = 1;
end
asrDATAs = asrDATA';

[fneg,I] = min(asrDATAs(zN<6000));
if fneg<0
    'diffrence is less than 0 shift towards 1'
    diff = 1-fneg;
    asrDATAs = asrDATAs + diff;
    
else
    'diffrence is greater than 0 shift away from 1'
    diff = fneg-1;
    asrDATAs = asrDATAs - diff;
end

asrDATAs(zN>=Q.ASRcutoffheight) = 1;
fneg1 = find(asrDATAs < 1);
asrDATAs(fneg1) = 1;
asrDATAnew =  asrDATAs;
plot(asrDATAnew,zN./1000,'r');
xlabel('ASR profile')
ylabel('Altitude (km)')
title( Q.Dateofthefolder);
set(gca,'fontsize',20)

hold off;

LR = 20.*ones(size(asrDATAs));
s2 = find(zN <2000);
LR(s2) = 80;
s1 = find(asrDATAnew > 2); % find indices asr greater than 2

%%
if isempty(s1)
    s3 = find(zN >=2000);
    LR(s3) = 50;
    cutoffOV = 5000;
else
    
    if  zN(s1(1))>5000
        LR(s1(1):end) = 25;
    elseif zN(s1(1))<5000
        LR(s1(1):end) = 20;
    else
        LR(s1(1):end)= 50;
    end
    
    if zN(s1(1))<5000
        cutoffOV = zN(s1(1));
    else
        cutoffOV = 5000;
    end
end


%%

alphaAer = LR .* (beta_mol .* (asrDATAnew-1));
znoAer = find(zN > Q.AerosolFreeheight); % was 3000 for 20130122
alphaAer(znoAer) = 1e-12;
fl0 = find(alphaAer <= 0);
alphaAer(fl0) = 1e-12;


alphaAerwv = LR .* (beta_molwv .* (asrDATAnew-1));
znoAerwv = find(zN > Q.AerosolFreeheight); % was 3000 for 20130122
alphaAerwv(znoAerwv) = 1e-12;
fl0wv = find(alphaAerwv <= 0);
alphaAerwv(fl0wv) = 1e-12;

alphaAern2 = LR .* (beta_moln2 .* (asrDATAnew-1));
znoAern2 = find(zN > Q.AerosolFreeheight); % was 3000 for 20130122
alphaAern2(znoAern2) = 1e-12;
fl0n2 = find(alphaAern2 <= 0);
alphaAern2(fl0n2) = 1e-12;


angswv = (log(beta_mol./beta_molwv)) ./ (log(lambda_emwv./lambda_em));
angsn2 = (log(beta_mol./beta_moln2)) ./ (log(lambda_emn2./lambda_em));

figure;plot(angswv,angsn2)

alphaCorErr = 0;
z0 = 0:.1:zN(1);
alpha0=alphaAer(1).*ones(size(z0));
odnorm = trapz(z0,alpha0);
odaer = cumtrapz(zN,alphaAer) +odnorm;


