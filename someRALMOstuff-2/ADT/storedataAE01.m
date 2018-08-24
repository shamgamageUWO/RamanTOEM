function status = storedataAE01(altv, absv, data, TreatedDataFolder, localTime, fileaveraging, numfiles, BinsOrVector, StartTime)
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

if isempty(absv)
    status=0;
    return
end

    % Header Initialization
    FilesDate       = datestr(data.tstart(1), 'dd.mm.yyyy');
    %
    if localTime, TimeZone='local'; else TimeZone='UTC'; end;
    %
    firstfiletime   = [datestr(data.tstart(1) ,'HH:MM:SS'),' ',TimeZone];
    lastfiletime    = [datestr(data.tstop(end),'HH:MM:SS'),' ',TimeZone];
    filename        = ['ralmo_abs_',datestr(StartTime, 'yymmdd_HHMM'),'.txt']; % to be changed with middle time
    %
    station     = data.GlobalParameters.Station(1,1:end);
    height      = data.GlobalParameters.HeightASL(1,1:end);
    latitude    = data.GlobalParameters.Latitude(1,1:end);
    longitude   = data.GlobalParameters.Longitude(1,1:end);
    %
    % Header 
    h01	= sprintf('RALMO - attenuated backscatter\n');
    h02 = sprintf(['Station: ',station,'\n']);
    h03 = sprintf('Coordinates:\n');
    h04 = sprintf('Latitude: %g \n',latitude);
    h05 = sprintf('Longitude: %g \n',longitude);
    h06 = sprintf('Altitude: %g, m\n\n',height);
    h07 = sprintf(['Date: ',FilesDate,'\n']);
    h08 = sprintf(['Start time: ',firstfiletime, '\n','Stop  time: ',lastfiletime,'\n\n']);
    h09 = sprintf('Raw data averaging: %d, min\n',fileaveraging);
    h10 = sprintf('Averaged files: %d\n',numfiles);
    if length(BinsOrVector)==1,
        h11 = sprintf('Fixed resolution: %d m\n\n',BinsOrVector*3.75);
    else
        h11 = sprintf('Variable resolution\n\n');
    end
    h12 = sprintf('Alt[m], P.r^2[a.u.]\n\n');
    %
    header  = [h01 h02 h03 h04 h05 h06 h07 h08 h09 h10 h11 h12];
    %
    % Opens a 'file pipe' 
    fn  = fullfile(TreatedDataFolder, filename); % Includes the folder
    fid = fopen(fn,'wt');
    %
    % Writes the header in the 'file pipe'
    fprintf(fid,header);
    %
    % Stores data in 'file pipe' 
    y=[altv';nanmean(absv,2)'];
    fprintf(fid,'%05d,  %06.3f \n',y);
    %
    % Close the file 
    status = fclose(fid);
% end
