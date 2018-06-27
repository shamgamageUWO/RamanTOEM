function C = estimations(Q)



Zi = Q.Zmes;
Za = Q.Zmes1;%analog
Zd = Q.Zmes2;%digital
Zdd= Q.Zmes3;

ind1 = Zd>6000 & Zd< 8000;
ind4 = Zdd>=4000 & Zdd< 6000; % WV digital
ind2 = Za>=1500 & Za< 3000;% 1800 was changed
ind3 = Za>=800 & Za < 1000;
ind5 = Za>= 800 & Za < 1000;
% ind3 = Zi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Removing true background from the desaturated signal
SJH = Q.JH_DS-Q.BaJH;
SJL = Q.JL_DS-Q.BaJL;
SJHa = Q.JHnewa - Q.BaJHa;
SJLa = Q.JLnewa - Q.BaJLa;
SN2 =  Q.N2_DS-Q.BaN2;
SWV =  Q.WV_DS-Q.BaWV;
SN2a = Q.N2newa - Q.BaN2a;
SWVa = Q.WVnewa - Q.BaWVa;

    OVa = ones(1,length(Q.Ta));
    Q.OVlength = length(OVa);

x = [Q.Tsonde2 0 0 1 Q.OVa 0 0 1 0 0 Q.RHa 0 0 1 1 Q.OVwva 0 0 1 1 0 0]; % coupled analog channels


[JL,JH,JLa,JHa,WV,N2,WVa,N2a]=forwardmodelTraman(Q,x);
  
yJL= SJL(ind1);
xJL=JL(ind1);
yJH= SJH(ind1);
xJH =JH(ind1);

fL = fittype({'x'});
[fitJL,C.GJL] = fit(xJL,yJL,fL,'Robust','on');
C.CJL = fitJL(1);

fH = fittype({'x'});
[fitJH,C.GJH] = fit(xJH,yJH,fH,'Robust','on');
C.CJH = fitJH(1);

yJLa = SJLa(ind2);
xJLa = JLa(ind2);
yJHa = SJHa(ind2);
xJHa = JHa(ind2);

fLa = fittype({'x'});
[fitJLa,C.GJLa] = fit(xJLa,yJLa,fLa,'Robust','on');
C.CJLa = fitJLa(1);

fHa = fittype({'x'});
[fitJHa,C.GJHa] = fit(xJHa,yJHa,fHa,'Robust','on');
C.CJHa = fitJHa(1);


ywv= SWV(ind4);
xwv=WV(ind4);
yn2= SN2(ind4);
xn2 =N2(ind4);

fwv = fittype({'x'});
[fitwv,C.Gwv] = fit(xwv,ywv,fwv,'Robust','on');
C.Cwv = fitwv(1);

fn2 = fittype({'x'});
[fitn2,C.Gn2] = fit(xn2,yn2,fn2,'Robust','on');
C.Cn2 = fitn2(1);

ywva = SWVa(ind5);
xwva = WVa(ind5);
yn2a = SN2a(ind3);
xn2a = N2a(ind3);

fwva = fittype({'x'});
[fitwva,C.Gwva] = fit(xwva,ywva,fwva,'Robust','on');
C.Cwva = fitwva(1);

fn2a = fittype({'x'});
[fitn2a,C.Gn2a] = fit(xn2a,yn2a,fn2a,'Robust','on');
C.Cn2a = fitn2a(1);
