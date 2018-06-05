function [R,Ra,R_fit,Ra_fit,dfacR,dfacRa,ind1,ind2] = Restimationnew(Q)
cutoffOV = Q.cutoffOV;
Zd = Q.Zmes2;
Za = Q.Zmes1;

ind1 = Zd>=6000 & Zd< 8000;% If the cloud height is below full overlap
ind2 = Za>=800 & Za< 1800;% 1800 was changed



N1 = length(Q.JHnewa);



JHnew = Q.JH_DS-Q.BaJH;
JLnew = Q.JL_DS-Q.BaJL;
JHnewa = Q.JHnewa-Q.BaJHa;
JLnewa = Q.JLnewa-Q.BaJLa;



%% loading cross sections
load('DiffCrossSections.mat');
Td = interp1(Q.Zret,Q.Tsonde2,Q.Zmes2,'linear'); % T on data grid (digital)
Ta = interp1(Q.Zret,Q.Tsonde2,Q.Zmes1,'linear');


Diff_JHia = interp1(T,Diff_JH,Ta,'linear');
Diff_JLia = interp1(T,Diff_JL,Ta,'linear');

Diff_JHid = interp1(T,Diff_JH,Td,'linear');
Diff_JLid = interp1(T,Diff_JL,Td,'linear');


Ratio_diff_a = Diff_JLia./Diff_JHia; % analog
Ratio_diff_d = Diff_JLid./Diff_JHid; % digi


Digital_ratio = JHnew ./JLnew ;
Analog_ratio = JHnewa./JLnewa;

R =  Digital_ratio'.*Ratio_diff_d;
Ra = Analog_ratio'.* Ratio_diff_a;


 x = 1./Ratio_diff_d(ind1);
 y = Digital_ratio(ind1);

 
f = fittype({'x'});
[fit3,GR] = fit(x',y,f,'Robust','on');
R_fit = fit3(1);
dfacR = GR.rmse;
% 

 xa = 1./Ratio_diff_a(ind2);
 ya = Analog_ratio(ind2);

fa = fittype({'x'});
[fit3a,GRa] = fit(xa',ya,fa,'Robust','on');
Ra_fit = fit3a(1);
dfacRa = GRa.rmse;

if cutoffOV < 6000
    
    ind1 = Zd>=6000 & Zd< 8000;% If the cloud height is below full overlap
    ind2 = Za>=800 & Za< 1800;% 1800 was changed
else
    ind1 = Zd>=4000 & Zd< cutoffOV;% 6-8km
    ind2 = Za>=800 & Za< 1800;%%     1800 was changed
    
end
% figure;plot(Q.Zmes2./1000,R,'r',Q.Zmes1./1000,Ra,'b')
% xlabel('Alt(km)')
% ylabel('R or Ra')
% legend('R','Ra')

%%
