function S = saphir(file, varargin)

% read saphir data in the common format
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.
%
% FIXME DOC
%
% See also: SatDataset/reader

core_fields = {'ScanTimestart', 'LatScan', 'LonScan'};
extra_fields  = optargs(varargin, {{}});
all_fields    = [core_fields(:); extra_fields(:)];

data = read_saphir_l1(file, all_fields, 'l1a2');

% need to rotate lat and lon
S.lat = data.data.LatScan.';
S.lon = data.data.LonScan.';

% lon is in [0 360], convert to [-180, 180]
S.lon = shift_longitudes(S.lon, -180, 180);

% interpret time strings
tmsm = cell2mat(data.data.ScanTimestart);
tt = textscan(tmsm(:, 1:21).', '%4d%2d%2d %2d%2d%2d%6d');
dv = double(horzcat(tt{:})); % need to convert to double for date2unixsecs

S.epoch = round(date2unixsecs(dv(1, 1), dv(1, 2), dv(1, 3), ...
            dv(1, 4), dv(1, 5), dv(1, 6)));
S.time = date2unixsecs(dv(:, 1), dv(:, 2), dv(:, 3), ...
            dv(:, 4), dv(:, 5), dv(:, 6)) - S.epoch;

wrong_way = {'TbCh1', 'TbCh2', 'TbCh3', 'TbCh4', 'TbCh5', 'TbCh6', 'IncidencAngle'};
% copy over extra fields
for i = 1:length(extra_fields)
    S.(extra_fields{i}) = data.data.(extra_fields{i});
    if any(strcmp(extra_fields{i}, wrong_way))
        S.(extra_fields{i}) = S.(extra_fields{i}).';
    end
        
end

end
