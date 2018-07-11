function H = traditionalTraman_combined(Q)
datadirS3='/Volumes/Sham_RALMO/RALMO_DATA/RALMO_Data/RALMO';
file = 'S3';
Dateofthefolder = Q.Dateofthefolder;
folderpath = [datadirS3 filesep  Dateofthefolder filesep  file];

load(folderpath);
% which signals to process
what = 'Combined';
data = S3;
% range vector
 z  = data.JL.(what).Range;
g = hour(data.GlobalParameters.Start);%S0.GlobalParameters.Start.FastCom );
Minute = minute(data.GlobalParameters.Start);%(S0.GlobalParameters.Start.FastCom  );

% from 2300 to 2330
 tin =Q.time_in;

starttime=find(g==tin & Minute==Q.min1);
endtime=find(g==tin & Minute==Q.min2);

JL = nansum(data.JL.(what).Signal(:,starttime:endtime)');
JH = nansum(data.JH.(what).Signal(:,starttime:endtime)');

JL=JL';
JH=JH';
% MHZ to Counts conversion constant 
binsize = Q.altbinsize;
F = 1800.* (binsize./150);
       
% Coadd in time
% Eb= S0.Channel(2).Signal; % this is over night signal
JL = F.*JL; % single scans
JH = F.*JH;

[JH, JHzc] = coadd(JH, z, Q.coaddalt);
[JL, JLzc] = coadd(JL, z, Q.coaddalt);

z = JLzc;

bkg_ind = z > 40e3 & z<50e3;
JL = CorrBkg(JL,sum(bkg_ind),0,1);
JH = CorrBkg(JH,sum(bkg_ind),0,1);

JH =JH(z>=Q.alt_d0 & z <= Q.alt_df);
JL =JL(z>=Q.alt_d0 & z <= Q.alt_df);
Q_Digi = JL./JH;


Tprofiledg = 1./log(Q_Digi);

T_digi = Q.Tsonde;%interp1(Q.Zmes,Q.Tsonde,Q.Zmes2,'linear');


ind2 = Q.Zmes>6000 & Q.Zmes < 8000;

y_d = (T_digi);
y_d = y_d( ind2);
x_d = 1./Tprofiledg(ind2);


ftdg=fittype('a/(x+b)','dependent',{'y'},'independent',{'x'},'coefficients',{'a','b'});
fodg = fitoptions('method','NonlinearLeastSquares','Robust','On');
set(fodg, 'StartPoint',[350, 0.3]);


[f_dg,gofdg] = fit(x_d,y_d',ftdg,fodg);
a_dg = f_dg.a;
b_dg = f_dg.b;

H.T_dg = real(a_dg./(1./Tprofiledg +b_dg));

 %figure;plot(Q.Tsonde,Q.Zmes./1000,'r',H.T_an(Q.Zmes1<=10000),Q.Zmes1(Q.Zmes1<=10000)./1000,'b',H.T_dg(Q.Zmes2<=30000),Q.Zmes2(Q.Zmes2<=30000)./1000,'g')
% xlabel('Temperature (K)')
% ylabel('Altitude (km)')
% legend('Tsonde','T analog','T digital')


% H.alt_digi= alt;
% H.alt_an = alt_an;