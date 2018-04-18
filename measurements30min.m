% this is to read S0.mat files and pick the measurements from 11-11.30pm
% Save the JL,JH,Eb and alt in seperate structure 

function [Y] = measurements30min(date)




%  date = Q.date_in;
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

load(folderpath);

% Display the start and end times of the lidar measurment
% disp('Start time')
g = hour(S0.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
Minute = minute(S0.GlobalParameters.Start);%(S0.GlobalParameters.Start.FastCom  );
% tin =Q.time_in;
% from 2300 to 2330
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
%% Load the analog channel measurements too 
% figure;
%   hold on;


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
Y.JH= JH(1:N-zAoffset,:); % already in counts ./ (y2HzRaw./1e6);
Y.JL =JL(1:N-zAoffset,:); % ./ (y2HzRaw./1e6);
Y.Eb= Eb(1:N-zAoffset,:); % already in counts ./ (y2HzRaw./1e6);
Y.JH_an = JH_an(:,1+zAoffset:end);
Y.JL_an = JL_an(:,1+zAoffset:end);
Y.Eb_an = Eb_an(:,1+zAoffset:end);
Y.alt = alt(1:N-zAoffset);
Y.alt_an = alt_an(1+zAoffset:end);

for i = 1:length(Y.alt_an)
[Y.ACFJL(:,i),Y.LagsJL] = autocorr(Y.JL_an(:,i),29);
[Y.ACFJH(:,i),Y.LagsJH] = autocorr(Y.JH_an(:,i),29);
[Y.ACFJLd(i,:),Y.LagsJLd] = autocorr(Y.JL(i,:),29);
[Y.ACFJHd(i,:),Y.LagsJHd] = autocorr(Y.JH(i,:),29);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% vaJL_12km = nansum(Y.JL(3200,:)')

% Find variance at each height

for i =1:length(Y.alt_an)
    Variance_JLa(i) = var(Y.JL_an(:,i));
    Variance_JHa(i) = var(Y.JH_an(:,i));

end


% Covariance 

 for i =1:length(Y.alt_an)
    CovVariance_JLa(:,i) =   Y.ACFJL(:,i).*Variance_JLa(i);
    CovVariance_JHa(:,i) =   Y.ACFJH(:,i).*Variance_JHa(i);

 end   

figure;
subplot(2,2,1)
plot(Y.LagsJL,CovVariance_JLa(:,257),Y.LagsJL,CovVariance_JLa(:,524),Y.LagsJL,CovVariance_JLa(:,790),Y.LagsJL,CovVariance_JLa(:,1057),Y.LagsJL,CovVariance_JLa(:,1324),Y.LagsJL,CovVariance_JLa(:,1590))
xlabel('Lag')
ylabel('ACF _ JL _ analog')
legend('1km','2km','3km','4km','5km','6km')
title( Dateofthefolder);
set(gca,'fontsize',16)


subplot(2,2,2)
plot(Y.LagsJH, CovVariance_JHa(:,257),Y.LagsJH, CovVariance_JHa(:,524),Y.LagsJH, CovVariance_JHa(:,790),Y.LagsJH, CovVariance_JHa(:,1057),Y.LagsJH, CovVariance_JHa(:,1324),Y.LagsJH, CovVariance_JHa(:,1590))
xlabel('Lag')
ylabel('ACF _ JH _ analog')
legend('1km','2km','3km','4km','5km','6km')
title( Dateofthefolder);
set(gca,'fontsize',16)

subplot(2,2,3)
semilogx((CovVariance_JLa(1,:))./30,Y.alt_an./1000)
xlabel('Cov JL analog')
ylabel('alt ')

subplot(2,2,4)
semilogx((CovVariance_JHa(1,:))./30,Y.alt_an./1000) 
 xlabel('Cov JH analog')
ylabel('alt')
 %%
% Y.varJL = nansum(Y.JL');
% 
% Y.ACFJL_12km = Y.ACFJL(:,3200);
% Y.varACF = 1./Y.ACFJL_12km;
% disp('Digital Variance at 12km_Measurements ')
% Y.varJL(3200)
% 
% disp('Digital Variance at 12km_ACF')
% Y.varACF(1)

% figure;
% subplot(1,2,1)
% plot(Y.LagsJL,Y.ACFJL_12km)
% subplot(1,2,2)
% plot(Y.LagsJL,1./Y.ACFJL_12km)



% figure;
% subplot(2,2,1)
% plot(Y.LagsJL,Y.ACFJL(:,257),Y.LagsJL,Y.ACFJL(:,524),Y.LagsJL,Y.ACFJL(:,790),Y.LagsJL,Y.ACFJL(:,1057),Y.LagsJL,Y.ACFJL(:,1324),Y.LagsJL,Y.ACFJL(:,1590))
% xlabel('Lag')
% ylabel('ACF _ JL _ analog')
% legend('1km','2km','3km','4km','5km','6km')
% title( Dateofthefolder);
% set(gca,'fontsize',16)
% 
% 
% subplot(2,2,2)
% plot(Y.LagsJH,Y.ACFJH(:,257),Y.LagsJH,Y.ACFJH(:,524),Y.LagsJH,Y.ACFJH(:,790),Y.LagsJH,Y.ACFJH(:,1057),Y.LagsJH,Y.ACFJH(:,1324),Y.LagsJH,Y.ACFJH(:,1590))
% xlabel('Lag')
% ylabel('ACF _ JH _ analog')
% legend('1km','2km','3km','4km','5km','6km')
% title( Dateofthefolder);
% set(gca,'fontsize',16)


% subplot(2,2,3)
% plot(Y.LagsJLd,Y.ACFJLd(267,:),Y.LagsJLd,Y.ACFJLd(534,:),Y.LagsJLd,Y.ACFJLd(800,:),Y.LagsJLd,Y.ACFJLd(1067,:),Y.LagsJLd,Y.ACFJLd(1334,:),Y.LagsJLd,Y.ACFJLd(1600,:))
% xlabel('Lag')
% ylabel('ACF _ JL _ digital')
% legend('1km','2km','3km','4km','5km','6km')
% title( Dateofthefolder);
% set(gca,'fontsize',16)
% 
% 
% subplot(2,2,4)
% plot(Y.LagsJHd,Y.ACFJHd(267,:),Y.LagsJHd,Y.ACFJHd(534,:),Y.LagsJHd,Y.ACFJHd(800,:),Y.LagsJHd,Y.ACFJHd(1067,:),Y.LagsJHd,Y.ACFJHd(1334,:),Y.LagsJHd,Y.ACFJHd(1600,:))
% xlabel('Lag')
% ylabel('ACF _ JH_ digital')
% legend('1km','2km','3km','4km','5km','6km')
% title( Dateofthefolder);
% set(gca,'fontsize',16)
% 
% Y.bajl = nanmean(Y.ACFJL(:,1:1590)');
% Y.bdjl = nanmean(Y.ACFJL(:,1600,:)');
% Y.bajh = nanmean(Y.ACFJH(:,1:1590)');
% Y.bdjh = nanmean(Y.ACFJH(:,1600,:)');
% 
% figure;subplot(1,2,1)
% plot(Y.LagsJHd,Y.bajl,Y.LagsJHd,Y.bdjl)
% legend('analog jl','digital jl')
% subplot(1,2,2)
% plot(Y.LagsJHd,Y.bajh,Y.LagsJHd,Y.bdjh)
% legend('analog jh','digital jh')

%%
% Y.YYa = (std(JL_an)).^2;
% Y.YYYa = (std(JH_an)).^2;


%  %% coaddding 30mints
% JL = nansum(JL');
% JH = nansum(JH');
% Eb = nansum(Eb');
% 
% JL_an = nansum(JL_an);
% JH_an = nansum(JH_an);
% Eb_an = nansum(Eb_an');

% N = length(JH);
% 
% % %% Fix off set 
% zAoffset = 10; % bins ie 10*3.75 = 37.5m 
% JH= JH(1:N-zAoffset); % already in counts ./ (y2HzRaw./1e6);
% JL =JL(1:N-zAoffset); % ./ (y2HzRaw./1e6);
% Eb= Eb(1:N-zAoffset); % already in counts ./ (y2HzRaw./1e6);
% JH_an = JH_an(1+zAoffset:end);
% JL_an = JL_an(1+zAoffset:end);
% Eb_an = Eb_an(1+zAoffset:end);
% alt = alt(1:N-zAoffset);
% alt_an = alt_an(1+zAoffset:end);
% 
%             figure;semilogx(JL,alt./1000,'b',JH,alt./1000,'r',JL_an,alt./1000,'g',JH_an,alt./1000,'y')%,Eb,Ebzc./1000,'g')
%             xlabel('30min Coadded signal (Counts/bin/time)')
%             ylabel('Alt (km)')
%             legend('JL','JH','JL an','JH an')

% Coadd in alt



% [JH, JHzc] = coadd(JH, alt, Q.coaddalt);
% [JL, JLzc] = coadd(JL, alt, Q.coaddalt);
% [Eb, Ebzc] = coadd(Eb, alt, Q.coaddalt);
% 
% [JH_an, JHazc] = coadd(JH_an, alt_an, Q.coaddalt);
% [JL_an, JLazc] = coadd(JL_an, alt_an, Q.coaddalt);
% [Eb_an, Ebazc] = coadd(Eb_an, alt_an, Q.coaddalt);
% 
% alt = JHzc;
% Alt = JHazc;
% 
%   figure;
%   semilogx(JL,alt./1000,'b',JH,alt./1000,'r',Eb,Ebzc./1000,'g',JL_an,Alt./1000,'y',JH_an,Alt./1000,'black') 
%   xlabel('30min Coadded signal') 
%   xlabel('30min Coadded signal')
%   ylabel('Altitude (km)')
%   legend('JL - Digital','JH - Digital','Eb - Digital','JL - Analog','JH - Analog')
%   
% % Save in a new mat file
% bkg_ind1 = alt>50e3;% & alt<60e3;
% bkg_ind2 = Alt>50e3;
% % bkg_ind3 = Alt>8e3 & Alt<12e3;
% % [JLwithoutBG,bkg_JL] = CorrBkg(JL, sum(bkg_ind), 0, 1);
% % [JHwithoutBG,bkg_JH]  = CorrBkg(JH, sum(bkg_ind), 0, 1);
% 
% % BAckground
% 
% % Desaturate and find the true background first
%      % 1. Make the Co added counts to avg counts
%         JHn = JH./(Q.deltatime.*Q.coaddalt);
%         JLn = JL./(Q.deltatime.*Q.coaddalt);
%         
%         % 2. Convert counts to MHz
%         JHnwn = (JHn./F);
%         JLnwn = (JLn./F);
% 
%         
%         % 3. Apply DT correction
%         JL_dtc = JLn ./ (1 - JLnwn.*(Q.deadtimeJL.*1e6)); % non-paralyzable
%         JH_dtc = JHn ./ (1 - JHnwn.*(Q.deadtimeJH).*1e6);
% 
% % %           % 4. Convert to counts
% %            JLC = JL_dtc.*(1./Q.f);
% %            JHC = JH_dtc.*(1./Q.f);
% 
% %        % 5. Scale bacl to coadded signal    
%        JL_DS = JL_dtc.*(Q.deltatime.*Q.coaddalt);
%        JH_DS = JH_dtc.*(Q.deltatime.*Q.coaddalt);
%        
% 
% 
% bkg_JL = JL_DS(bkg_ind1);
% bkg_JH = JH_DS(bkg_ind1);
% bkg_Eb = Eb(bkg_ind1);
% 
% 
% bkg_JLan = JL_an(bkg_ind2);
% bkg_JHan = JH_an(bkg_ind2);
% bkg_Eban = Eb_an(bkg_ind2);
% 
% % JLnew = JL-bkg_JL;
% % JHnew = JH-bkg_JH;
% 
% 
% %% Digital
% bg_JL_std = std(bkg_JL);
% bg_JH_std = std(bkg_JH);
% bg_JL_v = var(bkg_JL);
% bg_JH_v= var(bkg_JH);
% bg_JL = nanmean(bkg_JL);
% bg_JH = nanmean(bkg_JH);
% bg_Eb = nanmean(bkg_Eb);
% 
% bg_length1 = length(bkg_JH);
% bg_length2 = length(bkg_JL);
% 
% %% Analog
% bg_JLan_std = std(bkg_JLan);
% bg_JHan_std = std(bkg_JHan);
% bg_JLan_v = var(bkg_JLan);
% bg_JHan_v= var(bkg_JHan);
% bg_JLan = nanmean(bkg_JLan);
% bg_JHan = nanmean(bkg_JHan);
% bg_Eban= nanmean(bkg_Eban);
% 
% bg_length1an = length(bkg_JHan);
% bg_length2an = length(bkg_JLan);
% %%
% %    findBH = find(zzN > zHback);
% %     backHA = mean(SHcoaddA(findBH(1):end)-in.Aoffset);
% %     findBN = find(zzN > zNback);
% %     backNA = mean(SNcoaddA(findBN(1):end)-in.Aoffset);
% %     if in.varAVA
% %         backVarHA = (std(SHcoaddA(findBH(1):end)-in.Aoffset)...
% %          ./ sqrt(length(SHcoaddA(findBH(1):end)))).^2;
% %         backVarNA = (std(SNcoaddA(findBN(1):end)-in.Aoffset)...
% %          ./ sqrt(length(SNcoaddA(findBN(1):end)))).^2;
% %     else
% %         backVarHA = (std(SHcoaddA(findBH(1):end)-in.Aoffset)).^2;
% %         backVarNA = (std(SNcoaddA(findBN(1):end)-in.Aoffset)).^2;
% %     end
% % JLanwithoutBG = JL_an-bg_JLan;
% % JHanwithoutBG = JH_an-bg_JHan;
% % EbanwithoutBG = Eb_an-bg_Eban;
% % 
% %   figure;semilogx(JL,alt./1000,'b',JH,alt./1000,'r')%,Eb,Ebzc./1000,'g') 
% %   xlabel('Photon Counts')
% %   ylabel('Alt (km)')
% %   legend('JL','JH')
% % hold on;
% %         
% %     figure;subplot(1,2,1)
% %     semilogx(JL_an,Ebazc./1000,'m',JH_an,Ebazc./1000,'black',Eb_an,Ebazc./1000,'r')
% %     subplot(1,2,2)
% %     semilogx(Eb,alt./1000,'r',JL,alt./1000,'b',JH,alt./1000,'g')
% 
% %% Digital
% Y.JL = JL ;
% Y.JH = JH ;
% Y.Eb = Eb;
% Y.JL_DS = JL_DS;
% Y.JH_DS = JH_DS;
% Y.Ebalt = Ebzc;
% Y.alt = alt;
% Y.bgJL = bg_JL;
% Y.bgJH = bg_JH;
% Y.bgEb = bg_Eb;
% Y.bg_JL_std = bg_JL_std ;
% Y.bg_JH_std = bg_JH_std ;
% Y.bg_length1 = bg_length1;
% Y.bg_length2 = bg_length2;
% 
% %% analog
% Y.JLa = JL_an ;
% Y.JHa = JH_an ;
% Y.Eba = Eb_an;
% Y.bgJLa = bg_JLan;
% Y.bgJHa = bg_JHan;
% Y.bg_JL_stda = bg_JLan_std ;
% Y.bg_JH_stda = bg_JHan_std ;
% Y.bg_length1a = bg_length1an;
% Y.bg_length2a = bg_length2an;
% Y.alt_an = Alt;
% Y.F = F;
% 
% % save('data.mat','-struct','Y');
