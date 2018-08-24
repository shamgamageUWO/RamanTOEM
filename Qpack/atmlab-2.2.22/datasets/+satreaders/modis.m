function S = modis(file, varargin)

% SATREADERS.MODIS reads modis data
%
% Read MODIS data and output the data in the format common to all
% satreaders.<dataset>.m readers in atmlab. Geodata and time data are
% always retrieved from the data file.
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% IN
%
%   file    string      Path to hdf file
%   extra   cell array (optional) extra fields.
%
% OUT
%
%   data    struct  With fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%
% FORMAT
%
%   S = satreaders.modis(file, varargin)
 
% $Id: modis.m 8720 2013-10-21 20:41:39Z gerrit $
% Created by Salomon Eliasson

core_fields   = {'Scan_Start_Time','Latitude','Longitude'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];

for F = all_fields'
    S.(F{1}) = hdfread(file,F{1});
end

% Geodata and time need interpolating to make them the same size as the rest of
% the data
S = interpolate_geodataTime(S);

% CONSTRUCT time axis with same dimensions

S.lat = double(S.Latitude);
S.lon = double(S.Longitude);

% get the verion directly from the filename
D = datasets;
info = D.modis_aqua_L2.find_info_from_granule(file);
date = dayofyear_inverse(str2double(info.year), str2double(info.doy));
S.epoch = round(date2unixsecs(date.year, date.month, date.day));

%I need to do this after flagging, or the dimensions will be wrong.
% data starts at 1993, I need an offset. Only need one time per scan line
%(first 4 are NaN due to interpolation)
S.time = S.Scan_Start_Time(:,5) + date2unixsecs(1993) -S.epoch;

S = rmfield(S,core_fields);

S.version = info.version;
S.path = file;

S = MaskInvalidGeoTimedataWithNaN(S);

end
%%%%%%%%%%%%%
% SUBFUNCTION

function S = interpolate_geodataTime(S)

% NOTE: Latitude and Longitudes must be interpolated to the right
% dimensions. This is tested to be accurate compared to the MYD03 full
% geodata to within 1e-4 degrees. The alternative is to download the MYD03
% dataset, but that is about 3TB per year.
%
% NOTE: This will destroy all data outside the bounds of the sampled data!
%
% Warning: Slight dodgyness
%
% - I am using 'linear' interpolation on a geoid.
% - When LONGITUDES contain lon < -175 & lon > 175 the satellite clearly
%   passes the  dateline. For such swaths I temporarily switch to 0:360
%   representation, interpolate, and then switch back to -180:180
%   representation.
% - The incorrect interpolation of LATITUDES if the modis passes the poles is deemed
%   small and ignored here since the sampled footprints are about 5km
%   apart. e.g. in the worst case (for this footprint resolution):
%   [89.95 89.95] is interpolated to [89.95 89.95 89.95 89.95 89.95]
%   instead of [89.95 89.98 90 89.98 89.95]
%

% Use the sampling as described in variable documentation
%Longitude:Cell_Along_Swath_Sampling = 3, 2028, 5 ;
%Longitude:Cell_Across_Swath_Sampling = 3, 1348, 5 ;


[X,Y]   = meshgrid(3:5:size(S.Scan_Start_Time,2)*5-2,3:5:size(S.Scan_Start_Time,1)*5-2);
[Xi,Yi] = meshgrid(1:1354,1:size(S.Scan_Start_Time,1)*5);

fields2DealWith = {'Latitude','Longitude','Scan_Start_Time'};

lonflag = false;
for F = fields2DealWith
    Z = S.(F{1});
    
    % dateline patch
    if strcmp(F{1},'Longitude')
        Z(Z<-180) = NaN; % get rid of fill values
        if any(Z(:)<-175 ) && any(Z(:)>175) % Fill = -999
            % CONVERT LONGITUDES to [0 360] regime if the dateline is crossed
            Z=Z+(Z < 0)*360;
            lonflag=true;
        end
    end
    
    S.(F{1}) = interp2(X,Y,Z,Xi,Yi);
    
    if strcmp(F{1},'Longitude') && lonflag
        S.(F{1}) = S.(F{1})-(S.(F{1}) > 180)*360;
    end
end

end
