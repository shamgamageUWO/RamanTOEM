
function filearray = FindFiles03(startPath,subFolder,starttime,T,t,wb)
%
% _________________________________________________________________________
%
% filearray = FindFiles03(startPath,subFolder,starttime, T, t, wb)
% Release 03 Version 03
% _________________________________________________________________________
%
% FindFiles03('C:\LidarData','data',starttime,T,t,wb)
%
% Extracts the names of Licel data files created within the time range:
% [starttime, starttime - T] 
%
%    FindFiles03('C:\LidarData','data',datenum([2010 07 17 12 30 0),30,1,1)
%    FindFiles03('C:\LidarData','data',now,30,1),  wb = 0
%    FindFiles03('C:\LidarData','data',now,30),    t = 1, wb = 0
%    FindFiles03('C:\LidarData','data',now),       T = 30, t = 1, wb = 0
%
%
% Inputs:
% -------
% startPath: Folder with Lidar data (string) -> 'C:\LidarData' 
% subFolder: Subfolder name (string) -> 'data'  
% starttime: Timestamp defining the start of search (serial date number) 
% T:         Period in minutes for time averaging (integer)
% t:         Averaging time in minutes of one file (integer)
% wb:        Use a waitbar to indicate the progres of file search (integer)
%
% Output: 
% -------
% filearray: The full paths to the files (array of cells with strings) 
%               Example -> 'C:\LidarData\2010.04.17\data\a1041700.080902' 
% 
% 
% Functions: LicelFileTime.m
% ----------
%
% Notes: 
% ------
% If the extracted files from the defined folder are less then expected the 
%   function will try to look for files in a folder from the previous day.
% The function allows to be run with minimum three input arguments. Each 
%   missing input argument will be assumed equal to: T=30, t=1, and wb=0.
% Two and less input arguments leat to error and the function will return 
%   an empty array of cells with full filepaths -> filearray = {''}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Argument selection

if nargin < 6,
    wb = 0;
elseif nargin < 5
    t=1;     %[min]
elseif nargin < 4,
    T=30;    %[min]    
elseif nargin < 3,
    filearray = {''};
    error('Not enough input arguments ''FindFiles03.m''');
end

wb=0; % !!!! haa

wb = logical(wb);

% Caution !!! Only for debug purposses!
% Do use the following lines for internal initializationof the function
% starttime = datenum([2008 02 22 23 05 00]);
% startPath   =   'H:\- Lidar Data -';
% subFolder   =   'data';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find Files
% Works with the filenames - therefrom it extracts the time
% filename -> 'a07C3101.544821'
% Uses LicelFileTime(filename) to extract file time

% Creates today's data folder
todayFolder	=   fullfile( startPath,datestr(starttime,'yyyy.mm.dd'),subFolder);
  
% Creates yesterday's data folder
yestDate    =   addtodate( starttime,-1,'day');
yestFolder  =   fullfile( startPath,datestr(yestDate,'yyyy.mm.dd'),subFolder);

% Utilities
minTOdays = @(min) min / 1440;

% folderlist - is consisting of folders to be cheked for files ...
folderlist = {todayFolder,yestFolder};
folderlist = folderlist(cellfun(@isdir,{todayFolder,yestFolder}));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Defines the start and stop time of the files which are going to be used
% start   =   starttime - minTOdays(T) + minTOdays(0.5*t);
% 0.5 is an 'overlapping' coefficient; non 'overlapping' files use 1*t; for
% 0*t it will consider the stored 'creation time of the file' as the 
% start time of data averaging which has been stored to the file.   

% Creates 'start' timestamp from the current time or from 'starttime'
start   =   starttime - minTOdays(T);                      

% Creates 'stop' timestamp from the current time or from 'starttime'
stop    =   starttime - minTOdays(t) + minTOdays(1*t);    

% How many files are needed (Not used search for stop file)
Nfiles  =   T/t-1;    

% Waitbar pop up
if wb, 
    clear h
    h = waitbar(0.1,'Searching for availiable raw data files...'); 
end

% Predefinitions for the following cycle
filearray={''};
extractedfiles = 0;

% Start of the search
for folderi = 1:length(folderlist)    
    
    % Cycle on folders
    if extractedfiles < Nfiles 
        % Extracts the files from the 'todayFolder' or 'yestFolder'
        % It will check the second folder only if the extracted files are
        % not enough -> Caution!
        files   =   dir(folderlist{folderi});
        
        % Finds number of subfolders
        % folders =   sum(cell2mat({files.isdir})); %for now - not used
        % All files within the start stop interval -> in cell 'filearray'
        ii = length(files);
        
        % Cycle on files - skips the '.' and '..' folders
        while extractedfiles < Nfiles && ii>0
            
            % Checks only files (not folders), skips 'temp.dat' and '*.zip'
            properfiles =  ~(files(ii).isdir) && ...
                            isempty(strfind(files(ii).name,'temp')) && ...
                            isempty(strfind(files(ii).name,'zip'));                        
            if properfiles
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % The actual selection of files
                if (LicelFileTime(files(ii).name) >= start) && ...
                        (LicelFileTime(files(ii).name) <= stop)
                    
                    extractedfiles = extractedfiles + 1;
                    
                    filearray(extractedfiles) = ...
                        {fullfile(folderlist{folderi},files(ii).name)};
                    %{files(ii).name};
                    
                end
                % End of actual file selection
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            end
            ii = ii-1;
            if wb, waitbar(1-ii/length(files),h); end
            
        end
        % End of cycle on files
        
    end
    % End of cycle on folders
    
    if wb, waitbar( 1 - (folderi/length(folderlist)),h); end
    
end

% Close the waitbar
if wb, close(h); end;

% Assigns the result
filearray = sort(filearray)';

clear h

end
