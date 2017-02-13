% This is to find overlap function using the synthetic and the
% measurements.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 1: OV -= FM( xtr,OV) / FM(xa,OV=1)
% Part 2: OV = Y / FM(Xt)


%% Part 2
close all; clear all;
% load real meaurements
% run OEM
% run FM (xt) without ov
% take the ratio
date = 20110909; % night time measurement 
time = 11;
flag =2 ;

%real measurements
[JHnew,JLnew,alt,JLwithoutBG,JHwithoutBG,bg_JL_mean,bg_JH_mean,bg_JL_std,bg_JH_std,Eb,bg_length]=rawcountsRALMOnew(date);
disp('loaded real measurements')



% % oem retreival 
% [X,R,Q,O,S_a,Se,xa]=TRamanOEM( date,time,flag);
% close all;
% disp('OEM retrieval complete')

% make Q
[Q,x] = makeQsham( date,time,flag);
ind = Q.Zmes<10000;

% FMwithout ov 
[JL,JH,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelnoOV(Q,x);

figure;
semilogx(JHnew(ind),alt(ind)./1000,'r',JLnew(ind),alt(ind)./1000,'b');
hold on
semilogx(JH(ind),Q.Zmes(ind)./1000,'black',JL(ind),Q.Zmes(ind)./1000,'y')
hold off;
xlabel('Alt (km)')
ylabel('Counts (log)')
legend('JHreal','JLreal','JHsyn','JLsyn')


disp('Running FM without OV')

% need to interpolate to take the ratio or use limit 
 JHreal = interp1(alt,JHnew,Q.Zmes,'linear');
 JLreal = interp1(alt,JLnew,Q.Zmes,'linear');

% estimate overlap using individual channels
OVJL = JLreal./JL;
OVJH = JHreal./JH;
% Summation method
OVsum = (JLreal + JHreal)./(JL + JH);


disp('plotting OV')
figure;
plot(Q.Zmes(ind)./1000,OVJL(ind),'r',Q.Zmes(ind)./1000,OVJH(ind),'b',Q.Zmes(ind)./1000,OVsum(ind),'y')
xlabel('Alt (km)')
ylabel('OV')
legend('OVJL','OVJH','OVsum')