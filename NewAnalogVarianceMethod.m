% this is to read S0.mat files and pick the measurements from 11-11.30pm
% Save the JL,JH,Eb and alt in seperate structure 

function  NewAnalogVarianceMethod




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

JL = F.*F.*S0.Channel(12).Signal(:,starttime:endtime);%20121212(:,1310:1340);20120717(:,1347:1377);%20110909(:,961:990);
JH = F.*S0.Channel(4).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
Eb= F.*S0.Channel(10).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);


JL_an = S0.Channel(11).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
JH_an = S0.Channel(3).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
Eb_an = S0.Channel(9).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
JL_an = JL_an';
JH_an = JH_an';


N = length(JH);

% %% Fix off set 
zAoffset = 10; % bins ie 10*3.75 = 37.5m 
JH= JH(1:N-zAoffset,:); % already in counts ./ (y2HzRaw./1e6);
JL =JL(1:N-zAoffset,:); % ./ (y2HzRaw./1e6);
JH_an = JH_an(:,1+zAoffset:end);
JL_an = JL_an(:,1+zAoffset:end);
alt = alt(1:N-zAoffset);
alt_an = alt_an(1+zAoffset:end);


% Remove background from each profile
bkg_ind = alt>50e3;% & alt<60e3;
bkg_JLan = mean(JL_an(:,bkg_ind)');
bkg_JHan = mean(JH_an(:,bkg_ind)');

% Background removed signal
for i = 1:length(bkg_JLan)
JLa(i,:) = JL_an(i,:) - bkg_JLan(i);
JHa(i,:) = JH_an(i,:) - bkg_JHan(i);
end

    figure;
    subplot(1,4,1)
    plot(JLa,alt_an./1000)
    xlabel('JL Analog Signal')
    ylabel(' Alt(km)')

    subplot(1,4,2)
    plot(JHa,alt_an./1000)
    xlabel('JH Analog Signal')
    ylabel(' Alt(km)')

% Find the std at each height
for i = 1:length(alt_an)
stdJLa(:,i) = std(JLa(:,i));
stdJHa(:,i) = std(JHa(:,i));
end



    subplot(1,4,3)
    plot(stdJLa,alt_an./1000)
    xlabel('Std JL Analog ')
    ylabel(' Alt(km)')

    subplot(1,4,4)
    plot(stdJHa,alt_an./1000)
    xlabel('Std JH Analog ')
    ylabel(' Alt(km)')
    
 % Variance 
 JLvar = stdJLa.^2;
 JHvar = stdJHa.^2;
 
  figure;
    subplot(1,2,1)
    plot(JLvar,alt_an./1000)
    xlabel('JL Analog Signal')
    ylabel(' Alt(km)')

    subplot(1,2,2)
    plot(JHvar,alt_an./1000)
    xlabel('JH Analog Signal')
    ylabel(' Alt(km)')
 

