function data = LoadLicel(wb,FileName)

% data = LoadLicel(wb,FileName)
% Release 03 Version 3.2.
% 
% data = LoadLicel(1, 'C:\LidarData\2010.04.17\data\a1041700.080902')
% data = LoadLicel(1, {'C:\LidarData\2010.04.17\data\a1041700.080902'})
% data = LoadLicel(1, {'path of file 1', 'path of file 2', ...})
%
% Loads data files recorded by the data acquisition Licel. 
%
% Inputs:
% -------
% FileName:  Full pathname of a LIcel file or set of pathnames stored in 
%            array of cells including strings with the full file paths 
%            -> {'full file path 01', 'full file path 02', ...}
% 
% wb:        Use a waitbar to indicate the progres of file load (integer) 
%
% Outputs: 
% --------
% data:      Data structure including the signals recorded from all 
%            transient recorders. The structure is similar to Licel headers
%      
% data
%	|_ GlobalParameters
%	|       |_ Name         : Names of loaded files             (char array)                 
%	|       |_ Station      : Name of the station               (string)
%	|       |_ Start        : Start time of the files           (char array)
%	|       |_ End          : End time of the files             (char array)  
%	|       |_ HeightASL    : Station Height            [m]     (double)
%	|       |_ Latitude     : Station Latitude          [deg]	(double)
%	|       |_ Longitude	: Station Longitude         [deg]	(double)
%	|       |_ Channels     : Number of Active Channels         (double)
%	|
%	|_ Channel (i)
%           |_ isPhotonCounting : Is PhCount (T) or Analog (F)? (logical)
%           |_ Bins             : Number of bins                (double)
%           |_ Votage           : Voltage of the PMT	[V]     (double)
%           |_ BinSize          : Size of the bin       [m]     (double)
%           |_ Wavelength       : Detection wavelength	[nm]    (double)
%           |_ ADC              : Number of bits of the ADC     (double)
%           |_ Shots            : Number acquired shots         (double)
%           |_ Scale            : Voltage scale         [mV]    (double)
%           |                   :   or threschold level
%           |_ Transient        : Transient recorder no.0,1,..  (double)
%           |
%           |_ Signal           : Signal per laser shot per second 
%           |                       Analog digitized    [mV]    (array)
%           |                       Photon Counting     [MCPS]  (array)
%           |_ Range            : Altitude (AGL)        [m]     (array)
%           |                   
%           |_ Time             : Realtive time scale   [hours] (array)
% 
% Notes:
% ------
%   The function accepts string with full path name of a Licel file. 
%   It accepts as well cell array of strings with full pathnames of Licel
% files, user defined or created from the 'FindFiles03' function.
%   In case one more of the defined file paths does not exist the function 
% will exit with NaN as result. 
%   If run without defined files it opens a file selection window.
% 


if nargin == 2
    if ~iscell(FileName)
        % If a string is provided at the input
        FileName = {FileName};        
        
        if isempty(FileName{1}) || exist(FileName{1},'file')
            % If it is empty then assign to the ouput NaN and return
            data = NaN;
            warning('The provided files does not exist. Assigning NaN as a result for LoadLicel');
            return
        end
        
    else
        if all(cellfun(@exist, FileName))
            % If it is empty then assign to the ouput NaN and return
            FileName = sort(FileName);
            
        else
            % If there is by mistake a file that does not exist exit the
            % function 
            data = NaN;
            warning('One or more of the provided files does not exist. Assigning NaN as a result for LoadLicel');
            return
        end
        % If multiple files are provided then sort them 
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File selection GUI if no files

