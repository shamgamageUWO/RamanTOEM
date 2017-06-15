% this is to read S0.mat files and pick the measurements from 11-11.30pm
% Save the JL,JH,Eb and alt in seperate structure 

function [Y] = makeY(Q)

% open S0 matfile according to the given date
datadirS3='/Users/sham/Desktop';
% datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
file = 'S0';
folderpath = [datadirS3 filesep  file];


% date = Q.date_in;
% [year,month,day] = getYMDFromDate(date);
%  yr = num2str(year);
% 
%  
% %% Load S3 data files 
% 
% datadirS3 = '/Users/sham/Documents/MATLAB/RALMO_Data/RALMO/S3files';
% 
% cleanmacpollution(datadirS3); % this is to remove DS_store.dat files from the data folder
% 
% Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day)];
% 
% folderpath = [datadirS3 filesep  Dateofthefolder];
% folders = dirFiles(folderpath);
% lengthfolders = length(folders);
% 
%                 if lengthfolders ~= 1
% 
%                     if lengthfolders == 0
%                         sprintf('There are no folders of RALMO data for this date: \n')
%                         return
%                     end
%                     sprintf('There is more than one folder of RALMO data for this date: \n')
%                     disp(folders)
% 
%                     folder = input('Please type in the name of the folder you want, without quotes. \n','s');
%                     if isempty(folder)
%                         sprintf('Default is the first one')
% 
% 
%                         folder =(folders{1});
%                     end
%                     folderpath = [datadir filesep folder];
%                 else
%                     
%                     folders = folders{1};
%                     folderpath = [folderpath  filesep folders];
%                     
%                 end
% 
% files = dirFiles(folderpath);
% files = sort(files);
% 
% scans = length(files);
% if ~(0 < scans)
% %     error('NODATA:RawCountsem', ['No RALMO data is available for the date ' num2str(date)]);
% end
% 
% times = zeros(1,scans);
% shots = zeros(1,scans);
% bins = zeros(1,scans);

load(folderpath);

