close all; clear all;
date_in = [20110705];
for i = 1: length(date_in)
 % 4hrs coadded 20110628
time_in = 23;


% [JHnew,JLnew,alt,JLwithoutBG,JHwithoutBG,bkg_JL,bkg_JH]=rawcountsRALMOwithBG(date_in);
[JHnew,JLnew,alt,JLwithoutBG,JHwithoutBG,bkg_JL,bkg_JH,Es]=rawcountsRALMOnew(date_in(i));

% Bg_JL_real =  nansum(bkg_JL)%(nansum of bkg_JL, bkg_JL is the avg counts above 40km for each 1min profile)
% Bg_JH_real =  nansum(bkg_JH)

Bg_JL_real =  (bkg_JL)%(nansum of bkg_JL, bkg_JL is the avg counts above 40km for each 1min profile)
Bg_JH_real =  (bkg_JH)

Zi = 500:100:40000;
[JLL,JHH,T_US,CL,CH,Diff_JH_i,Diff_JL_i,A_Zi]=synthetic(date_in(i), time_in, Zi);


SJH = (JHwithoutBG);% background removed
SJL = (JLwithoutBG);

JLN = (A_Zi.* Diff_JL_i)./(T_US);
JHN = (A_Zi.* Diff_JH_i)./(T_US);

SSJL = interp1(alt,SJL,Zi,'linear');
SSJH = interp1(alt,SJH,Zi,'linear');

% with background
SSSJL = interp1(alt,JLnew,Zi,'linear');
SSSJH = interp1(alt,JHnew,Zi,'linear');

H = SSJL(Zi==2500)./JLN(Zi==2500);
K = SSJH(Zi==2500)./JHN(Zi==2500);

NewJL = H.*JLN+ Bg_JL_real;
 NewJL = NoiseP(NewJL);
% % % 
% NewJL = awgn(NewJL,8);

R = 0.76;
NewJH = R.*H.*JHN + Bg_JH_real;
NewJH = NoiseP(NewJH);

JJH = K.*JHN + Bg_JH_real;
JJH = NoiseP(JJH);

%  NewJH = awgn(NewJH,20);

Es = interp1(alt,Es,Zi,'linear');

figure;semilogx(SSSJL,Zi./1000,'r',NewJL,Zi./1000,'b');hold on
semilogx(SSSJH,Zi./1000,'y',NewJH,Zi./1000,'g',JJH,Zi./1000,'m',Es,Zi./1000,'black');hold off
xlabel('Log Counts')
ylabel('Alt (km)')
legend('Real JL','Syn JL','Real JH','Syn JH using R','Syn JH CJH','Elastic')

calR = ones(length(Zi));
calR = calR.* (K/H);
disp('Calculated R')
calR

disp('Fitted R')
R


% figure;plot(NoiseP(0.76.*H.*JHN),Zi./1000,'r',NoiseP(H.*JLN),Zi./1000,'b');hold on
% % plot(JHH,Zi./1000,'y',0.76.*H.*JHN,Zi./1000,'g');hold off
% xlabel('Log Counts')
% ylabel('Alt (km)')

%% R = 0.1723.*4.5=0.76;
%% CL = H = 2.065152155995913e+18;
%Bg_JH_real =2.9989
%Bg_JL_real =3.4144

% std(NewJL(1:396/2))
% std(NewJH(1:396/2))
% noiseJH = sqrt(SJH);
% noiseJL = sqrt(SJL);
x = (Diff_JH_i)./(Diff_JL_i);
y = SJH./SJL;
y = interp1(alt,y,Zi,'linear');
R_T = y./x;


figure;plot(R_T,Zi./1000,'r',calR,Zi./1000,'b')
% y= y(Zi>=3000);
% x= x(Zi>=3000);
% % Remove outliers
% 
%  f = fittype({'x'});
% fit3 = fit(x',y',f,'Robust','on');
% figure; plot(fit3,'b:');
% xlabel('Diff cross section ratio')
% ylabel('Count ratio')
end 
% 
% % figure;semilogx(SJL,alt,'r',qe15.*JLN,Zi,'b');