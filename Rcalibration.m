function [R,Ra,aa,bb] = Rcalibration(Q)

date_in = Q.date_in;
time_in = Q.time_in;
JHnew = Q.JHnew;
JLnew = Q.JLnew;
JHnewa = Q.JHnewa;
JLnewa = Q.JLnewa;
% alt = Q.alt;
% Zi= alt';
% Q.Zmes = (Zi>50);

%% Load Sonde
[Tsonde,Zsonde,Psonde] = get_sonde_RS92(date_in,time_in);
Pressi = Psonde';
Q.Pressi =interp1(Zsonde,Pressi,Q.Zmes,'linear');
Ti =interp1(Zsonde,Tsonde,Q.Zmes,'linear');
Q.rho = (Q.Pressi./(287.*Ti));
Q.Zret = Zsonde';

%% R estimation using JL and JH channels
% x_a = [Q.Ta Q.BaJH Q.BaJL Q.CL Q.OVa];
% Make background zero, CJL = 1 and overlap 1; Q.R =1;
OVa = ones(1,length(Zsonde));
Q.OVlength = length(OVa);
Q.R =1;
Q.Ra = 1;

x = [Tsonde' 0 0 1 OVa 0 0 1];

%% Digital
[JL,JH,JLa,JHa,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x);

ind1 = Q.Zmes > 8000 & Q.Zmes< 10000;
x = (JH(ind1)./JL(ind1));
y = JHnew(ind1)./JLnew(ind1);

f = fittype({'x'});
fit3 = fit(x',y,f,'Robust','on');
R = fit3(1);

%% analog
ind2 = Q.Zmes > 4000 & Q.Zmes< 5000;
xa = (JHa(ind2)./JLa(ind2));
ya = JHnewa(ind2)./JLnewa(ind2);

fa = fittype({'x'});
fit3a = fit(xa',ya,fa,'Robust','on');
Ra = fit3a(1);
%%

%  figure;plot(JLnewa,Ra.*JLa)

% % %%%%%% Calibration for traditional method Digital channel
lnQ = log(JHnew./JLnew);
yy = Ti;
yy = yy(Q.Zmes>=2000 & Q.Zmes<=20000);
xx = lnQ;
xx = xx(Q.Zmes>=2000 & Q.Zmes<=20000);
g = fittype('b/(a-x)','coeff',{'a','b'});
fit34 = fit(xx,yy',g,'Robust','on','Startpoint', [0 0]);
s= coeffvalues(fit34);
aa = s(1);
bb = s(2);
%  ff = fittype({'a*x+b'},);
