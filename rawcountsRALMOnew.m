%% Try converting MHz to counts
function [JHnew,JLnew,alt,JLwithoutBG,JHwithoutBG,bg_JL_mean,bg_JH_mean,bg_JL_std,bg_JH_std,Eb,bg_length]=rawcountsRALMOnew(Q)
% Note that the s3.mat file has the unit of MHz not in counts. so the first
% step is to convert the MHz to counts
% In this code , I remove the background too
% removing background is done using the last 1000bin sum and substracting
% If there is any value less than zero those were converted to be NaNs

date = Q.date_in;
[year,month,day] = getYMDFromDate(date);
 yr = num2str(year);

 
%% Load S3 data files 

datadirS3 = '/Users/sham/Documents/MATLAB/RALMO_Data/RALMO/S3files';

cleanmacpollution(datadirS3); % this is to remove DS_store.dat files from the data folder

Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day)];

folderpath = [datadirS3 filesep  Dateofthefolder];
folders = dirFiles(folderpath);
lengthfolders = length(folders);

                if lengthfolders ~= 1

                    if lengthfolders == 0
                        sprintf('There are no folders of RALMO data for this date: \n')
                        return
                    end
                    sprintf('There is more than one folder of RALMO data for this date: \n')
                    disp(folders)

                    folder = input('Please type in the name of the folder you want, without quotes. \n','s');
                    if isempty(folder)
                        sprintf('Default is the first one')


                        folder =(folders{1});
                    end
                    folderpath = [datadir filesep folder];
                else
                    
                    folders = folders{1};
                    folderpath = [folderpath  filesep folders];
                    
                end

files = dirFiles(folderpath);
files = sort(files);

scans = length(files);
if ~(0 < scans)
    error('NODATA:RawCountsem', ['No RALMO data is available for the date ' num2str(date)]);
end

times = zeros(1,scans);
shots = zeros(1,scans);
bins = zeros(1,scans);

load(folderpath);
% plot(nansum(S3.JH.Photon.Signal'),S3.JH.Photon.Range)
% disp('S3.mat is loaded');

c = 3*10^8;
Rate = 30;%Hz
t_bin = 60;%s
alt_bin_size = 3.75;%m
% clight = 299792458; %ISSI value


JH = nansum(S3.JH.Photon.Signal(:,1:30)');%(:,1:30)
JL = nansum(S3.JL.Photon.Signal(:,1:30)');
Eb = nansum(S3.Eb.Photon.Signal(:,1:30)');
alt = S3.JH.Photon.Range;

% figure;semilogx(JH,alt,JL,alt); hold on

% Conversion to Photon counts
JL = JL.*1800.*(S3.JL.Photon.BinSize./150);
JH = JH.*1800.*(S3.JH.Photon.BinSize./150);
Eb = Eb.*1800.*(S3.JH.Photon.BinSize./150);

[JH, JHzc] = coadd(JH, alt, Q.coaddalt);
[JL, JLzc] = coadd(JL, alt, Q.coaddalt);
[Eb, Ebzc] = coadd(Eb, alt, Q.coaddalt);

alt = JHzc;
% semilogx(JH,alt,JL,alt);
% hold off;
%     
bkg_ind1 = alt>57e3 & alt<58e3;
bkg_ind2 = alt>57e3 & alt<58e3;

% [JLwithoutBG,bkg_JL] = CorrBkg(JL, sum(bkg_ind), 0, 1);
% [JHwithoutBG,bkg_JH]  = CorrBkg(JH, sum(bkg_ind), 0, 1);

bkg_JL = JL(bkg_ind2);
bkg_JH = JH(bkg_ind1);
% JLnew = JL-bkg_JL;
% JHnew = JH-bkg_JH;


%%
bg_JL_std = std(bkg_JL);
bg_JH_std = std(bkg_JH);
bg_JL_v = var(bkg_JL);
bg_JH_v= var(bkg_JH);
bg_JL_mean = nansum(bkg_JL);
bg_JH_mean = nansum(bkg_JH);

bg_length = length(bkg_JH);
bg_JH_length = length(bkg_JH);


JLwithoutBG = JL-bg_JL_mean;
JHwithoutBG = JH-bg_JH_mean;
% 
% figure;semilogx(JL,alt./1000,'r',JH,alt./1000,'r') 
% hold on;


JLnew = JL ;
JHnew = JH ;
% Display the start and end times of the lidar measurment
% disp('Start time')
% g = hour(S3.GlobalParameters.Start);
% g(1)
% 
% disp('End time')
% gg = hour(S3.GlobalParameters.End);
% gg(end)

% figure; 
% semilogx(JLnew,alt./1000,'b',JHnew,alt./1000,'b')
% hold off;

% % Remove any negative counts
% % H = JHnew<0;
% % JHnew(H) = NaN;
% % 
% % L = JLnew<0;
% % JLnew(L) = NaN;

