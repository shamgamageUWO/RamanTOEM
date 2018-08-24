function power = LaserPower02(FileName,tstart,tstop, filetime,smoothit,allowdialog)

% Inputs: 
%  FileName - this is a cell array with filenames
%  tstart   - vector of standard times of the averaged files
%  tstop    - vector of standard stop times
%  filetime - the time ofaveraging of one file from Licel
%  allowdialog - flag - if 1 and no energy log file is found, opens a dialog
% Output:
%  power    - vector of oaveraged laser power for the averaged files 

% define which is the file of laser power
% it works over cell array 'FileName'
% use the first file name
% extract the path
% define path to look for ice laser power log file
% [pathstr, name, ext, versn] = fileparts(FileName{1});
[pathstr, name, ext] = fileparts(FileName{1});
% dos: ff = findstr('\',pathstr);
ff = findstr('/',pathstr);
path = pathstr(1:ff(end));
% list = dir(path);
list = dir([path,'Log EM*']);
filelindexes = ~[list(:).isdir]; % indexes of files only
files = {list(filelindexes).name}; % cellarray of file names
files = sort(files);

if (~isempty(findstr(files{end},'Log EM'))||~isempty(findstr(files{end},'Log PM')))
    % takes only the last file from all logs if in the name is found Log EM, LogPM 
    file = fullfile(path, files{end});   
elseif allowdialog
    %  requires user choice - more than two log files - several automat
    %  starts... 
    [file,path] = uigetfile('*.*','Select a laser power log file ', path);
    if isequal(file,0)
        errordlg('You cancelled the laser power log file selection. Please restart the application.');
        error('Cancelled choice of laser power log file');
    end
    file = fullfile(path, file); 
else
    file = '';
end

% extracts data from the file ---------------------------------------------
if ~isempty(file)
    [laserserialtime, laserpower] = LaserPowerImport(file);
else 
    laserserialtime = nan;
    laserpower = nan;
    error('Laser Power log not found');
end

if isempty(laserpower)
    power = [];
    return
end

if smoothit
laserpower = smooth (laserpower, 10); % moving average over the laser power
end
% plot(laserserialtime,laserpower);
% datetick('x',13);

% Extracts data form the log ----------------------------------------------
% from tstart(1) to tstop(end)

indexes = zeros(length(laserserialtime), length(tstart));
power   = zeros(length(tstart),1);
for col = length(tstart):-1:1
    delta = filetime/1440; % takes one more laser record ...
    indexes(:,col) = (laserserialtime >= (tstart(col)-delta)) & (laserserialtime <= (tstop(col)+delta));
    x = laserpower(logical(indexes(:,col)));
    power(col) = mean( x(~isnan(x)) );
end


end











