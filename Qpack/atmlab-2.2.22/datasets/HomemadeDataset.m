classdef HomemadeDataset < SatDataset
    % Any SatDataset that is locally created and stored.
    %
    % This class is an 'intermediate' class between <a href="matlab:help SatDataset">SatDataset</a> 
    % and <a href="matlab:help CollocatedDataset">CollocatedDataset</a>, but also parent to <a href="matlab:help AssociatedDataset">AssociatedDataset</a>.
    % It is unlikely you wish to instantiate this class directly.
    %
    % This class contains methods and properties that are related to
    % storing data to disk and reading data in the same (NetCDF) format
    % again from disk. It inherits from <a href="matlab:help SatDataset">SatDataset</a> and is parent to
    % <a href="matlab:help CollocatedDataset">CollocatedDataset</a> and <a href="matlab:help AssociatedDataset">AssociatedDataset</a>.
    %
    %
    % HomemadeDataset Properties:
    %
    %   cols -  Structure describing columns for matrix-stored data
    %   mattype - Type to use internally. Normally 'double'.
    %  (remaining properties inherited from <a href="matlab:help SatDataset">SatDataset</a>.
    %   Use <a href="matlab:properties HomemadeDataset">properties</a> for a complete listing)
    % 
    % HomemadeDataset Methods:
    %
    %  Constructor:
    %
    %   HomemadeDataset -   Create HomemadeDataset object
    %
    %  I/O:
    %
    %   store -             Store <a href="matlab:help HomemadeDataset/cols">cols</a>-described matrix to NetCDF
    %   read_single_day -   Read a single day of stored data
    %  (remaining methods inherited from <a href="matlab:help SatDataset">SatDataset</a>)
    %
    % See also: SatDataset (superclass), CollocatedDataset (subclass),
    %           AssociatedDataset (abstract subclass)
    %
    % Don't forget the Collocation's User Guide.

    % Note on implicit and explicit constructor calling:
    % http://www.mathworks.se/help/matlab/matlab_oop/creating-subclasses--syntax-and-techniques.html
    
    % $Id: HomemadeDataset.m 8750 2013-12-07 18:14:32Z seliasson $
    
    
    properties
        % structure describing columns of (internally) stored data
        %
        % The cols-structure describes columns of data passed around
        % internally as a matrix. For example, mid-level methods like
        % <a href="matlab:help CollocatedDataset/collocate_date">CollocatedDataset.collocate_date</a>
        % return a matrix, whose columns are then described by the
        % cols-member.
        cols = struct;
        
