function status = storedataEXT(data, ext, TreatedDataFolder, ...
                                    localTime, fileaveraging, numfiles, ...
                                        BinsOrVector, StartTime)
                                    
% status = storedataASR01(data, EXT, TreatedDataFolder, ...
%                           localTime, fileaveraging, numfiles, ...
%                                 BinsOrVector, StartTime)
% Writes to text file:
% data              - data structure from LoadLicel function 
% EXT               - Result structure from AerosolExtinction02.m 
% TreatedDataFolder - folder to store the files 
% localTime         - time flag for use of local time: local - 1; UTC - 0 
% fileaveraging  	- time of data stored in one file  (1800 shots = 1 min)
% numfiles          - number of files that are averaged to get the data stored in the file
% BinsOrVector      - vector with min and max vertical resolutions [min max]
% StartTime         - The time of data treat
% Output: 
% status - the status form closing the file after being created (0 -> Ok; -1 -> problem)

    % Header Initialization
    FilesDate       = datestr(data.GlobalParameters.Start(1,:), 'dd.mm.yyyy');
    %
    if localTime, TimeZone='local'; else TimeZone='UTC'; end;
    %
    firstfiletime   = [datestr(data.GlobalParameters.Start(1,:) ,'HH:MM:SS'),' ',TimeZone];
    lastfiletime    = [datestr(data.GlobalParameters.End(end,:),'HH:MM:SS'),' ',TimeZone];
    filename        = ['Ralmo_EXT_',datestr(StartTime, 'yymmdd_HHMM'),'.txt']; % to be changed with middle time
    %
    station     = data.GlobalParameters.Station(1,1:end);
    height      = data.GlobalParameters.HeightASL(1,1:end);
    latitude    = data.GlobalParameters.Latitude(1,1:end);
    longitude   = data.GlobalParameters.Longitude(1,1:end);
    %
    % Header 
    h01	= sprintf('RALMO - Aerosol Extinction \n');
    h02 = sprintf(['Station: ',station,'\n']);
    h03 = sprintf('Coordinates:\n');
    h04 = sprintf('Latitude: %g \n',latitude);
    h05 = sprintf('Longitude: %g \n',longitude);
    h06 = sprintf('Altitude: %g, m\n\n',height);
    h07 = sprintf(['Date: ',FilesDate,'\n']);
    h08 = sprintf(['Start time: ',firstfiletime, '\n','Stop  time: ',lastfiletime,'\n\n']);
    h09 = sprintf('Raw data averaging: %d, min\n',fileaveraging);
    h10 = sprintf('Averaged files: %d\n',numfiles);
    h11 = sprintf('Variable resolution\n');
    h12 = sprintf('Alt[m],  EXT,      , RelErr\n\n');
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
    % Defines index for 'good' data with enough precision 
    ind = 1:length(ext.z);
    % Stores data in 'file pipe'
    y=[ext.z(ind)';ext.ext(ind)';ext.relerr(ind)'];
    fprintf(fid,'%6.1f,  %09.8f, %03.1f \n',y);
    %
    % Close the file 
    status = fclose(fid);
end
