function [R_fit,Ra_fit,dfacR,dfacRa,ind1] = Restimationnew(Q)
JHnew = Q.JH_DS-Q.BaJH;
JLnew = Q.JL_DS-Q.BaJL;
JHnewa = Q.JHnewa-Q.BaJHa;
JLnewa = Q.JLnewa-Q.BaJLa;
cutoffOV = Q.cutoffOV;
Zd = Q.Zmes2;
Za = Q.Zmes1;

if cutoffOV < 6000
    
    ind1 = Zd>=6000 & Zd< 8000;% If the cloud height is below full overlap
    ind2 = Za>=800 & Za< 1800;% 1800 was changed
else
    ind1 = Zd>=4000 & Zd < 5000;%cutoffOV;% 6-8km
    ind2 = Za>=800 & Za< 1800;% 1800 was changed
    
end
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

%  Alt = Q.Zmes2;
%  ind1 = Alt >= 6000 & Alt< 8000;
% 
 x = 1./Ratio_diff_d(ind1);
 y = Digital_ratio(ind1);
% 
 f = fittype({'x'});
[fit3,GR] = fit(x',y,f,'Robust','on');
R_fit = fit3(1);
dfacR = GR.rmse;
% 

% %% analog
% Alt2 = Q.Zmes1;
% ind2 = Alt2 >= 1000 & Alt2 <= 1200;
 xa = 1./Ratio_diff_a(ind2);
 ya = Analog_ratio(ind2);

fa = fittype({'x'});
[fit3a,GRa] = fit(xa',ya,fa,'Robust','on');
Ra_fit = fit3a(1);
dfacRa = GRa.rmse;

% figure;plot(Q.Zmes2./1000,R,'r',Q.Zmes1./1000,Ra,'b')
% xlabel('Alt(km)')
% ylabel('R or Ra')
% legend('R','Ra')

% %%
% 
% WVnew = Q.WV_DS-Q.BaWV;
% N2new = Q.N2_DS-Q.BaN2;
% WVnewa = Q.WVnewa-Q.BaWVa;
% N2newa = Q.N2newa-Q.BaN2a;
% 
% R_tr_n2 = (Q.Tr_N2');
% R_tr_wv = (Q.Tr_WV');
% 
% Diff_transmission = R_tr_n2./R_tr_wv;
% 
% R_tr_d = Diff_transmission(end-length(Q.WVnew)+1:end);%interp1(Q.Zmes,R_tr_i,Q.Zmes2,'linear');
% R_tr_a = Diff_transmission(1:length(Q.WVnewa));%interp1(Q.Zmes,R_tr_i,Q.Zmes1,'linear');
% 
% Count_Ratio_d = WVnew./N2new;
% Count_Ratio_a = WVnewa./N2newa;

% for i = 1:length(Q.Tsonde)
%     if Q.Tsonde(i) <= 273 
%         M_Aa = 17.84;
%         M_Ba = 245.4;
%     else 
%         M_Aa = 17.08;
%         M_Ba = 234.2;
%     end
%     
%     es(i) = 6.107 * exp ((M_Aa .*(Q.Tsonde(i)-273))./(M_Ba + (Q.Tsonde(i)-273)));
%     U(i) = (0.6222 .* Q.RHsonde(i))./(Q.Psonde(i) - Q.RHsonde(i).*es(i));    
% end
%% For N2 digital
% Q_d = U(end-length(Q.WVnew)+1:end);
% Q_a = U(1:length(Q.WVnewa));

% 
% d = Count_Ratio_d'.*R_tr_d;
% a = Count_Ratio_a.*R_tr_a;
% 
% 
% X_n2 = 1./Count_Ratio_d';
% Y_n2 = R_tr_d;
% 
% aalt = Q.Zmes3;
% ind4 = aalt >= 4000 & aalt< 6000;
% xc = X_n2(ind4);
% yc = Y_n2(ind4);
% fc = fittype({'x'});
% [fitr,GRr] = fit(xc',yc',fc,'Robust','on');
% R_fitn2 = fitr(1);
% dfacRn2 = GRr.rmse;
% 
% 
% X_n2a = 1./Count_Ratio_a';
% Y_n2a = R_tr_a;
% ind5 = Alt2 >= 4500 & Alt2< 6000;
% xca = X_n2a(ind5);
% yca = Y_n2a(ind5);
% fca = fittype({'x'});
% [fitra,GRra] = fit(xca',yca',fca,'Robust','on');
% R_fitn2a = fitra(1);
% dfacRn2a = GRra.rmse;
% figure;plot(d,Q.Zmes3./1000)
% figure;plot(a,Q.Zmes1./1000)

% ,RN2_fit,RN2a_fit,dfacRN2,dfacRN2a