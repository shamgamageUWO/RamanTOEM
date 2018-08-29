function [R_real,R_esti,dR] = Rtest 
dT = [-10,-5,-2,0,2,5,10];

R_esti=[];
% R_real=[];
dR =[];
date_in = 20110909;
time_in = 23;
Zi= 1000:100:40000;
ind = Zi>=4000 & Zi<=8000;

% real measurements
[JHnew,JLnew,alt,JLwithoutBG,JHwithoutBG,bg_JL_mean,bg_JH_mean,bg_JL_std,bg_JH_std,Eb]=rawcountsRALMOnew(date_in);
Bg_JL_real =  (bg_JL_mean);%(nansum of bkg_JL, bkg_JL is the avg counts above 40km for each 1min profile)
Bg_JH_real =  (bg_JH_mean);
SJH = (JHwithoutBG);% background removed
SJL = (JLwithoutBG);
SSJL = interp1(alt,SJL,Zi,'linear');
SSJH = interp1(alt,SJH,Zi,'linear');
% y = SJH./SJL;
% y = interp1(alt,y,Zi,'linear');
% y = y(ind);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% US model
[temp, press, dens, alt] = US1976(date_in, time_in, Zi); 
P = press;
[Diff_JH_i,Diff_JL_i,A_Zi]=synthetic(temp,P,Zi);
JLN = (A_Zi.* Diff_JL_i)./(temp);
JHN = (A_Zi.* Diff_JH_i)./(temp);

CJL = SSJL./JLN;
CJH = SSJH./JHN;
CJL = mean(CJL(ind));
CJH = mean(CJH(ind));
% figure;plot(CJL,Zi(ind),CJH,Zi(ind))
R_real = (CJH/CJL);

y = (CJH.*Diff_JH_i)./(CJL.*Diff_JL_i);
 
for i = 1:length(dT)
 T = temp+dT(i);
% Synthetic
[Diff_JH_i,Diff_JL_i,A_Zi]=synthetic(T,P,Zi);

% 
% Estimation of R 
x = (Diff_JH_i)./(Diff_JL_i);
% x=x(ind);
f = fittype({'x'});
fit3 = fit(x',y',f,'Robust','on');
R_esti(i) = fit3(1);
dR(i) = ((-R_real+R_esti(i))./R_real).*100;
end 



%% Residual plot
% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% Create plot
plot(dT,dR);

% Create xlabel
xlabel('Change in T from US model temperatures');

% Create title
title({'R % (esti-ratio)'});

% Create ylabel
ylabel('dR (%)');

box(axes1,'on');
% Set the remaining axes properties
set(axes1,'FontSize',16,'XTickLabel',...
    {'T_U_S -10','T_U_S -8','T_U_S -6','T_U_S -4','T_U_S -2','T_U_S ','T_U_S +2','T_U_S +4','T_U_S +6','T_U_S +8','T_U_S +10'});
% figure;plot(dT,dR)
% xlabel('Change in T from US model temperatures','FontSize',16)
% ylabel('dR (%)','FontSize',16)


%%
% figure;plot(Diff_JL_i,Zi,Diff_JH_i,Zi,'r')
% NewJL = CJL.*JLN+ Bg_JL_real;
% NewJL = NoiseP(NewJL);
% 
% NewJH = R_esti(i)*CJL.*JHN + Bg_JH_real;
% NewJH = NoiseP(NewJH);
% % figure; plot(fit3,'b:');
% % xlabel('Diff cross section ratio')
% % ylabel('Count ratio')
%     figure;semilogx(SSSJL,Zi./1000,'r',NewJL,Zi./1000,'b');hold on
%     semilogx(SSSJH,Zi./1000,'y',NewJH,Zi./1000,'g',Eb,Zi./1000);hold off
% xlabel('Log Counts','Fontsize',16) 
% ylabel('Alt (km)','Fontsize',16)
% legend({'Real JL','Syn JL','Real JH','Syn JH','Elastic'},'Fontsize',16);%
