classdef CollocatedDataset < HomemadeDataset
    % Defines a collocated dataset, between two (different) datasets.
    %
    % A CollocatedDataset consists of two <a href="matlab:help SatDataset">SatDataset</a>s.
    % To start collocating, first create two <a href="matlab:help SatDataset">SatDataset</a>
    % objects and define all required properties there. Predefined datasets
    % are defined in <a href="matlab:help define_datasets">define_datasets</a>. Then <a href="matlab:help CollocatedDataset/CollocatedDataset">create</a> a CollocatedDataset.
    % To list existing datasets, use <a href="matlab:help datasets">datasets</a>.
    % Remember that CollocatedDataset inherits from <a href="matlab: help
    % HomemadeDataset">HomemadeDataset</a>,
    % so it has all capabilities that HomemadeDataset has. You may also
    % want to look at the Collocation User's Guide.
    %
    % CollocatedDataset Properties:
    %
    %   primary -   primary dataset
    %   secondary - secondary dataset
    %   distance -  maximum collocation distance (km)
    %   interval -  maximum collocation time (seconds)
    %   members -   structure containing full info on how data are stored
    %               (as well as all <a href="matlab:help SatDataset">SatDataset</a> and <a href="matlab:help HomemadeDataset">HomemadeDataset</a> properties)
    %   pcd -       if set, cache <a href="matlab:help CollocatedDataset/read">read</a> results to disk
    %   (see <a href="matlab:properties CollocatedDataset">properties</a> for a complete listing)
    %   gridsize -  parameter for calculating collocations. Set small if
    %               you expect many collocations, large if you expect few.
    %
    % CollocatedDataset methods:
    %
    %  Class instantiation:
    %
    %   CollocatedDataset -         created CollocatedDataset object
    %
    %  Finding and storing collocations:
    %
    %   overlap_granule -           Find overlapping granules from filenames
    %   collocate_granule -         Collocate primary with all secondaries
    %   collocate_date -            Collocate all granules in day
    %   collocate_and_store_date -  Collocate entire day and store results
    %   collocate_and_store_date_range - Collocate many days and store
    %
    %  Reading collocations:
    %
    %   read -                      Read collocations for date range
    %   list_fields -               Find what fields can be read
    %
    %  (as well as all <a href="matlab:help SatDataset">SatDataset</a> and <a href="matlab:help HomemadeDataset">HomemadeDataset</a> methods)
    %
    % For a full overview of methods, see <a href="matlab:doc CollocatedDataset">doc CollocatedDataset</a>.
    %
    % Example:
    %
    %   >> D = datasets;
    %   >> mhscpr = CollocatedDataset(D.mhs, D.cpr, 'distance', 10, 'interval', 300, 'name', 'NarrowCPRMHSCollocs');
    %
    % Hint: if the collocations are slow, try tweaking <a href="matlab:help
    % CollocatedDataset/gridsize">gridsize</a>.
    %
    % See also: SatDataset (grandparent), HomemadeDataset (superclass), AssociatedDataset,
    %           FieldCopier, Collapser,
    %
    %
    % Don't forget the Collocation User's Guide.
    %
    % $Id: CollocatedDataset.m 8750 2013-12-07 18:14:32Z seliasson $
    properties (Transient)
        % Primary dataset.
        %
        % This is usually a <a href="matlab:help SatDataset">SatDataset</a>.
        %
        % When collocating, there are some considerations as to chosing
        % the primary vs. the secondary dataset:
        % 
        %   - Choose the dataset with the largest footprint as the primary.
        %     This becomes particularly important when the secondary is
        %     averaged over the primary using <a href="matlab:help Collapser"</a>Collapser</a> or a similar class.
        %
        %   - Choose the dataset with the largest granule as the primary.
        %     As long as there is no caching implemented in <a href="matlab: help SatDataset/read_granule">SatDataset.read_granule</a>,
        %     this is much faster than the opposite.
        primary;
        
        % Secondary dataset
        %
        % For considerations, see help for <a href="matlab:help CollocatedDataset/primary">primary</a>.
        secondary;
        
        % Maximum distance in km
        %
        % The maximum distance that is considered a collocation. Distance
        % is determined between footprint geolocations, in lat/lon.
        distance;
        
        % Maximum time-interval in seconds
        %
        % The maximum time interval that is considered a collocation.
        interval;
        
        % Grid-size (in degrees) to use inside collocationg algorithm
        %
        % The size of the grid that is used inside the collocation
        % algorithm. The method <a href="matlab:help CollocatedDataset/collocate">collocate</a> works by gridding the
        % measurements on a equirectangular lat-lon grid (see algorithm
        % description in John. et al (2012)), using <a href="matlab:help binning_fast">binning_fast</a>.
        % The speed of binning_fast is a injective function of the gridsize
        % with a strictly positive derivative. The speed does not depend on
        % the number of collocations. In the next step, all distances
        % between pairs within a grid-cell are calculated. This step
        % strongly depends on the number of collocations. Therefore, to
        % optimise the speed of calculating collocations, set the grid_size
        % small if you expect many collocations and large if you expect
        % very few.
        %
        % It has a default value of 1 (degree).
        gridsize = 1;
        
        % Logfile for describing what collocations were performed
        %
        % When collocations are read and written to disk, the toolkit will
        % write a short report to this file reporting what collocations
        % were located etc. This is used only by
        % <a href="matlab:help CollocatedDataset/collocate_and_store_date_range">collocate_and_store_date_range</a>.
        % The logfile is put directly in self.basedir and appended to on
        % every occasion.
        logfile = 'collocations_log';
        
        % Marker to seperate between different logfile entries
        marker = [repmat('-', [1 72]) '\n'];

        % Collocation method: classical or experimental
        %
        % If things go wrong in 'collocate', set to 'classical'.
        binning = 'experimental'
    end
    
    % read-only props (may be alterable with methods)
    properties (Transient, SetAccess = protected)
        % Cell array of <a href="matlab:help AssociatedDataset">AssociatedDataset</a>.
        %
        % This automatically-filled cell-array contains all datasets that
        % can be used in associated with this <a href="matlab:help CollocatedDataset">CollocatedDataset</a>.
        % This can be e.g. <a href="matlab:help FieldCopier">FieldCopier</a>, <a href="matlab:help Collapser">Collapser</a>, etc.
        associated = {};
    end
    
    properties (Transient, Constant)
        
        % Structure describing layout of NetCDF files storing collocations
        %
        % This read-only structure describes exactly the layout of the
        % NetCDF files in which the collocations are stored.
        %
        % Valid types are at:
        % http://www.unidata.ucar.edu/software/netcdf/docs/netcdf-c/NetCDF_002d3-Variable-Types.html#NetCDF_002d3-Variable-Types
        members_const = struct(...
            'START1', struct(...
                'type', 'int', ... % won't work after 2038-01-19 03:14:07 UTC
                'atts', struct(...
                    'long_name', 'primary granule start time', ...
                    'units', 'seconds since 1970-01-01 00:00:00')), ...
            'LINE1', struct(...
                'type', 'int', ...
                'atts', struct(...
                    'long_name', 'primary scanline number')), ...
            'POS1', struct(...
                'type', 'int', ...
                'atts', struct(...
                    'long_name', 'primary scanline position')), ...
            'TIME1', struct(...
                'type', 'int', ...
                'atts', struct(...
                    'long_name', 'primary measurement time', ...
                    'units', 'seconds since 1970-01-01 00:00:00')), ...
            'LAT1', struct(...
                'type', 'double', ...
                'atts', struct(...
                    'long_name', 'primary latitude', ...
                    'units', 'degrees_north', ...
                    'valid_range', [-90 90])), ...
            'LON1', struct(...
                'type', 'double', ...
                'atts', struct(...
                    'long_name', 'primary longitude', ...
                    'units', 'degrees_east', ...
                    'valid_range', [-180 180])), ...
            'START2', struct(...
                'type', 'int', ...
                'atts', struct(...
                    'long_name', 'secondary granule start time', ...
                    'units', 'seconds since 1970-01-01 00:00:00')), ...
            'LINE2', struct(...
                'type', 'int', ...
                'atts', struct(...
                    'long_name', 'secondary scanline number')), ...
            'POS2', struct(...
                'type', 'int', ...
                'atts', struct(...
                    'long_name', 'secondary scanline position')), ...
            'TIME2', struct(...
                'type', 'int', ...
                'atts', struct(...
                    'long_name', 'secondary measurement time', ...
                    'units', 'seconds since 1970-01-01 00:00:00')), ...
            'LAT2', struct(...
                'type', 'double', ...
                'atts', struct(...
                    'long_name', 'secondary latitude', ...
                    'units', 'degrees_north', ...
                    'valid_range', [-90 90])), ...
            'LON2', struct(...
                'type', 'double', ...
                'atts', struct(...
                    'long_name', 'secondary longitude', ...
                    'units', 'degrees_east', ...
                    'valid_range', [-180 180])), ...
            'DIST', struct(...
                'type', 'float', ...
                'atts', struct(...
                    'long_name', 'Distance secondary to primary', ...
                    'units', 'km')), ...
            'INT', struct(...
                'type', 'float', ...
                'atts', struct(...
                    'long_name', 'Time secondary minus time primary', ...
                    'units', 'seconds')), ...
            'INDEX', struct(...
                'type', 'int', ...
                'atts', struct(...
                    'long_name', 'Collocation index number')));
        
    end
    
    properties (Transient, GetAccess = private, SetAccess = private)
        log;
        success = false;
    end
    
    methods
        %% constructor

        function self = CollocatedDataset(prim, sec, varargin)
            % Constructor for CollocatedDataset
            %
            % FORMAT
            %
            %   cd = CollocatedDataset(prim, sec, 'prop', 'val', ...)
            %
            % IN
            %
            %   prim    SatDataset  primary
            %   sec     SatDataset  secondary
            %   ... (key - value) pairs as for <a href="matlab:help SatDataset">SatDataset</a>
            %   for a CollocatedDataset, of particular importance are
            %   'distance' and 'interval'.
            %
            % OUT
            %
            %   cd      CollocatedDataset object
            super_args = [varargin, {'primary', prim, 'secondary', sec}];
            self = self@HomemadeDataset(super_args{:}); % call parent constructor
            % check that both are SatDataset
            for x = {prim, sec}
                assert(isa(x{1}, 'SatDataset'), ['atmlab:' mfilename ':TypeError'], ...
                    'Collocations must be between 2 x SatDataset, got %s instead', ...
                     class(x{1}));
            end
            
            % set distance and interval to global default if not given
            for f = {'distance', 'interval'}
                if isempty(self.(f{1}))
                    warning(['atmlab:' mfilename ':notgiven'], ...
                        'Field ''%s'' not given for %s, setting to global default %d', ...
                        f{1}, self.name, colloc_config(f{1}));
                    self.(f{1}) = colloc_config(f{1});
                end
            end

            % add both to corresponding datasets
            for x = {prim, sec}
                x{1}.add_collocated_dataset(self);
            end
            
            % make 'cols'-structure for internal data specification
             
            self.members = self.members_const;
            fnms = fieldnames(self.members);
            nfields = length(fnms);
            fv = 1:nfields;
            self.cols = cell2struct(num2cell(fv), fnms.', 2);
            
            if isempty(self.granule_duration)
                self.granule_duration = 86400;
            end
        end
                
        %% implement new methods
        
        function secondary_granules = overlap_granule(self, date1, spec2)
            % secondary granules that, judging from filenames, might overlap
            %
            % Based on the filename and on the <a href="matlab:help SatDataset/granule_duration">granule_duration</a>
            % properties, guess what secondary granules need to be read in
            % order to fully cover the period indicated by the first
            % granule. This is the first step in performing collocations
            % for a particular granule.
            %
            % This is a low-level function usually not called directly
            % by the user.
            %
            % Assumes granules contain data for at most one day.
            % This implies a limitation for the entire collocation toolkit.
            %
            % FORMAT
            %
            %   grans = cd.overlap_granule(datevec1, spec2);
            %
            % IN
            %
            %   datevec1    datevec     Starting time for primary granule
            %   spec2       various     Satellite etc. for secondary granule
            %
            % OUT
            %
            %   grans       matrix      describing secondary start-times
            %
            % EXAMPLE
            %
            %   >> sec = mhscpr.overlap_granule([2010 9 8 8 8], '');
            
            
            %% find starting time in unixsecs
            
            primary_unixsecs = self.primary.get_starttime(date1);
            %granule_end = primary_unixsecs + duration;
            
            %% find all granules yesterday/today/tomorrow
            
            today_num = datenum(date1(1), date1(2), date1(3));
            yesterday = datevec(today_num - 1);
            tomorrow = datevec(today_num + 1);
            
            threedays = [...
                self.secondary.find_granules_by_date(yesterday, spec2, false); ...
                self.secondary.find_granules_by_date(date1, spec2, false); ...
                self.secondary.find_granules_by_date(tomorrow, spec2, false)];
            threedays = sortrows(threedays);
            % get corresponding starting times
            secondary_unixsecs = zeros(1, size(threedays, 1));
            for i = 1:size(threedays, 1)
                st = self.secondary.get_starttime(threedays(i, :));
                secondary_unixsecs(i) = st;
            end
%             granules_unixsecs = date2unixsecs(...
%                 threedays(:, 1), threedays(:, 2), threedays(:, 3), threedays(:, 4), threedays(:, 5));

%            primstart_before_secstart = primary_unixsecs < secondary_unixsecs;
            
            primstart_before_secend = primary_unixsecs < secondary_unixsecs + self.secondary.granule_duration + self.interval;
            
            primend_after_secstart = primary_unixsecs + self.primary.granule_duration + self.interval > secondary_unixsecs;
            
            okej = primstart_before_secend & primend_after_secstart;
            
%{          
            
            
            % first granule 

            % last granule starting after the reference granule
            % those are all 'too late'
            
            toolate = primary_unixsecs - self.interval > secondary_unixsecs;
            b = find(toolate, 1, 'last');
            
            % first granule ending before the reference granule
            % those are all 'too early'
            
            tooearly = granule_end + self.interval < secondary_unixsecs;
            e = find(tooearly, 1, 'first');
            
            % if all match, none are too early or too late
            if isempty(b) && isempty(e)
                okej = (primary_unixsecs < secondary_unixsecs) & (granule_end > secondary_unixsecs);
            elseif ~isempty(b) && ~isempty(e)
                % anything not too early, not too late, is good
                okej = b:e;
            elseif (all(tooearly) && none(toolate)) || ...
                   (all(toolate) && none(tooearly))
                % all too early, none too late
                % all too late, none too early
                % this means all are off
                okej = [];
            else
                % this means:
                % if b is empty, then 1:e
                % if e is empty, then b:end
                okej = max([~isempty(b)+1 b]):max([isempty(e)*size(threedays, 1) e]);
                
                %X={b,e};
                %okej = X{[~isempty(b) ~isempty(e)]};
            end   
%}            
            secondary_granules = threedays(okej, :);
        end

        function [result, additional_results, also] = collocate_granule(self, date1, spec1, spec2, varargin)           
            % collocate_granule Collocate granules from sat/sensor pairs
            %
            % This method collocates a granule from the primary with all
            % overlapping granules from the secondary satellite, and
            % returns the results. 
            %
            % FORMAT
            %
            %   [result, additional_results, also] = ...
            %       cd.collocate_granule(date1, spec1, spec2[, additionals[, oneday]])
            %
            % IN
            %
            %   date1   datevec     starting date/time for primary
            %   spec1   various     specification, e.g. satellite or pair
            %                       of satellites, for the primary. May be
            %                       empty if not applicable.
            %   spec2   various     specification for the secondary
            %   addis   cell-array  optional; cell array of objects from
            %                       classes implementing <a href="matlab:help AdditionalDataset">AdditionalDataset</a>,
            %                       such as <a href="matlab:help FieldCopier">FieldCopier</a>
            %                       or <a href="matlab:help Collapser">Collapser</a>.
            %                       Defaults to empty cell-array {}.
            %   oneday  logical     optional. If true, force collocations to be all
            %                       from the indicated day. If false, all
            %                       collocations from all granules covering
            %                       this day will be considered. Defaults
            %                       to false, but if one is looping through
            %                       the days one wants it to be true.
            %   
            % OUT
            %
            %   result  matrix      Contains core collocation-info. Columns
            %                       described by <a href="matlab:help CollocatedDataset/cols">CollocatedDataset.cols</a>.
            %   add_res cell-array  Cell array of matrices. The elements of
            %                       this cell-array correspond to the
            %                       elements of input arguments 'addis'.
            %                       For each matrix, the columns are
            %                       described by the corresponding <a href="matlab:help AssociatedDataset/cols">cols</a>
            %                       member for the <a href="matlab:help AssociatedDataset">AssociatedDataset</a>
            %                       object.
            %   also    struct      More information.
            %
            % EXAMPLE
            %
            %   (example assumes fc is a <a href="matlab:help FieldCopier">FieldCopier</a>)
            %
            % >> [result, additional_results, also] = ...
            %   mhscpr.collocate_granule([2010 9 8 8 8], 'noaa18', '', {fc}, true)
            
            [additionals, oneday] = optargs(varargin, {{}, false});
            self.verify_addis(additionals);
            additional_results = cell(size(additionals));
            
            additionals = self.sort_additionals(additionals);
            
            % collect all extra fields, for all additional datasets
            extra_args_primary = {};
            extra_args_secondary = {};
            for i = 1:length(additionals)
                addi = additionals{i};
                primfields = addi.primary_arguments();
                secofields = addi.secondary_arguments();
                extra_args_primary = [extra_args_primary primfields]; %#ok<AGROW>
                extra_args_secondary = [extra_args_secondary secofields]; %#ok<AGROW>
            end
            extra_args_primary = unique(extra_args_primary);
            extra_args_secondary = unique(extra_args_secondary);
            
            %% output
            
            fid = atmlab('OUT');
            eid = atmlab('ERR');
            
            %% find date/times for which to search for secondary granules
            
            % overlap check 1: primary filename, secondary filename
            secondary_granules = self.overlap_granule(date1, spec2);
            
            if size(secondary_granules, 1)==0
                error(['atmlab:' mfilename ':noother'], ...
                    'No overlapping granules found for [%s] %s/%s with %s/%s', ...
                    num2str(date1), spec1, self.primary.name, spec2, self.secondary.name);
            end
            
            logtext(fid, 'Found %d other granules to collocate with\n', size(secondary_granules, 1));
            
            %% pre-allocate
            
            result = zeros(0, length(fieldnames(self.cols)), self.mattype);
            
            %% read data for sat1/sensor1
            % Here, I decide to keep the duplicates for now. Simple is better than
            % complex. My collocation output are rows and column indices, and if I already
            % remove duplicates /before/ collocation, the row-indices will be
            % incorrect/ need to be corrected for. This causes more problems than it
            % solves, so I will remove the duplicates in the postprocessing instead.
            try
                data1 = self.primary.read_granule(date1, spec1, extra_args_primary, false, false); % keep duplicates for now
            catch ME
                switch ME.identifier
                    case {'MATLAB:load:couldNotReadFile', 'atmlab:invalid_data', 'atmlab:SatDataset:cannotread'}
                        logtext(eid, 'Collocating failed: %s\n', ME.message);
                        also = struct('version', {{'?', '?'}});
                        return
                    otherwise
                        ME.rethrow();
                end
            end
            
            also.version{1} = data1.version;
            also.version{2} = '?'; % secondary version not yet available
            
            if isempty(data1.time)
                logtext(fid, 'Primary is empty, nothing to collocate\n');
                %                self.version{2} = 'N/A';
                return
            end
            
            % keep effective range, check time overlap before actually reading the
            % secondary data, because the primary might be sparse. E.g. when judging
            % from the filenames the granules contain overlapping periods, but if the
            % primary in reality only contains data for a certain part of this period
            % (e.g. in the case of collocations), should check the primary data with
            % the secondary filename in order not to read files one knows will not
            % contain overlap anyway.
            
            % self.primary and self.secondary may actually be the same
            % object, do not store any 'temporary' data there.
            data1.time_orig = data1.time; % store because of subsequent unify_time_axis can lead to errors
            data1.eff_range = double(data1.epoch) + ...
                [min(data1.time)-self.interval, ...
                max(data1.time)+self.interval];
            
            %% loop through all the granules to collocate with
            
            for i = 1:size(secondary_granules, 1)
                % Overlap check 2; primary data with secondary filename
                data2_start = self.secondary.get_starttime(secondary_granules(i, :));
                data2_end = data2_start + self.secondary.granule_duration;
                
                [datecell{1:5}] = unixsecs2date(data2_start);
                
                logtext(atmlab('OUT'), 'Collocating with ''%s'' ''%s'' @ %04d-%02d-%02d %02d:%02d\n', ...
                    self.secondary.name, spec2, datecell{1:5});
                
                
                if (data2_start > data1.eff_range(2)) || (data2_end < data1.eff_range(1))
                    % no possible time overlap; data1 range already compensated for
                    % self.interval, no use even reading granule2
                    logtext(atmlab('OUT'), 'Not reading, no overlap with primary\n');
                    continue
                end
                
                %% read secondary
                
                try
                    data2 = self.secondary.read_granule(secondary_granules(i, :), spec2, extra_args_secondary, false);
                catch ME
                    switch ME.identifier
                        case {'atmlab:find_datafile_by_date', ...
                                'atmlab:invalid_data', ...
                                'atmlab:find_granule_by_datetime', ...
                                'atmlab:exec_system_cmd:shell', ...
                                'atmlab:rqre_in_range:invalid', ...
                                'atmlab:SatDataset:cannotread'}
                            logtext(eid, 'Error in reading datafile %4d-%02d-%02d %02d:%02d: %s. SKIPPING\n', ...
                                datecell{:}, ME.message);
                            continue
                        otherwise
                            ME.rethrow();
                    end
                end
                
                also.version{2} = data2.version;
                data2.time_orig = data2.time; % store, see note at data1.time_orig
                if isempty(data2.time)
                    logtext(fid, 'Secondary is empty, skipping\n');
                    continue
                end
                
                %%
                switch sign(data1.epoch - data2.epoch)
                    case -1 % data1 epoch is earliest
                        data2.time = data2.time + double(data2.epoch - data1.epoch);
                        data2.epoch = data1.epoch;
                    case 0 % do nothing
                    case 1 % data2 epoch is earliest
                        % FIXME: Bug? primary changes also for next loop
                        % iteration? Or should be ok as long as
                        % epoch/time consistent, maybe will iteratively
                        % increase but at least consistent
                        data1.time = data1.time + double(data1.epoch - data2.epoch);
                        data1.epoch = data2.epoch;
                    otherwise
                        error(['atmlab:' mfilename ':bug'], 'Reached impossible place. Bug.');
                end
                
                % overlap check 3: primary data, secondary data
                [iv1, iv2] = find_common_time(data1.time, data2.time, self.interval);
                % limit to one day (if needed)
                switch oneday
                    case 1
                        % only consider data on the same date as the start for data1
                        if data1.time(1) < 86400
                            sameday = data1.time < 86400;
                        else
                            sameday = data1.time < 2*86400;
                        end
                        if ~all(sameday)
                            logtext(fid, 'taking only %d/%d that are on the same day\n', ...
                                sum(sameday), length(data1.time));
                        end
                        iv1 = iv1 & sameday;
                    case 2
                        % only consider data on date after the start date for data1
                        sameday = data1.time > 86400;
                        iv1 = iv1 & sameday;
                        if ~all(sameday)
                            logtext(fid, 'taking from primary only %d/%d that are on the next day\n', ...
                                sum(sameday), length(data1.time));
                        end
                end
                if ~(any(iv1) && any(iv2)) % no overlap
                    logtext(fid, 'upon checking actual data, no actual time overlap, so nothing to collocate\n');
                    continue
                end
                
                %% perform collocations
                logtext(atmlab('OUT'), 'Performing collocations (distance < %g km, time < %g s)\n', ...
                                       self.distance, self.interval);
                collocations = self.collocate(data1.time(iv1), ...
                    data1.lat(iv1, :), ...
                    data1.lon(iv1, :), ...
                    data2.time(iv2), ...
                    data2.lat(iv2, :), ...
                    data2.lon(iv2, :));
                if any(collocations)
                    % compensate for the fact that we passed only a subset to collocate
                    collocations(:, 1) = collocations(:, 1) + find(iv1, 1, 'first') - 1;
                    collocations(:, 3) = collocations(:, 3) + find(iv2, 1, 'first') - 1;
                else
                    logtext(fid, 'No collocations\n');
                    continue
                end
                %% process core
                % should return a matrix with info

                %lockfile = get_lock(atmlab('WORK_AREA'), 'collocations.lock');
                %cl1 = onCleanup(@()delete(lockfile));

                logtext(fid, 'Collecting info for %d collocations\n', size(collocations, 1));
                
                this_result = self.process(collocations, data1, date1, spec1, data2, secondary_granules(i, :), spec2);
                clear collocations;
                old_result = result;
                result = [result; this_result]; %#ok<AGROW>
                % correct INDEX
                if ~isempty(result)
                    result(:, self.cols.INDEX) = 1:size(result, 1);
                end
                
                %% process additional
                %
                % additionals are all implementations of AssociatedDataset able
                % to process data and knowing how to store it, how to deal
                % with it, etc.
                % For copying, there is FieldCopier.
                %
                % Note that in collocate_granule, we always overwrite
                % everything.
                
                % this might be memory-intensive, make sure to get a lock
                
                this_additional_result = cell(size(additionals));
                cc = cell(size(additionals));
                for j = 1:length(additionals)
                    additional = additionals{j};
                    % Get data that this additional depends upon
                    
                    %depdata = self.fix_dependencies(additional, additionals, this_additional_result);                    
                    [depdata, depcols] = self.fix_dependencies(additional, additionals, this_additional_result, cc);
                    [this_additional_result{j}, cc{j}] = additional.process_granule(this_result, data1, date1, spec1, data2, secondary_granules(i, :), spec2, ...
                        depdata, depcols, 'all');
                        %depdata);
                    clear depdata
                    % since we use 'all', we can safely set
                    % additional.cols
                    additional.cols = cc{j};
                    %clear this_result
                    % use special method to concatenate, sometimes need to
                    % correct values, e.g. FIRST, LAST in case of meandata
                    additional_results{j} = additional.concatenate(old_result, additional_results{j}, this_additional_result{j});
                    %clear this_additional_result;
                end
                clear old_result this_additional_result this_result data2

                %logtext(atmlab('OUT'), 'Clearing lockfile\n');
                %delete(lockfile);

                logtext(fid, 'Info collected\n');
            end
            % return: result, additional_results, also
        end
        
        function [result, additional_results, also] = collocate_date(self, date, spec1, spec2, varargin)           
            % collocate_date Collect all collocations for given date
            %
            % This method takes all granules from the primary that contain
            % data for the indicated date. It then <a href="matlab:help CollocatedDataset/collocate_granule">collocates each granule</a>
            % with the secondary and thus collects all collocations for the
            % given date. The result is not stored, but returned; to store
            % the result, use <a href="matlab:help CollocatedDataset/collocate_and_store_date">CollocatedDataset.collocate_and_store_date</a>.
            %
            % FORMAT
            %
            %   [M, addis, also] = cd.collocate_date([year, month, day], spec1, spec2[, additionals])
            %
            % IN
            %
            %   datevec     vector      [year month day]
            %   spec1       various     sat for primary, if applicable
            %   spec2       various     sat for secondary, if applicable
            %   additionals (optional)  cell array; see help for
            %                           corresponding argument for
            %                           <a href="matlab:help CollocatedDataset/collocate_granule">CollocatedDataset.collocate_granule</a>.
            %
            % OUT
            %
            %   For output arguments, see help for <a href="matlab:help CollocatedDataset/collocate_granule">CollocatedDataset.collocate_granule</a>.
            %
            % EXAMPLE
            % 
            % (example assumes fc is a <a href="matlab:help FieldCopier">FieldCopier</a>)
            % >> [result, additional_results, also] = ...
            %   mhscpr.collocate_date([2010 9 8], 'noaa18', '', {fc})
            
            additionals = optargs(varargin, {{}});
            self.verify_addis(additionals);
            
            fid = atmlab('OUT');
            year = date(1);
            month = date(2);
            day = date(3);
            % find granules for primary dataset; if the length equals one day, do not
            % take the day before as it's already sorted per day
            grans = self.primary.find_granules_by_date(date, spec1, ...
                self.primary.granule_duration~=86400);
            if isempty(grans)
                logtext(atmlab('ERR'), 'no granules found %s/%s %d-%d-%d\n', ...
                    self.primary.name, spec1, year, month, day);
            end
            ngrans = size(grans, 1);
            
            % pre-allocate; I know 'result's right size, but do not know
            % the right size for additional_results because I don't know
            % the sizes of the involved fields
            result = zeros(0, length(fieldnames(self.cols)), self.mattype);
            additional_results = cell(size(additionals));
            
            anysuccess = false;
            also = struct();
            
            for i = 1:ngrans
                % keep track, because first granule is probably yesterday
                thisyear = grans(i, 1);
                thismonth = grans(i, 2);
                thisday = grans(i, 3);
                hour = grans(i, 4);
                minute = grans(i, 5);
                
                logtext(fid, 'Collocating %s ''%s'' %04d-%02d-%02d %02d:%02d with %s %s \n', ...
                    self.primary.name, spec1, thisyear, thismonth, thisday, hour, minute, self.secondary.name, spec2);
                
                if ~isequal([thisyear thismonth thisday], [year month day]);
                    % only take collocations happening in part of granule occuring on
                    % the day requested
                    oneday = 2;
                else % take any collocations happening on the day requested
                    oneday = 1;
                end
                
                try
                    [result_granule, result_granule_addis, new_also] = self.collocate_granule(...
                        [thisyear, thismonth, thisday, hour, minute], spec1, spec2, additionals, oneday);
                    if ~isempty(fieldnames(also)) && ~isequal(also, new_also)
                        warning(['atmlab:' mfilename ':inconsistent'], ...
                            ['Additional information structures not consistent within the day. ' ...
                             'Expected: ' struct2string_compact(also) ...
                             ' Got: ' struct2string_compact(new_also)]);
                    end
                    also = new_also;
                    anysuccess = true;
                catch ME
                    switch ME.identifier
                        case {'atmlab:find_datafile_by_date', 'atmlab:find_granule_by_datetime'}
                            logtext(atmlab('ERR'), 'Error in searching for datafile %4d-%02d-%02d %02d:%02d %s %s: %s. SKIPPING\n', ...
                                thisyear, thismonth, thisday, hour, minute, self.primary.name, spec1, ME.message);
                            continue
                        case {'atmlab:collocate', 'atmlab:atovs_get_l1c:zamsu2l1c', 'atmlab:CollocatedDataset:noother', 'atmlab:collocate_granule:noother'}
                            logtext(atmlab('ERR'), 'Error in collocating with datafile at %4d-%02d-%02d %02d:%02d %s %s: %s. SKIPPING\n', ...
                                thisyear, thismonth, thisday, hour, minute, self.primary.name, spec1, ME.message);
                            continue
                        case {'MATLAB:hdfinfo:invalidFile', 'MATLAB:imagesci:hdfinfo:invalidFile', 'MATLAB:imagesci:validate:fileOpen'}
                            logtext(atmlab('ERR'), 'Cannot read datafile %s %s %4d-%02d-%02d %02d:%02d: %s. SKIPPING\n', ...
                                self.primary.name, spec1, thisyear, thismonth, thisday, hour, minute, ME.message);
                            continue
                        otherwise
                            ME.rethrow();
                    end
                end
                old_result = result;
                result = [result; result_granule]; %#ok<AGROW>
                            
                % special case; INDEX should be throughout entire date
                % need to redo this AFTER concatenation but BEFORE further
                % processing
                if ~isempty(result)
                    result(:, self.cols.INDEX) = 1:size(result, 1);
                end
                
                for j = 1:length(additional_results)
                    % use special method for concatenation, because some
                    % additional datasets, such as Collapser, need to
                    % correct certain columns, such as FIRST and LAST, upon
                    % concatenation
                    additional_results{j} = additionals{j}.concatenate(old_result, additional_results{j}, result_granule_addis{j});
