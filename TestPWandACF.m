clear all; close all;
date = 20110909;


%  date = Q.date_in;
[year,month,day] = getYMDFromDate(date);
 yr = num2str(year);

 % open S0 matfile according to the given date
datadirS3='/Users/sham/Documents/MATLAB/RALMO_Data/RALMO';%/2011.09.28
file = 'S0';

% 
 Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day)];
 folderpath = [datadirS3 filesep  Dateofthefolder filesep  file];
load(folderpath);

g = hour(S0.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
Minute = minute(S0.GlobalParameters.Start);%(S0.GlobalParameters.Start.FastCom  );
tin = 23;
starttime=find(g==tin & Minute==00);
endtime=find(g==tin & Minute==30);

%% Analog Channels
JL_an=[];
JH_an =[];

% for Eb channel they have a different binzise
alt_an = S0.Channel(11).Range ; % Note alt = alt_an
%% Load the analog channel measurements too 
JL_an = S0.Channel(11).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
JH_an = S0.Channel(3).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
JL_an = JL_an';
JH_an = JH_an';


% N = length(JH);

% %% Fix off set 
zAoffset = 10; % bins ie 10*3.75 = 37.5m 

Y.JH_an = JH_an(:,1+zAoffset:end);
Y.JL_an = JL_an(:,1+zAoffset:end);
Y.alt_an = alt_an(1+zAoffset:end);


Y.JL_an = Y.JL_an(:,Y.alt_an<=8000);
Y.JH_an = Y.JH_an(:,Y.alt_an<=8000);
Y.alt_an = Y.alt_an(Y.alt_an<=8000);

% Coadd in height
for i = 1:30
[Ha(:,i), JHazc] = coadd(Y.JH_an(i,:), Y.alt_an,4);
[La(:,i), JLazc] = coadd(Y.JL_an(i,:), Y.alt_an,4);   
end

Y.alt = JLazc;

% PW for individual
for i = 1:30
    [varH(:,i),g] = bobpoissontest(Ha(:,i),Y.alt,10);
    [varL(:,i),g] = bobpoissontest(La(:,i),Y.alt,10);
end

% sum over time 
Ya = nansum(varL');
YYa = nansum(varH');

r111 = ones(1,g-1).* YYa(1);
r211 = ones(1,g-1).* YYa(end);
r311 = ones(1,g-1).* Ya(1);
r411 = ones(1,g-1).* Ya(end);
Y.YYYa = [r111 YYa  r211];
Y.YYa = [r311 Ya  r411];%JL

figure;plot(Y.YYYa,Y.alt./1000,'r',Y.YYa,Y.alt./1000,'b')
hold on

%% ACF for individual
for i = 1:length(Y.alt)
[ACF_JL(i,:)] = acf(La(i,:),0);
[ACF_JH(i,:)] = acf(Ha(i,:),0);
end

ACF_JL_30 = 30.*(ACF_JL);
ACF_JH_30 = 30.*(ACF_JH);

plot(ACF_JH_30,Y.alt./1000,'y',ACF_JL_30,Y.alt./1000,'g')
legend('JH PW','JL PW','JH ACF','JLACF')    


