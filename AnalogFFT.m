% this is to read S0.mat files and pick the measurements from 11-11.30pm
% Save the JL,JH,Eb and alt in seperate structure 

function [Pyy_JL,Pyy_JH,L,H] = AnalogFFT

%  date = Q.date_in;
[year,month,day] = getYMDFromDate(20110909);
 yr = num2str(year);

 % open S0 matfile according to the given date
datadirS3='/Users/sham/Documents/MATLAB/RALMO_Data/RALMO';%/2011.09.28
% datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
file = 'S0';
Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day)];
folderpath = [datadirS3 filesep  Dateofthefolder filesep  file];
load(folderpath);

% Display the start and end times of the lidar measurment
% disp('Start time')
g = hour(S0.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
Minute = minute(S0.GlobalParameters.Start);%(S0.GlobalParameters.Start.FastCom  );
tin = 23;
starttime=find(g==tin & Minute==00);
endtime=find(g==tin & Minute==30);

%% Digital Channels
JL=[];
JH=[];
Eb =[];

%% Analog Channels
JL_an=[];
JH_an =[];
Eb_an =[];



alt = S0.Channel(4).Range;
Alte = S0.Channel(2).Range ; % for Eb channel they have a different binzise
alt_an = S0.Channel(11).Range ; % Note alt = alt_an
Y.binsize = S0.Channel(12).BinSize;
F = 1800.* (Y.binsize./150);




JL_an = S0.Channel(11).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
JH_an = S0.Channel(3).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
Eb_an = S0.Channel(9).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
JL_an = JL_an';
JH_an = JH_an';


N = length(JH);

% %% Fix off set 
zAoffset = 10; % bins ie 10*3.75 = 37.5m 
% JH= JH(1:N-zAoffset,:); % already in counts ./ (y2HzRaw./1e6);
% JL =JL(1:N-zAoffset,:); % ./ (y2HzRaw./1e6);
JH_an = JH_an(:,1+zAoffset:end);
JL_an = JL_an(:,1+zAoffset:end);
alt = alt(1:N-zAoffset);
alt_an = alt_an(1+zAoffset:end);


bkg_ind = alt_an>10e3;% & alt<60e3;
bkg_Lan = mean(JL_an(:,bkg_ind)');
bkg_Han = mean(JH_an(:,bkg_ind)');


JH_an = JH_an(:,alt_an<=12000);
JL_an = JL_an(:,alt_an<=12000);
alt_an = alt_an(alt_an<=12000);





%% Remover bg and single profile


% % Background removed signal
for i = 1:length(bkg_Lan)
    L(i,:) = JL_an(i,:) - bkg_Lan(i);
    H(i,:) = JH_an(i,:) - bkg_Han(i);
end


Length = length(JL_an);

%% now for each height run FFT
for k = 1:length(JL_an)
    FFT_JL(:,k) =  L(:,k);
    FFT_JH(:,k) =  H(:,k);
    
    Pyy_JL(:,k) = FFT_JL(:,k).*conj(FFT_JL(:,k))/Length;
    Pyy_JH(:,k) = FFT_JH(:,k).*conj(FFT_JH(:,k))/Length;
    
end

JL_var = nansum(Pyy_JL);
JH_var = nansum(Pyy_JH);
figure;
subplot(1,2,1)
% semilogy(Pyy_JL(:,1:10))
semilogx(JL_var,alt_an./1000)
subplot(1,2,2)
semilogx(JH_var,alt_an./1000)

% semilogy(Pyy_JH(:,1:10))

