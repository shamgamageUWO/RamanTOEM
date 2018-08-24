function status = storedataWV01(altv, mrv, errv, Lidar, TreatedDataFolder, localTime, fileaveraging, numfiles, vvert, StartTime, constant)
% Writes to text file:
% Inputs:
% altv      - altitude vector to store in the file 
% mrv       - vertical profile (i.e. mixing ratio)
% altv      - vertical profile with relative error of the estimation 
% Lidar     - data structure from the LoadLidar.mat function 
% TreatedDataFolder     - folder to store the files 
% localTime - time flag for use of local time: local - 1; UTC - 0 
% fileaveraging         - time of data stored in one file  (1800 shots = 1 min)
% numfiles  - number of files that are averaged to get the data stored in the file
% vvert     - vector with min and max vertical resolutions [min max]
% Output: 
% status - the status form closing the file after being created (0 -> Ok; -1 -> problem)

    % Header Initialization
    FilesDate       = datestr(Lidar.GlobalParameters.Start(1,:), 'dd.mm.yyyy');
    if localTime,   TimeZone='local'; else TimeZone='UTC'; end;
    firstfiletime   = [datestr(Lidar.GlobalParameters.Start(1,:),'HH:MM:SS'),' ',TimeZone];
    lastfiletime    = [datestr(Lidar.GlobalParameters.End(end,:),'HH:MM:SS'),' ',TimeZone];
    filename        = ['ralmo_',datestr(StartTime, 'yymmdd_HHMM'),'.txt']; % to be changed with middle time
    %
    station     = Lidar.GlobalParameters.Station(1,1:end);
    height      = Lidar.GlobalParameters.HeightASL(1,1:end);
    latitude    = Lidar.GlobalParameters.Latitude(1,1:end);
    longitude   = Lidar.GlobalParameters.Longitude(1,1:end);
    %
    % Header 
    h01	= sprintf('RALMO - water vapor mixing ratio data\n');
    h02 = sprintf(['Station: ',station,'\n']);
    h03 = sprintf('Coordinates:\n');
    h04 = sprintf('Latitude: %g \n',latitude);
    h05 = sprintf('Longitude: %g \n',longitude);
    h06 = sprintf('Altitude: %g, m\n\n',height);
    h07 = sprintf(['Date: ',FilesDate,'\n']);
    h08 = sprintf(['Start time: ',firstfiletime, '\n','Stop  time: ',lastfiletime,'\n\n']);
    h09 = sprintf('Raw data averaging: %d, min\n',fileaveraging);
    h10 = sprintf('Averaged files: %d\n',numfiles);
    h11 = sprintf('Variable resolution: %d to %d m\n',vvert(1),vvert(2));
    h12 = sprintf('Calibration: %.3f \n\n',constant);
    h13 = sprintf('Alt[m], mr[g/kg], RelErr \n\n');
    %
    header  = [h01 h02 h03 h04 h05 h06 h07 h08 h09 h10 h11 h12 h13];
    %
    % Opens a 'file pipe' 
    fn  = fullfile(TreatedDataFolder, filename); % Includes the folder
    fid = fopen(fn,'wt');
    %
    % Writes the header in the 'file pipe'
    fprintf(fid,header);
    %
    % Stores data in 'file pipe' 
    y=[altv';mrv';errv'];
    fprintf(fid,'%05d,  %09.6f,   %06.4f\n',y);
    %
    % Close the file 
    status = fclose(fid);
end