% this is to read S0.mat files and pick the measurements from 11-11.30pm
% Save the JL,JH,Eb and alt in seperate structure 

function K = NewAnalogVarianceMethod

%  date = Q.date_in;
[year,month,day] = getYMDFromDate(20110909);
 yr = num2str(year);

 % open S0 matfile according to the given date
datadirS3='/Users/sham/Documents/MATLAB/RALMO_Data/RALMO';%/2011.09.28
% datadirS3='/Volumes/Sham_RALMO/2011/2011.09.09';
file = 'S0';
Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day)];
folderpath = [datadirS3 filesep  Dateofthefolder filesep  file];
load(folderpath);

% Display the start and end times of the lidar measurment
% disp('Start time')
g = hour(S0.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
Minute = minute(S0.GlobalParameters.Start);%(S0.GlobalParameters.Start.FastCom  );
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
Y.binsize = S0.Channel(12).BinSize;
F = 1800.* (Y.binsize./150);

% JL = F.*F.*S0.Channel(12).Signal(:,starttime:endtime);%20121212(:,1310:1340);20120717(:,1347:1377);%20110909(:,961:990);
% JH = F.*S0.Channel(4).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
% Eb= F.*S0.Channel(10).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);


JL_an = S0.Channel(11).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
JH_an = S0.Channel(3).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
Eb_an = S0.Channel(9).Signal(:,starttime:endtime);%20120717(:,1347:1377);%(:,961:990);
JL_an = JL_an';
JH_an = JH_an';

% figure;plot(JL_an(:,3200),alt_an./1000)

N = length(JH);

% %% Fix off set 
zAoffset = 10; % bins ie 10*3.75 = 37.5m 
% JH= JH(1:N-zAoffset,:); % already in counts ./ (y2HzRaw./1e6);
% JL =JL(1:N-zAoffset,:); % ./ (y2HzRaw./1e6);
JH_an = JH_an(:,1+zAoffset:end);
JL_an = JL_an(:,1+zAoffset:end);
alt = alt(1:N-zAoffset);
alt_an = alt_an(1+zAoffset:end);


