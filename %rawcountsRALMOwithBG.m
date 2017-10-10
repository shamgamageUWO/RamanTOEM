%% Try converting MHz to counts
function [JHnew,JLnew,alt,JLwithoutBG,JHwithoutBG,bkg_JL,bkg_JH]=rawcountsRALMOwithBG(date)
% Note that the s3.mat file has the unit of MHz not in counts. so the first
% step is to convert the MHz to counts
% In this code , I remove the background too
% removing background is done using the last 1000bin sum and substracting
% If there is any value less than zero those were converted to be NaNs


[year,month,day] = getYMDFromDate(date);
 yr = num2str(year);

 
%% Load S3 data files 
%datadirS3 = '/Volumes/Sham_RALMO'; %% from hard
 datadirS3 = '/Users/sham/Documents/MATLAB/RALMO_Data/RALMO/S3files';

cleanmacpollution(datadirS3); % this is to remove DS_store.dat files from the data folder

Dateofthefolder =[yr sprintf('.')  sprintf('%02.f',month) sprintf('.') sprintf('%02.f',day)];
% matfile = 'S3.mat';
% folderpath = [datadirS3 filesep  yr filesep Dateofthefolder filesep 'S3.mat'] % from hard

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
disp('S3.mat is loaded');

c = 3*10^8;
Rate = 30;%Hz
t_bin = 60;%s
alt_bin_size = 3.75;%m
% clight = 299792458; %ISSI value


JH = (S3.JH.Photon.Signal);
JL = (S3.JL.Photon.Signal);
alt = S3.JH.Photon.Range;

% Conversion to Photon counts
JL = JL.*1800.*(S3.JL.Photon.BinSize./150);
JH = JH.*1800.*(S3.JH.Photon.BinSize./150);


% figure;plot(A,alt,'r',B,alt,'b'); hold on;
% % % % % % % Deadtime removal
% % % % % % trueH = [0:0.01:25];%MHz
% % % % % % obsH = trueH .*exp(-(4e-9)*trueH*(10^6)); %MHz
% % % % % % XH = obsH;
% % % % % % YH = trueH;
% % % % % % yyH = spline(XH, YH);%MHz
% % % % % % 
% % % % % % trueL = [0:0.01:25];
% % % % % % obsL = trueL.*exp(-(4e-9)*trueL*(10^6));  
% % % % % % XL = obsL;
% % % % % % YL = trueL;
% % % % % % yyL = spline(XL, YL);
% % % % % % 
% % % % % % % newy is in MHz
% % % % % % %newY2 = ppval(yy, simulated_counts2);
% % % % % % newY1 = ppval(yyH, A);
% % % % % % newY2 = ppval(yyL, B);
% % % % % % % plot(newY1,alt,'r',newY2,alt,'b'); hold off;
% % % % % % 
% % % % % % % Convert to counts 
% % % % % % % Ref: '/Users/BobSica/Dropbox/matlab/matlabWork/matlabOEM/qpackOEM/wvOEM/ralmodata/adt.conf';
% % % % % % 
% % % % % %            jshotsH = sum(S3.JH.Photon.Shots);
% % % % % %            y2HzRawH = clight ./ (2.*(jshotsH./1800).*Rate.*alt_bin_size);
% % % % % % %            JH = A ./ (y2HzRawH./1e6);
% % % % % %            JH = newY1./(y2HzRawH./1e6);
% % % % % % %            figure;plot(nansum(JH'),alt,'r',nansum(JHH'),alt,'b')
% % % % % %            jshotsL = sum(S3.JL.Photon.Shots);
% % % % % %            y2HzRawL = clight ./ (2.*(jshotsL./1800).*Rate.*alt_bin_size);
% % % % % % %            JL = B ./ (y2HzRawL./1e6);
% % % % % %             JL = newY2 ./ (y2HzRawL./1e6);
%            
%     

bkg_ind = alt > 40e3 & alt<60e3;
[JLwithoutBG,bkg_JL] = CorrBkg(JL, sum(bkg_ind), 0, 1);
[JHwithoutBG,bkg_JH]  = CorrBkg(JH, sum(bkg_ind), 0, 1);

JLwithoutBG =nansum(JLwithoutBG');
JHwithoutBG = nansum(JHwithoutBG');
% 
% figure;semilogx(JL,alt./1000)
% figure;semilogx(JH,alt./1000)

JLnew = nansum(JL');
JHnew = nansum(JH');

% figure;semilogx(JLnew,alt./1000)
% figure;semilogx(JHnew,alt./1000)

% % Remove any negative counts
% % H = JHnew<0;
% % JHnew(H) = NaN;
% % 
% % L = JLnew<0;
% % JLnew(L) = NaN;

