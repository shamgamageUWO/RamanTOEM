date = 20170921;
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

JL_L = S0.Channel(12).Signal;
JH_L = S0.Channel(4).Signal;

figure;
subplot(1,2,1)
plot(JL,alt./1000)
xlabel('counts MHz')
ylabel('alt')
subplot(1,2,2)
plot(JH,alt./1000)
xlabel('counts MHz')
ylabel('alt')


% MHZ to Counts conversion constant 
Y.binsize = S0.Channel(11).BinSize;
F = 1800.* (Y.binsize./150);      
% Convert to counts
JL = F.*JL; % single scans
JH = F.*JH;
Eb = F.*Eb;
JL_L = F.*JL_L; % single scans
JH_L = F.*JH_L;

 %% coaddding 30mints
JL = nansum(JL');
JH = nansum(JH');
Eb = nansum(Eb');
JL_L = nansum(JL_L');
JH_L = nansum(JH_L');


figure;
subplot(1,2,1)
semilogx(JL,alt./1000)
xlabel('counts 30min coadded')
ylabel('alt')
subplot(1,2,2)
semilogx(JH,alt./1000)
xlabel('counts 30min coadded')
ylabel('alt')

%MHZ

jlh = JL./(F.*deltatime); % single scans
jhh = JH./(F.*deltatime);
jll = JL_L./(F.*deltatime); % single scans
jhl = JH_L./(F.*deltatime);

figure;
plot(jlh,alt./1000,'r',jhh,alt./1000,'b')
xlabel('counts avg signal in MHz')
ylabel('alt')


%
% [Q] = makeQsham( 20170921,00,2);
%  x = [Q.Ta Q.BaJH Q.BaJL Q.CL Q.OVa 0 0];
% [JLfm,JHfm]=forwardmodelTraman(Q,x);
% 
% x1=JLfm./(Q.deltatime.*Q.coaddalt);
% x2=JHfm./(Q.deltatime.*Q.coaddalt);
