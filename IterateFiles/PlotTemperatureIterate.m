function [TOEM,alt,time] = PlotTemperatureIterate(date_in,time)
%  time = [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16];%20110910
%   time = [19 20 21 22 23];% 20110909
%  date_in = 20110909;
% figure;
for i = 1:length(time)
    time_in = time(i);
 filename = sprintf('%d_%d.mat', date_in,time_in);   
load(filename);
m = length(Q.Zret);
    Toem(i,:) = X.x(1:m); 
    T= Toem(i,:);
    % Create plot
%     plot(T(Q.Zret<=30000),Q.Zret(Q.Zret<=30000)./1000,'DisplayName','T OEM');
%      hold on;
%     % Create plot
%     plot(Q.Tsonde2(Q.Zret<=30000),Q.Zret(Q.Zret<=30000)./1000,'DisplayName','T sonde','Color',[0 0 1]);
%     
     alt = Q.Zret(Q.Zret<=20000);
     TOEM(i,:) = T(Q.Zret<=20000);
end
% hold off
% Tavg = nanmean(TOEM);
% Tmeanplot = TOEM - Tavg;

figure;
 imagescnanEmily(time,alt./1000,TOEM');
% imagescnanEmily(time,alt./1000,Tmeanplot');
colorbar
set(gca,'YDir','normal');
title('OEM Temperature','fontsize',20);
xlabel('Time (UTC)','fontsize',20);
ylabel('Alt (km)','fontsize',20);
set(gcf,'color','w');


% contourf(Z,10) this to drow contours ! 