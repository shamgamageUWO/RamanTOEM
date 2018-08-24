classdef GriddedDataset < SatDataset
    % Class for gridded datasets
    %
    % This class contains functionality for gridded datasets.  Gridded
    % datasets are a special case of SatDatasets.  The special property of
    % a gridded dataset is that any datapoint can be uniquely identified by
    % lat, lon, time, where lat, lon, time are three cartesian axes.

    methods
        
        %% constructor
        
        function self = GriddedDataset(varargin)
            self = self@SatDataset(varargin{:});
        end
        
        %% overloaded methods
        
        function n = granule_first_line(varargin)
            n = int32(1);
        end        
        
        %% new methods
        
        function S = read_from_grid(self, lat, lon, time, fields)
            % Get data based on lat, lon, time.
            %
            % Currently, time is assumed to be on a resolution of one hour!
            %
            % FORMAT
            %
            %   S = ds.read_from_grid(lat, lon, time, fields)
            %
            % IN
            %
            %   lat     vector of latitudes
            %   lon     vector of longitudes, size must match lat
            %   time    vector or matrix of time: size must match lat&lon,
            %           and must be sorted.  Each row is a datevec.
            %   fields  Cell array of strings, fields to read
            %
            % OUT
            %
            %   S       structure with one member for each 'fields', each
            %           member is a vector with sizes matching lat/lon/time
            
            rqre_datatype(lat, @isvector);
            rqre_datatype(lon, @isvector);
            assert(length(lat)==length(lon), ['atmlab:' mfilename ':invalid'], 'lat and lon must be the same length, were found to differ');
            assert(size(time, 1)==length(lat), ['atmlab:' mfilename ':invalid'], 'no. rows in time must match length of lat and lon, were found to differ');
            assert(isequal(time, sortrows(time)), ['atmlab:' mfilename ':invalid'], 'time must be sorted in increasing order');
            
            % use time_plus_30m to get the nearest hour, for example,
            % between 23:30 and 24:00 nearest hour is on the following day
            time_plus_30m = datevec(datenum(time) + 1800/86400);
            [~, uni_indices] = unique(time_plus_30m(:, 1:3), 'rows');
            uni_indices = [uni_indices; length(lat)+1]; % add length(lat)+1 because later I run slices to llat-1
            S = struct();
            for i = 1:length(uni_indices)-1;
                gran = self.find_granule_covering_instant(time_plus_30m(uni_indices(i), :), '');
                if isempty(gran)
                    error(['atmlab:' mfilename ':nodata'], ...
                        ['No gridded data found for time %s %s. ' ...
                        'Please add to %s.'], ...
                        self.name, num2str(time_plus_30m(uni_indices(i), :)), ...
                        self.basedir);
                end
                SS = self.read_granule(gran, '', fields);
                ustime = SS.epoch + SS.time;
                assert(length(unique(sign(diff(SS.lat))))==1, ['atmlab:' mfilename ':invalid'], 'Weird lats came from source');
                assert(length(unique(sign(diff(SS.lon))))==1, ['atmlab:' mfilename ':invalid'], 'Weird lons came from source');    
                llat = lat(uni_indices(i):uni_indices(i+1)-1);
                llon = lon(uni_indices(i):uni_indices(i+1)-1);
                ttime = time(uni_indices(i):uni_indices(i+1)-1, :);
                ttime_us = date2unixsecs(ttime(:, 1), ttime(:, 2), ttime(:, 3), ttime(:, 4), ttime(:, 5), ttime(:, 6));
                llat_i = round(interp1(SS.lat, 1:length(SS.lat), llat, 'linear', 'extrap'));
                % next line is an ugly hack, not 100% sure why this happens
                llat_i(llat_i>length(SS.lat))=length(SS.lat);
                llon_i = round(interp1(shift_longitudes(SS.lon, -180, 180), 1:length(SS.lon), shift_longitudes(llon, -180, 180), 'linear', 'extrap'));
                ttime_i = round(interp1(ustime, 1:length(ustime), ttime_us, 'linear', 'extrap'));
                if any(ttime_i<=0)
                    logtext(atmlab('ERR'), [...
                        'Warning: rounding %d timestamps in the first 30 minutes of the month up instead of down. ' ...
                        'This is because the first hour of a month is contained in the /previous/ month-file, ' ...
                        'and I haven''t fixed the sorting-per-day for those instances.\n'], sum(ttime_i<=0));
                    ttime_i(ttime_i<=0) = 1;
                end
                if any(llat_i==0)
                    logtext(atmlab('ERR'), [...
                         'Warning: found some latitudes so close to the' ...
                         'south pole that they''re out of range']);
                    llat_i(llat_i==0) = 1;
                end
                mask = true(size(llat_i));
                mask(ttime_i>length(SS.time)) = false;
                clear ii;
                ii(mask) = sub2ind(size(SS.(fields{1})), llon_i(mask), llat_i(mask), ttime_i(mask));
                ii(~mask) = NaN;
                for j = 1:length(fields)
                    field = fields{j};
                    content(mask) = SS.(field)(ii(mask));
                    content(~mask) = NaN;
                    S.(field)(uni_indices(i):uni_indices(i+1)-1) = content;
                    clear content;
                    %S.(field)(uni_indices(i):uni_indices(i+1)-1) = SS.(field)(ii);                    
                end
            end
        end
    end
end
