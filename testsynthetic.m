
close all;
clear all;

Zi = 500:100:30000;
% [JLrealson,JHrealson,A_Zi,Diff_JL_i,Diff_JH_i,T_sonde,Pressi]=realmeasurementsfromsonde(Zi);
[JLreal,JHreal,T_US,CLus,CHus,Diff_JH_ius,Diff_JL_ius,A_ZiUS,Pressius]=realmeasurements(20110705, 23, Zi);
[JHnew,JLnew,alt,JLwithoutBG,JHwithoutBG]=rawcountsRALMOwithBG(20110705);

% JLsonde = (A_Zi.*Diff_JL_i)./T_sonde;
% JLsonde =  NoiseP((JLsonde));
JLus = (A_ZiUS.*Diff_JL_ius)./T_US;
% JLus =  NoiseP((JLus));



% JHsonde = (A_Zi.*Diff_JH_i)./T_sonde;
% JLsonde =  NoiseP((JLsonde));
JHus = (A_ZiUS.*Diff_JH_ius)./T_US;
% JLus =  NoiseP((JLus));
% figure;
% subplot(1,2,1)
% plot( T_US,Zi./1000,'r',T_sonde,Zi./1000,'b')
% xlabel('Temp (K)')
% ylabel('Alt (km)')
% subplot(1,2,2)
% plot(T_US-T_sonde,Zi./1000,'black')
% xlabel('Temp difference(K)')
% ylabel('Alt (km)')
% 
% figure; 
% subplot(2,2,1)
% semilogx(JLwithoutBG,alt./1000,'black')
% subplot(2,2,2)
% semilogx(JLus,Zi./1000,'b',JLsonde,Zi./1000,'r')
% 
% subplot(2,2,3)
% semilogx(JHwithoutBG,alt./1000,'black')
% subplot(2,2,4)
% semilogx(JHus,Zi./1000,'b',JHsonde,Zi./1000,'r')
% 
% 
% 
% figure; 
% subplot(1,2,1)
% semilogx(Diff_JH_i,Zi./1000,'b',Diff_JH_ius,Zi./1000,'r')
% subplot(1,2,2)
% semilogx(Diff_JL_i,Zi./1000,'b',Diff_JL_ius,Zi./1000,'r')
% 
% figure; 
% semilogx(A_Zi,Zi./1000,'b',A_ZiUS,Zi./1000,'r')


