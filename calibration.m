function [CJL, CJH, R,Bg_JL_real,Bg_JH_real,bg_JL_std,bg_JH_std,bg_length,JHnew,JLnew,alt] = calibration(Q)

date_in = Q.date_in;
time_in = Q.time_in;
Zi = Q.Zmes ;
ind = Zi>=4000 & Zi<=8000;
% [JHnew,JLnew,alt,JLwithoutBG,JHwithoutBG,bkg_JL,bkg_JH]=rawcountsRALMOwithBG(date_in);
[JHnew,JLnew,alt,JLwithoutBG,JHwithoutBG,bg_JL_mean,bg_JH_mean,bg_JL_std,bg_JH_std,Eb,bg_length]=rawcountsRALMOnew(date_in);
% Bg_JL_real =  (bg_JL_mean);%(nansum of bkg_JL, bkg_JL is the avg counts above 40km for each 1min profile)
% Bg_JH_real =  (bg_JH_mean);
% HEre I'm trying to make an estimation of true background
Bg_JL_obs =  (bg_JL_mean); % this is an estimation of obs background
Bg_JH_obs =  (bg_JH_mean);

Bg_JL_real = Bg_JL_obs/(1+Q.deadtime*Bg_JL_obs);
Bg_JH_real = Bg_JH_obs/(1+Q.deadtime*Bg_JH_obs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% US model
[temp, press, dens, Alt] = US1976(date_in, time_in, Zi); 
T = temp;
P = press;
[Diff_JH_i,Diff_JL_i,A_Zi]=synthetic(T,P,Zi);

SJH = (JHwithoutBG);% background removed
SJL = (JLwithoutBG);

JLN = (A_Zi.* Diff_JL_i)./(T);
JHN = (A_Zi.* Diff_JH_i)./(T);

SSJL = interp1(alt,SJL,Zi,'linear');
SSJH = interp1(alt,SJH,Zi,'linear');

% with background
SSSJL = interp1(alt,JLnew,Zi,'linear');
SSSJH = interp1(alt,JHnew,Zi,'linear');

CJL = SSJL./JLN;
CJH = SSJH./JHN;
CJL = mean(CJL(ind));
CJH = mean(CJH(ind));
% figure;plot(CJL,Zi(ind),CJH,Zi(ind))
R_real = (CJH/CJL);

Eb = interp1(alt,Eb,Zi,'linear');
% 
% Estimation of R 
x = (Diff_JH_i)./(Diff_JL_i);
y = SJH./SJL;
y = interp1(alt,y,Zi,'linear');

x = x(ind);
y=y(ind);

f = fittype({'x'});
fit3 = fit(x',y',f,'Robust','on');
R = fit3(1);


% figure;plot(Diff_JL_i,Zi,Diff_JH_i,Zi,'r')
NewJL = CJL.*JLN+ Bg_JL_real;
NewJL = NoiseP(NewJL);

NewJH = R*CJL.*JHN + Bg_JH_real;
NewJH = NoiseP(NewJH);
% figure; plot(fit3,'b:');
% xlabel('Diff cross section ratio')
% ylabel('Count ratio')
% figure;semilogx(SSSJL,Zi./1000,'r',NewJL,Zi./1000,'b');hold on
% semilogx(SSSJH,Zi./1000,'y',NewJH,Zi./1000,'g',Eb,Zi./1000);hold off
% xlabel('Log Counts','Fontsize',16) 
% ylabel('Alt (km)','Fontsize',16)
% legend({'Real JL','Syn JL','Real JH','Syn JH','Elastic'},'Fontsize',16);%
