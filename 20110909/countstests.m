 clear all; close all;

% open S0 matfile according to the given date
datadirS3='/Users/sham/Desktop';
file = 'S0';
folderpath = [datadirS3 filesep  file];
load(folderpath);

% % Display the start and end times of the lidar measurment
% % disp('Start time')
% g = hour(S0.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
% Minute = minute(S0.GlobalParameters.Start);%(S0.GlobalParameters.Start.FastCom  );
% start =  [g(1) Minute(1)];
% endtime =  [g(end) Minute(end)];
% 

% pick the measurements from 11-11.30
JL=[];
JH=[];
alt = S0.Channel(4).Range;


% MHZ to Counts conversion constant 
F = 1800.* (S0.Channel(12).BinSize./150);
% Counts to Hz (This is what we need to when applying the DT 1/F gives MHz )
f = 1e-6./F;
deadtime = 4e-9;


JL = S0.Channel(12).Signal(:,961:990);
JH = S0.Channel(4).Signal(:,961:990);

if size(JL,2)==30 && size(JH,2) == 30
    disp('30mints profile')
else
    pause;
    disp('not 30mints')
end
% Convert to counts
JL_scan = F.*JL; % single scans
JH_scan = F.*JH;


% coadding
JL_coadd = nansum(JL_scan');
JH_coadd = nansum(JH_scan');

% averaging
JL_mean = nanmean(JL_scan');
JH_mean = nanmean(JH_scan');

% apply deadtime correction

JL_Tr = JL_scan./(1-deadtime.*JL_scan.*f); % for single scans
JH_Tr = JH_scan./(1-deadtime.*JH_scan.*f);

% now average 
JL_Tr = nanmean(JL_Tr');
JH_Tr = nanmean(JH_Tr');

% full profiles
JL_Tr_Final = 30.*JL_Tr;
JH_Tr_Final = 30.*JH_Tr;



% coadded signal deadtime correction
JL_Co = JL_coadd./(1-(deadtime.*JL_coadd.*f));
JH_Co = JH_coadd./(1-(deadtime.*JH_coadd.*f));

JL_Av = JL_mean./(1-(deadtime.*JL_mean.*f));
JH_Av = JH_mean./(1-(deadtime.*JH_mean.*f));

% 
% % ktest 
% 
% h1 = kstest(JL_Av)
% h2 = kstest(JL_Co)
% h3 = kstest(30.*JL_Tr)
% 
% % checkPoissonStat(alt,JL_Co);
% % checkPoissonStat(alt,30.*JL_Av);
% % checkPoissonStat(alt,JL_Tr_Final);
% 
% % 
%  figure;
%  subplot(1,2,1)
%  semilogx(JL_Tr_Final,alt,'y',JL_Co,alt,'k',30.*JL_Av ,alt,'m')
%   xlabel('Counts/bin/time')
%   ylabel('Alt (m)')
%   legend('single scan - DT corrected- Avg *30','Coadded DT corrected','Mean - DT corrected - *30') 
%   
% subplot(1,2,2)
% semilogx(JH_Tr_Final,alt,'r',JH_Co,alt,'b',30.*JH_Av ,alt,'g')
%   xlabel('Counts/bin/time')
%   ylabel('Alt (m)')
%   legend('single scan - DT corrected- Avg *30','Coadded DT corrected','Mean - DT corrected - *30') 
% % 
% %  r1=JL_Tr_Final./JL_Co; 
% %  r2=JL_Tr_Final./(30.*JL_Av);
% % %  r3=JL_Co,alt./(30.*JL_Av);
% %   figure;
% % subplot(1,2,1)
% % plot(JL_Tr_Final./JL_Co,alt,'b',JL_Tr_Final./(30.*JL_Av) ,alt,'g',JL_Co./(30.*JL_Av),alt,'r')
% %   xlabel('Ratio')
% %   ylabel('Alt (m)')
% %   legend('single scan /coadd','single scan /avg','Coadd/avg') 
% % subplot(1,2,2)
% % plot(JH_Tr_Final./JH_Co,alt,'b',JH_Tr_Final./(30.*JH_Av) ,alt,'g',JH_Co./(30.*JL_Av),alt,'r')
% %   xlabel('Ratio')
% %   ylabel('Alt (m)')
% %   legend('single scan /coadd','single scan /avg','Coadd/avg') 
% % 
% %   
% %   
%   % SNR plots
% %   
% figure;
% subplot(1,2,1)
% plot(sqrt(JL_Tr_Final),alt,'r',sqrt(JL_Co),alt,'b',sqrt(30.*JL_Av) ,alt,'g')
%   xlabel('SNR')
%   ylabel('Alt (km)')
%   legend('single scan - DT corrected- Avg *30','Coadded DT corrected','Mean - DT corrected - *30') 
% subplot(1,2,2)
% plot(sqrt(JH_Tr_Final),alt,'r',sqrt(JH_Co),alt,'b',sqrt(30.*JH_Av) ,alt,'g')
%   xlabel('SNR')
%   ylabel('Alt (km)')
%   legend('single scan - DT corrected- Avg *30','Coadded DT corrected','Mean - DT corrected - *30') 
% 
% %   