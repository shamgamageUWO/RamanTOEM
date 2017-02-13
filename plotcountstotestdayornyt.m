%% Try converting MHz to counts
% Clear nights = 20110621,20110628,20110705,
% cloudy = 20110706
function start = plotcountstotestdayornyt(date)
start =[];
for i = 1:length(date)

    [year,month,day] = getYMDFromDate(date(i));
 yr = num2str(year);

 
%% Load S3 data files 
datadirS3 = '/Volumes/Sham_RALMO'; %% from hard
% datadirS3 = '/Users/sham/Documents/MATLAB/RALMO_Data/RALMO/S3files';

cleanmacpollution(datadirS3); % this is to remove DS_store.dat files from the data folder

Dateofthefolder =[yr sprintf('.')  sprintf('%02.f',month) sprintf('.') sprintf('%02.f',day)];
% matfile = 'S3.mat';
folderpath = [datadirS3 filesep  yr filesep Dateofthefolder filesep 'S3.mat'] % from hard


load(folderpath);
% plot(nansum(S3.JH.Photon.Signal'),S3.JH.Photon.Range)
disp('S3.mat is loaded');
% F=string(S3.GlobalParameters.Start);

 
 
% disp('Start time of the measurement')
% start(i) = F(1);
% c = 3*10^8;
% Rate = 30;%Hz
% t_bin = 60;%s
% alt_bin_size = 3.75;%m
% % clight = 299792458; %ISSI value
% 

JH = (S3.JH.Photon.Signal');
JL = (S3.JL.Photon.Signal');
Es = (S3.Es.Photon.Signal');
alt = S3.JH.Photon.Range;

g = hour(S3.GlobalParameters.Start);
 ind = (g>=7) & (g<= 18);
 fg = g(ind);
 JL = JL(ind);
 JH = JH(ind);
 Es = Es(ind);
 alt = alt(ind);
 
% % Co add the altitudes 
% % bin_size = 10;
% % JH = coadd2(JH,bin_size);
% % JL = coadd2(JL,bin_size);
% % alt = coadd2(alt',bin_size);
% 
% % Conversion to Photon counts
% JL = JL.*1800.*(S3.JL.Photon.BinSize./150);
% JH = JH.*1800.*(S3.JH.Photon.BinSize./150);
% Es = Es.*1800.*(S3.JH.Photon.BinSize./150);
% 
% 
% figure;semilogx(JL,alt./1000,'r',JH,alt./1000,'b',Es,alt./1000,'black')

end 

