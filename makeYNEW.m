% this is to read S0.mat files and pick the measurements from 11-11.30pm
% Save the JL,JH,Eb and alt in seperate structure 

function [Y] = makeYNEW(Q)




 date = Q.date_in;
[year,month,day] = getYMDFromDate(date);
 yr = num2str(year);

 % open S0 matfile according to the given date
% datadirS3='/Users/sham/Documents/MATLAB/RALMO_Data/RALMO';%/2011.09.28/Volumes/Sham_RALMO/RALMO_DATA/RALMO_Data
 datadirS3='/Volumes/Sham_RALMO/RALMO_DATA/RALMO_Data/RALMO';
file = 'S0';

%  
% %% Load S3 data files 

% 
 Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day)];
% 
 folderpath = [datadirS3 filesep  Dateofthefolder filesep  file];



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
N2 = S0.Channel(6).Signal(:,starttime:endtime);  
WV = S0.Channel(8).Signal(:,starttime:endtime); 


JL_an = S0.Channel(11).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
JH_an = S0.Channel(3).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
Eb_an = S0.Channel(9).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
N2_an = S0.Channel(5).Signal(:,starttime:endtime);  
WV_an = S0.Channel(7).Signal(:,starttime:endtime); 
JL_an = JL_an';
JH_an = JH_an';
N2_an = N2_an';
WV_an = WV_an';



% MHZ to Counts conversion constant 
Y.binsize = S0.Channel(12).BinSize;
F = 1800.* (Y.binsize./150);
       
% Coadd in time
% Eb= S0.Channel(2).Signal; % this is over night signal
JL = F.*JL; % single scans
JH = F.*JH;
Eb = F.*Eb; % single scans
N2 = F.*N2;
WV = F.*WV;

N = length(JH);

% %% Fix off set 
zAoffset = 10; % bins ie 10*3.75 = 37.5m 
JH= JH(1:N-zAoffset,:); % already in counts ./ (y2HzRaw./1e6);
JL =JL(1:N-zAoffset,:); % ./ (y2HzRaw./1e6);
Eb= Eb(1:N-zAoffset,:); % already in counts ./ (y2HzRaw./1e6);
N2= N2(1:N-zAoffset,:); 
WV= WV(1:N-zAoffset,:); 

JH_an = JH_an(:,1+zAoffset:end);
JL_an = JL_an(:,1+zAoffset:end);
Eb_an = Eb_an(1+zAoffset:end,:);
N2_an = N2_an(:,1+zAoffset:end);
WV_an = WV_an(:,1+zAoffset:end);


alt = alt(1:N-zAoffset);
alt_an = alt_an(1+zAoffset:end);

 %% coaddding 30mints
