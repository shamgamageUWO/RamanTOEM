% this is first get S3 file with asr content
function [alphaAer] = asrSham(Q)
% first load S3.mat 

% % open S0 matfile according to the given date
% datadirS3='/Users/sham/Desktop';
% % datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
% file = 'S3';
% folderpath = [datadirS3 filesep  file];
% load(folderpath);
date = Q.date_in;
[year,month,day] = getYMDFromDate(date);
 yr = num2str(year);
 datadirS3 = '/Users/sham/Documents/MATLAB/RALMO_Data/RALMO';
% 
 cleanmacpollution(datadirS3); % this is to remove DS_store.dat files from the data folder
% 
 Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day)];
% 
filename = 'S3.mat';
folderpath = [datadirS3 filesep  Dateofthefolder filesep filename];
load(folderpath);

% now run the config file
config = setup('adt.conf');
 config.t0 = datenum (['20170921'], 'yyyymmdd'); % needto change daily
config = getCalibration(config);

% Now run the aerosol code
asr =AerosolScatteringRatio03(S3,config );

%% 
% Load beta molecular values here 
% Max's Codes ( all are now in the same directory as QpackSham)
zN = Q.Zmes;
% P = Q.Psonde;
% T = Q.Tsonde;
P = Q.Pdigi;%Q.Pressi;
T = Q.Ti;
lambda_rec= 354.7; % nm
lambda_em = 354.7;

[alpha_mol,beta_mol,lidar_signal,beta_att,density]=get_rayleigh_v3(zN,P,T,lambda_rec,lambda_em);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% These from BOB- WVOEM.m
in.LRfree = 50; % was 20 on 0305, 0308 50, 200905-6 50
in.LRpbl = 80; % 50 on 0305; was 80 on otherwise
in.LRtranHeight = 2000; % this is the height to the BL
% inputs for ralmo data
in.go = 3; % plus/minus in.go points in pieceWise
in.slope = 34; %30.14; %35; % 2015 37.88; 34 is adhoc, (30+38)/2
in.slopeA = in.slope ./ 3; % 3 is nominal, not accurate 2.75; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% These lines are from BOB - WV - makeQ.m

asrDATA = interp1(asr.z,asr.profile,zN,'linear');
flow = find(zN < asr.z(1));
if ~isempty(flow)
 asrDATA(flow) = asrDATA(flow(end)+1);
end
fhi = find(zN > asr.z(end));
if ~isempty(fhi)
  asrDATA(fhi) = 1;
end


LR = in.LRfree * ones(size(asrDATA));
fff = find(zN < in.LRtranHeight);
LR(fff) = in.LRpbl;
asrDATAs = smooth(asrDATA,5); %asrDATA; %smooth(asrDATA,90); %was 45

% Find the minimum value of the distribution and make it 1;
% all the points above the minimum should go to 1 and below minimum needed
% to be shifted by the difference of 1- min


% legend('raw asr','Interpolated asr','smoothen asr')

[fneg,I] = min(asrDATAs);
% diff = 1-fneg;
asrDATAnew = asrDATAs./fneg;
% figure;plot(asr.profile,(asr.z)./1000,'r',asrDATA,Q.Zmes./1000,'b',asrDATAs,Q.Zmes./1000,'g',asrDATAnew,Q.Zmes./1000,'y')
% hold on;

    for i = 1:length(Q.Zmes)
        if Q.Zmes(i) >= 50

            asrDATAnew(i) = 1;
        end
    end
% remove the comments later
%%%%%%%%%%%%%







% plot(asrDATAnew,Q.Zmes./1000,'m')
% ylabel( 'Alt (km)' )
% xlabel ( ' Aerosol')
% legend('raw asr','Interpolated asr','smoothen asr','fixed values')
% 
% hold off;
%         for i = 1: length(asrDATAs)
%             if i == I
%                 asrDATAs(i) = 1;
% 
%             elseif  i < I
%                 asrDATAs(i) = diff + asrDATAs(i);
    % else
    %     asrDATAs(i) = 1;
    % % elseif i > I
    % % asrDATAs(i) = diff + asrDATAs(i);
% % end
% % 
% % end
% % fneg = find(asrDATAs < 1);
    % asrDATAs(fneg) = 1;

alphaAer = LR' .* (beta_mol .* (asrDATAnew-1));
% znoAer = find(zN > 15000); % was 3000 for 20130122
znoAer = find( asrDATAnew ==1);
alphaAer(znoAer) = 1e-12;
% figure;semilogx(alphaAer,Q.Zmes./1000)

%     % alphaCorErr = 0;
%     % z0 = 0:.1:zN(1);
%     % alpha0 = alphaAer(1) .* ones(size(z0));
%     % odnorm = trapz(z0,alpha0);
%     % odAer = cumtrapz(zN,alphaAer) + odnorm; 
%     % odAerH = cumtrapz(zN,alphaAer.*lambda./lambdaH) + odnorm;
%     % odAerN = cumtrapz(zN,alphaAer.*lambda./lambdaN) + odnorm;
%     % % note in v11 we don't include the bit from the ground up in odAer,
%     % % it is in the retrieved "C*tau"
%     % z0A = 0:.1:zNA(1);
%     % alpha0A = alphaAerA(1) .* ones(size(z0A));
%     % odnormA = trapz(z0A,alpha0A);
%     % odAerA = cumtrapz(zNA,alphaAerA) + odnormA; 
%     % odAerHA = cumtrapz(zNA,alphaAerA.*lambda./lambdaH) + odnormA;
%     % odAerNA = cumtrapz(zNA,alphaAerA.*lambda./lambdaN) + odnormA;
% 
% figure
% subplot(1,2,1)
% plot(asrDATAs,zN./1000,'r')
% xlabel 'ASR (\beta_{tot}/\beta_{mol})'
% ylabel 'Altitude (km)'
% 
% subplot(1,2,2)
% plot(alphaAer,zN./1000,'r');
% xlabel 'Aerosol Extinction (m^{-1})'
% ylabel 'Altitude (km)'