%        members;
        
        % flag controlling how to consider granules already existing
        %
        % This flag, defaulting to 'false', controls how the toolkit treats
        % files that are already there.  For example, by default,
        % collocations are not rerun and associateddatasets are not
        % recalculated if files already exist.  The exact behaviour depends
        % on the class.  Usually, the meaning is straightforward: false
        % means do not overwrite, true means do so.  This can be set per
        % dataset, so if one wants to use the core but regenerate
        % additionals, one can set the property for the additionals to
        % true.
        %
        % Since atmlab-2-1-334, the value for FieldCopier and Collapser
        % (NOTE: FIXME, ALL AssociatedDataset?) can have other values.
        % Note that these work ONLY when processing is delayed; when
        % processing is done along with the CollocatedDataset, the system
        % will always regenerate additionals.
        %
        % overwrite = 2     read original files, and check per field, i.e.
        %                   extend them without changing existing fields
        %
        % overwrite = {'cell', 'array', 'of', 'fields'}
        %
        %                   read original files, redo all fields in the
        %                   cell array, keep others untouched.
        overwrite = false;
        
        % Set diskcache to store results of '.read' or others to disk.
        %
        % Runnig <a href="matlab:help CollocatedDataset/read">.read()</a> can take considerable time. Therefore, it is worthwhile
        % to cache the results. If 'pcd' is set to a <a href="matlab:help PersistentCachedData">PersistentCachedData</a>,
        % .read() will cache the results and read from disk if possible.
        % WARNING: DO NOT SET PCD TO A DIRECTORY YOU ARE OTHERWISE
        % USING! The caching mechanism may remove files from this
        % directory, so be very careful. Caching works by calculating a key
        % (almost certainly unique) based on input arguments and storing
        % the results in a .mat-file in the cache-directory.
        %
        % Example use:
        % >> d = datasets;
        % >> d.collocation_mhs_amsub.pcd = PersistentCachedData('/local/gerrit/cache');
        % >> [M, c] = d.collocation_mhs_amsub.read([2006 4 25], [2006 4 26], {'noaa18', 'noaa16'}, {'LAT1', 'LAT2', 'BT1'});
        % (later)
        % >> [M, c] = d.collocation_mhs_amsub.read([2006 4 25], [2006 4 26], {'noaa18', 'noaa16'}, {'LAT1', 'LAT2', 'BT1'});
        % 14-May-2012 11:37:33.707:PersistentCachedData.get_entry:54:Reading from persistent cache: /local/gerrit/cache/aff3735816ae90b11a4ddfd571f88e3b.mat
        pcd;
        
        % Type to use for internal storage
        %
        % Internally, the collocation toolkit passes around collocations as
        % matrices.  To be on the safe side, this normally uses the type
        % 'double'.  If you are low on memory, or trying to store a lot of
        % data and/or have a lot of collocations, you can set this to
        % 'single'.  Do not set it to any non-floating point type unless
        % you want severe loss of precision and crashing code.
        mattype = 'double';

        % Users may set this for various purposes.  Among others, it's used
        % by strrep.
        version;
    end
    
    properties (Dependent = true)
        % contains detailed information on how data are stored etc.
        %
        % To be documented in more detail.
        members;
    end
    
    properties (Access = protected)
        % for internal usage
        ownmembers;
        dynamic_members = false;
    end
    
    methods
        
        %% overload parent methods
        
        function self = HomemadeDataset(varargin)
            self = self@SatDataset(varargin{:});
            %{
            args = varargin;
            
            % extract 'members' because SatDataset is not allowed to set
            % HomemadeDataset private property, and it must be private in
            % order for subclasses to redefine it etc.
            setmem = false;
            if any(strcmp(args, 'members'))
                setmem = true;
                i = find(strcmp(args, 'members'));
                mem = args{i+1};
                args = [args(1:i-1) args(i+2:end)];
            end
            self = self@SatDataset(args{:});
            if setmem
                self.members = mem;
            end
            %}
                   
            
            if ~any(strcmp(varargin, 'reader')) % set reader
                self.reader = @self.read_homemade_granule;
            end
             
            if isequal(self.granule_duration, [])
                self.granule_duration = 86400;
            end
        end
        
        %% implement new methods
        
        function [fn, global_atts] = store(self, date, spec, data, varargin)
            % store Write collocation data to netcdf file
            %
            % Write collocation data for date in data to a netcdf file.
            % The filename is determined from self, date, spec.
            % This is a relatively low-level function and not normally
            % called directly; rather call <a href="matlab:help CollocatedDataset/collocate_and_store_date">CollocatedDataset.collocate_and_store_date</a>
            %
            % FORMAT
            %
            %   [fn, global_atts] = obj.store(date, spec, data[, info])
            %
            % IN
            %
            %   date        vector [year month day] to which data corresponds
            %   spec        string / cellstr, satellite (or so)
            %   data        actual data, columns described by <a href="matlab:help HomemadeDataset/cols">self.cols</a>
            %               unless 'localcols' argument is given
            %   info        (optional) struct with more info to put in NetCDF
            %   localcols   structure describing columns of data
            %
            % OUT
            %
            %   fn          file data was written to
            %   atts        global attributes that were written to file
            %
            % $Id: HomemadeDataset.m 8750 2013-12-07 18:14:32Z seliasson $
            
            if ~all(isfinite(data(:)))
                warning(['atmlab:' mfilename ':format'], ...
                    'Found nans or infs in data. Data should be finite. I''ll do my best.');
            end
            
            fn = self.find_granule_by_datetime(date, spec);
            
            [info, localcols] = optargs(varargin, {struct(), self.cols});

            %year = date(1);
            %month = date(2);
            %day = date(3);
            
            % create or append to the file
            
            if exist(fn, 'file')
                switch self.overwrite
                    case 0
                        error(['atmlab:' mfilename ':fileexists'], ...
                            ['You really shouldn''t tell me not to overwrite ' ...
                             'and then tell me to store data where a file already exists.']);
                    case 1
                        newfile = true;
                    otherwise
                        % FIXME: should add a line to 'history' global
                        % attribute
                        newfile = false;
                end
            else
                newfile = true;
            end
            
