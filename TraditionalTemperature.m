function H = TraditionalTemperature(date,time)
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

filename = 'S3.mat';
folderpath = [datadirS3 filesep  Dateofthefolder filesep filename];
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
load(folderpath);


g = hour(S0.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
Minute = minute(S0.GlobalParameters.Start);%(S0.GlobalParameters.Start.FastCom  );

% from 2300 to 2330
starttime=find(g==23 & Minute==00);
endtime=find(g==23 & Minute==30);

g1 = hour(S3.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
Minute1 = minute(S3.GlobalParameters.Start);%(S0.GlobalParameters.Start.FastCom  );
% from 2300 to 2330
starttime1=find(g1==23 & Minute1==00);
endtime1=find(g1==23 & Minute1==30);

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

JL_Com = S3.JL.Combined.Signal(:,starttime1:endtime1);
JH_Com = S3.JH.Combined.Signal(:,starttime1:endtime1);%;(:,1347:1377)
Eb_Com = S3.Eb.Combined.Signal(:,starttime1:endtime1);
alt_Com = S3.JL.Combined.Range;


% MHZ to Counts conversion constant 
Y.binsize = S0.Channel(12).BinSize;
F = 1800.* (Y.binsize./150);


% Coadd in time
JL = F.*JL; % single scans
JH = F.*JH;
Eb = F.*Eb; % single scans
JL_Com = F.*JL_Com; % single scans
JH_Com = F.*JH_Com;
Eb_Com = F.*Eb_Com; % single scans


 %% coaddding 30mints
JL = nansum(JL');
JH = nansum(JH');
Eb = nansum(Eb');

JL_Com = nansum(JL_Com');
JH_Com = nansum(JH_Com');
Eb_Com = nansum(Eb_Com');

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

coaddalt = 10;
[JH, JHzc] = coadd(JH, alt, coaddalt);
[JL, JLzc] = coadd(JL, alt, coaddalt);
[Eb, Ebzc] = coadd(Eb, alt, coaddalt);

[JH_Com, JHzc_Com] = coadd(JH_Com, alt_Com, coaddalt);
[JL_Com, JLzc_Com] = coadd(JL_Com, alt_Com, coaddalt);
[Eb_Com, Ebzc_Com] = coadd(Eb_Com, alt_Com, coaddalt);

[JH_an, JHazc] = coadd(JH_an, alt_an, coaddalt);
[JL_an, JLazc] = coadd(JL_an, alt_an, coaddalt);
[Eb_an, Ebazc] = coadd(Eb_an, alt_an, coaddalt);

alt = JHzc;
alt_an = JHazc;
Alt = JHzc_Com;


% Deadtime correction for the digital and combined signal Not neccessary as
% we take the ratios
% Desaturate and find the true background first
     % 1. Make the Co added counts to avg counts
        JHn = JH./(30.*coaddalt);
        JLn = JL./(30.*coaddalt);
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
       JL_DS = JL_dtc.*(30.*coaddalt);
       JH_DS = JH_dtc.*(30.*coaddalt);
%        JL_DScm = JL_dtcm.*(30.*coaddalt);
%        JH_DScm = JH_dtcm.*(30.*coaddalt);
% Remove background
bkg_ind1 = alt>50e3;% & alt<60e3;
bkg_ind2 = alt_an>10e3;
bkg_ind3 = Alt>50e3;

bkg_JL =  JL_DS (bkg_ind1);
bkg_JH =  JH_DS (bkg_ind1);
bkg_Eb = Eb(bkg_ind1);


bkg_JLan = JL_an(bkg_ind2);
bkg_JHan = JH_an(bkg_ind2);
bkg_Eban = Eb_an(bkg_ind2);

bkg_JL_Com =  JL_Com(bkg_ind3);
bkg_JH_Com  = JH_Com(bkg_ind3);
bkg_Eb_Com  = Eb_Com (bkg_ind3);


bg_JL = nanmean(bkg_JL);
bg_JH = nanmean(bkg_JH);
bg_Eb = nanmean(bkg_Eb);

bg_JLcm = nanmean(bkg_JL_Com);
bg_JHcm = nanmean(bkg_JH_Com);


bg_JLan = nanmean(bkg_JLan);
bg_JHan = nanmean(bkg_JHan);
bg_Eban= nanmean(bkg_Eban);


%% Define ratios

JH = JH_DS-bg_JH;
JL = JL_DS-bg_JL;

JH_an = JH_an-bg_JHan;
JL_an = JL_an-bg_JLan;


JH_cm = JH_Com-bg_JHcm;
JL_cm = JL_Com-bg_JLcm;




Q_Digi = JL./JH;
Q_an = JL_an./JH_an;
Q_Com = JL_cm./JH_cm;

Tprofilean = 1./log(Q_an);
Tprofiledg = 1./log(Q_Digi);
Tprofilecm = 1./log(Q_Com);

[Tsonde,Zsonde,Psonde] = get_sonde_RS92(date,time);

% figure;plot(Tsonde,Zsonde,'g')
Zsonde = Zsonde-491;

% Zsonde = Zsonde(Zsonde>=3);
% Tsonde = Zsonde(Zsonde>=3);
T_digi = interp1(Zsonde,Tsonde,alt,'linear');
T_an = interp1(Zsonde,Tsonde,alt_an,'linear');
T_Com = interp1(Zsonde,Tsonde,Alt,'linear');


% figure;plot(Q_Digi,(1./T_digi),'r',Q_an,(1./T_an),'b',Q_Com,(1./T_Com),'g')
y_d = (T_digi);
y_d = y_d( alt>=3000 & alt<=6000);
x_d = 1./Tprofiledg( alt>=3000 & alt<=6000);

y_a = (T_an);
y_a = y_a( alt_an>=1000 & alt_an<=2000);
x_a = 1./Tprofilean( alt_an>=1000 & alt_an<=2000);


y_c = (T_Com);
y_c = y_c( Alt>=3000 & Alt<=6000);
x_c = 1./Tprofilecm( Alt>=3000 & Alt<=6000);






ftan=fittype('a/(x+b)','dependent',{'y'},'independent',{'x'},'coefficients',{'a','b'});
foan = fitoptions('method','NonlinearLeastSquares','Robust','On');
set(foan, 'StartPoint',[350, 0.3]);

ftdg=fittype('a/(x+b)','dependent',{'y'},'independent',{'x'},'coefficients',{'a','b'});
fodg = fitoptions('method','NonlinearLeastSquares','Robust','On');
set(fodg, 'StartPoint',[350, 0.3]);

ftcm=fittype('a/(x+b)','dependent',{'y'},'independent',{'x'},'coefficients',{'a','b'});
focm = fitoptions('method','NonlinearLeastSquares','Robust','On');
set(focm, 'StartPoint',[350, 0.3]);


[f_a,gofa] = fit(x_a,y_a,ftan,foan);
a_an = f_a.a;
b_an = f_a.b;

[f_dg,gofdg] = fit(x_d,y_d,ftdg,fodg);
a_dg = f_dg.a;
b_dg = f_dg.b;


[f_cm,gofcm] = fit(x_c,y_c,ftcm,focm);
a_cm = f_cm.a;
b_cm = f_cm.b;

H.T_an = real(a_an./(1./Tprofilean +b_an));
H.T_dg = real(a_dg./(1./Tprofiledg +b_dg));
H.T_cm = real(a_cm./(1./Tprofilecm +b_cm));


% figure;
% subplot(1,3,1);plot(f_dg,x_d,y_d)
% subplot(1,3,2);plot(f_cm,x_c,y_c)
% subplot(1,3,3);plot(f_a,x_a,y_a)


figure;plot(Tsonde,Zsonde./1000,'r',H.T_an(alt_an<=10000),alt_an(alt_an<=10000)./1000,'b',H.T_dg(alt<=30000),alt(alt<=30000)./1000,'g',H.T_cm(Alt<=30000),Alt(Alt<=30000)./1000,'y')
xlabel('Temperature (K)')
ylabel('Altitude (km)')
legend('Tsonde','T analog','T digital','T Combined')



H.alt_digi= alt;
H.alt_an = alt_an;
H.alt_com = Alt;

% Pick a range of altitude where the fitting is done
% Fit and find calibration constants
% Temperature vs Altitude plots