%                     if isempty(additional_results{j})
%                         additional_results{j} = result_granule_addis{j};
%                     else
%                         additional_results{j} = [additional_results{j}; result_granule_addis{j}];
%                     end
                end
            end
            
            if ~anysuccess
                error('atmlab:collocate_date:nosource', 'no source data found at all');
            end
            
            % special case; INDEX should be throughout entire date
            if ~isempty(result)
                result(:, self.cols.INDEX) = 1:size(result, 1);
            end
            
        end
        
        function collocate_and_store_date(self, date, spec1, spec2, varargin)
            % collocate_and_store_date Collect collocations and store appropiately
            %
            % For a given date, check whether a collocation datafile exists.
            % If it doesn't (or <a href="matlab:help colloc_config">colloc_config</a>('overwrite') is set), collocate the indicated
            % satellites and sensors with each other and store the result in the
            % appropiate datafile.
            %
            % This only works on a single day; for long periods of time,use
            % <a href="matlab:help CollocatedDataset/collocate_and_store_date_range">CollocatedDataset.collocate_and_store_date_range</a>.
            %
            % FORMAT
            %
            %   collocate_and_store_date(date, spec1, spec2, additionals)
            %
            % IN
            %
            %   Input arguments as for <a href="matlab:help CollocatedDataset/collocate_date">CollocatedDataset.collocate_date</a>.
            %   However, if the last argument is a structure, this is not
            %   passed on to collocate_date, but instead interpreted as
            %   instructions to collocate_and_store_date.  Currently, a
            %   single flag is recognised:
            %
            %       autofix     When reading b0rked data, try to fix it by
            %                   recollocating
            %
            % OUT
            %
            %   none (but writes file)
            % 
            % EXAMPLE
            %
            % (example assumes fc is a <a href="matlab:help FieldCopier">FieldCopier</a>)
            % >> mhscpr.collocate_date([2010 9 8], 'noaa18', '', {fc})
            
            default_flags = struct('autofix', false);
            if ~isempty(varargin) && isa(varargin{end}, 'struct')
                flags = optargs_struct(varargin{end}, default_flags);
                varargin = varargin(1:end-1);
            else
                flags = default_flags;
            end
            
            if self.overwrite==2
                error(['atmlab:' mfilename ':invalid'], ...
                    'You set %s %s.overwrite=2.  This is meaningless for core datasets.', class(self), self.name);
            end
            
            additionals = optargs(varargin, {{}});
            self.verify_addis(additionals);
            % get filename
            
            if isempty(spec1)
                spec = spec2;
            elseif isempty(spec2)
                spec = spec1;
            else
                spec = {spec1, spec2};
            end
            
            fn = self.find_granule_by_datetime(date, spec);
            mainfileexists = exist(fn, 'file');
            if ~mainfileexists || self.overwrite == 1
                % assumption:
                % if the main file needs reprocessing, so do all
                % additionals
                
                do_all_main = true;
                % therefore, set those 'overwrite' attributes temporarily
                % to 1
                clobjs = cell(size(additionals));
                owst = zeros(size(additionals));
                for i = 1:length(additionals)
                    owst(i) = additionals{i}.overwrite;
                    clobjs{i} = onCleanup(@()setfield(additionals{i}, 'overwrite', owst(i)));
                    additionals{i}.overwrite = 1;
                end
            else
                do_all_main = false;
            end

            addisexist = false(size(additionals));
            addisvalid = true(size(additionals));
            addisread = repmat({{}}, size(additionals));
            addisprocess = repmat({{}}, size(additionals));
            addishas = repmat({{}}, size(additionals));
            for i = 1:length(additionals)
                fna = additionals{i}.find_granule_by_datetime(date, spec);
                addisexist(i) = exist(fna, 'file');
                if addisexist(i)
                    switch additionals{i}.overwrite
                        case 0
                            addisread{i} = {};
                            addisprocess{i} = {};
                        case 1
                            addisread{i} = {};
                            addisprocess{i} = fieldnames(additionals{i}.members);
                        case 2
                            addisread{i} = {};
                            [addishas{i}, globattr] = quickly_read_gzipped_netcdf_header(additionals{i}.find_granule_by_datetime(date, spec));
                            if additionals{i}.redo_all(globattr.software_version)
                                addisprocess{i} = fieldnames(additionals{i}.members);
                                addisvalid(i) = false;
                            else
                                addisprocess{i} = setdiff(...
                                    fieldnames(additionals{i}.members), ...
                                    addishas{i});
                            end
                        otherwise
                            addisread{i} = 'all';
                            if iscell(additionals{i}.overwrite)
                                addisprocess{i} = additionals{i}.overwrite;
                            else
                                error(['atmlab:' mfilename ':invalid'], ...
                                    '%s %s has invalid value for overwrite', ...
                                    class(self), self.name);
                            end
                    end
                else
                    addisread{i} = {};
                    addisprocess{i} = fieldnames(additionals{i}.members);
                end
            end
            [addisread, addisprocess] = self.meet_dependencies(additionals, addisread, addisprocess, addishas);
            
            % if everything is already there, do nothing
            if mainfileexists && all(cellfun(@isempty, addisprocess))
                logtext(atmlab('OUT'), 'All output files already exist and contain the requested fields.  None are to be processed.\n');
                logtext(atmlab('OUT'), 'I found the following files:\n');
                logtext(atmlab('OUT'), '    %s\n', fn);
                for i = 1:length(additionals)
                    logtext(atmlab('OUT'), '    %s\n', additionals{i}.find_granule_by_datetime(date, spec));
                end
                return
            end

            % so SOME work is to be done, at least

            info_addi = struct();
            info_addi.history = [datestr(now, 'YYYY-mm-dd') ' Obtained additionals from collocs'];
            info_addi.parent_dataset = self.name;
            if iscell(spec)
                info_addi.parent_spec = [spec{:}];
            else
                info_addi.parent_spec = spec;
            end
            
            if mainfileexists && ~self.overwrite
                logtext(atmlab('OUT'), 'Collocations exist, but additionals incomplete or to be overwritten or complemented\n');
                logtext(atmlab('OUT'), 'I will reprocess some additionals\n');
                [result, ~, attr] = self.read_single_day(date, spec, fieldnames(self.cols));
                if isempty(result)
                    logtext(atmlab('OUT'), 'Upon reading collocations, appears there are none, nothing to be done for today\n');
                    return
                end
                info_addi.parent_id = attr.id;
                
