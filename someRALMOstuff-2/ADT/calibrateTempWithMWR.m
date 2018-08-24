function Temp = calibrateTempWithMWR(Temp, config)

% check if lidar temp profile available
if isempty(Temp.profile)==1
    disp('calibrateTempWithMWR: No lidar temperature profile available.')
    return
end

% find MWR bulletin
files = dir(fullfile(config.MWRFolder, sprintf('%s%s*',config.ini.dTE.MWRBulletinBasename,datestr(config.t0-1/96,'yyyymmddHH'))));

% return, if no files are found
if isempty(files)
    disp('No MWR data files found. No MWR calibration done.')
    return
end

% determine time
t=nan(1,length(size(files)));
for i=1:length(files)
    t(i) =  datenum(files(i).name(8:19),'yyyymmddHHMM');
end

% find indices within lidar integration period
ind = find(t>=config.t0-1/48 & t<=config.t0);

% return, if no files within integration interval
if isempty(ind)
    disp('No MWR data for observation period found. No MWR calibration done.')
    return
end

% load data
r=0;
for i=ind
    % increment counter
    r=r+1;
    
    % read data from file
    mwr = read_mwp_from_bulletin(fullfile(config.MWRFolder, files(i).name),Temp.z);
    
    % write to matrix T
    T(:,r) = mwr.T;
    
end

% take mean value of MWR T profiles
T = mean(T,2);


% find indices within calibration interval
ii = find(Temp.z>=config.ini.dTE.MWRCalibInterval(1) & Temp.z<=config.ini.dTE.MWRCalibInterval(2));
D1 = Temp.profile(ii);
D2 = T(ii);

% return, if there are no data in the calibration interval
if isempty(D1) | isempty(D2)
    disp('No overlap for MWR calibration. No MWR calibration done.')
    return
end

% fit using y=C*x
ft = fittype({'x'});
[cf gof] = fit(D1,D2,ft);

C = cf.a;
dC = diff(confint(cf))/2;


% write scaled temperature profile
Temp.profile = C*Temp.profile;

% give message
disp('MWR recalibration successful')
