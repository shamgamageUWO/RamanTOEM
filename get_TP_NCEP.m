function [z,T,P]=get_TP_NCEP(date,hour,latitude,longitude,varargin)
% Provide Pressure and temperature from NCEP/NCAR Reanalysis Model
% Model resolution is 6 hours, 2.5 degree x 2.5 degree ,17 vertical steps
% More info. http://www.esrl.noaa.gov/psd/data/gridded/data.ncep.reanalysis.html
%
% INPUT:
%   date : date (format 'yyyymmdd' or number)
%   hour: hour MUST be 00,60 12 or 18 (format ''HH' or number)
%   latitude: latitude (in degree)
%   longitude: longitude (in degree)
%   z : altitude above see level (vector in m) (optionnal)
%   folder: path to folder where NCEP data are stored (optional)
%
% OUPUT:
% z, altitude abose sea level in m
% T temperature in K
% P Pressure in hPA
%
% Function summary:
% -download Files from NCEP ftp if needed (ftp.cdc.noaa.gov)
% -Read  T and HGT files
% -interpolate pressure and temperature for a set latitude and longitude
% -interpolate for altitude
%
% example of use:
%  [z,T,P]=get_TP_NCEP('20140625','00',46.82,6.95,0:100:15000,'C:\DATA\');
%
% By M.Hervo (MeteoSwiss) 06/2014
%
% Citation
% "If you use NCEP Reanalysis data products from PSD, we ask that you acknowledge us in your use of the data.
% This may be done by including text such as NCEP Reanalysis data provided by the NOAA/OAR/ESRL PSD, Boulder, Colorado, USA, from their Web site at http://www.esrl.noaa.gov/psd/"


%% check input
disp('Get T P data from NCEP')
if nargin==0
    warning('Default values')
    date='20141231';
    hour='00';
    latitude=46.82;
    longitude=6.95;
end

if nargin<5
    z=0:100:15000;
else
    z=varargin{1};
end

if nargin<6
    folder='C:\DATA\Hysplit\';
else
    folder=varargin{2};
end

if ~ischar(date)
    date=num2str(date);
end
if ~ischar(hour)
    hour=num2str(hour,'%2.0f');
end
if ~(strcmp(hour,'00') || strcmp(hour,'06') || strcmp(hour,'12') || strcmp(hour,'18'))
    error('hour MUST be 00,60 12 or 18 (format HH or number) ')
end
date=[date hour];
fileT=[ 'air.' date(1:4) '.nc'];
fileHGT=[ 'hgt.' date(1:4) '.nc'];
year_str=date(1:4);
%% download from ftp if needed
% read last profile in nc file, if more recent, download from ftp
% file downlaoded from ftp.cdc.noaa.gov /Projects/Datasets/ncep.reanalysis/pressure/

if exist([folder fileT],'file')==0
    download=1;
else
    time_raw2=ncread([ folder 'hgt.' date(1:4) '.nc'],'time');
    %     time2=time_raw2/24+datenum(1,1,1);
    time2=time_raw2/24+datenum(1800,1,1);
    
    if max(time2)<datenum(date,'yyyymmddHH')
        download=1;
    else download =0;
    end
end
if download==1
    tic
    disp('Download new data from NOAA, this will take few minutes')
    f=ftp('ftp.cdc.noaa.gov');
    cd(f,'/Projects/Datasets/ncep.reanalysis/pressure/');
    mget(f,fileT,folder );
    disp('One file left, be patient')
    mget(f,fileHGT,folder);
    close(f);
    disp('downloading finished')
    toc
end
%% read P
hgt_all=ncread([ folder 'hgt.' year_str '.nc'],'hgt');
% level2=ncread('C:\DATA\Hysplit\hgt.2014.nc','level');
% lat2=ncread('C:\DATA\Hysplit\hgt.2014.nc','lat');
% lon2=ncread('C:\DATA\Hysplit\hgt.2014.nc','lon');
% time_raw2=ncread('C:\DATA\Hysplit\hgt.2014.nc','time');
% time2=time_raw2/24+datenum(1,1,1);

%% Read T
T_all=ncread([ folder 'air.' year_str '.nc'],'air');
level=ncread([ folder 'air.' year_str '.nc'],'level');
lat=ncread([ folder 'air.' year_str '.nc'],'lat');
lon=ncread([ folder 'air.' year_str '.nc'],'lon');
time_raw=ncread([ folder 'air.' year_str '.nc'],'time');

% time=time_raw/24+datenum(1,1,1);
time=time_raw/24+datenum(1800,1,1);

ind=find(time==datenum(date,'yyyymmddHH'));
if isempty(ind)
    error('bad time')
end
%% interpolate for station
T_raw=NaN(size(level));
hgt=NaN(size(level));

for i=1:length(level)
    T_temp=squeeze(T_all(:,:,i,ind));
    hgt_temp=squeeze(hgt_all(:,:,i,ind));
    T_raw(i)=interp2(lon,lat,T_temp',longitude,latitude);
    hgt(i)=interp2(lon,lat,hgt_temp',longitude,latitude);
end


%% interpolate altitude
T=interp1(hgt,T_raw,z);
P=interp1(hgt,level,z);