%                 if ~isempty(self.log)
%                     logtext(self.log, '%s %s %s Collocations present, regenerate additionals\n', mat2str(date), spec1, spec2);
%                 end
                addi = cell(size(additionals));
                cc = repmat({struct()}, size(additionals));
                for i = 1:length(additionals)
                    % step 1: add fields that must be processed
                    % step 2: read fields needed for later additionals
                    % step 3: possibly try to fix if broken
                    if ~isempty(addisprocess{i})
                        [addi, cc] = self.fill_addi(result, date, spec, spec1, spec2, additionals, i, addi, info_addi, cc, addisprocess, addisvalid);
                        addisprocess{i} = cell(0, 1);
                        addisvalid(i) = true;
                    end
                    
                    if ~isempty(addisread{i})
                        logtext(atmlab('OUT'), 'Reading additionals for %s %s: %s\n', class(additionals{i}), additionals{i}.name, strjoin(vec2row(addisread{i}), ', '));
                        try
                            [addi{i}, cc{i}] = additionals{i}.read_single_day(date, spec, addisread{i});
                            addisvalid(i) = true;
                        catch ME
                            switch ME.identifier
                                case {'atmlab:HomemadeDataset:invalid'}
                                    if flags.autofix
                                        addisvalid(i) = false;
                                        logtext(atmlab('OUT'), ...
                                            'Encountered problem: %s.  I''l try to fix that.', ...
                                            ME.message);
                                    else
                                        ME.rethrow();
                                    end
                                otherwise
                                    ME.rethrow();
                            end
                        end
                                
