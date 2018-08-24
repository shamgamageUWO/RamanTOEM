% Mean plotting

date1 = 20110909;
time1 = [ 19 20 21 22 23];
[TOEM1,alt1,time1] = PlotTemperatureIterate(date1,time1);

date2 = 20110910;
time2 = [00 01 02 03 04 05];
[TOEM2,alt2,time2] = PlotTemperatureIterate(date2,time2);

MeanT_night = (nanmean(TOEM1) + nanmean(TOEM2))./2;
T_night_all= [TOEM1; TOEM2];
T_night_avgremoved = T_night_all - MeanT_night;



time3 = [06 07 08 09 10 11 12 13 14 15 16];
[TOEM3,alt3,time3] = PlotTemperatureIterate(date2,time3);
T_day_avgremoved = TOEM3 - nanmean(TOEM3);


T_all = [T_night_avgremoved ;T_day_avgremoved];
 for i = 1:22
T_smoothen(:,i) = smooth(T_all(i,:),16);% 15*18 = 240m resolution
end

% alt = smooth(alt1,7);
tin = 1:22;
close all;
figure;
 imagescnanEmily(tin,alt1./1000,T_smoothen);
% imagescnanEmily(time,alt./1000,Tmeanplot');
colorbar
set(gca,'YDir','normal');
title('OEM Temperature','fontsize',20);
xlabel('Time (UTC)','fontsize',20);
ylabel('Alt (km)','fontsize',20);
set(gcf,'color','w');