bkg_ind = alt_an>10e3;% & alt<60e3;
bkg_Lan = mean(JL_an(:,bkg_ind)');
bkg_Han = mean(JH_an(:,bkg_ind)');

La = nansum(JL_an);
Ha = nansum(JH_an);

bkgL = mean(La(bkg_ind)');
bkgH = mean(Ha(bkg_ind)');

La = La(:,alt_an<=12000);
Ha = Ha(:,alt_an<=12000);
JH_an = JH_an(:,alt_an<=12000);
JL_an = JL_an(:,alt_an<=12000);
alt_an = alt_an(alt_an<=12000);



%% Method 1
% Run piecewise method for each profile;

% for i = 1:30
%     [varJLa(i,:),go] = bobpoissontest(JL_an(i,:),alt_an',25);
%     [varJHa(i,:),go] = bobpoissontest(JH_an(i,:),alt_an',25);
% end
% 
% % figure;
% % subplot(1,2,1)
% % plot(varJLa')
% % subplot(1,2,2)
% % plot(varJHa)
% % 
% % figure;
% % plot(mean(varJLa)','black')
% % hold on
% % plot(mean(varJHa)','r')
% % hold off
% 
% 
% MeanJLvar = mean(varJLa);
% MeanJHvar = mean(varJHa);
% 
% r1 = ones(1,go-1).* MeanJHvar(1);
% r2 = ones(1,go-1).* MeanJHvar(end);
% r3 = ones(1,go-1).* MeanJLvar(1);
% r4 = ones(1,go-1).* MeanJLvar(end);
% MJHvar = [r1 MeanJHvar r2];
% MJLvar = [r3 MeanJLvar r4];
% 
% figure;plot(MJHvar,alt_an./1000,'r',MJLvar,alt_an./1000,'b')
% hold on

%% Method 2 - old method

% 
%     [varLa,go1] = bobpoissontest(La,alt_an',25);
%     [varHa,go1] = bobpoissontest(Ha,alt_an',25);
%     
% r11 = ones(1,go1-1).*varHa(1);
% r21 = ones(1,go1-1).* varHa(end);
% r31 = ones(1,go1-1).* varLa(1);
% r41 = ones(1,go1-1).* varLa(end);
% Havar = [r11 varHa r21];
% Lavar = [r31 varLa r41];

% plot(Havar,alt_an./1000,'y',Lavar,alt_an./1000,'black')
% xlabel('Piecewise Variance')
% ylabel('Alt(km)')
% legend('single profile,mean, PW - JH','single profile,mean, PW - JL','30min coadded, PW - JH','30min coadded, PW - JL')
% hold off



%% Method 3 - Remover bg and single profile


% % Background removed signal
% for i = 1:length(bkg_Lan)
%     L(i,:) = JL_an(i,:) - bkg_Lan(i);
%     H(i,:) = JH_an(i,:) - bkg_Han(i);
% end
% 
% 
% for i = 1:30
%     [varL(i,:),g] = bobpoissontest(L(i,:),alt_an',25);
%     [varH(i,:),g] = bobpoissontest(H(i,:),alt_an',25);
% end
% 
% MeanLvar = mean(varL);
% MeanHvar = mean(varH);
% 
% r111 = ones(1,g-1).* MeanHvar(1);
% r211 = ones(1,g-1).* MeanHvar(end);
% r311 = ones(1,g-1).* MeanLvar(1);
% r411 = ones(1,g-1).* MeanLvar(end);
% MHvar = [r111 MeanHvar r211];
% MLvar = [r311 MeanLvar r411];
% 
% % figure;plot(MHvar,alt_an./1000,'r',MLvar,alt_an./1000,'b')
% % hold on


%% Method 4 - old method bg removed


LLa = La -bkgL;
HHa = Ha -bkgH;

    [varLLa,gg] = bobpoissontest(LLa,alt_an',25);
    [varHHa,gg] = bobpoissontest(HHa,alt_an',25);
    
rr1 = ones(1,gg-1).*varHHa(1);
rr2 = ones(1,gg-1).* varHHa(end);
rr3 = ones(1,gg-1).* varLLa(1);
rr4 = ones(1,gg-1).* varLLa(end);
HHavar = [rr1 varHHa rr2];
LLavar = [rr3 varLLa rr4];

% plot(HHavar,alt_an./1000,'y',LLavar,alt_an./1000,'black')
% xlabel('Piecewise Variance')
% ylabel('Alt(km)')
% legend('single profile,mean, PW - JH','single profile,mean, PW - JL','30min coadded, PW - JH','30min coadded, PW - JL')
% hold off

K.noiseLLa = sqrt(LLavar);
K.noiseHHa = sqrt(HHavar);

% K.VaJLSingle = MLvar;
% K.VaJHSingle = MHvar;
% K.VaJLcoadd = LLavar;
% K.VaJHcoadd = HHavar;
K.alt=alt_an;
K.L= LLa./K.noiseLLa;
K.H= HHa./K.noiseHHa;


figure;
subplot(1,2,1)
plot(La./K.noiseLLa,alt_an./1000,'r',Ha./K.noiseHHa,alt_an./1000,'b')
xlabel('Total Signal/Noise')
ylabel('Alt(km)')
legend('JLa','JHa')
subplot(1,2,2)
plot(LLa./K.noiseLLa,alt_an./1000,'r',HHa./K.noiseHHa,alt_an./1000,'b')
xlabel('Background Removed Signal/Noise')
ylabel('Alt(km)')
legend('JLa','JHa')

% plot noise/signal and bg/signal

% Signal to noise
% JL_P = ((stdJLa./JL_an)).*100;
% JH_P = ((stdJHa./JH_an)).*100;
% figure;plot(JL_P,JLazc./1000,'r',JH_P,JLazc./1000,'b')

                    % % Remove background from each profile
                    % bkg_ind = alt>50e3;% & alt<60e3;
                    % bkg_JLan = mean(JL_an(:,bkg_ind)');
                    % bkg_JHan = mean(JH_an(:,bkg_ind)');
                    %
                    % % Background removed signal
                    % for i = 1:length(bkg_JLan)
                    % JLa(i,:) = JL_an(i,:) - bkg_JLan(i);
                    % JHa(i,:) = JH_an(i,:) - bkg_JHan(i);
                    % end
                    %
                    %     figure;
                    %     subplot(1,4,1)
                    %     plot(JLa,alt_an./1000)
                    %     xlabel('JL Analog Signal')
                    %     ylabel(' Alt(km)')
                    %
                    %     subplot(1,4,2)
                    %     plot(JHa,alt_an./1000)
                    %     xlabel('JH Analog Signal')
                    %     ylabel(' Alt(km)')
                    %
                    % % Find the std at each height
                    % for i = 1:length(alt_an)
                    % stdJLa(:,i) = std(JLa(:,i));
                    % stdJHa(:,i) = std(JHa(:,i));
                    % end
                    %
                    %
                    %
                    %     subplot(1,4,3)
                    %     plot(stdJLa,alt_an./1000)
                    %     xlabel('Std JL Analog ')
                    %     ylabel(' Alt(km)')
                    %
                    %     subplot(1,4,4)
                    %     plot(stdJHa,alt_an./1000)
                    %     xlabel('Std JH Analog ')
                    %     ylabel(' Alt(km)')
                    %
                    %  % Variance
                    %  JLvar = stdJLa.^2;
                    %  JHvar = stdJHa.^2;
                    %
                    %   figure;
                    %     subplot(1,2,1)
                    %     plot(JLvar,alt_an./1000)
                    %     xlabel('JL Analog Signal')
                    %     ylabel(' Alt(km)')
                    %
                    %     subplot(1,2,2)
                    %     plot(JHvar,alt_an./1000)
                    %     xlabel('JH Analog Signal')
                    %     ylabel(' Alt(km)')
                    %
                    %
