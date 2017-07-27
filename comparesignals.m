%This code is to compare the signals from analog,digital anc combine
%signals of RALMO
% I have hardcoded this for 20110909, picked the signals from the same time
% zone

% only coadding over time for 3hrs and no coadding in altitude
close all; clear all;
% load S0.mat file
datadirS3='/Users/sham/Desktop';
% datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
file = 'S0';
folderpath = [datadirS3 filesep  file];
load(folderpath);

alt = S0.Channel(4).Range;
JL = S0.Channel(12).Signal(:,844:end-1);
JH = S0.Channel(4).Signal(:,844:end-1);
binsize = S0.Channel(12).BinSize;
F = 1800.* (binsize./150);
JL = F.*JL;
JH = F.*JH;




alt_an = S0.Channel(11).Range ; 
JL_an = (S0.Channel(11).Signal(:,844:end-1));
JH_an = (S0.Channel(3).Signal(:,844:end-1));

JL_digi= nansum(JL');
JH_digi= nansum(JH');
JL_an =nansum(JL_an');
JH_an =nansum(JH_an');

N = length(JH);
zAoffset = 10; % bins ie 10*3.75 = 37.5m 
JH_digi= JH_digi(1:N-zAoffset); % already in counts ./ (y2HzRaw./1e6);
JL_digi =JL_digi(1:N-zAoffset); % ./ (y2HzRaw./1e6);
JH_an = JH_an(1+zAoffset:end);
JL_an = JL_an(1+zAoffset:end);
alt = alt(1:N-zAoffset);
alt_an = alt_an(1:N-zAoffset);




% load S3.mat file
datadir='/Users/sham/Desktop';
% datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
file1 = 'S3';
folderpath1 = [datadir filesep  file1];
load(folderpath1);

alt_c = S3.JL.Combined.Range;
JL_c = nansum(S3.JL.Combined.Signal');
JH_c = nansum(S3.JH.Combined.Signal');

JL_c = F.*JL_c;
JH_c = F.*JH_c;

% make sure they have the same time 
g = hour(S3.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
Minute = minute(S3.GlobalParameters.Start);%(S0.GlobalParameters.Start.FastCom  );
startS3 =  [g(1) Minute(1)]
endtimeS3 =  [g(end) Minute(end)]

g1 = hour(S0.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
Minute1 = minute(S0.GlobalParameters.Start);
startS0 = [g1(844) Minute1(844)]
endS0 = [g1(end-1) Minute1(end-1)]


% Plot
figure;
subplot(1,2,1)
semilogx(JL_digi,alt./1000,'r',JL_an,alt_an./1000,'b',JL_c,alt_c./1000,'black')
hold on;
semilogx(JH_digi,alt./1000,'g',JH_an,alt_an./1000,'y',JH_c,alt_c./1000,'m')
xlabel('Log Counts')
ylabel('Altitude (km)')
legend('JL _ digi','JL _ an','JL _ com','JH _ digi','JH _ an','JH _ com')

A = [30,60,150,300,600,900,1500,3000,4500,6000,9000,15000,24000,30000];
for i = 1:length(A)
r(i)=JL_c(alt_c==A(i))./JL_digi(alt==A(i));
end

subplot(1,2,2)
plot(A./1000,r)
ylabel('ratio of combiner to digital')
xlabel('Altitude (km)')


