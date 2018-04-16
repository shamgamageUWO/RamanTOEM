% this is first get S3 file with asr content
function [alphaAer,odaer] = asrSham(Q)
% first load S3.mat 
 date = Q.date_in;
[year,month,day] = getYMDFromDate(date);
 yr = num2str(year);

 % open S0 matfile according to the given date
datadirS3='/Users/sham/Documents/MATLAB/RALMO_Data/RALMO';%/2011.09.28
% datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
file = 'S3';
%  Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day)];
 Dateofthefolder = Q.Dateofthefolder;
 folderpath = [datadirS3 filesep  Dateofthefolder filesep  file];
% % open S0 matfile according to the given date
% datadirS3='/Users/sham/Desktop';
% % datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
% file = 'S3';
% folderpath = [datadirS3 filesep  file];
load(folderpath);
tin =Q.time_in;
% now run the config file
config = setup('ralmo.conf');
config.t0 = datenum ([num2str(date)], 'yyyymmdd');
config = getCalibration(config);

% Now run the aerosol code
asr =AerosolScatteringRatio03(S3,config,tin );
figure;
% subplot(1,2,1)
plot(asr.profile,(asr.z)./1000); hold on


% % % % [fneg,I] = min(asr.profile);
% % % %  diff = 1-fneg;
% % % %  if diff<0
% % % %   'diffrence is less than 0'
% % % %     
% % % %     stop
% % % %  end 
% % % %  asr.profile = asr.profile + diff;
% % % %  fneg2 = find(asr.profile < 1);
% % % % %  fneg3 = find(asrDATAs >= 1);
% % % % %  asrDATAs(fneg3)  = asrDATAs(fneg3) + diff;
% % % %  asr.profile(fneg2) = 1;




% xlabel('asr profile')
% ylabel('Alt(km)')
%% 
% Load beta molecular values here 
% Max's Codes ( all are now in the same directory as QpackSham)
zN = Q.Zmes;
P = Q.Psonde;
T = Q.Tsonde;
lambda_rec= 354.7; % nm
lambda_em = 354.7;

[alpha_mol,beta_mol,lidar_signal,beta_att,density]=get_rayleigh_v3(zN,P,T,lambda_rec,lambda_em);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% These from BOB- WVOEM.m
% Q.LRfree = 50; % was 20 on 20120228/20110901, 0308 50, 200905-6 50
% Q.LRpbl = 80; % 50 on 20110901; was 80 on otherwise
% Q.LRtranHeight =900; %  800 for 20120228 2000 for 20110901 this is the height to the BL
% % 3 is nominal, not accurate 2.75; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% These lines are from BOB - WV - makeQ.m

asrDATA = interp1(asr.z,asr.profile,zN,'linear');
% plot(asrDATA,zN./1000,'black');

flow = find(zN < asr.z(1));
if ~isempty(flow)
 asrDATA(flow) = asrDATA(flow(end)+1);
end
fhi = find(zN > asr.z(end));
if ~isempty(fhi)
  asrDATA(fhi) = 1;
end



LR = Q.LRfree * ones(size(asrDATA));
fff = find(zN < Q.LRtranHeight);
LR(fff) = Q.LRpbl;
asrDATAs = smooth(asrDATA,50); %asrDATA; %smooth(asrDATA,90); %was 45

fneg1 = find(asrDATAs < 1);
asrDATAs(fneg1) = 1;

% 
 [fneg,I] = min(asrDATAs(zN<4000));
 if fneg<0
  'diffrence is less than 0'
     stop
 end 
%  
  diff = fneg-1;
   asrDATAs = asrDATAs - diff;

%  fneg2 = find(asrDATAs < 1);
%  asrDATAs(fneg2) = 1;
%   fneg3 = find(asrDATAs >= 1);
%  asrDATAs(fneg3)  = asrDATAs(fneg3) + diff;
 asrDATAs(zN>=Q.ASRcutoffheight) = 1;
%  asrDATAs(zN>= 3000 & zN<=8000) = 1;
asrDATAnew =  asrDATAs;
% 
% fneg = find(asrDATAs < 1);
% asrDATAs(fneg) = 1;


plot(asrDATAnew,zN./1000,'r'); 
xlabel('ASR profile')
ylabel('Altitude (km)')
title( Q.Dateofthefolder);
  set(gca,'fontsize',20)

hold off;

% subplot(1,2,2)
% plot(asrDATAnew(zN<=12000),(zN(zN<=12000))./1000);
% xlabel('asr profile after fixing the diff')
% ylabel('Alt(km)')

alphaAer = LR' .* (beta_mol .* (asrDATAnew-1));
znoAer = find(zN > Q.AerosolFreeheight); % was 3000 for 20130122
alphaAer(znoAer) = 1e-12;
% 'asr set to 0 > Q.AerosolFreeheight'
    fl0 = find(alphaAer <= 0);
    alphaAer(fl0) = 1e-12;
    
    
     alphaCorErr = 0;
     z0 = 0:.1:zN(1);
     alpha0=alphaAer(1).*ones(size(z0));
     odnorm = trapz(z0,alpha0);
    odaer = cumtrapz(zN,alphaAer) +odnorm;


