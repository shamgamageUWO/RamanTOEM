function T = TraditionalTemperatureIterate(H,date,time)
%% RALMO Traditional Temperature new code 
%% All channels are added
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load S0 and S3 mat files for the date needed

[year,month,day] = getYMDFromDate(date);
 yr = num2str(year);
datadirS3='/Users/sham/Documents/MATLAB/RALMO_Data/RALMO';%/2011.09.28
file = 'S0';
 Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day)];
% 
 folderpath1 = [datadirS3 filesep  Dateofthefolder filesep  file];

% load(folderpath);
% 
% % datadirS0='/Users/sham/Desktop';
% % % datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
% % file1 = 'S0';
% % folderpath1 = [datadirS0 filesep  file1];
% 
% 
% 
% datadirS3='/Users/sham/Desktop';
% % datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
% file = 'S3';
% folderpath = [datadirS3 filesep  file];

load(folderpath1);



g = hour(S0.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
Minute = minute(S0.GlobalParameters.Start);%(S0.GlobalParameters.Start.FastCom  );
% from 2300 to 2330
% starttime=find(g==time); %% somedays it skips 2mints
% endtime=find(g==time+1);

% from 2300 to 2330
starttime=find(g==time & Minute==00);
endtime=find(g==time & Minute==59);


alt =  S0.Channel(4).Range;
alt_an = S0.Channel(11).Range ; % Note alt = alt_an
%% Load the analog channel measurements too 
% figure;
%   hold on;


JL = S0.Channel(12).Signal(:,starttime:endtime);
JH = S0.Channel(4).Signal(:,starttime:endtime);
Eb= S0.Channel(10).Signal(:,starttime:endtime);



JL_an = S0.Channel(11).Signal(:,starttime:endtime);
JH_an = S0.Channel(3).Signal(:,starttime:endtime);
Eb_an = S0.Channel(9).Signal(:,starttime:endtime);

JL_an = JL_an';
JH_an = JH_an';

% JL_Com = S3.JL.Combined.Signal(:,starttime1:endtime1);
% JH_Com = S3.JH.Combined.Signal(:,starttime1:endtime1);%;(:,1347:1377)
% Eb_Com = S3.Eb.Combined.Signal(:,starttime1:endtime1);
% alt_Com = S3.JL.Combined.Range;


% MHZ to Counts conversion constant 
Y.binsize = S0.Channel(12).BinSize;
F = 1800.* (Y.binsize./150);


% Coadd in time
JL = F.*JL; % single scans
JH = F.*JH;
Eb = F.*Eb; % single scans



 %% coaddding 30mints
JL = nansum(JL');
JH = nansum(JH');
Eb = nansum(Eb');


JL_an = nansum(JL_an);
JH_an = nansum(JH_an);
Eb_an = nansum(Eb_an');

N = length(JH);

% % %% Fix off set 
%  zAoffset = 10; % bins ie 10*3.75 = 37.5m 
% JH= JH(1:N-zAoffset); % already in counts ./ (y2HzRaw./1e6);
% JL =JL(1:N-zAoffset); % ./ (y2HzRaw./1e6);
% Eb= Eb(1:N-zAoffset); % already in counts ./ (y2HzRaw./1e6);
% JH_an = JH_an(1+zAoffset:end);
% JL_an = JL_an(1+zAoffset:end);
% Eb_an = Eb_an(1+zAoffset:end);
% alt = alt(1:N-zAoffset);
% alt_an = alt_an(1+zAoffset:end);

coaddalt = 4;
[JH, JHzc] = coadd(JH, alt, coaddalt);
[JL, JLzc] = coadd(JL, alt, coaddalt);
[Eb, Ebzc] = coadd(Eb, alt, coaddalt);

[JH_an, JHazc] = coadd(JH_an, alt_an, coaddalt);
[JL_an, JLazc] = coadd(JL_an, alt_an, coaddalt);
[Eb_an, Ebazc] = coadd(Eb_an, alt_an, coaddalt);

alt = JHzc;
alt_an = JHazc;



% Deadtime correction for the digital and combined signal Not neccessary as
% we take the ratios
% Desaturate and find the true background first
     % 1. Make the Co added counts to avg counts
        JHn = JH./(60.*coaddalt);
        JLn = JL./(60.*coaddalt);
%         JHncm = JH_Com./(30.*coaddalt);
%         JLncm = JL_Com./(30.*coaddalt);
        % 2. Convert counts to Hz
        JHnwn = (JHn./F);
        JLnwn = (JLn./F);
%         JHnwncm = (JHncm./F);
%         JLnwncm = (JLncm./F);
deadtime = 3.8e-9;
        
        % 3. Apply DT correction
        JL_dtc = JLn ./ (1 - JLnwn.*(deadtime.*1e6)); % non-paralyzable
        JH_dtc = JHn ./ (1 - JHnwn.*(deadtime).*1e6);
%        JL_dtcm = JLncm ./ (1 - JLnwncm.*(deadtime.*1e6)); % non-paralyzable
%         JH_dtcm = JHncm ./ (1 - JHnwncm.*(deadtime).*1e6);
% %           % 4. Convert to counts
%            JLC = JL_dtc.*(1./Q.f);
%            JHC = JH_dtc.*(1./Q.f);

%        % 5. Scale bacl to coadded signal    
       JL_DS = JL_dtc.*(60.*coaddalt);
       JH_DS = JH_dtc.*(60.*coaddalt);
%        JL_DScm = JL_dtcm.*(30.*coaddalt);
%        JH_DScm = JH_dtcm.*(30.*coaddalt);
% Remove background
bkg_ind1 = alt>50e3;% & alt<60e3;
bkg_ind2 = alt_an>10e3;


bkg_JL =  JL_DS (bkg_ind1);
bkg_JH =  JH_DS (bkg_ind1);

bkg_JLan = JL_an(bkg_ind2);
bkg_JHan = JH_an(bkg_ind2);

bg_JL = nanmean(bkg_JL);
bg_JH = nanmean(bkg_JH);




bg_JLan = nanmean(bkg_JLan);
bg_JHan = nanmean(bkg_JHan);



%% Define ratios

JH = JH_DS-bg_JH;
JL = JL_DS-bg_JL;

JH_an = JH_an-bg_JHan;
JL_an = JL_an-bg_JLan;


Q_Digi = JL./JH;
Q_an = JL_an./JH_an;


Tprofilean = 1./log(Q_an);
Tprofiledg = 1./log(Q_Digi);


T.T_an = real(H.a_an./(1./Tprofilean +H.b_an));
T.T_dg = real(H.a_dg./(1./Tprofiledg +H.b_dg));


T.alt_digi= alt;
T.alt_an = alt_an;

fname = sprintf('%d_%d.mat', date,time);
save(fname,'T')
% Pick a range of altitude where the fitting is done
% Fit and find calibration constants
% Temperature vs Altitude plots


