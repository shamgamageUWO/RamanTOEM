%% RALMO Traditional Temperature new code 
%% All channels are added
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load S0 and S3 mat files for the date needed
datadirS0='/Users/sham/Desktop';
% datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
file1 = 'S0';
folderpath1 = [datadirS0 filesep  file1];

datadirS3='/Users/sham/Desktop';
% datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
file = 'S3';
folderpath = [datadirS3 filesep  file];

load(folderpath1);
load(folderpath);


alt =  S0.Channel(4).Range;
alt_an = S0.Channel(11).Range ; % Note alt = alt_an
%% Load the analog channel measurements too 
% figure;
%   hold on;


JL = S0.Channel(12).Signal(:,1347:1377);%(:,961:990);
JH = S0.Channel(4).Signal(:,1347:1377);%(:,961:990);
Eb= S0.Channel(10).Signal(:,1347:1377);%(:,961:990);



JL_an = S0.Channel(11).Signal(:,1347:1377);%(:,961:990);
JH_an = S0.Channel(3).Signal(:,1347:1377);%(:,961:990);
Eb_an = S0.Channel(9).Signal(:,1347:1377);%(:,961:990);

JL_an = JL_an';
JH_an = JH_an';

JL_Com = S3.JL.Combined.Signal(:,1347:1377);%(:,118:147);
JH_Com = S3.JH.Combined.Signal(:,1347:1377);%(:,118:147);
Eb_Com = S3.Eb.Combined.Signal(:,1347:1377);%(:,118:147);
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

% Deadtime correction for the digital and combined signal Not neccessary as
% we take the ratios

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

% %% Fix off set 
 zAoffset = 10; % bins ie 10*3.75 = 37.5m 
% % JH= JH(1:N-zAoffset); % already in counts ./ (y2HzRaw./1e6);
% % JL =JL(1:N-zAoffset); % ./ (y2HzRaw./1e6);
% % Eb= Eb(1:N-zAoffset); % already in counts ./ (y2HzRaw./1e6);
JH_an = JH_an(1+zAoffset:end);
JL_an = JL_an(1+zAoffset:end);
Eb_an = Eb_an(1+zAoffset:end);
% % alt = alt(1:N-zAoffset);
alt_an = alt_an(1+zAoffset:end);

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

% Remove background
bkg_ind1 = alt>50e3;% & alt<60e3;
bkg_ind2 = alt_an>10e3;
bkg_ind3 = Alt>50e3;

bkg_JL = JL(bkg_ind1);
bkg_JH = JH(bkg_ind1);
bkg_Eb = Eb(bkg_ind1);


bkg_JLan = JL_an(bkg_ind2);
bkg_JHan = JH_an(bkg_ind2);
bkg_Eban = Eb_an(bkg_ind2);

bkg_JL_Com = JL_Com (bkg_ind3);
bkg_JH_Com  = JH_Com (bkg_ind3);
bkg_Eb_Com  = Eb_Com (bkg_ind3);


bg_JL = nanmean(bkg_JL);
bg_JH = nanmean(bkg_JH);
bg_Eb = nanmean(bkg_Eb);
bg_JLan = nanmean(bkg_JLan);
bg_JHan = nanmean(bkg_JHan);
bg_Eban= nanmean(bkg_Eban);


%% Define ratios

JH = JH-bg_JH;
JL = JL-bg_JL;

JH_an = JH_an-bg_JHan;
JL_an = JL_an-bg_JLan;


Q_Digi = JH./JL;
Q_an = JH_an./JL_an;
Q_Com = JH_Com./JL_Com;

Q_Digi = log(Q_Digi);
Q_an = log(Q_an);
Q_Com = log(Q_Com);

[Tsonde,Zsonde,Psonde] = get_sonde_RS92(20120718,00);

% figure;plot(Tsonde,Zsonde,'g')
Zsonde = Zsonde-491;

T_digi = interp1(Zsonde,Tsonde,alt,'linear');
T_an = interp1(Zsonde,Tsonde,alt_an,'linear');
T_Com = interp1(Zsonde,Tsonde,Alt,'linear');


% figure;plot(Q_Digi,(1./T_digi),'r',Q_an,(1./T_an),'b',Q_Com,(1./T_Com),'g')
y_d = (1./T_digi);
y_d = y_d( alt>=8000 & alt<=10000);
x_d = Q_Digi( alt>=8000 & alt<=10000);

y_a = (1./T_an);
y_a = y_a( alt_an>=1000 & alt_an<=2000);
x_a = Q_an( alt_an>=1000 & alt_an<=2000);

y_c = (1./T_Com);
y_c = y_c( Alt>=8000 & Alt<=10000);
x_c = Q_Com( Alt>=8000 & Alt<=10000);

[f_d,gofd] = fit(x_d,y_d,'poly1');
[f_a,gofa] = fit(x_a,y_a,'poly1');
[f_c,gofc] = fit(x_c,y_c,'poly1');

figure;
subplot(1,3,1);plot(f_d,x_d,y_d)
subplot(1,3,2);plot(f_c,x_c,y_c)
subplot(1,3,3);plot(f_a,x_a,y_a)

A_d = -0.002158;%f_d(1);
B_d =  0.001631;%f_d(2);

A_c = f_c(1);
B_c = f_c(2);

A_a = f_a(1);
B_a = f_a(2);



T_lidar_d = 1./(Q_Digi.*A_d+ B_d) ;
T_lidar_c =  1./(Q_Com.*A_c+ B_c);
T_lidar_a =  1./(Q_an.*A_a+ B_a);

% Pick a range of altitude where the fitting is done
% Fit and find calibration constants
% Temperature vs Altitude plots


