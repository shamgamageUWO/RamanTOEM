% This is to get the radiosonde files

function [Tsonde,Zsonde,Psonde] = get_sonde_RS92(date,time)
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



% if tin>5 && tin<17
% time= 12;
% elseif tin == 0
%     time = 0;
% else
% day = day+1;
% time =0;
% end


% here have to decide which sonde need to be used


Dateofthefolder =[yr  sprintf('%02.f',month) sprintf('%02.f',day) sprintf('%02.f',time)];



datadir = '/Users/sham/Documents/MATLAB/RALMO_Data/Sonde/RS92';

folder = [datadir filesep Dateofthefolder];
files = dirFiles(folder);
%Find the FLEDfile
FLEDTfile = strfind(files,'FLEDT.tsv');
FLEDTfile = find(~cellfun(@isempty,FLEDTfile));

if length(FLEDTfile)>1
    FLEDTfile = FLEDTfile(1);
end
  file = [folder filesep files{FLEDTfile}]
if exist(file, 'file')
        disp('ok')    
        fid = fopen(file); %create the file number
        C = textscan(fid, repmat('%n', 1, 20), 'headerlines', 40);
        rs92 = struct();
        rs92.min = C{1};
        rs92.sec = C{2};
        rs92.T = C{3};
        rs92.RH = C{4};
        rs92.v = C{5};
        rs92.u = C{6};
        rs92.z = C{7};
        rs92.P = C{8};
        rs92.TD = C{9};
        rs92.MR = C{10};
        rs92.DD = C{11};
        rs92.FF = C{12};
        rs92.AZ = C{13};
        rs92.EL = C{14};
        rs92.Range = C{15};
        rs92.Lon = C{16};
        rs92.Lat = C{17};
        
        
        Tsonde = rs92.T;
        Zsonde = rs92.z; % RALMO height
        Psonde = rs92.P;
        Psonde = Psonde.*100; % unit conversion hetaPas to Pascal
        fclose(fid);
        
else
    disp('No Sonde file found')
end

index1 = find(Psonde>0);
index2 = find(Tsonde>0);
Psonde = Psonde(index1);
Tsonde = Tsonde(index2);
Zsonde = Zsonde(index1);
 
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

