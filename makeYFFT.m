% this is to read S0.mat files and pick the measurements from 11-11.30pm
% Save the JL,JH,Eb and alt in seperate structure 

function [Y] = makeYFFT(Q)




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

    bkg_ind = alt>50e3;% & alt<60e3;
    bkg_Lan = mean(JL_an(:,bkg_ind)');
    bkg_Han = mean(JH_an(:,bkg_ind)');
    
    % Background removed signal
    for i = 1:length(bkg_Lan)
        JLa(i,:) = JL_an(i,:) - bkg_Lan(i);
        JHa(i,:) = JH_an(i,:) - bkg_Han(i);
    end
    
%     for i = 1:length(alt_an)
%         stdJLaa(:,i) = std(JLa(:,i));
%         stdJHaa(:,i) = std(JHa(:,i));
%     end
La = JLa(:,alt_an<=12000);
Ha = JHa(:,alt_an<=12000);
alt_a = alt_an(alt_an<=12000);


Length = length(La);


 %% Here I am using FFT and find the power spectrum
for k = 1:Length

    FFT_JL(:,k) =  La(:,k);
    FFT_JH(:,k) =  Ha(:,k);
    
    Pyy_JL(:,k) = FFT_JL(:,k).*conj(FFT_JL(:,k))/Length;
    Pyy_JH(:,k) = FFT_JH(:,k).*conj(FFT_JH(:,k))/Length;
    
end



Ya = nansum(Pyy_JL);
YYa = nansum(Pyy_JH);

% 
% % MeanLvar = mean(varL);
% % MeanHvar = mean(varH);
% % 
% r111 = ones(1,g-1).* YYa(1);
% r211 = ones(1,g-1).* YYa(end);
% r311 = ones(1,g-1).* Ya(1);
% r411 = ones(1,g-1).* Ya(end);
% YYYa = [r111 YYa  r211];
% YYa = [r311 Ya  r411];

[Y.YYYa, zz] = coaddNEW(YYa, alt_a, Q.coaddalt);
[Y.YYa, zz] = coaddNEW(Ya, alt_a, Q.coaddalt);

JL_an = nansum(JL_an);
JH_an = nansum(JH_an);
Eb_an = nansum(Eb_an');


[JH, JHzc] = coadd(JH, alt, Q.coaddalt);
[JL, JLzc] = coadd(JL, alt, Q.coaddalt);
[Eb, Ebzc] = coadd(Eb, alt, Q.coaddalt);

[JH_an, JHazc] = coadd(JH_an, alt_an, Q.coaddalt);
[JL_an, JLazc] = coadd(JL_an, alt_an, Q.coaddalt);
[Eb_an, Ebazc] = coadd(Eb_an, alt_an, Q.coaddalt);

alt = JHzc;
Alt = JHazc;

% stdJHa = interp1(alt_an,stdJHaa,JHazc,'spline');
% stdJLa = interp1(alt_an,stdJLaa,JHazc,'spline');
% 
% % Signal to noise
% JL_P = ((stdJLa./JL_an)).*100;
% JH_P = ((stdJHa./JH_an)).*100;
% figure;plot(JL_P,JLazc./1000,'r',JH_P,JLazc./1000,'b')


  figure;
  semilogx(JL,alt./1000,'b',JH,alt./1000,'r',Eb,Ebzc./1000,'g',JL_an,Alt./1000,'y',JH_an,Alt./1000,'black') 
  xlabel('30min Coadded signal') 
  xlabel('30min Coadded signal')
  ylabel('Altitude (km)')
  legend('JL - Digital','JH - Digital','Eb - Digital','JL - Analog','JH - Analog')
title( Dateofthefolder);
  set(gca,'fontsize',20)
  
% Save in a new mat file
bkg_ind1 = alt>50e3;% & alt<60e3;
bkg_ind2 = Alt>50e3;
% bkg_ind3 = Alt>8e3 & Alt<12e3;
% [JLwithoutBG,bkg_JL] = CorrBkg(JL, sum(bkg_ind), 0, 1);
% [JHwithoutBG,bkg_JH]  = CorrBkg(JH, sum(bkg_ind), 0, 1);

% BAckground

% Desaturate and find the true background first
     % 1. Make the Co added counts to avg counts
        JHn = JH./(Q.deltatime.*Q.coaddalt);
        JLn = JL./(Q.deltatime.*Q.coaddalt);
        
        % 2. Convert counts to MHz
        JHnwn = (JHn./F);
        JLnwn = (JLn./F);

        
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