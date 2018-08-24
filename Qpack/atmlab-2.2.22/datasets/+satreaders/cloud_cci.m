function S = cloud_cci( file, varargin )
% SATREADERS.CLOUD_CCI
%
% Read cloud cci data and output the data in the format common to all
% satreaders.<dataset>.m readers in atmlab. Geodata and time data are
% always retrieved from the data file.
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% FORMAT
%
%   S = satreaders.cloud_cci(file,varargin)
%
% IN
%
%   file    string      Path to file
%   fields  cell array (optional) extra fields.
%
% OUT
%
%   data    struct  At least with fields:
%                   time    time in seconds since 00:00 UT
%                   lat     latitude in degrees, one column per viewing angle
%                   lon     longitude in [-180, 180] degrees, colums as for lat
%
%
% Salomon Eliasson
% $Id: cloud_cci.m 8720 2013-10-21 20:41:39Z gerrit $

core_fields   = {'time','lat','lon'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];

S = loadncvar(file, all_fields );
attr = loadncattr(file, all_fields);

% -----------
% Add offsets and scale the data if this is provided. Protect the invalid values
for F = fieldnames(S)'
    if isfield(attr.(F{1}),'scale_factor')
        if isfield(attr.(F{1}),'x_FillValue')
            % unscale the fill value
            mask=S.(F{1})==attr.(F{1}).x_FillValue;
        end

        S.(F{1}) = (S.(F{1})*double(attr.(F{1}).scale_factor))+ ...
            double(attr.(F{1}).add_offset);
        
        if isfield(attr.(F{1}),'x_FillValue')
            S.(F{1})(mask)=attr.(F{1}).x_FillValue;
        end
    end
end

% is saved as column major. flip the data.
refsz = size(S.lat);
for F = fieldnames(S)'
    if isequal(size(S.(F{1})),refsz)
        S.(F{1}) = S.(F{1})';
    end
end

S.time = S.time(:,1); %Each scanline has the same time. 'Julian Date, days elapsed since 12:00 January 1, 4713 BC'
[~,~,~,h,m,s] = jd2date(S.time);
S.time = h*3600+m*60+s; % seconds since O:00 UTC

S.lat = double(S.lat);
S.lon = double(S.lon);

% get additional stuff
D = datasets;
info = D.cloud_cci.find_info_from_granule(file);

S.epoch = round(date2unixsecs(str2double(info.year), str2double(info.month), str2double(info.day)));

S.path = file;
ga = loadncglobalattr(file);
S.version = ga.product_version;

S = MaskInvalidGeoTimedataWithNaN(S);

end
