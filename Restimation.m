function [R,Ra,R_fit,Ra_fit] = Restimation(Q)
JHnew = Q.JHnew-Q.BaJH;
JLnew = Q.JLnew-Q.BaJL;
JHnewa = Q.JHnewa-Q.BaJHa;
JLnewa = Q.JLnewa-Q.BaJLa;
N1 = length(Q.JHnewa);

[Tsonde,Zsonde,Psonde] = get_sonde_RS92(Q.date_in,Q.time_in);
Ti = interp1(Zsonde,Tsonde,Q.Zmes,'linear'); % T on data grid (digital)

% Ti = interp1(Q.Zret,Q.Ta,Q.Zmes,'linear'); % T on data grid (digital)

%% loading cross sections
load('DiffCrossSections.mat');
Diff_JHi = interp1(T,Diff_JH,Ti,'linear');
Diff_JLi = interp1(T,Diff_JL,Ti,'linear');

Ratio_diff = Diff_JLi./Diff_JHi;

Digital_ratio = JHnew./JLnew;
Analog_ratio = JHnewa./JLnewa;

R =  Digital_ratio'.*Ratio_diff(Q.d_alti_Diff+1:end);
Ra = Analog_ratio'.* Ratio_diff(1:N1);

X1 = Q.Zmes2./1000;
X2 = Q.Zmes1./1000;
Y1 = R;
Y2 = Ra;

figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% Create semilogx
semilogx(X1,Y1,'DisplayName','R','Color',[1 0 0]);

% Create semilogx
semilogx(X2,Y2,'DisplayName','Ra','Color',[0 0 1]);

% Create xlabel
xlabel('Log Altitude (km)');

% Create ylabel
ylabel('R and Ra');

% Uncomment the following line to preserve the X-limits of the axes
% xlim(axes1,[0 20]);
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'FontSize',20,'XMinorTick','on','XScale','log');
% Create legend
legend(axes1,'show');


 Alt = Q.Zmes2;
 ind1 = Alt >= 8000 & Alt< 10000;
% 
 x = 1./Ratio_diff(ind1);
 y = Digital_ratio(ind1);
% 
 f = fittype({'x'});
fit3 = fit(x',y,f,'Robust','on');
R_fit = fit3(1);
% 

% %% analog
Alt2 = Q.Zmes1;
ind2 = Alt2 >= 1500 & Alt2 <= 1700;
 xa = 1./Ratio_diff(ind2);
 ya = Analog_ratio(ind2);

fa = fittype({'x'});
fit3a = fit(xa',ya,fa,'Robust','on');
Ra_fit = fit3a(1);
%%