%                         if addisvalid(i) && isempty(fieldnames(additionals{i}.cols))
%                             additionals{i}.cols = cc;
%                         end
                    else
                        addi{i} = [];
                        cc{i} = struct();
                    end
                    
                    if ~addisvalid(i)
                        logtext(atmlab(out), 'Redoing %s %s completely!', class(additionals{i}), additionals{i}.name);
                        [addi, cc] = self.fill_addi(result, date, spec, spec1, spec2, additionals, i, addi, info_addi, cc, fieldnames(additionals{i}.members), addisvalid);
%                         logtext(atmlab('OUT'), 'Collecting additionals for %s %s\n', class(additionals{i}), additionals{i}.name);
%                         [depdata, depcols] = self.fix_dependencies(additionals{i}, additionals, addi, cc);
%                         
%                         %logtext(atmlab('OUT'), 'Fields to process: %s\n', strjoin(vec2row(addisprocess{i}), ', '));
%                         logtext(atmlab('OUT'), 'Fields to process: %s\n', strjoin(addisprocess{i}(:)', ', ')); % much quicker and to avoid "Warning: Cannot convert zero-sized vector to row "
%                         [addii, cci] = additionals{i}.process_delayed(result, spec1, spec2, depdata, cc, addisprocess{i});
%                         additionals{i}.store(date, spec, addii, info_addi, cci);
%                         if isempty(addi{i})
%                             addi{i} = addii;
%                             cc{i} = cci;
%                         else
%                             addi{i} = [addi{i}, addii];
%                             cc{i} = catstruct(cc{i}, structfun(@(X)X+max(cellfun(@(X)X, struct2cell(cc{i}))), cci, 'UniformOutput', false));
%                         end
                    end
                end

            else
                % So, we redo everything then
                
%                 if ~isempty(self.log)
%                     logtext(self.log, '%s %s %s Generating collocations\n', mat2str(date), spec1, spec2);
%                 end
                try
                    [result, addis, also] = ...
                        self.collocate_date(date, spec1, spec2, additionals);
                catch ME
                    switch ME.identifier
                        case {'atmlab:collocate_date:nosource', ...
                                'atmlab:CollocatedDataset:noother'}
                            logtext(atmlab('ERR'), ...
                                'No succesful collocations at %04d-%02d-%02d, not writing\n', ...
                                date(1), date(2), date(3));
                            return;
                        otherwise
                            ME.rethrow();
                    end
                end
                
                % additional attributes, main part
                
                info_core = struct();
                info_core.history = [datestr(now, 'YYYY-mm-dd') ' Collocations generated from scratch'];
                info_core.maxdist_km = self.distance;
                info_core.maxtime_s = self.interval;
                info_core.primary_dataset = self.primary.name;
                info_core.primary_info = spec1;
                info_core.primary_version = also.version{1};
                info_core.secondary_dataset = self.secondary.name;
                info_core.secondary_sensor = spec2;
                info_core.secondary_version = also.version{2};
                info_core.start_time = double(date2unixsecs(date(1), date(2), date(3)));

                logtext(atmlab('OUT'), 'Storing %d collocations\n', size(result, 1));
                [~, attr] = self.store(date, spec, result, info_core);
                
%                 if ~isempty(additionals) && ~isempty(self.log)
%                         logtext(self.log, '%s Generating additionals\n', mat2str(date));
%                 end
                info_addi.parent_id = attr.id;

                if do_all_main
                    for i = 1:length(additionals)
                        additionals{i}.store(date, spec, addis{i}, info_addi);
                        additionals{i}.overwrite = owst(i);
                    end

                end
            end
        end
        
        function collocate_and_store_date_range(self, date_start, date_end, spec1, spec2, varargin)
            % Collocate and store date range
            %
            % Loop through a range of dates and for each date,
            % <a href="matlab:help CollocatedDataset/collocate_and_store_date">collocate and store</a> collocations for each date.
            %
            % This is the most suitable method for collocating large
            % quantities of data.
            %
            % FORMAT
            % 
            %   col.collocate_and_store_date_range(date_start, date_end, spec1, spec2, varargin)
            %
            % IN
            %
            %   date_start      datevec     starting date
            %   date_end        datevec     ending date
            %   spec1           various     sat or sat pair or empty
            %   spec2           various     sat or sat pair or empty
            %   additionals     cell-array  (optional) <a href="matlab:help AssociatedDataset">AssociatedDataset</a>s, if any
            %   flags           struct      (optional) flags as for <a
            %   href="matlab:help
            %   CollocatedDataset/collocate_and_store_date">collocate_and_store_date</a>.
            %
            % OUT
            %
            %   No output; the volume of data may be very large, so the
            %   only 'output' is written to disc.
            %
            % EXAMPLE
            %            
            % (example assumes fc is a <a href="matlab:help FieldCopier">FieldCopier</a>)
            %   mhscpr.collocate_and_store_date_range([2010 9 1], ...
            %       [2010 9 30], '', 'noaa18', {fc});
            
            try
                self.log = fileopen(fullfile(self.basedir, self.logfile), 'a');
            catch ME
                switch ME.identifier
                    case 'atmlab:fileopen:IOError'
                        logtext(atmlab('ERR'), ...
                            'Unable to append to logfile at %s. Error message: %s. Not writing logfile\n', ...
                            fullfile(self.basedir, self.logfile), ...
                            ME.message);
                        self.log = fileopen('/dev/null', 'w');
                end
            end
            c = onCleanup(@self.cleanup_log);
            logtext(self.log, self.marker);
            logtext(self.log, 'Starting collocations: %s %s %s vs. %s %s from %s to %s\n', ...
                atmlab_version(), self.primary.name, spec1, self.secondary.name, spec2, ...
                mat2str(date_start), mat2str(date_end));
            logtext(atmlab('OUT'), 'Starting collocations\n');
            logtext(atmlab('OUT'), '%s %s vs. %s %s\n', self.primary.name, spec1, self.secondary.name, spec2);
            logtext(atmlab('OUT'), 'From %s to %s\n', mat2str(date_start), mat2str(date_end));
            alldates = daterange(date_start, date_end);
            
            i = 1;
            while i <= size(alldates, 1)
                year = alldates(i, 1);
                month = alldates(i, 2);
                day = alldates(i, 3);
                logtext(atmlab('OUT'), 'collocating %04d-%02d-%02d\n', ...
                    year, month, day);
                try
                    self.collocate_and_store_date([year, month, day], spec1, spec2, varargin{:});
                    i = i + 1;
                catch ME
                    [~] = ME.getReport();
                    switch ME.identifier
                        case {'atmlab:SatDataset:missing_firstline'}
                            % run firstline-thingies
                            if strfind(ME.message, self.primary.name)
                                again = self.primary;
                                spec = spec1;
                            elseif strfind(ME.message, self.secondary.name)
                                again = self.secondary;
                                spec = spec2;
                            else
                                error(['atmlab:' mfilename], ...
                                    ['I received a missing_firstline-error message but ' ...
                                     'I don''t know what dataset it is about. This is a bug. ' ...
                                     'The message was: ' ME.message]);
                            end
                            logtext(atmlab('ERR'), 'Warning: I don''t have firstline-data for today for %s. I''ll try to get some! (todays collocation will be redone)\n', again.name);
                            again.find_granule_first_line(...
                                par(datevec(datenum(alldates(1, :))-1), 1:3), ...
                                par(datevec(datenum(alldates(end, :))+1), 1:3), ...
                                spec);
                            again.granule_first_line(0, spec, true, true); % force reload
                        case {'atmlab:AssociatedDataset:cannolongerread'}
                            logtext(atmlab('ERR'), ...
                                'Oddly, I can no longer read a file I could read in the past.  The full problem is:\n');
                            if isempty(ME.cause{1}.cause)
                                rep1 = [];
                            else
                                rep1 = ME.cause{1}.cause{1}.getReport();
                            end
                            rep2 = ME.cause{1}.getReport();
                            rep3 = ME.getReport();
                            if ~isequal(rep1, [])
                                fprintf(atmlab('ERR'), rep1);
                            end
                            fprintf(atmlab('ERR'), rep2);
                            fprintf(atmlab('ERR'), rep3);
                            logtext(atmlab('ERR'), ...
                                'I''ll redo the entire day completely...\n');
                            ovr = self.overwrite;
                            clo = onCleanup(@()setfield(self, 'overwrite', ovr));
                            self.overwrite = true;
                            self.collocate_and_store_date([year, month, day], spec1, spec2, varargin{:});
                            i = i + 1;
                            self.overwrite = ovr;
                            
                        otherwise
                            ME.rethrow();
                    end
                end
            end
            logtext(self.log, 'Collocations finished. All seems fine.\n');
            logtext(atmlab('OUT'), 'Finished!\n');
            self.success = true;
            %%%
        end
        
        function varargout = read(self, date_start, date_end, spec, all_fields, varargin)
            % Read collocations for indicated period
            %
            % This method reads all or a selection of the collocations for
            % the indicated period, between date_start and date_end.
            % If less than two output arguments are requested, additionals will
            % be merged with the core.  Note that this means that only a
            % fraction of the stored 'core' information will be returned.
            % From each set of secondaries sharing the same primary, only
            % one piece of information will be returned.  It is not defined
            % to what core collocation this belongs.  Therefore, it is not
            % meaningful to both merge, *and* obtain fields from the
            % secondary.
            % Merging is required in the presence of limitations.
            %
            % FORMAT
            %
            % [M, M_cols, addis, addis_cols, additionals] = ...
            %       col.read(date_start, date_end, spec, fields[, limits[,
            %       filters[, associated_datasets]]]);
            %
            % IN
            %
            %   date_start  datevec     First date to read
            %   date_end    datevec     Last date to read (inclusive)
            %   spec        various     Specification. Details depend
            %                           on dataset, but usually a
            %                           string with a satellite or a
            %                           cell array of strings with two
            %                           satellites.
            %   fields      cell-str    Cell array of strings with all
            %                           the fields to be read. Can be
            %                           from the core-dataset or from
            %                           the additional datasets. It must
            %                           contain at least some fields from
            %                           the core dataset. See <a href="matlab:help CollocatedDataset/list_fields">list_fields</a> for a full list.
            %
            %   limits      structure   (optional)
            %                           Structure describing acceptable
            %                           ranges for zero or more fields.
            %                           E.g. struct('LAT1', [-30 30])
            %                           will limit collocations to
            %                           those where the value of
            %                           'LAT1', is between -30 and +30,
            %                           inclusive on both ends.
            %                           NOTE: This (currently) works only
            %                           if you let the output data be
            %                           merged (e.g. 2 output args).
            %   filters     cell-array  (optional)
            %                           Cell array of cell arrays:
            %                           {filter1, filter2, ...}. Each
            %                           filter1 is itself a cell-array
            %                           with 2 or 3 elements:
            %                           {handle, fieldnames, extra},
            %                           where handle is a
            %                           function-handle, fieldnames a
            %                           cell array of strings with
            %                           fields whose values will be
            %                           passed on to the filter, and
            %                           extra a cell array of arbitrary
            %                           values that will be passed on
            %                           to the handle as-is.
            %                           NOTE: This (currently) works only
            %                           if you let the output data be
            %                           merged (e.g. 2 output args).
            %
            %   ads     cell array of AssociatedDatasets
            %
            %       Limit searching of fields in AssociatedDatasets to this
            %       cell-array of AssociatedDatasets. This is necessary if
            %       multiple AssociatedDatasets contain the same fields,
            %       and it is thus ambiguous from what AssociatedDataset a
            %       field is to be read.
            % 
            % OUT
            %
            %   M       matrix      with values corresponding to fields stored
            %                       in core collocations
            %
            %   M_cols  structure   describing what field ended up in what
            %                       column of M
            %
            % More than 2 output arguments will change the behaviour; if
            % you have at most 2 output arguments, the result will be
            % merged; i.e. only one piece of information per primary is
            % returned, yielding information from the secondary potentially
            % meaningless.  With more than 2 output arguments, the result
            % will be separate for each AdditionalDataset, and limitations
            % will not work.
            %
            %   addis   cell-array  Cell array of matrices similar to 'M',
            %                       one for each additional dataset for
            %                       which at least one field was found
            %
            %   addis_cols structure Like M_cols, corresponding to each of
            %                       addis
            %
            %   associated cell-array of AssociatedData containing the
            %                       AssociatedData objects for which at
            %                       least one field ended up in addis.
            %
            % TODO:
            %  - read back from original data. Currently,
            %  col.collocate_and_store_date can already take care of this, if
            %  collocations exist.
            %  - add check that associated-datasets match
            %  - when merging, make sure required fields such as FIRST and
            %  LAST are present
            %
            % EXAMPLE
            %
            % [M, c, MM, cc, aa] = ...
            %       col.read([2007 1 1],[2007 1 10], 'n18', ...
            %                {'LAT1', 'LON1', 'LAT2', 'LON2', 'RO_ice_water_path', 'cld_reff_vis','cld_opd_vis'}, ...
            %                 struct('LAT1', [-30 30]), ...
            %                 {{@(x, y) x>y, {'LAT1', 'LON1'}}});
            %
            %
            
            narginchk(5, 8);
            
            %% prepare configuration things        
            
            [limits, filters_by_name, ads] = optargs(varargin, {struct(), {}, self.associated});
                        
            rqre_datatype(date_start, @isvector);
            rqre_datatype(date_end, @isvector);
            rqre_datatype(spec, {@ischar, @iscellstr});
            rqre_datatype(limits, @isstruct);
            rqre_datatype(filters_by_name, @iscell);
            rqre_datatype(ads, @iscell);
            
            % try to read from cache
            if ~isempty(self.pcd)
                cachestr = self.calc_cache_key(date_start, date_end, spec, all_fields, limits, filters_by_name, ads, nargout);
                if self.pcd.has_entry(cachestr)
                    logtext(atmlab('OUT'), 'Reading from cache entry %s %s.%s\n', ...
                        class(self), self.name, cachestr)
                    varargout = self.pcd.get_entry(cachestr);
                    return
                else
                    logtext(atmlab('OUT'), 'No cache entry found, starting reading\n');
                end
            else
                logtext(atmlab('OUT'), 'No cache object defined, starting reading\n');
            end
            
            % distribute fields, limits, etc. over core, additionals
            [fields_core, additionals, additional_fields, ~] = self.deal_fields(all_fields, ads);

            additionals_day = cell(size(additional_fields));
            addis_cols = cell(size(additional_fields));
            addis_cols_here = cell(size(additional_fields));
            addis = cell(size(additional_fields));
            for i = 1:length(addis)
                addis{i} = struct();
            end
            
            merge = false;
            if nargout<3 && ~isempty(additionals)
                merge = true;
                logtext(atmlab('OUT'), ...
                    'CollocatedDataset.read was called with %d (<3) output arguments, additionals will be merged into the first 2 arguments, possibly reducing their size!\n', ...
                    nargout);
            
                % if merging, check that required merging fields are all
                % there
                for j = 1:length(additionals)
                    required_fields = additionals{j}.get_mergefields();
                    given_fields = additional_fields{j};
                    for k = 1:length(required_fields)
                        required_field = required_fields{k};
                        if ~any(strcmp(given_fields, required_field))
                            logtext(atmlab('OUT'), ...
                                'Additional dataset %s requires field %s, but not given. Will add unsolicited!\n', ...
                                additionals{j}.name, required_field);
                            additional_fields{j} = [additional_fields{j} required_field];
                        end
                    end
                end
                
            elseif nargout>=3 % more than 2 output arguments
                if ~isempty(fieldnames(limits)) || ~isempty(filters_by_name)
                    error(['atmlab:' mfilename ':NotImplemented'], ...
                        ['Applying limits or filters is not supported when ' ...
                         'additionals are seperately output. Try running ' ...
                         'with less than 3 output arguments (found %d) or ' ...
                         'do your own limitations aftewards. Sorry!'], ...
                         nargout);
                end
            end
            % Not filtering duplicates, this should be done when processing
            % collocations initially, just before storing

            M = [];
            
            %% loop through all the dates
            
            dates = daterange(date_start, date_end);
            M_cols = struct();
            M_cols_merged = struct();
            filters_by_no = cell(size(filters_by_name));
            hitno = 0; % count no. of days with collocs
            for i = 1:size(dates, 1)
                date = dates(i, :);
                %% read collocations for date
                                                
                try
                    [collocations_day, M_cols_core_here, attr_core] = self.read_single_day(date, spec, fields_core);

                    if numel(collocations_day)==0
                        if length(fields_core) == 0
                            % ugly hack, will secretly read core ANYWAY
                            % because I need to tell if there are
                            % collocations
                            collocations_day = self.read_single_day(date, spec, {'LAT1'});
                            if numel(collocations_day) == 0
                                logtext(atmlab('OUT'), 'really no collocations\n');
                                continue
                            else
                                logtext(atmlab('OUT'), 'no fields asked from core\n');
                            end
                        else
                            logtext(atmlab('OUT'), 'no collocations\n');
                            continue
                        end
                    end
                    M_cols_core = M_cols_core_here;
                    %hitno = hitno + 1;
                    % also read for all additionals
                    for j = 1:length(additionals)
                        [additionals_day{j}, addis_cols_here{j}, attr_addi] = additionals{j}.read_single_day(date, spec, additional_fields{j});
                        % verify that AssociatedDataset was generated for
                        % the same CollocatedDataset
                        self.verify_addi_granule_consistency(attr_core, attr_addi, additionals{j}, date);
                        if numel(additionals_day{j})>0
                            addis_cols{j} = addis_cols_here{j};
                        end
                    end
                    stoplater = false;
                    if merge
                        M_cols_merged_here = M_cols_core_here;
                        for j = 1:length(additionals)
                            [collocations_day, M_cols_merged_here] = additionals{j}.merge_matrix(collocations_day, M_cols_merged_here, additionals_day{j}, addis_cols_here{j});
                        end
                        %M_cols = M_cols_here;
                        if numel(collocations_day)==0
                            logtext(atmlab('OUT'), 'At least one of the additionals had 0 elements. Upon merging, no collocations left --- continuing with next day\n');
                            stoplater = true;
                        else
                            M_cols_merged = M_cols_merged_here;
                        end
                        M_cols = M_cols_merged;
                    else
                        M_cols = M_cols_core;
                    end
                catch ME
                    switch (ME.identifier)
                        case {'MATLAB:load:couldNotReadFile', ...
                                'MATLAB:nonExistentField', ...
                                'MATLAB:gunzip:invalidFilename',...
                                'MATLAB:netcdf:open:noSuchFile', ...
                                'atmlab:exec_system_cmd:shell', ...
                                'atmlab:find_granule_by_datetime'}
                            logtext(atmlab('ERR'), 'Problem for %04d-%02d-%02d: %s\n', ...
                                date(1), date(2), date(3), ME.message);
                            continue
                        otherwise
                            ME.rethrow();
                    end
                end
                
                if stoplater
                    continue
                else
                    hitno = hitno + 1;
                end
                
                %% apply limitations
                if hitno == 1
                    % convert limits-structure to limits-matrix. This is
                    % done only after the first time I find collocations,
                    % because only then I know for sure what sizes the
                    % fields have.
                    limmat = limstruct2limmat(limits, M_cols);
                    for k = 1:length(filters_by_name)
                        filters_by_no{k} = {...
                            filters_by_name{k}{1}, ...
                            cellfun(@(s) M_cols.(s)', filters_by_name{k}{2}, 'UniformOutput', false), ...
                            filters_by_name{k}{3:end}};
                    end
                    
                end
                
                lim = collocation_restrain(collocations_day, limmat, filters_by_no);
                collocations_day = collocations_day(lim, :);
                
                %% add to total
                if isempty(M) % should mean additionals are empty, too
                    M = collocations_day;
                    addis = additionals_day;
                else
                    L = size(M, 1);
                    N = size(collocations_day, 1);
                    M((L+1):(L+N), :) = collocations_day;
                    logtext(atmlab('OUT'), '%d + %d = %d collocations so far\n', L, N, L+N);
                    for j = 1:length(additional_fields)
                        N_a = size(additionals_day{j}, 1);
                        if ~isempty(additionals_day{j})
                            addis{j}((L+1):(L+N_a), :) = additionals_day{j};
                        end
                    end
                end
            end
            if hitno==0
                warning(['atmlab:' mfilename], ...
                    'No collocations found at all. Do not trust column descriptions.');
            end
            
            varargout{1} = M;
            if nargout > 1
                varargout{2} = M_cols;
                if nargout > 2
                    varargout(3:5) = {addis, addis_cols, additionals};
                end
            end
            
            % possibly cache result
            if ~isempty(self.pcd)
                logtext(atmlab('OUT'), 'Storing result in cache\n');
                try
                    self.pcd.set_entry(cachestr, varargout, ...
                        {self.name, date_start, date_end, spec, all_fields, limits, evalc('disp(filters_by_name)')}); % OUCH! :(
                catch ME
                    switch ME.identifier
                        case 'atmlab:PersistentCachedData:noSpace'
                            logtext(atmlab('ERR'), 'Not storing, no space: %s', ME.message);
                        otherwise
                            ME.rethrow();
                    end
                end
            end
            
            %%%
        end
        
        function varargout = list_fields(self)
            % return struct with valid fields in this dataset + associated
            %
            % If called without output arguments, writes to atmlab('OUT') a
            % pretty-printed list of all fields that are valid to pass on
            % to self.read. With one output argument, return a structure
            % with this information. No input arguments.
            %
            % WARNING: this lists the fields as defined in the core and
            % associated datasets.  It is possible that some collocations
            % were generated with older versions of those datasets.
            % Therefore, it is NOT guaranteed that all those fields can be
            % read for all granules!
            
            S.(self.name) = list_fields@HomemadeDataset(self);
            for i = 1:length(self.associated)
                S.(self.associated{i}.name) = self.associated{i}.list_fields();
            end
            switch nargout
                case 0 % write it out nicely
                    mems = fieldnames(S);
                    for i = 1:length(mems)
                        fprintf(atmlab('OUT'), '%s:\n', mems{i});
                        fprintf(atmlab('OUT'), '    ');
                        for k = 1:length(S.(mems{i}))
                            fprintf(atmlab('OUT'), '%s ', S.(mems{i}){k});
                        end
                        fprintf(atmlab('OUT'), '\n\n');
                    end
                case 1
                    varargout = {S};
                otherwise
                    error(['atmlab:' mfilename], 'Too many output arguments');
            end
        end
        
        % low-level
        
        function collocations = collocate(self, t1, lat1, long1, t2, lat2, long2)
            % collocate Return collocations between matrices
            %
            % collocate searches for collocations between the measurements in (t1, lat1,
            % long1) and (t2, lat2, long2). Latitudes and longitudes should be in degrees,
            % the time can be in any unit. 'collocate' considers footprints as points and
            % defines a collocation according to a maximum distance ('maxdist', in km).
            % The maximum time to consider a collocation is in 'maxtime' and should be in
            % the same unit as t1 and t2.
            %
            % The maximum distance and time are defined by the properties
            % <a href="matlab:help CollocatedDataset/distance">distance</a> and <a href="matlab:help CollocatedDataset/interval">interval</a>.
            %
            % This is a low-level method that is not usually called
            % directly. Rather call <a href="matlab:help CollocatedDataset/collocate_granule">collocate_granule</a> or
            % <a href="matlab:help CollocatedDataset/collocate_and_store_date_range">collocate_and_store_date_range</a> or so.
            %
            % FORMAT collocations = cd.collocate(t1, lat1, long1, t2, lat2, long2)
            %
            % OUT M       Nx4 matrix. Each row corresponds to a collocation, and has the
            %             rows and columns of the 1st and 2nd dataset respectively. 
            %
            % IN  t1      Array length L1 giving the times of the scanlines.
            % IN  lat1    Matrix L1xW1 with latitude for L1 scanlines with W1 scans per
            %             line. The latitude should be in degrees.
            % IN  long1   Matrix L1xW1 with longitude (-180, 180), L1 scans, W1 scans/line.
            % IN  t2      Array of length L2 giving the times of the scanlines.
            % IN  lat2    Matrix L2xW2 with latitude, L2 scans, W2 scans/line.
            % IN  long2   Matrix L2xW2 with longitude (-180, 180), L2 scans, W2 scans/line.
            %
            % Hint: if the collocations are slow, try tweaking <a href="matlab:help
            % CollocatedDataset/gridsize">gridsize</a>.

            %% data checks

            nrows1 = size(lat1, 1);
            ncols1 = size(lat1, 2);
            nrows2 = size(lat2, 1);
            ncols2 = size(lat2, 2);
            nel1 = numel(lat1);
            nel2 = numel(lat2);

            errid = 'atmlab:collocate';
            % check dimensions
            assert(size(long1, 1)==nrows1, errid, 'length long1 differs from length lat1');
            assert(size(long2, 1)==nrows2, errid, 'length long2 differs from length long1');
            assert(length(t1)==nrows1, errid, 'length t1 differs from length lat1');
            assert(length(t2)==nrows2, errid, 'length t2 differs from length long2');
            assert(size(long1, 2)==ncols1, errid, 'width long1 differs from width lat1');
            assert(size(long2, 2)==ncols2, errid, 'width long2 differs from width lat2');

            % check correct numbers
            assert(max(abs(long1(:)))<=180, errid, 'Invalid data in long1');
            assert(max(abs(lat1(:)))<=90, errid, 'Invalid data in lat1');
            assert(max(abs(long2(:)))<=180, errid, 'Invalid data in long2');
            assert(max(abs(lat2(:)))<=180, errid, 'Invalid data in lat2');
            if length(lat1) > 1 && length(lat2) > 1
                assert(max(lat1(:))~=min(lat1(:)), errid, 'lat1 constant');
                assert(max(lat2(:))~=min(lat2(:)), errid, 'lat2 constant');
                assert(max(long1(:))~=min(long1(:)), errid, 'lon1 constant');
                assert(max(long2(:))~=min(long2(:)), errid, 'lon2 constant');
            end
            
            %% make t, rows, cols at the same grid --> no need for ind2sub
            
            t1f = reshape(repmat(t1, [1 ncols1]), [1 nel1]);
            rows1f = reshape(repmat((1:nrows1)', [1 ncols1]), [1 nel1]);
            cols1f = reshape(repmat(1:ncols1, [nrows1 1]), [1 nel1]);

            t2f = reshape(repmat(t2, [1 ncols2]), [1 nel2]);
            rows2f = reshape(repmat((1:nrows2)', [1 ncols2]), [1 nel2]);
            cols2f = reshape(repmat(1:ncols2, [nrows2 1]), [1 nel2]);

            % determine earth radius

            earth_radius = constants('EARTH_RADIUS_MEAN')/1e3; % m -> km

            %% find collocations

            % arbitrary start for pre-alloc, but getting more if needed later
            collocations = zeros(numel(lat1), 4, 'uint32');

            % Bin the measurements into bins, where the 'data' is the index of the
            % measurement. We only need to consider those bins where:
            % - instrument 1 has any measurements in the cell
            % - instrument 2 has any mearurements in the cell or a nearby cell
            % "Nearby" cell means a neighbouring cell, except near the poles, where it
            % can be much further away (because the cells are equirectangular)
            
            % NB! New method as per 2013-03-04!
            logtext(atmlab('OUT'), 'Gridding %d + %d = %d points using %s method...\n', ...
                numel(lat1), numel(lat2), numel(lat1)+numel(lat2), self.binning);
            if isequal(self.binning, 'classical')
                [grid1, lat_grid1, ~] = binning_fast(...
                    struct(...
                    'lat', lat1(:), ...
                    'lon', long1(:), ...
                    'data', uint32(1:numel(lat1)).', ...
                    'gridsize', self.gridsize));
                
                grid2 = binning_fast(...
                    struct(...
                    'lat', lat2(:), ...
                    'lon', long2(:), ...
                    'data', uint32(1:numel(lat2)).', ...
                    'gridsize', self.gridsize));
                
            elseif isequal(self.binning, 'experimental')
                lat_grid1 = -90:self.gridsize:90;
                lon_grid1 = -180:self.gridsize:180;
                % cache result because same binning happens repeatedly if
                % collocating one primary granule with many secondary
                % granules
                grid1 = self.cache.evaluate(1, @bin_nd, {lat1(:), long1(:)}, {lat_grid1, lon_grid1});
                
                lat_grid2 = lat_grid1;
                lon_grid2 = lon_grid1;
                grid2 = self.cache.evaluate(1, @bin_nd, {lat2(:), long2(:)}, {lat_grid2, lon_grid2});
                % throw away exactly-polar values (should be extremely
                % rare). FIXME: should add to last gridcell instead,
                % preferably inside bin_nd, not implemented
                grid1 = grid1(1:end-1, 1:end-1);
                grid2 = grid2(1:end-1, 1:end-1);
            else
                error(['atmlab:' mfilename ':unknownmethod'], ...
                    '%s.binning must be ''experimental'' or ''classical'', got ''%s''', ...
                    self.name, self.binning);
            end
            
            n_grid_lats = size(grid1, 1);
            n_grid_lons = size(grid1, 2);

            % Check each cell where there is data for grid1 AND at least one
            % neighbouring cell, or the cell itself, has data for grid2

            count = 0;

            % the width and height of the cells as a function of latitude
            cell_width = 2 * pi * earth_radius * cosd(lat_grid1) / 360;
            cell_height = 2 * pi * earth_radius / 360;

            % how many cells of longitude to check for particular latitude
            cells_in_lat_range = ceil(self.distance ./ cell_width);
            
            % very close to the poles, cells_in_lat_range may go to
            % infinity, but we never need more than the number of lats.
            cells_in_lat_range(cells_in_lat_range>n_grid_lats) = n_grid_lons;
            
            c_lon = ceil(self.distance ./ cell_height);

            logtext(atmlab('OUT'), 'Searching for collocations per grid-point...\n');
            for i = 1:size(grid1, 1) % latitude
                c_lat = cells_in_lat_range(i);
                for j = 1:size(grid1, 2) % longitude
                    if any(grid1{i, j})
                        
                        % find indices of points in this grid-cell
                        in_grid1 = grid1{i, j};
                        
                        % which range of grid-cells to look for collocations?
                        
                        % for longitude (cols), depends on cells_in_range
                        cols = j-c_lat:j+c_lat;
                        cols = unique(mod(cols, n_grid_lons));
                        cols(cols==0) = n_grid_lons;

                        % for latitude (rows), no dependence on lat

                        rows = i-c_lon:i+c_lon;
                        % edges do not wrap: if rows < 1  
                        rows(rows<1) = [];
                        rows(rows>n_grid_lats) = [];
                        
                        % find indices of points in nearby grid-cells to consider
                        in_grid2 = grid2(rows, cols);
                        % flatten and convert to an array
                        in_grid2 = vertcat(in_grid2{:});
                        if isempty(in_grid2)
                            continue
                        end           
                        
                        % find combinations of points that are near each other
                        for p1 = in_grid1'
                            index1 = rows1f(p1);
                            colno1 = cols1f(p1);
                            shorttime = in_grid2(abs(t2f(in_grid2) - t1f(p1)) < self.interval);
                            near = shorttime(sphdist(lat1(p1), long1(p1), ...
                                lat2(shorttime), long2(shorttime), ...
                                earth_radius) < self.distance);

                            nnear = length(near);
                            if nnear
                                index2 = rows2f(near)';
                                colno2 = cols2f(near)';
                                collocations(count+1:count+nnear, :) = ...
                                    [repmat(index1, [nnear 1]) repmat(colno1, [nnear 1]) ...
                                    index2 colno2];
                                count = count + nnear;
                            end
                            if count > .8*size(collocations, 1) % pre-allocate more
                                collocations = [collocations; ...
                                    zeros(size(collocations, 1), 4, 'uint32')]; %#ok<AGROW>
                            end
                        end
                    end
                end % for all grid rows
            end % for all grid columns

            % removing 0's
            collocations(collocations(:, 1)==0, :)=[];
        end
                        
        %% overload parent methods

        function line = granule_first_line(~, varargin)
            line = uint32(1); % collocated datasets do not contain duplicates
        end

    end
    
    methods (Access = {?SatDataset})
        function [fields, additionals, additional_fields, deal_index] = deal_fields(self, all_fields, ads)
            % deal fields over core, additionals, etc.
            %
            % FORMAT
            %
            %   [fields, additionals, additional_fields, deal_index] = ...
            %       deal_fields(all_fields)
            %
            % IN
            %
            %   all_fields  cell-array  all fields to be sorted
            %   ads         cell-array of associated datasets that must be
            %               a subset of self.associated
            %
            % OUT
            %
            %   fields_core         cell array  fields in core
            %   additionals         cell array  <a href="matlab:help
            %                       AssociatedDataset">AssociatedDataset</a>s
            %   additional_fields   cell array of cell array of fields
            %   deal_index          vector          
            
            n_f = 0;
            n_add = zeros(size(self.associated));
            fields = {};
            additionals = {};
            additional_fields = {};
            existing_names = {};
            % pre-allocate so that every field is at least an empty
            % cell-array
            %additional_fields = cell(size(self.associated));
            %for i = 1:length(self.associated)
            %    additional_fields{i} = {};
            %end
            deal_index = nan*zeros(size(all_fields));
            for i = 1:length(all_fields)
                field = all_fields{i};
                if any(strcmp(fieldnames(self.members), field))
                    % belongs to the core
                    n_f = n_f + 1;
                    fields{n_f} = field; %#ok<AGROW>
                    deal_index(i) = 0;
                else
                    % check if it belongs to any associated
                    found = false;
%                    additionals = cell(size(ads));
%                    existing_names = cell(size(ads));
                    for j = 1:length(ads)
                        asso = ads{j};
                        if any(strcmp(fieldnames(asso.members), field))
                            n_add(j) = n_add(j) + 1;
                            already_exists = cellfun(@(X) any(strcmp(field, X)), additional_fields);
                            if any(already_exists)
                                error(['atmlab:' mfilename], ...
                                    ['More than one additional contains field ' ...
                                     field '. Found in: ' ...
                                     additionals{already_exists}.name ' and ' ...
                                     asso.name '.\n' ...
                                     'Now I don''t know where to grab it from. ' ...
                                     'Please pass subset of AssociatedDatasets on to CollocatedDataset.read (' ...
                                     'see <a href="matlab:help CollocatedDataset/read">help</a>)']);
                            end
                            
                            additional_fields{j}{n_add(j)} = field;  %#ok<AGROW>
                            % check if this additionaldataset is already
                            % known, if yes, find index in existing names
                            %                           existing_names = cellfun(@(X) X.name, additionals, 'UniformOutput', false);
                            if ~any(strcmp(existing_names, asso.name))
                                %                               additionals = {additionals{:} asso}; %#ok<CCAT>
                                additionals{j} = asso;
                                existing_names{j} = asso.name;
                            end
                            samename = strcmp(existing_names, asso.name);
%                            assert(sum(samename)<=1, ['atmlab:' mfilename], ...
%                                ['More than one additional contains field ' ...
%                                asso.name]);
                            deal_index(i) = find(samename);
                            found = true;
                        end
                    end
                    if ~found
                        error(['atmlab:' mfilename], ...
                            'Field %s was not found in core or in any additional dataset', ...
                            field);
                    end
                end
            end
            % don't have empty things
            additional_fields = additional_fields(~cellfun(@isempty, additional_fields));
            additionals = additionals(~cellfun(@isempty, additionals));
            assert(length(additionals)==length(additional_fields), ...
                ['atmlab:' mfilename ':BUG'], ...
                'length(additionals) == %d != length(additional_fields) == %d, bug?', ...
                length(additionals), length(additional_fields));
%             assert(logical(exist('fields','var')),['atmlab:' mfilename ':notImplemented'],...
%                 'No fields from the core dataaset are listed in all_fields')
            
        end
        
        function cleanup_log(self)
            if ~self.success
                logtext(self.log, 'Collocations ended prematurely\n');
            end
            fclose(self.log);
        end
        
        function verify_addis(self, addis)
            % verify that all those additionals are actually known to me
            
            for i = 1:length(addis)
                addi = addis{i};
                knownnames = cellfun(@(x) x.name, self.associated, 'UniformOutput', false);
                if ~any(strcmp(addi.name, knownnames))
                    
                    error(['atmlab:' mfilename ':invalid'], ...
                        ['Hi!  This is %s %s speaking. ' ...
                        ' You asked to get %s %s as an AssociatedDataset, but you can only pass' ...
                        ' AssociatedDatasets that were created in my honour. ' ...
                        ' %s %s was created for %s %s. ' ...
                        ' As far as I know, mine are: %s'], ...
                        class(self), self.name, ...
                        class(addi), addi.name, ...
                        class(addi), addi.name, ...
                        class(addi.parent), addi.parent.name, ...
                        strjoin(knownnames, ', '));
                end
            end
        end
        
        function verify_addi_granule_consistency(self, attr_core, attr_addi, addi, date)
            % verify consistency between addi granule and core granule
            %
            % Note that this is different from verify_addis. Verify_addis
            % just checks the AssociatedDataset objects, whereas this one
            % verifies that the actual AssociatedDataset granule is
            % consistent with a CollocatedDataset granule
            if ~strcmp(attr_core.id, attr_addi.parent_id)
                error(['atmlab:' mfilename ':inconsistent'], ...
                    ['Upon reading %s %s with %s %s for date %s, ' ...
                    'found mismatch. %s %s was generated for ' ...
                    '%s %s with id ''%s'', but %s %s has id ''%s'''], ...
                    class(self), self.name, ...
                    class(addi), addi.name, ...
                    datestr(datenum(date)), ...
                    class(addi), addi.name, ...
                    class(self), self.name, ...
                    attr_addi.parent_id, ...
                    class(self), self.name, ...
                    attr_core.id);
            end
        end
        
    end
    
    methods (Access = {?SatDataset})
        function add_associated(self, ad)
            % Add an associated dataset INTERNAL USE ONLY
            %
            % FORMAT
            %
            %   cd.add_associated(ad);
            
            self.associated = {self.associated{:} ad}; %#ok<CCAT>
        end
        
        %% overload parent methods
        
        function [data, attr] = read_homemade_granule(self, fullpath, fields)
            core_fields = {'LAT1', 'LON1', 'TIME1'};
            
            errID = ['atmlab:' mfilename ':error'];
            % core
            [data, attr] = read_homemade_granule@HomemadeDataset(self, fullpath, core_fields);
            
            [~, additionals1, additional_fields1] = self.deal_fields(fields, self.associated);
            info = self.find_info_from_granule(fullpath);
            for i = 1:length(additionals1) % this is where the AssociatedDatasets are
                tmppath = additionals1{i}.find_granule_by_datetime(...
                    [str2double(info.year),str2double(info.month),str2double(info.day)],...
                    info.satname);
                [tmpS, tmpA] = additionals1{i}.read_homemade_granule(tmppath, additional_fields1{i});
                self.verify_addi_granule_consistency(attr, tmpA, additionals1{i});
                attr.(self.associated{1}(i).name) = tmpA;
                tmpS.(['path_' self.associated{1}(i).name]) = tmpS.path;
                data = additionals1{i}.merge_struct(data,rmfield(tmpS,{'path','epoch'}));
            end
            assert(all(ismember([core_fields(:);fields(:)],fieldnames(data))),errID,'Some field(s) is(are) missing')
            
            % collocations have time in unixsecs, but datasets have time in
            % seconds since start of day, which happens to equal data.epoch
            data.time = data.TIME1 - data.epoch;
            data.lat = data.LAT1;
            data.lon = data.LON1;
            data.version = ['COL(' attr.primary_version ', ' attr.secondary_version ')'];
            
        end
        
    end
    
    methods (Access = protected)
        %% implement new methods
        
        function M = process(self, collocations, data1, date1, spec1, data2, date2, spec2)
            % Process core collocations
            %
            % This method processes the output of <a href="matlab:help collocate">collocate</a>
            % and converts it to a matrix that is passed on for further
            % processing.
            %
            % This is an internal method not normally called by the end
            % user.
            %
            % FORMAT
            %
            %    M = cd.process(collocs, data1, date1, spec1, ...
            %                            data2, date2, spec2);
            %
            % IN
            %
            %   collocs     matrix      as output by <a href="matlab:help collocate</a>collocate</a>
            %   data1       struct      as returned by primary <a href="matlab:help SatDataset/reader">reader</a>
            %   date1       datevec     datevec for primary
            %   spec1       various     spec for primary (sat, sat pair, ...)
            %   data2       struct      as returned by secondary <a href="matlab:help SatDataset/reader">reader</a>
            %   date2       datevec     datevec for secondary
            %   spec2       various     spec for secondary
            %
            % OUT
            %
            %   M           matrix      collocations, columns described by
            %                           <a href="matlab:help CollocatedDataset/cols">self.cols</a>
            
            % NOTE: time is assumed to be 1D
            
            n = size(collocations, 1);
            X = mat2cell(collocations, size(collocations, 1), [1 1 1 1]);
            
            c = self.cols;
            nfields = length(fieldnames(c));
            M = nan*zeros(n, nfields, self.mattype);
            [line1, pos1, line2, pos2] = X{:};
            
            % index for direct addressing
            i1 = sub2ind(size(data1.lat), line1, pos1);
            i2 = sub2ind(size(data2.lat), line2, pos2);
            
            M(:, c.LINE1) = line1;
            M(:, c.LINE2) = line2;
            
            M(:, c.POS1) = pos1;
            M(:, c.POS2) = pos2;
            
            M(:, c.LAT1) = data1.lat(i1);
            M(:, c.LON1) = data1.lon(i1);
            
            M(:, c.LAT2) = data2.lat(i2);
            M(:, c.LON2) = data2.lon(i2);
            
            M(:, c.START1) = self.primary.get_starttime(date1);
            M(:, c.START2) = self.secondary.get_starttime(date2);
            
            M(:, c.TIME1) = double(data1.epoch) + double(data1.time(line1));
            M(:, c.TIME2) = double(data2.epoch) + double(data2.time(line2));
            
            M(:, c.DIST) = sphdist(M(:, c.LAT1), M(:, c.LON1), ...
                                   M(:, c.LAT2), M(:, c.LON2), ...
                                   constants('EARTH_RADIUS')/1e3);
            
            M(:, c.INT) = M(:, c.TIME2) - M(:, c.TIME1);

            %% sort, needed for averaging stuff later

            M = sortrows(M, [c.START1 c.LINE1 c.POS1 c.START2 c.LINE2 c.POS2]);
            
            
            %% remove duplicates
            
            first1 = self.primary.granule_first_line(date1, spec1);
            first2 = self.secondary.granule_first_line(date2, spec2);
            wrongrows = (M(:, c.LINE1) < first1) | ...
                (M(:, c.LINE2) < first2);
            logtext(atmlab('OUT'), ['Removing %d scanlines primary before %d, ', ...
                'or secondary before %d\n'], ...
                sum(wrongrows), first1, first2);
            M(wrongrows, :) = [];
            
            % add row-number after all else, here, but REDO just before
            % storing!
            if ~isempty(M)
                M(:, c.INDEX) = 1:size(M, 1);
            end
        end
        
        function nm = calculate_name(self)
            nm = [class(self) '__1_' self.primary.name '__2_' self.secondary.name];
        end
        
        function s = calc_cache_key(self, date_start, date_end, spec, all_fields, limits, filters_by_name, ads, no)
            % calculate a unique cache-key based on inputs
            
            % first generate an array of int8
            if isempty(spec)
                sp = uint8(0);
            elseif ischar(spec)
                sp = uint8(spec);
            else
                sp = cellfun(@uint8, spec, 'UniformOutput', false);
                sp = [sp{:}];
            end
            af = cellfun(@uint8, all_fields, 'UniformOutput', false);
            af = [af{:}];
            ff = cellfun(@(x) uint8([func2str(x{1}) horzcat(x{2}{:})]), filters_by_name, 'UniformOutput', false);
            ff = [ff{:}];
            ads = cellfun(@(x) uint8(x.name), ads, 'UniformOutput', false);
            ads = [ads{:}];
            D = [uint8(self.name), ...
                 typecast(uint16(date_start), 'uint8'), ...
                 typecast(uint16(date_end), 'uint8'), ...
                 sp, af, ff, ads, ...
                 uint8(struct2string_compact(limits)), ...
                 uint8(no)];
                        
            md = java.security.MessageDigest.getInstance('md5');
            md.update(D);
            digest = md.digest;
            s = genvarname(sprintf('%02x', typecast(digest, 'uint8')));

        end
         
    end
    
    methods (Access = private)
         function [addi, cc] = fill_addi(self, result, date, spec, spec1, spec2, additionals, i, addi, info_addi, cc, addisprocess, addisvalid)
            % fill up additional no. i.
            logtext(atmlab('OUT'), 'Collecting additionals for %s %s\n', class(additionals{i}), additionals{i}.name);
            [depdata, depcols] = self.fix_dependencies(additionals{i}, additionals, addi, cc);
            
            %logtext(atmlab('OUT'), 'Fields to process: %s\n', strjoin(vec2row(addisprocess{i}), ', '));
            if isequal(addisprocess, 'all')
                logtext(atmlab('OUT'), 'Processing all fields\n');
            else
                logtext(atmlab('OUT'), 'Fields to process: %s\n', strjoin(addisprocess{i}(:)', ', ')); % much quicker and to avoid "Warning: Cannot convert zero-sized vector to row "
            end
            [addii, cci] = additionals{i}.process_delayed(result, spec1, spec2, depdata, cc, addisprocess{i});
            curstate = additionals{i}.overwrite;
            if ~addisvalid(i)
                additionals{i}.overwrite = 1;
            end
            additionals{i}.store(date, spec, addii, info_addi, cci);
            additionals{i}.overwrite = curstate; %#ok<NASGU> M-Lint is simply wrong here.
            if isempty(addi{i})
                addi{i} = addii;
                cc{i} = cci;
            else
                addi{i} = [addi{i}, addii];
                cc{i} = catstruct(cc{i}, structfun(@(X)X+max(cellfun(@(X)X, struct2cell(cc{i}))), cci, 'UniformOutput', false));
            end
            
         end
    end
   
    methods (Static, Access = private)
        function sorted = sort_additionals(additionals)
            % sort additionals per dependencies
            %
            % Taking into account dependencies, sort the <a href="matlab:help AdditionalDataset">AdditionalDataset</a>s
            % in an appropiate order.
            %
            % FORMAT
            %
            %   sorted_addis = cd.sort_additionals(unsorted_addis)
            %
            % IN
            %
            %   cell array of <a href="matlab:help AdditionalDataset">AdditionalDataset</a>s
            %
            % OUT
            %
            %   cell array of <a href="matlab:help AdditionalDataset">AdditionalDataset</a>s
            oldidx = zeros(size(additionals));
            for k = 1:100
                for i = 1:length(additionals)
                    if ~isempty(additionals{i}.dependencies)
                        additionals{i}.priority = max(cellfun(@(x) x.priority, additionals{i}.dependencies))+1;
                    else
                        additionals{i}.priority = 0;
                    end
                end
                [~, idx] = sort(cellfun(@(x) x.priority, additionals));
                if isequal(idx, oldidx)
                    break
                end
                oldidx = idx;
            end
            if k==100
                error(['atmlab:' mfilename], ...
                    'Unable to sort additionals. This might indicate a circular dependency --- or a bug');
            end
            sorted = additionals(idx);
        end
        
        function [depdata, depcols] = fix_dependencies(additional_current, additional_all, results_so_far, varargin)
            % put data in cell array for dependencies
            %
            % This static method assures that requirements for additional X
            % (first argument) are met, given other additionals (second
            % argument) and results so far (third argument).
            %
            % FORMAT
            %
            %   depdata = cd.fix_dependencies(this_additional, all_additionals, result_so_far)
            %
            % IN
            %
            %   this_additional   <a href="matlab:help AdditionalDataset">AdditionalDataset</a> currently being worked on
            %   all_additionanls  cell array of all <a href="matlab:help AdditionalDataset">AdditionalDataset</a>s
            %   result_so_far     cell array with results of <a href="matlab:help AdditionalDataset">AdditionalDataset</a>s
            %                     already processed
            %   cc                cell array with cols structures
            %                     describing results_so_far
            %
            % OUT
            %
            %   depdata           cell array with results to be passed on
            %                     to the <a href="matlab:help AdditionalDataset">AdditionalDataset</a>
            %                     under consideration
            %
            %   depcols           cell array with cols structures belonging
            %                     to depdata
            
            cc = optargs(varargin, {cellfun(@(X) X.cols, additional_current.dependencies, 'UniformOutput', false)});
            if isempty(additional_current.dependencies)
                depdata = {};
                depcols = struct();
            else
                % for each dependency, find out what data to put in
                % depdata
                depdata = cell(size(additional_current.dependencies));
                depcols = cell(size(depdata));
                for di = 1:length(additional_current.dependencies)
                    depcy = additional_current.dependencies{di};
                    % dependency should match exactly one
                    nm_match = cellfun(@(X) strcmp(X.name, depcy.name), additional_all);
                    assert(sum(nm_match)==1, ['atmlab:' mfilename], ...
                        'Expected one name match. Got %d.', sum(nm_match));
                    % if the following line fails, something likely
                    % went wrong when sorting the additionals
                    % according to their dependencies
                    depdata{di} = results_so_far{nm_match};
                    depcols{di} = cc{nm_match};
                end
            end
        end
        
        function [addisread, addisprocess] = meet_dependencies(additionals, addisread, addisprocess, addishas)
            % adapt addisread, addisprocess so that dependencies read at
            % least the fields they should.
            

            % FIXME: should consider the fields that are wanted
            for i = 1:length(additionals)
                if isempty(addisprocess{i})
                    continue
                end
                %addi = additionals{i};
                for j = 1:length(additionals{i}.dependencies)
                    met = false;
                    for k = 1:(i-1)
                        if isequal(additionals{k}.name, additionals{i}.dependencies{j}.name)
                            met = true;
                            needs = additionals{i}.fields_needed_for_dependency(addisprocess{i}, additionals{i}.dependencies{j});
                            % make sure it reads what it has to read
                            
                            % FIXME 2013-06-11: should I be reading the
                            % netcdf header here to see what is already
                            % present?  Changing to simply put in
                            % addisread{k} what it needs.  What if a
                            % dependency is not yet there, but still to be
                            % processed?  Will this work out?
                            
%                             has_needed = ismember(needs, addishas{k});
%                             proc_needed = ismember(needs, addisprocess{k});
%                             if ~all(has_needed | proc_needed)
%                                 error(['atmlab:' mfilename ':missing'], ...
%                                     '%s %s needs fields %s from %s %s, but those seem absent', ...
%                                     class(additionals{i}), additionals{i}.name, ...
%                                     strjoin(vec2row(needs), ', '), ...
%                                     class(additionals{k}), additionals{k}.name);
%                             end
                            %addisread{k} = union(addisread{k}, needs(has_needed));
                            addisread{k} = union(addisread{k}, needs);
%                             addisprocess{k} = union(addisprocess{k}, needs(~has_needed));
                        end
                    end
                    if ~met
                        error(['atmlab:' mfilename ':unsatisfied_dependency'], ...
                            '%s %s depends on %s %s, but the latter was not requested :(', ...
                            class(additionals{i}), additionals{i}.name, ...
                            class(additionals{i}.dependencies{j}), additionals{i}.dependencies{j}.name);
                    end
                end
            end
        end
        
    end
end
