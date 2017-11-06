% this is to read S0.mat files and pick the measurements from 11-11.30pm
% Save the JL,JH,Eb and alt in seperate structure 

function [Y] = makeY(Q)

% Q.coaddalt = coaddalt;
% Q.deadtimeJL=deadtimeJL;
% Q. deadtimeJH =deadtimeJH;


date = Q.date_in;
[year,month,day] = getYMDFromDate(date);
 yr = num2str(year);
% 
%  
% %% Load S3 data files 
% 
 datadirS3 = '/Users/sham/Documents/MATLAB/RALMO_Data/RALMO';
% 
 cleanmacpollution(datadirS3); % this is to remove DS_store.dat files from the data folder
% 
 Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day)];
% 
filename = 'S0.mat';
 folderpath = [datadirS3 filesep  Dateofthefolder filesep filename];
 folders = dirFiles(folderpath);
%  lengthfolders = length(folders);
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
%      error('NODATA:RawCountsem', ['No RALMO data is available for the date ' num2str(date)]);
% end

% times = zeros(1,scans);
% shots = zeros(1,scans);
% bins = zeros(1,scans);

load(folderpath);

% Display the start and end times of the lidar measurment
% disp('Start time')
g = hour(S0.GlobalParameters.Start.FastCom);%S0.GlobalParameters.Start.FastCom );
Minute = minute(S0.GlobalParameters.Start.FastCom);%(S0.GlobalParameters.Start.FastCom  );
deltatime = length(g);

% starttime=find(g==23 & Minute==00);
% endtime= find(g==23 & Minute==30);

% pick the measurements from 11-11.30
%% Digital Channels Fast_COm high gain
JL=[];
JH=[];
Eb=[];

alt = S0.Channel(11).Range;
JL = S0.Channel(11).Signal;
JH = S0.Channel(3).Signal;
Eb = S0.Channel(10).Signal(:,2:31);
Ebalt = S0.Channel(10).Range;
% MHZ to Counts conversion constant 
Y.binsize = S0.Channel(11).BinSize;
F = 1800.* (Y.binsize./150);
       
% Convert to counts

JL = F.*JL; % single scans
JH = F.*JH;
Eb = F.*Eb;

 %% coaddding 30mints
JL = nansum(JL');
JH = nansum(JH');
Eb = nansum(Eb');
% Coadd in alt

[JH, JHzc] = coadd(JH, alt, Q.coaddalt);
[JL, JLzc] = coadd(JL, alt, Q.coaddalt);
[Eb, Ebzc] = coadd(Eb, Ebalt, Q.coaddalt);

alt = JHzc;

bkg_ind1 = alt>35e3;% & alt<60e3;
bkg_ind2 = alt>35e3;

% Desaturate and find the true background first
     % 1. Make the Co added counts to avg counts
        JHn = JH./(deltatime.*Q.coaddalt);
        JLn = JL./(deltatime.*Q.coaddalt);
        % 2. Convert counts to Hz
        JHnwn = (JHn./F);
        JLnwn = (JLn./F);

        
        % 3. Apply DT correction
        JL_dtc = JLn ./ (1 - JLnwn.*(Q.deadtimeJL.*1e6)); % non-paralyzable
        JH_dtc = JHn ./ (1 - JHnwn.*(Q.deadtimeJH).*1e6);

% %           % 4. Convert to counts
%            JLC = JL_dtc.*(1./Q.f);
%            JHC = JH_dtc.*(1./Q.f);

%        % 5. Scale bacl to coadded signal    
       JL_DS = JL_dtc.*(deltatime.*Q.coaddalt);
       JH_DS = JH_dtc.*(deltatime.*Q.coaddalt);
       
%                         JL_DS(JL_DS<=0)= round(rand(1)*10);
%                          JH_DS(JH_DS<=0)= round(rand(1)*10);

bkg_JL = JL_DS(bkg_ind1);
bkg_JH = JH_DS(bkg_ind2);




%% Digital
bg_JL_std = std(bkg_JL);
bg_JH_std = std(bkg_JH);
bg_JL_v = var(bkg_JL);
bg_JH_v= var(bkg_JH);
bg_JL = nanmean(bkg_JL);
bg_JH = nanmean(bkg_JH);


bg_length1 = length(bkg_JH);
bg_length2 = length(bkg_JL);

%%

%% Digital
Y.JL = JL ;
Y.JH = JH ;
Y.JL_DS = JL_DS;
Y.JH_DS = JH_DS;
Y.alt = alt;
Y.bgJL = bg_JL;
Y.bgJH = bg_JH;
Y.bg_JL_std = bg_JL_std ;
Y.bg_JH_std = bg_JH_std ;
Y.bg_length1 = bg_length1;
Y.bg_length2 = bg_length2;
Y.F = F;
Y.deltatime = deltatime;
Y.Eb = Eb;
Y.Ebalt = Ebzc;
% save('data.mat','-struct','Y');
