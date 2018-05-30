function H = traditionalTraman(Q)
 
JL = Q.JL_DS - Q.BaJL;
JH = Q.JH_DS - Q.BaJH;
JL_an = Q.JLnewa - Q.BaJLa;
JH_an = Q.JHnewa - Q.BaJHa;

Q_Digi = JL./JH;
Q_an = JL_an./JH_an;

Tprofilean = 1./log(Q_an);
Tprofiledg = 1./log(Q_Digi);

T_digi = interp1(Q.Zmes,Q.Tsonde,Q.Zmes2,'linear');
T_an = interp1(Q.Zmes,Q.Tsonde,Q.Zmes1,'linear');

ind1 = Q.Zmes1>1000 & Q.Zmes1 < 3000;
ind2 = Q.Zmes2>3000 & Q.Zmes2 < 8000;

y_d = (T_digi);
y_d = y_d( ind2);
x_d = 1./Tprofiledg(ind2);

y_a = (T_an);
y_a = y_a(ind1);
x_a = 1./Tprofilean(ind1);

ftan=fittype('a/(x+b)','dependent',{'y'},'independent',{'x'},'coefficients',{'a','b'});
foan = fitoptions('method','NonlinearLeastSquares','Robust','On');
set(foan, 'StartPoint',[350, 0.3]);

ftdg=fittype('a/(x+b)','dependent',{'y'},'independent',{'x'},'coefficients',{'a','b'});
fodg = fitoptions('method','NonlinearLeastSquares','Robust','On');
set(fodg, 'StartPoint',[350, 0.3]);

[f_a,gofa] = fit(x_a',y_a',ftan,foan);
a_an = f_a.a;
b_an = f_a.b;

[f_dg,gofdg] = fit(x_d,y_d',ftdg,fodg);
a_dg = f_dg.a;
b_dg = f_dg.b;

H.T_an = real(a_an./(1./Tprofilean +b_an));
H.T_dg = real(a_dg./(1./Tprofiledg +b_dg));

 %figure;plot(Q.Tsonde,Q.Zmes./1000,'r',H.T_an(Q.Zmes1<=10000),Q.Zmes1(Q.Zmes1<=10000)./1000,'b',H.T_dg(Q.Zmes2<=30000),Q.Zmes2(Q.Zmes2<=30000)./1000,'g')
% xlabel('Temperature (K)')
% ylabel('Altitude (km)')
% legend('Tsonde','T analog','T digital')


% H.alt_digi= alt;
% H.alt_an = alt_an;