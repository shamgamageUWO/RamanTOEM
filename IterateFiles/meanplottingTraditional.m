% Mean plotting

date1 = 20110909;
time1 = [ 19 20 21 22 23];
[Tall1,alt1] = PlotTemperatureIterateTraditional(date1,time1);

date2 = 20110910;
time2 = [00 01 02 03 04 05];
[Tall2,alt2] = PlotTemperatureIterateTraditional(date2,time2);

MeanT_night = (nanmean(Tall1) + nanmean(Tall2))./2;
T_night_all= [Tall1; Tall2];
T_night_avgremoved = T_night_all - MeanT_night;



time3 = [06 07 08 09 10 11 12 13 14 15 16];
[Tall3,alt3] = PlotTemperatureIterateTraditional(date2,time3);
T_day_avgremoved = Tall3 - nanmean(Tall3);


T_all = [T_night_avgremoved ;T_day_avgremoved];
tin = 1:22;

 for i = 1:22
T_smoothen(:,i) = smooth(T_all(i,:),16);% 15*18 = 240m resolution
end
close all

figure;
 imagescnanEmily(tin,alt1./1000,T_smoothen);
% imagescnanEmily(time,alt./1000,Tmeanplot');
colorbar
set(gca,'YDir','normal');
title('Traditional Temperature','fontsize',20);
xlabel('Time (UTC)','fontsize',20);
ylabel('Alt (km)','fontsize',20);
set(gcf,'color','w');