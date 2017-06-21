function [R,aa,bb] = Rcalibration(Q)

date_in = Q.date_in;
time_in = Q.time_in;
% Real measurements
% [JHnew,JLnew,alt,JLwithoutBG,JHwithoutBG,bg_JL_mean,bg_JH_mean,bg_JL_std,bg_JH_std,Eb,bg_length]=rawcountsRALMOnew(Q);
% [Y] = makeY(Q);
JHnew = Q.JHnew;
JLnew = Q.JLnew;
alt = Q.alt;


Zi= alt';
Q.Zmes = Zi(Zi>100);
% Sonde profile is needed here
[Tsonde,Zsonde,Psonde] = get_sonde_RS92(date_in,time_in);
% T = interp1(Zsonde,Tsonde,Q.Zmes,'linear');
% P =interp1(Zsonde,Psonde,Q.Zmes,'linear');
Pressi = Psonde';
Q.Pressi =interp1(Zsonde,Pressi,Q.Zmes,'linear');
Ti =interp1(Zsonde,Tsonde,Q.Zmes,'linear');
Q.rho = (Q.Pressi./(287.*Ti));
Q.Zret = Zsonde';
% x_a = [Q.Ta Q.BaJH Q.BaJL Q.CL Q.OVa];
% Make background zero, CJL = 1 and overlap 1; Q.R =1;
OVa = ones(1,length(Zsonde));
Q.OVlength = length(OVa);
Q.R =1;
x = [Tsonde' 0 0 1 OVa];


                %x = [Tsonde' 0 0 log(1) OVa];
[JL,JH,A_Zi,B_Zi,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x);
ind = Q.Zmes > 8000 & Q.Zmes< 10000;
x = (JH(ind)./JL(ind));
y = JHnew(ind)./JLnew(ind);

f = fittype({'x'});
fit3 = fit(x',y,f,'Robust','on');
R = fit3(1);

% % %%%%%% Calibration for traditional method
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
