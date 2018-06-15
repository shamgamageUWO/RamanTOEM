function [OV_N2_d,Zd]= ovestimationforWV(Q)
Zi = Q.Zmes;
Za = Q.Zmes1;%analog
Zd = Q.Zmes2;%digital

% ind1 = Zd>=6000 & Zd< 8000;
% 
% ind2 = Za>=1000 & Za< 2000;% 1800 was changed
% ind3 = Zi
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Removing true background from the desaturated signal

SN2 =  Q.N2_DS-Q.BaN2;
SWV =  Q.WV_DS-Q.BaWV;
SN2a = Q.N2newa - Q.BaN2a;
SWVa = Q.WVnewa - Q.BaWVa;

    OVa = ones(1,length(Q.Ta));
    Q.OVlength = length(OVa);

x = [Q.Tsonde2 0 0 Q.CL OVa 0 0 Q.CLa 0 0 Q.RHa 0 0 Q.CWV Q.CN2 OVa 0 0 Q.CWVa  Q.CN2a 0 0]; % coupled analog channels


[JL,JH,JLa,JHa,N2,WV,N2a,WVa]=forwardmodelTraman(Q,x);


OV_WV_d = SWV'./WV;
OV_WV_a = SWVa./WVa;
OV_N2_d = SN2'./N2;
OV_N2_a = SN2a./N2a;  

figure;
plot(Zd./1000,OV_WV_d,'r')
hold on;
plot(Zd./1000,OV_N2_d,'b')
plot(Za./1000,OV_WV_a,'g')
plot(Za./1000,OV_N2_a,'y')
hold off;
legend('wvd','n2d','wva','n2a')
xlabel('Alt (km)')
ylabel('OV')
