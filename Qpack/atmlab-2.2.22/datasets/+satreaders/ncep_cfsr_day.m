function S = ncep_cfsr_day(fullpath, fields)

% Read NCEP CFSR reanalysis data, split per day
%
% Read data from the National Center of Environmental Prediction Climate
% Forecast System Reanalysis
%
% For info on the common format, see <a href="matlab:help SatDataset/reader">SatDataset/reader</a>.

core_fields = {'lat', 'lon', 'time'};
all_fields = union(core_fields, fields);

S = struct();
for i = 1:length(all_fields)
    S.(all_fields{i}) = h5read(fullpath, ['/' all_fields{i}]);
end
es = h5readatt(fullpath, '/time', 'units');
ed = datevec(datenum(es(13:31))+double(S.time(1))/24);
S.epoch = date2unixsecs(ed(1), ed(2), ed(3));
S.time = mod(S.time, 24) * 3600;
S.version = 'ds093.1';

end
