function [serialtime, laserpower] = LaserPowerImport(FileName)

% import energy/power measurement
% works with characters so put {FileName} if the input is cell array

if nargin == 0
    [FileName,DirName] = uigetfile('*.*', 'Select laser power file');
    FileName = strcat(DirName,FileName);
end

% read import the data

powerdata = importdata(FileName, ' ', 0);

if isempty(powerdata)
    laserpower = [];
    serialtime = [];
    return
end

% serial time string
t = cell2mat(powerdata.textdata);
serialtime = datenum(t, 'dd.mm.yyHH:MM:SS');

% power measurement

laserpower = powerdata.data;

end