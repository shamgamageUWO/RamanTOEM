% This is to get the radiosonde files

function [Tsonde,Zsonde,Psonde]=get_Sonde_C50(date,tin)
% date =20110607;
% tin=20110607110917; % format yyyymmddHHMMSS;
% tfi=20110607181927;


[year,month,day] = getYMDFromDate(date);
yr = num2str(year);

% tfixed1 = 110000;
% tfixed2 = 130000;
% 
% tf1=[yr  sprintf('%02.f',month) sprintf('%02.f',day) sprintf('%02.f',tfixed1)];
% tf2=[yr  sprintf('%02.f',month) sprintf('%02.f',day) sprintf('%02.f',tfixed2)];



if tin>5 && tin<17
time= 12;
else
    time = 0;
day = day+1;
end


% here have to decide which sonde need to be used


Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day) sprintf('%02.f',time)];



datadir = '/Users/sham/Documents/MATLAB/RALMO_Data/Sonde/C50';

folder = [datadir filesep Dateofthefolder];
file= [folder '/' Dateofthefolder '.csv'];


  
 if exist(file, 'file')
         disp('operational Sonde file exsist')    
        fid = fopen(file); %create the file number
C = textscan(fid, '%n%s%s%n%s%s%n%n%n%n%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', 'Delimiter', ';','headerlines', 48);
         C50 = struct();
         
          C50.RealTime = C{1};
         C50.Date = C{2};
         C50.Time = C{3};
         C50.z = C{4};
         C50.winddirectio = C{5};
         C50.windspeed = C{6};
         C50.P = C{7};
         C50.T = C{8};
         C50.HU = C{9};
         C50.DP = C{10};
         C50.Ozone = C{11};
         C50.Ozonenorm = C{12};
         C50.PumpT= C{13};
         C50.a = C{14};
         C50.b = C{15};
         C50.c = C{16};
         C50.d = C{17};
        
%         
        Tsonde = C50.T; % K
        Tsonde = Tsonde +273.15;
        Zsonde = C50.z;
        Psonde = C50.P;%Pa
        Psonde = Psonde.*100;
        fclose(fid);
%         
else
    disp('No Sonde file found')
end

%     if exist(file, 'file')
%         disp('ok')
%         fid = fopen(file);
%         C = textscan(fid,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','headerlines',39);
%         fclose(fid);
%         [ rs92.time, rs92.pr, rs92.T, rs92.rh, rs92.v, rs92.u, rs92.z, rs92.p, rs92.TD, rs92.MR, rs92.DD, rs92.FF,rs92.AZ, rs92.zx, rs92.zg, rs92.zy,rs92.zyy, rs92.zi, rs92.zj]  = C{:};
% %         figure;plot(rs92.T,rs92.z)
%          rs92.T = rs92.T;
%     Tsonde = rs92.T;
%     Zsonde = rs92.z;
%     else
%         newfile = [datadir filesep Dateofthefolder filesep 'EDT_PTULevels.tsv']
%           disp('file EDT_PUTLevels exist')
%         fid = fopen(newfile);
%         C = textscan(fid,'%f%f%f%f%f%f%f%s%s%s%s','headerlines',49);
%         fclose(fid);
%         [ rs92.timemin, rs92.timesec,rs92.p, rs92.z, rs92.T, rs92.rh, rs92.dew, rs92.flag1, rs92.flag2,rs92.flag3,rs92.flag4]  = C{:};
%          rs92.T = rs92.T+273.15;
%     Tsonde = rs92.T;
%     Zsonde = rs92.z;
%         
%     end
   
    
% Interpolatedz = 2.5012e+03:37.5*2:2.1964e+04;
% Z = Zsonde((Zsonde>=2500) & (Zsonde <= 22000));
% TT= Tsonde((Zsonde>=2500) & (Zsonde <= 22000));
% 
% T= interp1(Z,TT,Interpolatedz,'spline');
% Tsonde= T';
% Zsonde = Interpolatedz';    
% figure;plot(Tsonde,Zsonde)
% Here we can interpolate the T and RH to fit with the lidar 

