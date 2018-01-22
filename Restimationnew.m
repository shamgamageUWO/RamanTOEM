function [R,Ra,R_fit,Ra_fit] = Restimationnew(Q)
% JHnew = Q.JHnew-Q.BaJH;
% JLnew = Q.JLnew-Q.BaJL;
% JHnewa = Q.JHnewa-Q.BaJHa;
% JLnewa = Q.JLnewa-Q.BaJLa;
N1 = length(Q.JHnewa);

% % Desaturate the signal
%         % 1. Make the Co added counts to avg counts
%         JHn = Q.JHnew./(Q.deltatime.*Q.coaddalt);
%         JLn = Q.JLnew./(Q.deltatime.*Q.coaddalt);
%         
%         % 2. Convert counts to Hz
%         JHnwn = (JHn.*Q.f);
%         JLnwn = (JLn.*Q.f);
% 
%         
%         % 3. Apply DT correction
%         JL_dtc = JLn ./ (1 - JLnwn.*(Q.deadtimeJL)); % non-paralyzable
%         JH_dtc = JHn ./ (1 - JHnwn.*(Q.deadtimeJH));
% 
% 
% 
% %        % 5. Scale bacl to coadded signal    
%        JLnew = JL_dtc.*(Q.deltatime.*Q.coaddalt);
%        JHnew = JH_dtc.*(Q.deltatime.*Q.coaddalt);
%        
%       ind1 = Q.Zmes2>50e3; 
% %      
%       bkg_JL = JLnew(ind1);
%      BaJL_t = nanmean(bkg_JL);
%     bkg_JH = JHnew(ind1);
%      BaJH_t = nanmean(bkg_JH);

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


 Alt = Q.Zmes2;
 ind1 = Alt >= 8000 & Alt< 10000;
% 
 x = 1./Ratio_diff_d(ind1);
 y = Digital_ratio(ind1);
% 
 f = fittype({'x'});
fit3 = fit(x',y,f,'Robust','on');
R_fit = fit3(1);
% 

% %% analog
Alt2 = Q.Zmes1;
ind2 = Alt2 >= 2000 & Alt2 <= 2200;
 xa = 1./Ratio_diff_a(ind2);
 ya = Analog_ratio(ind2);

fa = fittype({'x'});
fit3a = fit(xa',ya,fa,'Robust','on');
Ra_fit = fit3a(1);

figure;plot(Q.Zmes2./1000,R,'r',Q.Zmes1./1000,Ra,'b')
xlabel('Alt(km)')
ylabel('R or Ra')
legend('R','Ra')

%%
