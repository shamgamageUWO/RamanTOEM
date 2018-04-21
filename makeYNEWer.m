% this is to read S0.mat files and pick the measurements from 11-11.30pm
% Save the JL,JH,Eb and alt in seperate structure 

function [Y] = makeYNEWer(Q)




 date = Q.date_in;
[year,month,day] = getYMDFromDate(date);
 yr = num2str(year);

 % open S0 matfile according to the given date
datadirS3='/Users/sham/Documents/MATLAB/RALMO_Data/RALMO';%/2011.09.28
% datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
file = 'S0';

%  
% %% Load S3 data files 
% 
% datadirS3 = '/Users/sham/Documents/MATLAB/RALMO_Data/RALMO/S3files';
% 
% cleanmacpollution(datadirS3); % this is to remove DS_store.dat files from the data folder
% 
 Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day)];
% 
 folderpath = [datadirS3 filesep  Dateofthefolder filesep  file];
%  folderpath = [datadirS3 filesep  file];
 
% folders = dirFiles(folderpath);
% lengthfolders = length(folders);
% 
%                 if lengthfolders ~= 1
% 
%                     if lengthfolders == 0

% bins = zeros(1,scans);



load(folderpath);


g = hour(S0.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
Minute = minute(S0.GlobalParameters.Start);%(S0.GlobalParameters.Start.FastCom  );
tin =Q.time_in;
% from 2300 to 2330
starttime=find(g==tin & Minute==00);
endtime=find(g==tin & Minute==30);

% pick the measurements from 11-11.30
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
%% Load the analog channel measurements too 



JL = S0.Channel(12).Signal(:,starttime:endtime);%20121212(:,1310:1340);20120717(:,1347:1377);%20110909(:,961:990);
JH = S0.Channel(4).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
Eb= S0.Channel(10).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);



JL_an = S0.Channel(11).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
JH_an = S0.Channel(3).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
Eb_an = S0.Channel(9).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
JL_an = JL_an';
JH_an = JH_an';





% MHZ to Counts conversion constant 
Y.binsize = S0.Channel(12).BinSize;
F = 1800.* (Y.binsize./150);
       
% Coadd in time
% Eb= S0.Channel(2).Signal; % this is over night signal
JL = F.*JL; % single scans
JH = F.*JH;
Eb = F.*Eb; % single scans

N = length(JH);

% %% Fix off set 
zAoffset = 10; % bins ie 10*3.75 = 37.5m 
JH= JH(1:N-zAoffset,:); % already in counts ./ (y2HzRaw./1e6);
JL =JL(1:N-zAoffset,:); % ./ (y2HzRaw./1e6);
Eb= Eb(1:N-zAoffset,:); % already in counts ./ (y2HzRaw./1e6);
JH_an = JH_an(:,1+zAoffset:end);
JL_an = JL_an(:,1+zAoffset:end);
Eb_an = Eb_an(1+zAoffset:end,:);
alt = alt(1:N-zAoffset);
alt_an = alt_an(1+zAoffset:end);

 %% coaddding 30mints
