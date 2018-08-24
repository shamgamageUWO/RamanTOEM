function status = storedataBCKS(data, bcks, TreatedDataFolder, ...
                                    localTime, fileaveraging, numfiles, ...
                                        BinsOrVector, StartTime)
                                    
% status = storedataASR01(data, bcks, TreatedDataFolder, ...
%                           localTime, fileaveraging, numfiles, ...
%                                 BinsOrVector, StartTime)
% Writes to text file:
% data              - data structure from LoadLicel function 
% bcks           - Result structure from AerosolScatteringRatio02.m 
% TreatedDataFolder - folder to store the files 
% localTime         - time flag for use of local time: local - 1; UTC - 0 
% fileaveraging  	- time of data stored in one file  (1800 shots = 1 min)
% numfiles          - number of files that are averaged to get the data stored in the file
% BinsOrVector      - vector with min and max vertical resolutions [min max]
% StartTime         - The time of data treat
% Output: 
% status - the status form closing the file after being created (0 -> Ok; -1 -> problem)

if sum(~isnan(bcks.profile))==0
    status=0;
    return
end

    % Header Initialization
    FilesDate       = datestr(data.GlobalParameters.Start(1,:), 'dd.mm.yyyy');
    %
    if localTime, TimeZone='local'; else TimeZone='UTC'; end;
    %
    firstfiletime   = [datestr(data.GlobalParameters.Start(1,:) ,'HH:MM:SS'),' ',TimeZone];
    lastfiletime    = [datestr(data.GlobalParameters.End(end,:),'HH:MM:SS'),' ',TimeZone];
    filename        = ['Ralmo_BCKS_',datestr(StartTime, 'yymmdd_HHMM'),'.txt']; % to be changed with middle time
    %
    station     = data.GlobalParameters.Station(1,1:end);
    height      = data.GlobalParameters.HeightASL(1,1:end);
    latitude    = data.GlobalParameters.Latitude(1,1:end);
    longitude   = data.GlobalParameters.Longitude(1,1:end);
    %
    % Header 
    h01	= sprintf('RALMO - Aerosol Backscatter \n');
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
        h11 = sprintf('Fixed resolution: %d m\n',BinsOrVector*3.75);
    else
        h11 = sprintf('Variable resolution\n');
    end
    h12 = sprintf('ASR Calibration: %f\n',bcks.cal);
    h14 = sprintf('OK flag: %d\n\n', bcks.okflag*1);
    h15 = sprintf('Alt[m],\t  Backscatter [1/m/sr],\t AbsErr [1/m/sr],\t  RelErr [percent]\n\n');
    %
    header  = [h01 h02 h03 h04 h05 h06 h07 h08 h09 h10 h11 h12 h14 h15];
    %
    % Opens a 'file pipe' 
    fn  = fullfile(TreatedDataFolder, filename); % Includes the folder
    fid = fopen(fn,'wt');
    %
    % Writes the header in the 'file pipe'
    fprintf(fid,header);
    %
    % Defines index for 'good' data with enough precision 
    ind = 1:length(bcks.profile);
    % Stores data in 'file pipe'
    y=[bcks.z(ind)';bcks.profile(ind)';bcks.abserr(ind)'; bcks.relerr(ind)'];
    fprintf(fid,'%06d,\t  %d,\t %d,\t\t %06.4f \n',y);
    %
    % Close the file 
    status = fclose(fid);
end