JL = nansum(JL');
JH = nansum(JH');
Eb = nansum(Eb');
N2 = nansum(N2');
WV = nansum(WV');




    % Analog variance

    bkg_ind = alt>50e3;% & alt<60e3;
    bkg_Lan = mean(JL_an(:,bkg_ind)');
    bkg_Han = mean(JH_an(:,bkg_ind)');
    bkg_N2an = mean(N2_an(:,bkg_ind)');
    bkg_WVan = mean(WV_an(:,bkg_ind)');

    
    % Background removed signal
    for i = 1:length(bkg_Lan)
        JLa(i,:) = JL_an(i,:) - bkg_Lan(i);
        JHa(i,:) = JH_an(i,:) - bkg_Han(i);
        N2a(i,:) = N2_an(i,:) - bkg_N2an(i);
        WVa(i,:) = WV_an(i,:) - bkg_WVan(i);
    end
    

La = JLa(:,alt_an<=8000);
Ha = JHa(:,alt_an<=8000);
N2a = N2a(:,alt_an<=8000);
WVa = WVa(:,alt_an<=8000);


alt_a = alt_an(alt_an<=8000);

for i = 1:length(bkg_Lan)
    [varL(i,:),g] = bobpoissontest(La(i,:),alt_a',Q.b2);
    [varH(i,:),g] = bobpoissontest(Ha(i,:),alt_a',Q.b2);
    [varN2(i,:),g] = bobpoissontest(N2a(i,:),alt_a',Q.b2);
    [varWV(i,:),g] = bobpoissontest(WVa(i,:),alt_a',Q.b2);
end



Ya = nansum(varL);
YYa = nansum(varH);
YYN2a = nansum(varN2);
YYYWVa = nansum(varWV);
% 
r111 = ones(1,g-1).* YYa(1);
r211 = ones(1,g-1).* YYa(end);
r311 = ones(1,g-1).* Ya(1);
r411 = ones(1,g-1).* Ya(end);
YYYa = [r111 YYa  r211];
YYa = [r311 Ya  r411];

[Y.YYYa, zz] = coadd(YYYa, alt_a, Q.coaddalt);
[Y.YYa, zz] = coadd(YYa, alt_a, Q.coaddalt);


r1 = ones(1,g-1).* YYN2a(1);
r2 = ones(1,g-1).* YYN2a(end);
r3 = ones(1,g-1).* YYYWVa(1);
r4 = ones(1,g-1).* YYYWVa(end);
YYYN2a = [r1 YYN2a  r2];
YYWVa = [r3 YYYWVa  r4];

[Y.YYYN2a, zz] = coadd(YYYN2a, alt_a, Q.coaddalt);
[Y.YYWVa, zz] = coadd(YYWVa, alt_a, Q.coaddalt);

JL_an = nansum(JL_an);
JH_an = nansum(JH_an);
Eb_an = nansum(Eb_an');
N2_an = nansum(N2_an);
WV_an = nansum(WV_an);

[JH, JHzc] = coadd(JH, alt, Q.coaddalt);
[JL, JLzc] = coadd(JL, alt, Q.coaddalt);
[N2, N2zc] = coadd(N2, alt, Q.coaddalt);
[WV, WVzc] = coadd(WV, alt, Q.coaddalt);
[Eb, Ebzc] = coadd(Eb, alt, Q.coaddalt);

[JH_an, JHazc] = coadd(JH_an, alt_an, Q.coaddalt);
[JL_an, JLazc] = coadd(JL_an, alt_an, Q.coaddalt);
[N2_an, N2azc] = coadd(N2_an, alt_an, Q.coaddalt);
[WV_an, WVazc] = coadd(WV_an, alt_an, Q.coaddalt);
[Eb_an, Ebazc] = coadd(Eb_an, alt_an, Q.coaddalt);

alt = JHzc;
Alt = JHazc;

% Save in a new mat file
bkg_ind1 = alt>50e3;% & alt<60e3;
bkg_ind2 = Alt>50e3;

% BAckground

% Desaturate and find the true background first
     % 1. Make the Co added counts to avg counts
     JHn = JH./(Q.deltatime.*Q.coaddalt);
     JLn = JL./(Q.deltatime.*Q.coaddalt);
     N2n = N2./(Q.deltatime.*Q.coaddalt);
     WVn = WV./(Q.deltatime.*Q.coaddalt);
     
        % 2. Convert counts to MHz
        JHnwn = (JHn./F);
        JLnwn = (JLn./F);
        N2nwn = (N2n./F);
        WVnwn = (WVn./F);
        
        
        figure;
        subplot(2,2,1)
        semilogx(JLnwn,alt./1000,'b',JHnwn,alt./1000,'r')
        xlabel('Photon Counts (MHz)')
        ylabel('Altitude (km)')
        legend('JL','JH')
        title( Dateofthefolder);
        set(gca,'fontsize',16)
        subplot(2,2,2)
        plot(JL_an./(Q.deltatime.*Q.coaddalt),Alt./1000,'b',JH_an./(Q.deltatime.*Q.coaddalt),Alt./1000,'r')
        xlabel('Analog Signal (mV)')
        ylabel('Altitude (km)')
        legend('JL','JH')
        %   legend('JL - Digital','JH - Digital','Eb - Digital','JL - Analog','JH - Analog')
        title( Dateofthefolder);
        set(gca,'fontsize',16)
        
        subplot(2,2,3)
        semilogx(N2nwn,alt./1000,'b',WVnwn,alt./1000,'r')
        legend('N2','WV')
        xlabel('Photon Counts (MHz)')
        ylabel('Altitude (km)')
        title( Dateofthefolder);
        set(gca,'fontsize',16)
        subplot(2,2,4)
        plot(N2_an./(Q.deltatime.*Q.coaddalt),Alt./1000,'b',WV_an./(Q.deltatime.*Q.coaddalt),Alt./1000,'r')
        xlabel('Analog Signal (mV)')
        ylabel('Altitude (km)')
           legend('N2','WV')
        title( Dateofthefolder);
        set(gca,'fontsize',16)
  
  figure;plot(Eb,Ebzc./1000,'g')
  xlabel('Eb Photon Counts (MHz)') 
  ylabel('Altitude (km)')
        
        % 3. Apply DT correction
        JL_dtc = JLn ./ (1 - JLnwn.*(Q.deadtimeJL.*1e6)); % non-paralyzable
        JH_dtc = JHn ./ (1 - JHnwn.*(Q.deadtimeJH).*1e6);
        N2_dtc = N2n ./ (1 - N2nwn.*(Q.deadtimeJL.*1e6)); % non-paralyzable
        WV_dtc = WVn ./ (1 - WVnwn.*(Q.deadtimeJH).*1e6);



%        % 5. Scale bacl to coadded signal    
JL_DS = JL_dtc.*(Q.deltatime.*Q.coaddalt);
JH_DS = JH_dtc.*(Q.deltatime.*Q.coaddalt);
N2_DS = N2_dtc.*(Q.deltatime.*Q.coaddalt);
WV_DS = WV_dtc.*(Q.deltatime.*Q.coaddalt);


bkg_JL = JL_DS(bkg_ind1);
bkg_JH = JH_DS(bkg_ind1);
bkg_N2 = N2_DS(bkg_ind1);
bkg_WV = WV_DS(bkg_ind1);
bkg_Eb = Eb(bkg_ind1);


bkg_JLan = JL_an(bkg_ind2);
bkg_JHan = JH_an(bkg_ind2);
bkg_N2an = N2_an(bkg_ind2);
bkg_WVan = WV_an(bkg_ind2);
bkg_Eban = Eb_an(bkg_ind2);




%% Digital
bg_JL_std = std(bkg_JL);
bg_JH_std = std(bkg_JH);
bg_N2_std = std(bkg_N2);
bg_WV_std = std(bkg_WV);


bg_JL_v = var(bkg_JL);
bg_JH_v= var(bkg_JH);
bg_N2_v = var(bkg_N2);
bg_WV_v= var(bkg_WV);


bg_JL = nanmean(bkg_JL);
bg_JH = nanmean(bkg_JH);
bg_N2 = nanmean(bkg_N2);
bg_WV = nanmean(bkg_WV);

bg_Eb = nanmean(bkg_Eb);

bg_length1 = length(bkg_JH);
bg_length2 = length(bkg_JL);
bg_length3 = length(bkg_N2);
bg_length4 = length(bkg_WV);


%% Analog
bg_JLan_std = std(bkg_JLan);
bg_JHan_std = std(bkg_JHan);
bg_N2an_std = std(bkg_N2an);
bg_WVan_std = std(bkg_WVan);

bg_JLan_v = var(bkg_JLan);
bg_JHan_v= var(bkg_JHan);
bg_N2an_v = var(bkg_N2an);
bg_WVan_v= var(bkg_WVan);

bg_JLan = nanmean(bkg_JLan);
bg_JHan = nanmean(bkg_JHan);
bg_N2an = nanmean(bkg_N2an);
bg_WVan = nanmean(bkg_WVan);

bg_Eban= nanmean(bkg_Eban);

bg_length1an = length(bkg_JHan);
bg_length2an = length(bkg_JLan);
bg_length3an = length(bkg_N2an);
bg_length4an = length(bkg_WVan);

%% Digital
Y.JL = JL ;
Y.JH = JH ;
Y.N2 = N2 ;
Y.WV = WV ;
Y.Eb = Eb;


Y.JL_DS = JL_DS;
Y.JH_DS = JH_DS;
Y.N2_DS = N2_DS;
Y.WV_DS = WV_DS;

Y.Ebalt = Ebzc;
Y.alt = alt;

Y.bgJL = bg_JL;
Y.bgJH = bg_JH;
Y.bgN2 = bg_N2;
Y.bgWV = bg_WV;
Y.bgEb = bg_Eb;

Y.bg_JL_std = bg_JL_std ;
Y.bg_JH_std = bg_JH_std ;
Y.bg_N2_std = bg_N2_std ;
Y.bg_WV_std = bg_WV_std ;

Y.bg_length1 = bg_length1;
Y.bg_length2 = bg_length2;
Y.bg_length3 = bg_length3;
Y.bg_length4 = bg_length4;

%% analog
Y.JLa = JL_an ;
Y.JHa = JH_an ;
Y.N2a = N2_an ;
Y.WVa = WV_an ;
Y.Eba = Eb_an;

Y.bgJLa = bg_JLan;
Y.bgJHa = bg_JHan;
Y.bgN2a = bg_N2an;
Y.bgWVa = bg_WVan;

Y.bg_JL_stda = bg_JLan_std ;
Y.bg_JH_stda = bg_JHan_std ;
Y.bg_N2_stda = bg_N2an_std ;
Y.bg_WV_stda = bg_WVan_std ;

Y.bg_length1a = bg_length1an;
Y.bg_length2a = bg_length2an;
Y.bg_length3a = bg_length3an;
Y.bg_length4a = bg_length4an;
Y.alt_an = Alt;
Y.F = F;

Y.Dateofthefolder  = Dateofthefolder ;

% save('data.mat','-struct','Y');
