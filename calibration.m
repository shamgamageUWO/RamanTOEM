function [CJL, CJH, R,Bg_JL_real,Bg_JH_real,bg_JL_std,bg_JH_std,bg_length,JHnew,JLnew,alt,OV] = calibration(Q)

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


% In calibration need to use the desaturated counts. in S3.mat files its
% already taken into account.

SJH = (JHwithoutBG);% background removed 
SJL = (JLwithoutBG);

% need to desaturate the real counts
% 
% SJH = desaturated (JHnew) - Bg_JH_real;
% SJL = desaturated (JLnew) - Bg_JL_real;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% US model
[temp, press, dens, Alt] = US1976(date_in, time_in, Zi); 
T = temp;
P = press;
[Diff_JH_i,Diff_JL_i,A_Zi,B_Zi]=synthetic(T,P,Zi);
% B_Zi doesnt have OV


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


%%% Overlap fitting
% load real meaurements
% run OEM
% run FM (xt) without ov
% take the ratio
JLwoOV = ((CJL.*B_Zi.* Diff_JL_i)./(T)) + Bg_JL_real;
JHwoOV = ((R.*CJL.*B_Zi.* Diff_JH_i)./(T))+ Bg_JH_real;

% need to interpolate to take the ratio or use limit 
 JHreal = interp1(alt,JHnew,Q.Zmes,'linear');
 JLreal = interp1(alt,JLnew,Q.Zmes,'linear');

% estimate overlap using individual channels
% OVJL = JLreal./JL;
% OVJH = JHreal./JH;
% Summation method
OVz = (JLreal + JHreal)./(JLwoOV + JHwoOV);
 % Find the first altitude where OV reach 1, then everything after that
 % should equal to 1.
 OV = interp1(Q.Zmes,OVz,Q.Zret); % this is to smooth
 OV(OV>=1)=1;
 h = find(OV==1);
 OV(h(1):end)=1;

% figure;
% subplot(1,2,1)
% figure; plot(Q.Zret./1000,OV)

 % Fix the counts using the new OV function
 
 NewJL = NoiseP(((CJL.*B_Zi.* Diff_JL_i.*OVz)./(T)) + Bg_JL_real);
 NewJH = NoiseP((R.*CJL.*B_Zi.* Diff_JH_i.*OVz)./(T)  + Bg_JH_real);

% subplot(1,2,2)
% semilogx(JLreal,Q.Zmes./1000,'r',JHreal,Q.Zmes./1000,'b',JLwoOV,Q.Zmes./1000,'y',JHwoOV,Q.Zmes./1000,'g',NewJL,Q.Zmes./1000,'black',NewJH,Q.Zmes./1000,'m')