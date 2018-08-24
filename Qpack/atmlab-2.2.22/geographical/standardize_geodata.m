function [flags,lat,lon,data] = standardize_geodata(lat,lon,data)
% STANDARDIZE_GEODATA sort and rearrange lat,lon, data to common format
%
%                  For gridded data.
%   
%  PURPOSE  Makes sure lat lons are ascending, lons are in -180:180 regime, 
%           and makes sure that data has the dimensions data(lat,lon)
%
%  IN       lat      vector
%           lon      vector
%  OPT      data     matrix      dims = (lat,lon,...) or (lon,lat,...) 
%
%  OUT
%           flags     struct     A structure of flags to indicate which
%                                issue the function addressed.
%           lat       vector     Ascending lats
%           lons      vector     Ascending lons and 0:360 -> -180:180
%           data      matrix     data(lat,lon,....) and rearranged to new
%                                lat/lons
%
% NOTE: 1) If lat and lon are the same length the first dimesion of data is
%       assumed to correspond to lat.
%       2) If data is a region that has lons in the 0:360 regime AND wraps
%       over 360, this will cause an error. e.g. [350 360 10 20]
%
% USAGE:    [flags,lat,lon,data] = standardize_geodata(lat,lon,data)
%           or
%           [flags,lat,lon] = standardize_geodata(lat,lon)
%
% created by Salomon Eliasson
% $Id: homogenize_datalatlon.m 7163 2011-09-21 19:42:48Z seliasson $


% -------    CHECK for errors
errID = ['gmtlab:' mfilename ':badInput'];
dexist = exist('data','var');

assert(isvector(lat) && isvector(lon),errID,'lat and lons must be vectors')

assert(all(lat>=-90 & lat<=90) && all(lon>=-180 & lon<=360),...
    errID,'Lats and lons must have physical values')

if dexist
    sz = size(data);
    
    assert(isequal(prod(sz(1:2)),numel(lat)*numel(lon)),...
        errID,'data does not appear to be gridded')
end

assert(all(lon(2:end)<lon(1:end-1)) || all(lon(2:end)>lon(1:end-1)),...
    errID,'Longitudes must be ordered ascending or descending');

assert(all(lat(2:end)<lat(1:end-1)) || all(lat(2:end)>lat(1:end-1)),...
    errID,'Latitudes must be ordered ascending or descending');

% --------  SET FLAGS
if dexist
    %undesired dimensions
    flags.permute = (length(lon)==sz(1) && length(lat)==sz(2)) && ...
        length(lat) ~= length(lon);
end

%undesired lon orientation
flags.lon_descend = all(lon(2:end)<lon(1:end-1)); 

%undesired latorientation
flags.lat_descend = all(lat(2:end)<lat(1:end-1));

flags.lon360 = any(lon > 180);

flags.duplicate = flags.lon360 & all(ismember(lon,[0,360]));

% --------  HOMOGENIZE the input

% PERMUTE data so that dimensions are data(lat,lon)
if dexist
    if flags.permute
        x = 1:ndims(data);
        x(1)=2;x(2)=1;
        data = permute(data,x);
    end
end

% If any of the following flags are true the data matrix will be flattened
% on 3rd dimesion. A reshape at the end of this function will unflatten the
% data again later

% make LONS ASCENDING
if flags.lon_descend
    lon = lon(end:-1:1);
    if dexist
        data = data(:,end:-1:1,:);
    end
end

% make LATS ASCEND
if flags.lat_descend
    lat = lat(end:-1:1);
    if dexist
        data = data(end:-1:1,:,:);
    end
end

% make sure LONGITUDES ARE IN -180:180 REGIME
if flags.lon360
    lon = lon-(lon > 180)*360;
    [lon,lnindex] = sort(lon);
    if dexist
        data = data(:,lnindex,:);
    end
end


% DUPLICATE data
% Need to remove duplicate data at zeros and instead introduce duplicate
% data at lon = -180 and 180 if either -180 or 180 are amongst the lon
% values (if so).

% Since, by removing duplicate data, I change the size of the lon vector
% and data matrix which is undesireable. By adding either -180 or 180 as
% duplicates the sizes remain the same. The caveat is that if your original lons
% contain both 0 and 360 (duplicate), but don't contain the longitude: 180,
% the lon vector and data matrix will be shortened.

if flags.duplicate
    [sv,index] = unique(lon);
    lon = lon(index);
    if dexist
        data = data(:,index,:);
    end
    if lon(end)==180
        lon = [-180 lon];
        if dexist
            data = [data(:,end,:) data];
        end
    else
        warning(sprintf('atmlab:%s:ChangedDataDimensions',mfilename),...
            'Duplicate lons removed changing the size of the lon vector (and data)')
    end
end

if dexist
    data = reshape(data,[size(data,1),size(data,2),sz(3:end)]);
end