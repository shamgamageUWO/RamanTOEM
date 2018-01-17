% this is first get S3 file with asr content
function [alphaAer] = asrSham(Q)
% first load S3.mat 
 date = Q.date_in;
[year,month,day] = getYMDFromDate(date);
 yr = num2str(year);

 % open S0 matfile according to the given date
datadirS3='/Users/sham/Documents/MATLAB/RALMO_Data/RALMO';%/2011.09.28
% datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
file = 'S3';
 Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day)];
% 
 folderpath = [datadirS3 filesep  Dateofthefolder filesep  file];
% % open S0 matfile according to the given date
% datadirS3='/Users/sham/Desktop';
% % datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
% file = 'S3';
% folderpath = [datadirS3 filesep  file];
load(folderpath);

% now run the config file
config = setup('ralmo.conf');
config.t0 = datenum (['date'], 'yyyymmdd');
config = getCalibration(config);

% Now run the aerosol code
asr =AerosolScatteringRatio03(S3,config );
figure;
subplot(1,2,1)
plot(asr.profile,(asr.z)./1000);
xlabel('asr profile')
ylabel('Alt(km)')
%% 
% Load beta molecular values here 
% Max's Codes ( all are now in the same directory as QpackSham)
zN = Q.Zmes;
% P = Q.Psonde;
% T = Q.Tsonde;
P = Q.Pdigi;
T = Q.Ti;
lambda_rec= 354.7; % nm
lambda_em = 354.7;

[alpha_mol,beta_mol,lidar_signal,beta_att,density]=get_rayleigh_v3(zN,P,T,lambda_rec,lambda_em);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% These from BOB- WVOEM.m
in.LRfree = 50; % was 20 on 0305, 0308 50, 200905-6 50
in.LRpbl = 80; % 50 on 0305; was 80 on otherwise
in.LRtranHeight = 1000; % this is the height to the BL
% 3 is nominal, not accurate 2.75; 


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


LR = in.LRfree * ones(size(asrDATA));
fff = find(zN < in.LRtranHeight);
LR(fff) = in.LRpbl;
asrDATAs = smooth(asrDATA,10); %asrDATA; %smooth(asrDATA,90); %was 45


[fneg,I] = min(asrDATAs);
 diff = 1-fneg;
 fneg2 = find(asrDATAs < 1);
 fneg3 = find(asrDATAs >= 1);
 asrDATAs(fneg2) = 1;
asrDATAs(fneg3)  = asrDATAs(fneg3) + diff;
asrDATAnew =  asrDATAs;
% 
% fneg = find(asrDATAs < 1);
% asrDATAs(fneg) = 1;




subplot(1,2,2)
plot(asrDATAnew(zN<=12000),(zN(zN<=12000))./1000);
xlabel('asr profile after fixing the diff')
ylabel('Alt(km)')

alphaAer = LR' .* (beta_mol .* (asrDATAnew-1));
znoAer = find(zN > 8000); % was 3000 for 20130122
alphaAer(znoAer) = 1e-12;
'asr set to 0 > 8000'
    fl0 = find(alphaAer <= 0);
    alphaAer(fl0) = 1e-12;


