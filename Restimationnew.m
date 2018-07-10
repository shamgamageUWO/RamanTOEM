function [R,Ra,R_fit,Ra_fit,dfacR,dfacRa,ind1] = Restimationnew(Q)
% JHnew = Q.JHnew-Q.BaJH;
% JLnew = Q.JLnew-Q.BaJL;
% JHnewa = Q.JHnewa-Q.BaJHa;
% JLnewa = Q.JLnewa-Q.BaJLa;
cutoffOV = Q.cutoffOV;
Zd = Q.Zmes2;
Za = Q.Zmes1;

if cutoffOV < 6000
    
    ind1 = Zd>=2000 & Zd< 4000;% If the cloud height is below full overlap % for 20110621 1-2km
    ind2 = Za>=800 & Za< 1800;% 1800 was changed
else
    ind1 = Zd>=6000 & Zd < 8000;%cutoffOV;% 6-8km
    ind2 = Za>=800 & Za< 1800;% 1800 was changed
    
end


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


% Diff_JHi = interp1(T,Diff_JH,Q.Tsonde,'linear');

Digital_ratio = JHnew ./JLnew ;
Analog_ratio = JHnewa./JLnewa;

R =  Digital_ratio'.*Ratio_diff_d;
Ra = Analog_ratio'.* Ratio_diff_a;

% X1 = Q.Zmes2./1000;
% X2 = Q.Zmes1./1000;
% Y1 = R;
% Y2 = Ra;

% figure1 = figure;
% 
% % Create axes
% axes1 = axes('Parent',figure1);
% hold(axes1,'on');
% 
% % Create semilogx
% plot(X1,Y1,'DisplayName','R','Color',[1 0 0]);
% 
% % Create semilogx
% plot(X2,Y2,'DisplayName','Ra','Color',[0 0 1]);
% 
% % Create xlabel
% xlabel('Altitude (km)');
% 
% % Create ylabel
% ylabel('R and Ra');
% 
% % Uncomment the following line to preserve the X-limits of the axes
% % xlim(axes1,[0 20]);
% box(axes1,'on');
% % Set the remaining axes properties
% set(axes1,'FontSize',20,'XMinorTick','on','XScale','linear');
% % Create legend
% legend(axes1,'show');



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

if cutoffOV < 6000
    
    ind1 = Zd>=2000 & Zd< 4000;% If the cloud height is below full overlap
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