if nargin < 2
    % User interface to select files  
    [FileName,DirName] = uigetfile('*.*',...
                              'Select LICEL Files','MultiSelect','on');
    
    if isequal(FileName,0)
        % If Cancelled the FileName and PathName set the output to NaN 
        % and returns exitting the function 
        data = NaN;
        return  
        
    else
        % If files are selected 
        if ~iscell(FileName)
            % If only one file is selected
            FileName={FileName};
        else
            % If multiple files are selected
            FileName = sort(FileName);
        end
        FileName = strcat(DirName,FileName');
    end
end 

if nargin==0
    wb = 1;
end
wb=0; % !!!! haa
% cellfun(@exist, FileName)

% multiple file names - in a cell of strings
% single file name - one cell with string
% no file - cell with empty string

FileNumber = size(FileName,1);

if wb, 
    h = waitbar(0,'Loading the LICEL files'); 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over the number of files 

for k=FileNumber:-1:1 

    % [pathstr, name, ext] = fileparts( FileName{k} );
    % fid = fopen([pathstr, '/' ,name, ext],'r'); 
    
    % pointer to the beginning of the file
    fid = fopen(FileName{k},'r');
    
    if fid == -1 
        data = NaN;
        warning(['On ',datestr(now,'dd-mm-yyyy'),' at ',datestr(now,'HH:mm:ss'),' was not possible to open for reading one of the LICEL files files. Assigning NaN as a result for LoadLicel']);
        if wb, close(h); end
        return
        
    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Load LICELs Global parameters                                
        % created in Datafiles globallines.vi)                       
       
        data.GlobalParameters.Name(k,:)             = fscanf(fid,'%s',1);			% File name
        fseek(fid,80+1,'bof');
        if k == FileNumber
            data.GlobalParameters.Station			= fscanf(fid,'%s',1);			% Station name - whatever length of the string
        else
            fscanf(fid,'%s',1);
        end
        Day											= fscanf(fid,'%s',1);			% Start date
        Time										= fscanf(fid,'%s',1);			% Start time
        data.GlobalParameters.Start(k,:)    		= datestr(datenum([Day ' ' Time], 'dd/mm/yyyy HH:MM:SS')+1e-5);
        Day											= fscanf(fid,'%s',1);			% End date
        Time										= fscanf(fid,'%s',1);			% End time
        data.GlobalParameters.End(k,:)				= datestr(datenum([Day ' ' Time], 'dd/mm/yyyy HH:MM:SS')+1e-5); % do add 1e-5 in case the file neame is so exactly  precisely created in 00:00:00
        if k == FileNumber
            data.GlobalParameters.HeightASL         = fscanf(fid,'%f',1);			% Altitude
            data.GlobalParameters.Latitude			= fscanf(fid,'%f',1);			% Latitude
            data.GlobalParameters.Longitude         = fscanf(fid,'%f',1);			% Longitude
            %data.GlobalParameters.ZenithAngle		= fscanf(fid,'%f',1);			% Zenith angle
            fscanf(fid,'%f',1); % skips Zenith angle
        else
            fscanf(fid,'%f',4);
        end
        % data.GlobalParameters.Laser1Shots(k,:)        = fscanf(fid,'%f',1);       % Number of shots 1
        fscanf(fid,'%f',1);        	% Number of shots 1
        % if k == FileNumber
        %   data.GlobalParameters.Laser1Freq        = fscanf(fid,'%f',1);			% Frequency 1
        % else
        %   fscanf(fid,'%f',1);
        % end     
        fscanf(fid,'%f',1);         % Frequency 1
        
        fscanf(fid,'%f',1);			% Number of shots 2
        fscanf(fid,'%f',1);			% Frequency 2
        if k == FileNumber
            data.GlobalParameters.Channels			= fscanf(fid,'%f',1);			% Number of channels
        else
            fscanf(fid,'%f',1);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Loads LICELs Transient Parameters                    
        % created in Datafiles variablelines.vi             
       
        for i=1:data.GlobalParameters.Channels
            if k == FileNumber
                %data.Channel(i).isActive    			= fscanf(fid,'%f',1)'==1;		% is Active Channel?
                fscanf(fid,'%f',1); % Jump isActive
                isPhC									= fscanf(fid,'%f',1)';			% is Photon Counting?
                data.Channel(i).isPhotonCounting	    = isPhC==1;
                %data.Channel(i).LaserNumber     		= fscanf(fid,'%f',1)';			% Laser Number
                fscanf(fid,'%f',1); % Jump Laser Number
                data.Channel(i).Bins    				= fscanf(fid,'%f',1)';			% Number of bins
                %data.Channel(i).isHV    				= fscanf(fid,'%f',1);			% is HV on?
                fscanf(fid,'%f',1); % Jump is HV on
                data.Channel(i).Votage  				= fscanf(fid,'%f',1)';			% HV Voltage [V]
                data.Channel(i).BinSize     			= fscanf(fid,'%f',1)';			% Bin Size [m]
                data.Channel(i).Wavelength     			= fscanf(fid,'%f',1)';			% Wavelength [nm]
                %data.Channel(i).isParallel  			= fscanf(fid,'%c',1)=='p';		% is Parallel Polarisation?
                fscanf(fid,'%c',1); % Jump is parallel
                fseek(fid,11,'cof');													% Jump '0 0 00 000'
                data.Channel(i).ADC     				= fscanf(fid,'%f',1)';			% ADC Equivalent Resolution [bits]
            else
                fscanf(fid,'%f',8);
                fscanf(fid,'%c',1);
                fseek (fid,11,'cof');
                fscanf(fid,'%f',1);
            end
            data.Channel(i).Shots(k,:)                  = fscanf(fid,'%f',1)';			% Acquired Shots
            if k == FileNumber
                Scale									= fscanf(fid,'%f',1);			% Voltage Scale ...
                data.Channel(i).Scale   				= Scale * ...					% or Discriminator Level...
                    ((1000 * ~isPhC) + isPhC);    % [mV]
                fseek(fid,3,'cof');														% Jump 3 bytes
                data.Channel(i).Transient   			= fscanf(fid,'%f',1);			% Transient Number
            else
                fscanf(fid,'%f',1);
                fseek(fid,3,'cof');
                fscanf(fid,'%f',1);
            end
        end
        
        fseek(fid,80*(data.GlobalParameters.Channels+3),'bof');					% Go to end of header
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Loads LICELs Channels                                
        % created in Datafile Store Binary Data.vi          

        for i=1:data.GlobalParameters.Channels
            
            fseek(fid,2,'cof');														% Skip CR/LF
            
            if data.Channel(i).isPhotonCounting
                ScaleFactor = 150/data.Channel(i).BinSize;      					% Signal [MCPS] (Mega Counts Per Second)
            else
                ScaleFactor = data.Channel(i).Scale /2^data.Channel(i).ADC;     	% Signal [mV].
            end
            
            % Initialize the signal array
            if k == FileNumber
                data.Channel(i).Signal = zeros(...
                    data.Channel(i).Bins, ...
                    FileNumber);
            end
            
            DataVector = fread(fid, data.Channel(i).Bins, 'long');      			% Retrieve the channel bin information
            
            if length(DataVector) < data.Channel(i).Bins,
                
                data.Channel(i).Signal(:,k) = nan(data.Channel(i).Bins,1);
                warning(['LoadLicel.m ver.3.2. at ',datestr(now),' : Missing data within the loaded Licel file.']);
            else
                
                try
                    data.Channel(i).Signal(:,k)	= ...
                        DataVector * ScaleFactor / data.Channel(i).Shots(k);			% Signal [MCPS - Mega counts per second] or [mV] per shot !!! from number counts for the average time per bin
                catch err
                    % In case of missing data within the opened file
                    warning(err.getReport);
                    data.Channel(i).Signal(:,k) = nan(data.Channel(i).Bins,1);
                    clear err
                end
                
            end
            
            if k == FileNumber
                data.Channel(i).Range = ...
                    (1:data.Channel(i).Bins)' * data.Channel(i).BinSize;            % Range [m]
            end
            
            data.Channel(i).Time(k,:) =	...
                (datenum(data.GlobalParameters.Start(k,:)) + ...
                datenum(data.GlobalParameters.End(k,:))) / 2;
            
            if k == 1
                dataChannelTime = data.Channel(i).Time(1);
            end
        end
        fclose(fid);
    end
    
    % Update the waitbar
    if wb, 
        waitbar(1-k/FileNumber,h); 
    end
    
end

% Close the waitbar if opened
if wb, 
    close(h);
end; 

if length(data.GlobalParameters.Station)==1
    data.GlobalParameters.Station = data.GlobalParameters.Station{1};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Relative time axis

for i=1:length(data.Channel)
    %waitbar(i/length(data.Channel),h)
    data.Channel(i).Time = 24 * (data.Channel(i).Time - dataChannelTime);
end

%%%%%%%%%%%
% THE END %
%%%%%%%%%%%
end