% Display the start and end times of the lidar measurment
% disp('Start time')
g = hour(S0.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
Minute = minute(S0.GlobalParameters.Start);%(S0.GlobalParameters.Start.FastCom  );
start =  [g(1) Minute(1)];
% start

%
% disp('End time')
% gg = hour(S3.GlobalParameters.End);
endtime =  [g(end) Minute(end)];
% endtime;

% pick the measurements from 11-11.30
JL=[];
JH=[];
% Eb=[];
alt = S0.Channel(4).Range;
Alt = S0.Channel(2).Range ; % for Eb channel they have a different binzise

%% Load the analog channel measurements too 
% figure;
%   hold on;


JL = S0.Channel(12).Signal(:,961:990);
JH = S0.Channel(4).Signal(:,961:990);
Eb= S0.Channel(10).Signal(:,961:990);

% for i = 1: length(g)
%     if g(i)== 23 && (00 <= Minute(i)<=30)
%         JL(:,i) = S0.Channel(12).Signal(:,i); % change these for S0 format
%         JH(:,i) = S0.Channel(4).Signal(:,i);
%         JL_an(:,i) = S0.Channel(11).Signal(:,i);
%         JH_an(:,i) = S0.Channel(3).Signal(:,i);
%         single_scan_JL_Counts(:,i) = JL(:,i).*1800.*(S0.Channel(12).BinSize./150);
% %         semilogx(JL(:,i),alt);
% %         'pause here'
% %         pause   
%     end 
% end
% hold off
% single_scan_JL_MHz = S0.Channel(4).Signal(:,20);
% single_scan_JL_Counts = single_scan_JL_MHz.*1800.*(S0.Channel(12).BinSize./150);
% 
% figure;semilogx(single_scan_JL_MHz,alt,'r',single_scan_JL_Counts,alt,'b')
%   xlabel('Single Scan')
%   ylabel('Alt (km)')
%   legend('JL_ MHz','JL_Counts/bin/time')
% 
% mean_scan_JL_MHz = nanmean(S0.Channel(4).Signal');
% mean_scan_JL_Counts = mean_scan_JL_MHz.*1800.*(S0.Channel(12).BinSize./150);
% 
% figure;semilogx(mean_scan_JL_MHz,alt,'r',mean_scan_JL_Counts,alt,'b')
%   xlabel('Mean Scan')
%   ylabel('Alt (km)')
%   legend('JL_ MHz','JL_Counts/bin/time')  
%   
  
% 
% figure;plot(nanmean(S0.Channel(12).Signal'),alt,'b',nanmean(S0.Channel(4).Signal'),alt,'r')
%   xlabel('Counts(MHz)')
%   ylabel('Alt (km)')
%   legend('JL digital','JH digital')
% %   
%   figure;plot(nanmean(S0.Channel(11).Signal'),alt,'b',nanmean(S0.Channel(3).Signal'),alt,'r')
%   xlabel('Counts(MHz)')
%   ylabel('Alt (km)')
%   legend('JL ana','JH ana')

% MHZ to Counts conversion constant 
Y.binsize = S0.Channel(12).BinSize;
F = 1800.* (Y.binsize./150);


% Coadd in time
% Eb= S0.Channel(2).Signal; % this is over night signal
JL = F.*JL; % single scans
JH = F.*JH;
Eb = F.*Eb; % single scans




% figure;plot(nanmean(JL'),alt,'b',nanmean(JH'),alt,'r')

JL = nansum(JL');
JH = nansum(JH');
Eb = nansum(Eb');

%    figure;semilogx(JL,alt./1000,'b',JH,alt./1000,'r')%,Eb,Ebzc./1000,'g') 
%   xlabel('30min Coadded signal (Counts/bin/time)')
%   ylabel('Alt (km)')
%   legend('JL','JH')

% Coadd in alt



[JH, JHzc] = coadd(JH, alt, Q.coaddalt);
[JL, JLzc] = coadd(JL, alt, Q.coaddalt);
[Eb, Ebzc] = coadd(Eb, Alt, Q.coaddalt);

alt = JHzc;

%    figure;semilogx(JL,alt./1000,'b',JH,alt./1000,'r')%,Eb,Ebzc./1000,'g') 
%   xlabel('30min and 40bin  Coadded signal (Counts/bin/time)')
%   ylabel('Alt (km)')
%   legend('JL','JH')
% Save in a new mat file
bkg_ind1 = alt>40e3;% & alt<60e3;
bkg_ind2 = alt>40e3;
% [JLwithoutBG,bkg_JL] = CorrBkg(JL, sum(bkg_ind), 0, 1);
% [JHwithoutBG,bkg_JH]  = CorrBkg(JH, sum(bkg_ind), 0, 1);

bkg_JL = JL(bkg_ind1);
bkg_JH = JH(bkg_ind2);
bkg_Eb = Eb(bkg_ind1);
% JLnew = JL-bkg_JL;
% JHnew = JH-bkg_JH;


%%
bg_JL_std = std(bkg_JL);
bg_JH_std = std(bkg_JH);
bg_JL_v = var(bkg_JL);
bg_JH_v= var(bkg_JH);
bg_JL_mean = nanmean(bkg_JL);
bg_JH_mean = nanmean(bkg_JH);
bg_Eb_mean = nanmean(bkg_Eb);

bg_length1 = length(bkg_JH);
bg_length2 = length(bkg_JL);


JLwithoutBG = JL-bg_JL_mean;
JHwithoutBG = JH-bg_JH_mean;
EbwithoutBG = Eb-bg_Eb_mean;
% 
%   figure;semilogx(JL,alt./1000,'b',JH,alt./1000,'r')%,Eb,Ebzc./1000,'g') 
%   xlabel('Photon Counts')
%   ylabel('Alt (km)')
%   legend('JL','JH')
% hold on;


Y.JL = JL ;
Y.JH = JH ;
Y.Eb = Eb;
Y.Ebalt = Ebzc;
Y.alt = alt;
Y.bgJL = bg_JL_mean ;
Y.bgJH = bg_JH_mean ;
Y.bg_JL_std = bg_JL_std ;
Y.bg_JH_std = bg_JH_std ;
Y.bg_length1 = bg_length1;
Y.bg_length2 = bg_length2;


% save('data.mat','-struct','Y');
