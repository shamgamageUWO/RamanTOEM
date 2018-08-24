function  [Tall,alt] = PlotTemperatureIterateTraditional(date_in,time)
%  date_in = 20110909;  
% % time = [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16];%20110910
%   time = [18, 19, 20, 21, 22, 23];% 20110909

% figure;
for i = 1:length(time)
    time_in = time(i);
 filename = sprintf('%d_%d.mat', date_in,time_in);   
load(filename);

 alt_an = T.alt_an(2:end);
 
m = length(alt_an);

    T_an(i,:) = T.T_an(2:m); 
    T_a= T_an(i,:);
    altanalog = alt_an(alt_an<=5000);
    Tanalog(i,:) = T_a(alt_an<=5000);
    
alt = T.alt_digi;    
n = length(alt);

    T_dg(i,:) = T.T_dg; 
    T_d= T_dg(i,:);
    altdg = alt(alt>=5000 & alt<=15000);
    Tdigital(i,:) = T_d(alt>=5000 & alt<=15000);
    
end
% hold off

alt = [altanalog ;altdg];
Tall  = [Tanalog Tdigital]; 

figure;
imagescnanEmily(time,alt./1000,Tall');
colorbar
set(gca,'YDir','normal');
title('Temperature Colormap','fontsize',20);
xlabel('Time (UTC)','fontsize',20);
ylabel('Alt (km)','fontsize',20);
set(gcf,'color','w');


% contourf(Z,10) this to drow contours ! 