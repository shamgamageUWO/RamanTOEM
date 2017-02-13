
function [C,R,xx,yy]=FindCsumandR

[JHnew,JLnew,alt,JLwithoutBG,JHwithoutBG]=rawcountsRALMOwithBG(20110705);
Stotal = nansum(JLwithoutBG')+nansum(JHwithoutBG');

Alt = alt(alt>=500 & alt<=40000);
Stotal=Stotal(alt>=500 & alt<=40000);

date_in = 20110705;
time_in = 23;

Zi = 500:100:40000;
[JLL,JHH,T_US,CL,CH,Diff_JH_i,Diff_JL_i,A_Zi]=realmeasurements(date_in, time_in, Zi);

% DiffSum = (Diff_JH_i + Diff_JL_i).* A_Zi;
% DiffSum = interp1(Zi,DiffSum,Alt,'linear');


% y=Stotal(Alt>=4000&Alt<=7500);
% x=DiffSum(Alt>=4000&Alt<=7500)';
% [fitResults1]=createfigureNew(x,y,'b');
% 
% 'Constant from Sum of counts'
% C = fitResults1(1);
% C
% figure;
% subplot(1,2,1)
% semilogx(Stotal,Alt./1000,'b',fitResults1(1).*DiffSum ,Alt./1000,'r')
% legend('Total Real counts','Total Synthetic counts')
% xlabel('Log Counts')
% ylabel('Alt(km)')
% subplot(1,2,2)
% plot(Stotal'- fitResults1(1).*DiffSum ,Alt./1000,'r')
% xlabel('Difference of Counts')
% ylabel('Alt(km)')

 JLwithoutBG(JLwithoutBG<0)=NaN;
 JHwithoutBG(JHwithoutBG<0)=NaN;
% make a guess for R 
 SJH = nansum(JLwithoutBG');
 SJL = nansum(JHwithoutBG');
 
 SJL=SJL(alt>=500 & alt<=40000);
 SJH=SJH(alt>=500 & alt<=40000);
 
 DiffJL = interp1(Zi,Diff_JL_i,Alt,'linear');
 DiffJH = interp1(Zi,Diff_JH_i,Alt,'linear');
 
 JLN = (A_Zi.* Diff_JL_i)./(T_US);
 JHN = (A_Zi.* Diff_JH_i)./(T_US);
 
 
 
%  DiffJL = interp1(Zi,JLL./CL,Alt,'linear');
%  DiffJH = interp1(Zi,JHH./CH,Alt,'linear');
% yy= (SJH./SJL);
%  yy = yy(alt>=3000 & alt<=5000);
% % figure;plot(yy,Alt)
% xx=(DiffJL./DiffJH);
% % figure;plot(xx,Alt)
%  xx = xx(alt>=3000 & alt<=5000);
% figure;scatter(xx,yy,'r')
% xlabel('Diff cross ratio')
% ylabel('Counts ratio')
% lsline
% p=polyfit(xx',yy,1);
% 'R'
% R=p(1);
% R 

% close all;
% 
% % Find CL
% A_Zi = interp1(Zi,A_Zi,Alt,'linear');
% xxx = (DiffJL).* A_Zi;
% yyy = nansum(JLwithoutBG');
% yyy = yyy(alt>=500 & alt<=40000);
% figure;semilogx(xxx,Alt,yyy,Alt)
% Y=yyy(Alt>=3000&Alt<=7500);
% X=xxx(Alt>=3000&Alt<=7500)';
% pp=polyfit(X,Y,1);
% CLnew = pp(1);
%  figure;scatter(X,Y)
% STD = 1.538e+10./934;
% 
% figure;
% plot(CLnew.*DiffJL.*A_Zi,Alt./1000,'b',JLnew,alt./1000,'r')