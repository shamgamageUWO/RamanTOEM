%% Try converting MHz to counts
function [JHnew,JLnew,alt,JLwithoutBG,JHwithoutBG,bkg_JL,bkg_JH,bg_JH_std,bg_JL_std]=rawcountsRALMOfromhard(date)
% Note that the s3.mat file has the unit of MHz not in counts. so the first
% step is to convert the MHz to counts
% In this code , I remove the background too
% removing background is done using the last 1000bin sum and substracting
% If there is any value less than zero those were converted to be NaNs


[year,month,day] = getYMDFromDate(date);
 yr = num2str(year);

 
%% Load S3 data files 
datadirS3 = '/Volumes/Sham_RALMO'; %% from hard
% datadirS3 = '/Users/sham/Documents/MATLAB/RALMO_Data/RALMO/S3files';

cleanmacpollution(datadirS3); % this is to remove DS_store.dat files from the data folder

Dateofthefolder =[yr sprintf('.')  sprintf('%02.f',month) sprintf('.') sprintf('%02.f',day)]
% matfile = 'S3.mat';
folderpath = [datadirS3 filesep  yr filesep Dateofthefolder filesep 'S3.mat'] % from hard

% % %folderpath = [datadirS3 filesep  Dateofthefolder];
% % folders = dirFiles(folderpath);
% % lengthfolders = length(folders);
% % 
% %                 if lengthfolders ~= 1
% % 
% %                     if lengthfolders == 0
% %                         sprintf('There are no folders of RALMO data for this date: \n')
% %                         return
% %                     end
% %                     sprintf('There is more than one folder of RALMO data for this date: \n')
% %                     disp(folders)
% % 
% %                     folder = input('Please type in the name of the folder you want, without quotes. \n','s');
% %                     if isempty(folder)
% %                         sprintf('Default is the first one')
% % 
% % 
% %                         folder =(folders{1});
% %                     end
% %                     folderpath = [datadir filesep folder];
% %                 else
% %                     
% %                     folders = folders{1};
% %                     folderpath = [folderpath  filesep folders];
% %                     
% %                 end
% % 
% % % files = dirFiles(folderpath)
% % % files = sort(files)
% % % 
% % % scans = length(files);
% % % if ~(0 < scans)
% % %     error('NODATA:RawCountsem', ['No RALMO data is available for the date ' num2str(date)]);
% % % end
% % % 
% % % times = zeros(1,scans);
% % % shots = zeros(1,scans);
% % % bins = zeros(1,scans);

load(folderpath);
% plot(nansum(S3.JH.Photon.Signal'),S3.JH.Photon.Range)
disp('S3.mat is loaded');

c = 3*10^8;
Rate = 30;%Hz
t_bin = 60;%s
alt_bin_size = 3.75;%m
% clight = 299792458; %ISSI value


JH = nansum(S3.JH.Photon.Signal');
JL = nansum(S3.JL.Photon.Signal');
alt = S3.JH.Photon.Range;

% Co add the altitudes 
bin_size = 10;
JH = coadd2(JH,bin_size);
JL = coadd2(JL,bin_size);
alt = coadd2(alt',bin_size);

% Conversion to Photon counts
JL = JL.*1800.*(S3.JL.Photon.BinSize./150);
JH = JH.*1800.*(S3.JH.Photon.BinSize./150);



bkg_ind = alt > 40e3 & alt<60e3;
bkg_JL = nanmean(JL(bkg_ind));
bkg_JH = nanmean(JH(bkg_ind));
bg_JL_std = std(JL(bkg_ind));
bg_JH_std = std(JH(bkg_ind));

JLwithoutBG = JL-bkg_JL;
JHwithoutBG = JH-bkg_JH;
% 
% figure;semilogx(JL,alt./1000)
% figure;semilogx(JH,alt./1000)

JLnew = JL;
JHnew = JH;