%             if strcmp(fn(end-1:end), 'gz') % take off this part
%                 fn(end-2:end) = '';
%             end
            
            outdir = fileparts(fn);
            if ~exist(outdir, 'dir')
                logtext(atmlab('OUT'), 'Creating %s\n', outdir);
                mkdir(outdir);
            end
            
            %% Estimate size
            
            ncollocs = size(data, 1);            
            nbytes = self.linesize(localcols) * ncollocs;
            logtext(atmlab('OUT'), 'Will write %d collocations, %s of uncompressed data (not including header)\n', ncollocs, nbytes2string(nbytes));
            
            
            
            if newfile
                % temporary filename, later compressed written to final place
                temp_out = tempname(atmlab('WORK_AREA'));                
                logtext(atmlab('OUT'), 'Writing %s\n', temp_out);
                ncid = netcdf.create(temp_out, 'NC_CLOBBER'); % overwrite existing
            else
                logtext(atmlab('OUT'), 'Appending to %s\n', fn);
                temp_out = uncompress(fn, atmlab('WORK_AREA'), struct('unidentified', 'error'));
                ncid = netcdf.open(temp_out, 'WRITE');
                netcdf.reDef(ncid); % put in header define mode
            end
            cleanupObj = onCleanup(@() self.cleanup(temp_out, ncid));
            
            if newfile
                % define the dimensions
                
                dim_collocs = netcdf.defDim(ncid, 'Collocations', ncollocs);
                
                % put global attributes
                
                global_atts = struct();
                global_atts.Conventions = 'CF-1.4';
                global_atts.title = 'Collocations';
                global_atts.date = iso_timestamp();
                global_atts.institution = ['Department of Computer Science, Electrical and Space Engineering, Division of Space Technology, Lule' char(unicode2native('å')) ' University of Technology, Kiruna, Sweden'];
                global_atts.source = 'Collocation codes, part of atmlab';
                global_atts.references = 'Holl et al.  (2010); John et al. (2012)';
                global_atts.contact = 'gerrit.holl@gmail.com';
                global_atts.software_version = atmlab_version;
                global_atts.id = [atmlab_version() ' -- ' iso_timestamp() ' -- ' fn];
                global_atts.license = ...
                    ['This dataset is made available under the ' ...
                     'Open Data Commons Attribution License (ODC-By) v1.0 ' ...
                     'whose full text can be found at ' ...
                     'http://opendatacommons.org/licenses/by/1.0/. ' ...
                     'Any rights in individual contents of the dataset are ' ...
                     'licensed under the Open Data Commons Attribution License (ODC-By) v1.0 ' ...
                     'whose text can be found at http://opendatacommons.org/licenses/by/1.0/.'];
                
                % add caller-contributed ones
                %warning('off', 'catstruct:DuplicatesFound');
                inf_fields = fieldnames(info);
                for i = 1:length(inf_fields)
                    fldnm = inf_fields{i};
                    global_atts.(fldnm) = info.(fldnm);
                end
                %global_atts = catstruct(global_atts, info);
                %warning('on', 'catstruct:DuplicatesFound');
                addncattributes(ncid, global_atts)
            else
                dim_collocs = netcdf.inqDimID(ncid, 'Collocations');
            end
            
            %% define variables, variable attributes, additional dimensions
            
            vars = fieldnames(localcols);
            
            varids = zeros(size(vars));
            dims = struct();
            for j = 1:length(vars)
                varname = vars{j};
                type = self.members.(varname).type;
                if isfield(self.members.(varname), 'atts')
                    atts = self.members.(varname).atts;
                else
                    atts = struct();
                end
                
                % check if we have other dimensions besides the length
                if isfield(self.members.(varname), 'dims') && size(data, 1)>0
                    dimname = self.members.(varname).dims{1};
                    dimsize = self.members.(varname).dims{2};
                    try
                        if ~isfield(dims, dimname)
                            dims.(dimname) = netcdf.defDim(ncid, dimname, dimsize);
                        end
                    catch ME
                        switch ME.identifier
                            case {'MATLAB:netcdf:defDim:nameIsAlreadyInUse', 'MATLAB:imagesci:netcdf:libraryFailure'}
                                % no problem
                                dims.(dimname) = netcdf.inqDimID(ncid, dimname);
                            otherwise
                                ME.rethrow();
                        end
                    end
                    thisdim = [dim_collocs dims.(dimname)];
                else
                    thisdim = dim_collocs;
                end
                % define variable and put attributes
                try
                    % if this doesn't fail, the variable already exists
                    varid = netcdf.inqVarID(ncid, varname);
                    % while we're at it, let's check the dimensions
                    [~, ~, dids] = netcdf.inqVar(ncid, varid);
                    [~, stored_n_collocs] = netcdf.inqDim(ncid, dids(1));
                    if size(data, 1) ~= stored_n_collocs
                        errstr = sprintf(['NetCDF file contains data for variable %s ' ...
                            'with a different size than the data I''m trying to store. ' ...
                            ' Stored no. of entries is %d, whereas new size is %d entries. '], ...
                            varname, stored_n_collocs, size(data, 1));
                        if self.overwrite == 2 && isa(self, 'Collapser')
                            errstr = [errstr, ...
                                sprintf([' Probably the original collapsing ' ...
                                'is from the era where entries where removed if ' ...
                                'all data were flagged, even if the collocation was ' ...
                                'otherwise valid.  When additional data is added that ' ...
                                'is not flagged, this results in a different no. of ' ...
                                'collocations.  The only solution is to set %s.overwrite ' ...
                                'to 1.  Sorry about that :('], self.name)];
                        else
                            errstr = [errstr, ...
                                sprintf([' I''m not sure why I''m even ' ...
                                'here in the first place, because I''m not trying ' ...
                                'to extend a Collapser (I''m a %s in overwrite ' ...
                                'mode %d'], class(self), self.overwrite)];
                        end
                        error(['atmlab:' mfilename ':wrongsize'], errstr);
                    end
                    varids(j) = -1;
                catch ME
                    switch ME.identifier
                        case 'MATLAB:imagesci:netcdf:libraryFailure'
                            varid = netcdf.defVar(ncid, varname, type, thisdim);
                            varids(j) = varid;
                            for k = fieldnames(atts)'
                                netcdf.putAtt(ncid, varid, k{1}, atts.(k{1}));
                            end
                            
                        otherwise
                            ME.rethrow();
                    end
                end

            end
            
            %% write data
            
            % end define mode
            
            netcdf.endDef(ncid);
            
            if isempty(data)
                logtext(atmlab('OUT'), 'No data, NetCDF file will be dataless\n');
            else
                % put vars
                logtext(atmlab('OUT'), 'Writing: ');
                
                for j = 1:length(vars(:).')
                    varname = vars{j};
                    
                    varid = varids(j);
                    if varid == -1
                        fprintf(atmlab('OUT'), '(not: %s) ', varname);
                        continue
                    end
                    
                    fprintf(atmlab('OUT'), '%s ', varname);
                    if any(any(~isfinite(data(:, localcols.(varname)))))
                        if ~isfield(self.members.(varname).atts, 'missing_value')
                            error(['atmlab:' mfilename ':missingmissing'], ...
                                ['I found nonfinite values for field %s, ' ...
                                'but no missing_value is defined for ' ...
                                '%s.members.%s.atts.missing_value. Please define.'], ...
                                varname, self.name, varname);
                        end
                        % need to flag only the relevant channels.  Matlabs
                        % lacks views, so I have to do this in a really
                        % cumbersome way.
                        chanmask = false(size(data));
                        chanmask(:, localcols.(varname)) = true;
                        invmask = ~isfinite(data);
                        data(chanmask&invmask) = self.members.(varname).atts.missing_value;
                        %data(any(~isfinite(data(:, localcols.(varname)))), localcols.(varname)) = self.members.(varname).atts.missing_value;
                    end
                    
                    netcdf.putVar(ncid, varid, data(:, localcols.(varname)));
                end
                fprintf(atmlab('OUT'), '\n');
            end
            
            logtext(atmlab('OUT'), 'Finalising\n');
            logtext(atmlab('OUT'), 'Gzipping to %s and removing uncompressed\n', fn);
            netcdf.close(ncid);
            gzipped_filename = gzip(temp_out, outdir);
            if ~isequal(gzipped_filename{1}, fn)
                movefile(gzipped_filename{1}, fn);
            end
            logtext(atmlab('OUT'), 'Done\n');
            
        end
                
        function fields = list_fields(self)
            % return valid fields in this dataset
            fields = fieldnames(self.members);
        end
             
        function S = cast_fields_back(self, M, c)
            % Cast columns from data-matrix to 'stored' types
            % 
            % The collocation toolkit internally passes around data in a
            % matrix.  To be on the safe side, this uses double, because
            % all other types (except (u)int64) fit.  However, sometimes
            % this is not desirable, and this method can be used to cast
            % types back to their types, based on the type to which they
            % should be stored.
            %
            % FORMAT
            %
            %   varargout = hd.cast_fields_back(M, c,)
            %
            % IN
            %
            %   M   matrix containing data
            %   c   structure describing columns by name
            %
            % OUT
            %
            %   S   structure with data in smaller type
            
            S = struct();
            fields = fieldnames(c);
            for i = 1:length(fields)
                field = fields{i};
                newtype = type_nc2ml(self.members.(field).type);
                S.(field) = cast(M(:, c.(field)), newtype);
            end
        end
        
        function nbytes = linesize(self, localcols)
            % Calculate the stored size (in bytes) per collocation
            nbytes = 0;
            sizes = struct(...
                'float', 4, ...
                'double', 8, ...
                'short', 2, ...
                'int', 4, ...
                'byte', 1);
            fields = fieldnames(localcols);
            for f = vec2row(fields)
                tp = self.members.(f{1}).type;
                width = length(localcols.(f{1}));
                nbytes = nbytes + sizes.(tp) * width;
            end
        end
        
        function first = granule_first_line(varargin)
            first = int32(1);
        end
        
        %% getters/setters
        function mem = get.members(self)
            % members getter, see doc for property members
            
            if self.dynamic_members
                mem = self.dynamically_get_members();
            else
                mem = self.ownmembers;
            end
        end
        
        function set.members(self, val)
            if self.dynamic_members
                error(['atmlab:' mfilename ':readonly'], ...
                    ['The property ''members'' for class %s is dynamically calculated. ' ...
                     'Therefore, you cannot set the members property for %s.'], ...
                     class(self), self.name);
            else
                self.ownmembers = val;
            end
        end
        
    end
    
    methods (Access = protected)
        
        %% overload parent methods
        function s_out = repvars(self, s, datevec, spec)
            s = repvars@SatDataset(self, s, datevec, spec);
            if isempty(self.version)
                s_out = s;
            else
                s_out = strrep_multi(s, ...
                    '$VERSION', strrep(self.version, '.', '_'));
            end
        end
                    
        function matches = infofit(self, is, datevec, spec)
            matches = infofit@SatDataset(self, is, datevec, spec);
            if isfield(is, 'version') && ~isempty(self.version)
                matches = matches && isequal(is.version, strrep(self.version, '.', '_'));
            elseif isempty(self.version)
                matches = true;
            else
                matches = false;
            end
        end

        %% implement new methods
        % those are for internal use, user uses
        % CollocatedDataset.read
        function [M, localcols, attr] = read_single_day(self, date, spec, fields)
            % Read collocation 'fields' for 'date', 'spec'.
            %
            % Low-level function, not normally called directly. To read
            % collocated data, use <a href="matlab:help CollocatedDataset/read">CollocatedDataset.read</a>.
            %
            % Reads a single day of data.
            %
            % FORMAT
            %
            %   [M, localcols, attr] = ds.read_single_day(date, spec, fields)
            %
            % IN
            %   
            %   date    datevec     datevec for which to read data
            %   spec    various     satellite(s)
            %   fields  cellstr     fields to read from data.
            %
            % Note:
            %
            % 'fields' may be 'all', in which case all fields are read.
            % No guarantee about the order, but this information is
            % returned via 'localcols'. If you need consistence of order
            % with actual collocating, consider passing
            % fieldnames(self.cols) as fields.
            %
            % OUT
            %
            %   M           matrix      contains requested data
            %   localcols   struct      describes data columns
            %   attr        struct      contains NetCDF global attributes
            %
            % See also: HomemadeDataset/read_homemade_granule
            
            fn = self.find_granule_by_datetime(date, spec);
            logtext(atmlab('OUT'), 'Gunzipping and reading %s\n', fn);
            tmp = tempname(atmlab('WORK_AREA'));
            c = onCleanup(@()delete(tmp));
            exec_system_cmd(['gunzip -c ' fn '>' tmp]); % 3x faster than ML's gunzip
            
            if ischar(fields)
                if strcmp(fields, 'all')
                    data = loadncfile(tmp);
                    attr = data.global_attributes;
                    fields = fieldnames(data);
                else
                    error(['atmlab:' mfilename ':invalid'], ...
                        ['Invalid ''fields'' argument: ' fields]);
                end
            else
                [data, attr] = loadncvar(tmp, fields);
            end
            
            % find n. of columns to allocate, keep order
            data_fields = intersect_unsorted(fields, fieldnames(self.members));
            %n_columns = sum(cellfun(@(ff) length(self.cols.(ff)), data_fields));
            n_columns = sum(cellfun(@(ff) size(data.(ff), 2),  data_fields));
            n_rows = max(cellfun(@(ff) size(data.(ff), 1), fields));
            M = nan*zeros(n_rows, n_columns);
            if isempty(M)
                localcols = struct();
                return;
            end
            n = 1;
            % copy data to matrix
            for i = 1:length(data_fields)
                fld = data_fields{i};
                %n_local_cols = length(self.cols.(fld));
                n_local_cols = size(data.(fld), 2);
                range_local_cols = n:(n+n_local_cols-1);
                D = data.(fld);
                
                M(:, range_local_cols) = D;

                % verify data validity; should be done on writing but
                % wasn't always in the past, so still needed here
                if any(isfield(self.members.(fld).atts, {'valid_range', 'valid_min', 'valid_max'}))
                    if isfield(self.members.(fld).atts, 'valid_range')
                        lo = self.members.(fld).atts.valid_range(1);
                        hi = self.members.(fld).atts.valid_range(2);
                    else
                        % fallbacks
                        if isinteger(D)
                            getlow = @intmin;
                            gethi = @intmax;
                        elseif isfloat(D)
                            getlow = @realmin;
                            gethi = @realmax;
                        else
                            error(['atmlab:' mfilename ':unknown'], ...
                                'Non-numeric type unsupported, %s is %s', fld, class(fld));
                        end
                        lo = getlow(class(data.(fld)));
                        hi = gethi(class(data.(fld)));
                        if isfield(self.members.(fld).atts, 'valid_min')
                            lo = self.members.(fld).atts.valid_min;
                        end
                        if isfield(self.members.(fld).atts, 'valid_max')
                            hi = self.members.(fld).atts.valid_max;
                        end
                    end
                    % 
                    % FIXME: test that lo < data < hi || data==missing
                    wrong = (D < lo | D > hi);
                    if isfield(self.members.(fld).atts, 'missing_value')
                        wrong = wrong & (D ~= self.members.(fld).atts.missing_value);
                    end
                    if any(wrong)
                        error(['atmlab:' mfilename ':invalid'], ...
                            ['Encountered invalid data for %s %s at %s.  Data for field %s ' ...
                             'must be in range %g -- %g or flagged.  Found ' ...
                             'value %g instead.  Perhaps an artefact from before ' ...
                             'the proper use of flags.  Suggest to recollocate ' ...
                             'or redo AssociatedDataset.'], ...
                             class(self), self.name, datestr(datenum(date), 'yyyy-mm-dd'), ...
                                fld, lo, hi, D(find(wrong, 1)));
                    end
                end
                    
                % set flagged to nan
                if isfield(self.members.(fld).atts, 'missing_value')
                    flagged = M(:, range_local_cols) == self.members.(fld).atts.missing_value;
                    M(all(flagged, 2), range_local_cols) = nan;
                end
                    
                localcols.(fld) = range_local_cols;
                n = n + n_local_cols;

            end
            if isempty(data_fields)
                localcols = struct();
            end

        end
               
        function pos2re(self)
            % convert self.{basedir,subdir,filename} to self.re
            %
            % This method attempts to convert
            % self.{basedir,subdir,filename) to self.re at a best-effort
            % basis.
            r = [fullfile(self.basedir, self.subdir, self.filename) ...
                 '|' self.filename];
            self.re = strrep_multi(r, ...
                '$YEAR4', '(?<year>\d{4})', ...
                '$MONTH', '(?<month>\d{2})', ...
                '$DAY', '(?<day>\d{2})', ...
                '$YEAR2', '(?<year>\d{2})', ...
                '$DOY', '(?<doy>\d{3})', ...
                '$HOUR', '(?<hour>\d{2})', ...
                '$MINUTE', '(?<minute>\d{2})', ...
                '$SAT', '(?<satname>[a-z0-9]*)', ...
                '$VERSION', '(?<version>[a-z0-9_]{3,4})');
            % However, we don't need it to locate granules. It's only used
            % by find_info_from_granule.
            self.tryre = false;
        end           
    end
    
    methods (Access = {?SatDataset})
        function [S, strattr] = read_homemade_granule(self, file, varargin)
            % internal usage, reader for any granule made by this toolkit
            %
            % hd.read_homemade_granule(file, [fields])
            
            fields  = optargs(varargin, {{}});
            
            [S, strattr] = loadncvar(file, fields);
           
            % get additional stuff
            info = self.find_info_from_granule(file);
            
            if isfield(info, 'doy')
                date = dayofyear_inverse(str2double(info.year), str2double(info.doy));
                date = [date.year date.month date.day];
            else
                date = [str2double(info.year) str2double(info.month) str2double(info.day)];
            end
            S.epoch = round(date2unixsecs(date(1), date(2), date(3)));
            
            S.path = file;
            
            if isfield(strattr, 'version')
                S.version = strattr.version;
            end
            
            if isfield(S, 'lat')
                S = MaskInvalidGeoTimedataWithNaN(S);
            end
        end   
        
    end
        
    % static/private are used like subfunctions
    methods (Static, Access = protected)
        function cleanup(temp_out, ncid)
            % remove temporary files and close NetCDF
            logtext(atmlab('OUT'), 'Cleaning up\n');
            try
                netcdf.close(ncid);
            catch ME
                switch ME.identifier
                    case {'MATLAB:netcdf:inq:notNetcdfID', 'MATLAB:netcdf:close:notNetcdfID', ...
                            'MATLAB:netcdf:close:ebadid:notNetcdfID', 'MATLAB:imagesci:netcdf:libraryFailure'} % already closed
                    otherwise
                        delete(temp_out);
                        ME.rethrow();
                end
            end
            delete(temp_out);
        end
    end
    
end