JL = nansum(JL');
JH = nansum(JH');
Eb = nansum(Eb');


    % Analog variance


for i = 1:30
% [Ha(:,i), JHazc] = coadd(Y.JH_an(i,:), Y.alt_an,4);
% [La(:,i), JLazc] = coadd(Y.JL_an(i,:), Y.alt_an,4);   

[Ha(:,i), JHazc] = coadd(JH_an(i,:), alt_an, Q.coaddalt);
[La(:,i), JLazc] = coadd(JL_an(i,:), alt_an, Q.coaddalt);
[Eba(i,:), Ebazc] = coadd(Eb_an(:,i), alt_an, Q.coaddalt);

end

JL_an = La;
JH_an = Ha;
Eb_an = Eba;
alt_an = JHazc;

LLa = JL_an(alt_an<=12000,:);
HHa = JH_an(alt_an<=12000,:);
alt_a = alt_an(alt_an<=12000);

for i = 1:length(alt_a)
[ACF_JL(i,:)] = acf(LLa(i,:),0);
[ACF_JH(i,:)] = acf(HHa(i,:),0);
end


Y.YYa = 30.*(smooth(ACF_JL,5));
Y.YYYa = 30.*(smooth(ACF_JH,5));


JL_an = nansum(JL_an');
JH_an = nansum(JH_an');
Eb_an = nansum(Eb_an);

JL_an = JL_an';
JH_an = JH_an';


[JH, JHzc] = coadd(JH, alt, Q.coaddalt);
[JL, JLzc] = coadd(JL, alt, Q.coaddalt);
[Eb, Ebzc] = coadd(Eb, alt, Q.coaddalt);



alt = JHzc;
Alt = alt_an;

figure;semilogx(JH,alt./1000,'r',JL,alt./1000,'g',Eb,alt./1000,'b')
hold on
semilogx(JL_an, Alt./1000,'black',JH_an,Alt./1000,'m')
legend('JH','JL','Eb','JLa','JHa')
xlabel('Coadded signal')
ylabel('Altitude (km)')
  
% Save in a new mat file
bkg_ind1 = alt>50e3;% & alt<60e3;
bkg_ind2 = Alt>50e3;


% BAckground

% Desaturate and find the true background first
     % 1. Make the Co added counts to avg counts
        JHn = JH./(Q.deltatime.*Q.coaddalt);
        JLn = JL./(Q.deltatime.*Q.coaddalt);
        
        % 2. Convert counts to MHz
        JHnwn = (JHn./F);
        JLnwn = (JLn./F);
  figure;
  subplot(1,2,1)
  semilogx(JLnwn,alt./1000,'b',JHnwn,alt./1000,'r')
  xlabel('Digital Signal (MHz)')
  ylabel('Altitude (km)')
title( Dateofthefolder);
  set(gca,'fontsize',16)
  subplot(1,2,2)
  semilogx(JL_an./(Q.deltatime.*Q.coaddalt),Alt./1000,'b',JH_an./(Q.deltatime.*Q.coaddalt),Alt./1000,'r') 
  xlabel('Analog Signal (mV)')
  ylabel('Altitude (km)')
title( Dateofthefolder);
  set(gca,'fontsize',16)
  
  figure;
  semilogx(Eb,Ebzc./1000,'g')
    xlabel('Eb digital')
  ylabel('Altitude (km)')
        
        % 3. Apply DT correction
        JL_dtc = JLn ./ (1 - JLnwn.*(Q.deadtimeJL.*1e6)); % non-paralyzable
        JH_dtc = JHn ./ (1 - JHnwn.*(Q.deadtimeJH).*1e6);

% %           % 4. Convert to counts
%            JLC = JL_dtc.*(1./Q.f);
%            JHC = JH_dtc.*(1./Q.f);

%        % 5. Scale bacl to coadded signal    
       JL_DS = JL_dtc.*(Q.deltatime.*Q.coaddalt);
       JH_DS = JH_dtc.*(Q.deltatime.*Q.coaddalt);
       


bkg_JL = JL_DS(bkg_ind1);
bkg_JH = JH_DS(bkg_ind1);
bkg_Eb = Eb(bkg_ind1);


bkg_JLan = JL_an(bkg_ind2);
bkg_JHan = JH_an(bkg_ind2);
bkg_Eban = Eb_an(bkg_ind2);

% JLnew = JL-bkg_JL;
% JHnew = JH-bkg_JH;


%% Digital
bg_JL_std = std(bkg_JL);
bg_JH_std = std(bkg_JH);
bg_JL_v = var(bkg_JL);
bg_JH_v= var(bkg_JH);
bg_JL = nanmean(bkg_JL);
bg_JH = nanmean(bkg_JH);
bg_Eb = nanmean(bkg_Eb);

bg_length1 = length(bkg_JH);
bg_length2 = length(bkg_JL);

%% Analog
bg_JLan_std = std(bkg_JLan);
bg_JHan_std = std(bkg_JHan);
bg_JLan_v = var(bkg_JLan);
bg_JHan_v= var(bkg_JHan);
bg_JLan = nanmean(bkg_JLan);
bg_JHan = nanmean(bkg_JHan);
bg_Eban= nanmean(bkg_Eban);

bg_length1an = length(bkg_JHan);
bg_length2an = length(bkg_JLan);

%% Digital
Y.JL = JL ;
Y.JH = JH ;
Y.Eb = Eb;
Y.JL_DS = JL_DS;
Y.JH_DS = JH_DS;
Y.Ebalt = Ebzc;
Y.alt = alt;
Y.bgJL = bg_JL;
Y.bgJH = bg_JH;
Y.bgEb = bg_Eb;
Y.bg_JL_std = bg_JL_std ;
Y.bg_JH_std = bg_JH_std ;
Y.bg_length1 = bg_length1;
Y.bg_length2 = bg_length2;

%% analog
Y.JLa = JL_an ;
Y.JHa = JH_an ;
Y.Eba = Eb_an;
Y.bgJLa = bg_JLan;
Y.bgJHa = bg_JHan;
Y.bg_JL_stda = bg_JLan_std ;
Y.bg_JH_stda = bg_JHan_std ;
Y.bg_length1a = bg_length1an;
Y.bg_length2a = bg_length2an;
Y.alt_an = Alt;
Y.F = F;
% Y.YYa = JL_P.*JL_an;
% Y.YYYa = JH_P.*JH_an;
Y.Dateofthefolder  = Dateofthefolder ;

% save('data.mat','-struct','Y');
