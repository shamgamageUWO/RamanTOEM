%% this is to fit the analog to digital 

% {Corrected digital counts / CJL} = {(analog - bg)/CJLa}
% CJLa =  {(analog - bg)} / {Corrected digital counts / CJL} 

[Q] = makeQsham( 20110909,23,2);
x_a = [Q.Ta Q.BaJH Q.BaJL Q.CL Q.OVa Q.BaJHa Q.BaJLa 1.9e17 Q.deadtimeJH Q.deadtimeJL];
[JL,JH,JLa,JHa,A_Zi_an,A_Zi_d,B_Zi_an,B_Zi_d,Diff_JL_i,Diff_JH_i,Ti]=forwardmodelTraman(Q,x_a);

% Desaturate the digital
JLDS =Q.JL_DS;
JHDS =Q.JH_DS;
% Remove Bg
JL_CC = JLDS - Q.BaJL;
JH_CC = JHDS - Q.BaJH;
% divide by CJL
PC_ratio = JL_CC./Q.CL;
% analog remove bg 
JLan = Q.JLnewa - Q.BaJLa;

% Measurements between 2-3km
ind = Q.Zmes>1e3 & Q.Zmes<10e3;
PC_CC_Ratio = PC_ratio(ind);
JLa_Range = JLan(ind);

CJLa = JLa_Range./PC_CC_Ratio';
fL = fittype({'x'});
fitJL = fit(PC_CC_Ratio,JLa_Range',fL,'Robust','on');
CJLafit = fitJL(1)
figure;plot(CJLa,Q.Zmes(ind));