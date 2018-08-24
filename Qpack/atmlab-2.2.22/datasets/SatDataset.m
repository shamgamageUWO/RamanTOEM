classdef SatDataset < handle % subclass from handle to pass-by-reference
    % Class to represent a dataset.
    %
    % Objects from this class lie at the basis of everything that the
    % Collocation Toolkit does. For example, a <a href="matlab:help CollocatedDataset">CollocatedDataset</a>
    % consists of two SatDatasets. The SatDataset describes where the data
    % are stored on the disk, how the data are read, and contains some more
    % information needed for collocations. However, a SatDataset can
    % certainly also be used stand-alone, for example, to loop through all
    % the granule in a particular time period.
    %
    % When <a href="matlab:help SatDataset/SatDataset">instantiating</a> an object from this class, (or, for that matter,
    % any class in the toolkit!), you should define a number of its properties
    % (see below). This can be done either when creating the class (see
    % <a href="matlab:help SatDataset/SatDataset">constructor info</a>), or later, in the same way as setting a member
    % of a structure. It's probably best to define overall properties, such
    % as name, granule_duration, etc., when creating, and to define local
    % properties later. For example:
    %
    % >> spam = SatDataset('name', 'MyDataset', 'granule_duration', '3600', ...
    %                      'satname', 'SpamSat');
    %
    % and later:
    %
    % >> spam.basedir = '/here/are/the/data';
    %
    % When a dataset is created, it is registered in a global structure
    % that can be obtained by calling <a href="matlab:datasets">datasets</a>. For this reason, it
    % is recommended to always at least give a dataset a name when it is
    % first created. Not doing so will result in a warning and an
    % automatically calculated name, which is probably neither helpful nor
    % descriptive.
    %
    % A number of datasets are pre-defined in <a href="matlab:help define_datasets">define_datasets</a>.
    % All registered datasets can be listed with <a href="matlab:help datasets">datasets</a>.
    %
    % 
    % SatDataset properties:
    %
    %  Properties to describe the location of the granules:
    %
    %   basedir -   Specify root for all datasets
    %   subdir -    Specify directory for individual granule
    %   re -        Regular expression matching individual granule
    %   filename -  Exact filename calculating path for individual granule
    %
    %  Property describing how to read the granule:
    %
    %   reader -    Reading routine for one granule for this dataset
    %
    %  Other properties:
    %
    %   name -      Name with which this dataset is registered
    %   granule_duration - Duration of a single granule in seconds
    %   satname -   Name for a single-satellite dataset
    %   collocated_datasets - Read-only prop. listing <a href="matlab:help CollocatedDataset">CollocatedDatasets</a>.
    %   starttimesfile - Name for filename containing start times if not in filename
    %   (Use <a href="matlab:properties SatDataset">properties</a> for a complete listing)
    %
    % SatDataset methods:
    %
    %   A selection of the most important methods is shown below.
    %   For a full listing, see <a href="matlab:doc SatDataset">doc SatDataset</a>.
    %
    %  Class instantiation:
    %
    %   SatDataset -                Info on creating a SatDataset object
    %
    %  Methods for finding granules:
    %
    %   find_datadir_by_date -      Find dir. containing granules for date
    %   find_granules_by_date -     Find all granules for date
    %   find_granules_for_period -  Find all granules for multi-day period
    %   find_granule_by_datetime -  Find granule starting at exact datetime
    %   find_granule_by_unixsecs -  Similar, but in unixsecs
    %   find_extreme_granule -      Find first or last granule for dataset
    %   get_starttime -             Get starttime from db (if not in file)
    %   set_starttimes -            Update starttimes-db
    %
    %  Methods for reading granules:
    %
    %   read_granule -              Read granule starting at exact datetime
    %
    %  Methods for detecting duplicates:
    %
    %   find_granule_first_line -   Create hashtable cataloguing duplicates
    %   granule_first_line -        Look up entry from this hashtable
    %
    %  Other useful methods:
    %
    %   find_info_from_granule -    Get information from granule filename
    %
    % See also: CollocatedDataset, HomemadeDataset (child), AssociatedDataset, FieldCopier, Collapser
    %
    % Don't forget the Collocation User's Guide.

    % $Id: SatDataset.m 8777 2014-02-12 12:45:13Z gerrit $
    
    % read/write props
    properties
        % Name of the dataset (pseudo-required).
        %
        % If not given, a name will be automatically calculated. This name
        % is not necessarily descriptive, so it's usually good to give a
        % name upon creating the dataset.
        name;
        
        % Basedir for the dataset (required).
        %
        % The base directory in which all granules reside. For example,
        % mhs.basedir = '/storage3/data/mhs'.
        basedir;
        
        % Subdir for a particular day of data (required).
        %
        % In many datasets, data are stored per date, in subdirectories
        % such as year/month/day/ or year/doy/. With this property, the user
        % tells the dataset how the data are sorted. In locating granules,
        % certain strings are replaced: $SAT, $YEAR4, $YEAR2, $MONTH, $DAY,
        % $DOY. Example: mhs.subdir = '$SAT_mhs_$YEAR4/$MONTH/$DAY'.
        subdir;
        
        % Regular expression to find individual granule (conditionally optional).
        %
        % This is required for datasets where the full filename cannot be
        % exactly calculated from available information, for example, due
        % to each filename containing orbit numbers, downlink stations, or
        % other information not known or relevant. When <a href="matlab:help SatDataset/find_granules_by_date">searching</a>
        % for granules, the regular expression described by this field is
        % used for all files in a particular directory, expecting exactly
        % one match. Therefore, the regular expression (a named one passed
        % to <a href="matlab:help regexp">regexp</a> must match exactly one file.
        %
        % The regular expression may be applied either to the basename, or
        % to the full path, or to anything in-between.
        %
        % Fields used for matching are:
        %       year02, year04, year, month, day, doy, hour, minute, orbitno
        %
        % For datasets that are L1 or L2, data is usually sorted at least
        % per day, but often per granule, which may be specified either by
        % hour/minute or by orbitno, some unique orbit number. Hopefully
        % each filename specifies either hour/minute uniquely within a
        % day, or an orbit number uniquely. See 'kiruna_init' for examples
        % of what to write in re.
        %
        % See also: <a href="matlab:help SatDataset/filename">filename</a>, <a href="matlab:help SatDataset/find_granule_by_datetime">find_granule_by_datetime</a>
        %
        % Example:
        % mhs.re = '(?<satname>[a-z0-9]{6})_(?<type>[a-z0-9]+)_(?<year>\d{4})/(?<month>\d{2})/(?<day>\d{2})/[A-Z0-9.]+\.S(?<hour>\d{2})(?<minute>\d{2})|\.S(?<hour>\d{2})(?<minute>\d{2})'
        re;
        
        % String describing basename (conditionally optional).
        %
        % This is used for datasets where the full filename can be exactly
        % calculate from available information, and no <a href="matlab:help SatDataset/re">regular expression</a>
        % is needed. This includes only the basename (no directory).
        % 
        % See also: <a href="matlab:help SatDataset/re">re</a>, <a href="matlab:help SatDataset/find_granule_by_datetime">find_granule_by_datetime</a>
        %
        % Example:
        % mhs.collocated_datasets(1).filename = 'collocations_$SAT.nc.gz'
        filename;
        
        % Function handle to read a single granule (required)
        %
        % This property points to a function handle used to read a single
        % granule (so it becomes in effect a static method). The documentation
        % below is a prescription of the interface that the function handle
        % assigned to this property must have in order for methods like
        % <a href="atmlab:help SatDataset/read_granule">read_granule</a> and <a href="atmlab:help CollocatedDataset/collocate_granule">CollocatedDataset.collocate_granule</a> to work.
        % It is not the documentation for any method that already exists!
        %
        % FORMAT
        %
        %   data = cd.reader(fullpath, fields)
        %
        % IN
        %
        %   fullpath    string      Full path to granule to be read.
        %   fields      cellstr     
        %
        %       Any other fields to be read. This is used by the <a  href="atmlab:help FieldCopier">FieldCopier</a>
        %       class to copy fields from the original datasets.
        % 
        % OUT
        %
        %   The function shall return a single output. This output is a
        %   structure with at least the following fields:
        %
        %       lat     double
        %
        %           Latitude in degrees. This must be a 2-D matrix, although
        %           the dimensions may be 1 (so it can be a row-vector, a
        %           column-vector, a scalar, or a matrix). It contains the
        %           latitude for every single measurement in the data.
        %
        %       lon     double
        %
        %           Longitude in degrees. Like the latitude. The sizes of the
        %           fields 'lat' and 'lon' must be exactly equal.
        %
        %       time    double
        %
        %           Time in seconds since 00:00 UT. This must be a column
        %           vector where the number of elements is equal to the number
        %           of rows in the 'lat' and 'lon' fields (one scanline can
        %           only have a single time).
        %
        % THROWS
        %
        %       If the data cannot be read, throws an error with
        %       error identifier `atmlab:invalid_data`.
        %
        % EXAMPLE
        %
        %   This function is not normally called directly by the user, but
        %   since it must often be implemented by the user, examples consist
        %   of example implementations. The <a href="matlab:what datasets">datasets</a> directory
        %   contains a number of functions with names starting with
        %   'common_read'. Those are all implementations for 'reader' used for
        %   various datasets that come with atmlab. For example, for data
        %   stored in the same format as AMSU, MHS, HIRS, one can use:
        %
        % mhs.reader = '@<a href="matlab:help satreaders.poes_radiometer">satreaders.poes_radiometer</a>'
        reader = @(varargin)[];
        
        % Function to post-process a single granule
        %
        % After a granule is read (see attribute reader), there might be
        % dataset-specific post-processing to be done immediately after the
        % reading.  For example, one may want to calculate pseudo-fields
        % to get IWP when the data only have IWC, and one should save
        % memory for later on. By default, this property is set to a no-op.
        %
        % Note that since this is a function implemented as an attribute
        % and not as a method (so that redefining does not require
        % subclassing), one needs to explicitly pass the dataset as a first
        % argument (see below) when calling the function. However, calling
        % this function is taken care of by read_granule, and normally the
        % user does not need to call this function explicitly.
        %
        % The method read_granule takes care of removing ballast as
        % indicated by the 'dependencies' fields.
        %
        % FORMAT
        %
        %   data = self.processor(self, data, fields)
        %
        % IN
        %
        %   self    SatDataset object
        %   data    data as returned by self.reader
        %   fields  fields as passed to self.reader
        %
        % OUT
        %   data    altered data struct
        %
        % See also: SatDataset/pseudo_fields
        reader_processor = @(self, data, fields)data;
        
        % Structure with pseudo-field information
        %
        % For some datasets, the user might want to acquire fields not
        % actually in the data. For example, to save memory, one might want
        % to get IWP when the data actually contain IWC. For this,
        % read_granule needs some information on pseudo_fields,
        % specifically, for each pseudo field a cell string with
        % dependencies. The dependencies cellstr lists the real fields upon
        % which the pseudo fields depend. These will be read, passed to
        % reader_processor, and then thrown away.
        %
        % You may wish to add some attributes for user documentation.
        %
        % Note: every pseudo field MUST have a dependencies member that is
        % a cellstr, but this cellstr may be empty.
        %
        % Note: Users choosing pseudo-field names equal to fields in the
        % actual data will be sentenced to the Usenet Death Penalty.
        %
        % See also: SatDataset/reader_processor
        pseudo_fields = struct();
        
        % Granule duration in seconds (required)
        %
        % Describes the duration in seconds for a single granule. In case
        % this varies, choose an upper limit. This is used by
        % <a href="matlab:help CollocatedDataset/overlap_granule">CollocatedDataset.overlap_granule</a>.
        %
        % Example:
        % mhs.granule_duration = 6130
        granule_duration;
        
        % Satellite name for single-satellite datasets (conditionally required)
        %
        % Some datasets, such as cpr, are contained only on a single satellite.
        % However, the database genereated by <a href="matlab:help SatDataset/find_granule_first_line">find_granule_first_line</a>
        % and used by <a href="matlab:help SatDataset/granule_first_line">granule_first_line</a> still needs a satellite to
        % generate the string for the filename to store the data. The
        % satellite name is also used in some verbose output. It is not
        % needed or used for multi-satellite datasets, where instead the
        % 'spec' specifies the satellite (such as in MHS).
        %
        % Example:
        % cpr.satname = 'cloudsat'
        satname;
        
        % Name for first-line database (predefined)
        %
        % Predefined property describing where firstline-db is stored
        %
        % The first-line database (see <a href="matlab:help SatDataset/find_granule_first_line">find_granule_first_line</a>
        % and <a href="matlab:help SatDataset/granule_first_line">granule_first_line</a>)
        % is needed to prevent duplicates. This contains the filename, but
        % not the directory. Currently unused? FIXME
        %
        % firstline_filename = 'firstline_$NAME_$SPEC';

        % Cache for reading granules
        cache;
        
        % Make this dataset visible. Defaults to true.
        %
        % If you're creating a dataset for fully internal use, you might
        % want to set this to false to prevent automatic searchers from
        % detecting it.
        visible = true;
        
        % List of satellites
        %
        % For multi-satellite datasets, this may contain a list of
        % satellites for this dataset. This is only for information and
        % does not need to be complete. It may be used e.g. for looping
        % through all the possible datasets. Not to be confused with
        % <a href="matlab:help SatDataset/satname">satname</a>, which is for single-satellite datasets.
        sats;
    
        % try to use regular expression for finding; a regular expression
        % may still be needed for identifying information by
        % find_info_from_granule, but not used for finding a filename in
        % the first place.
        tryre = true;
        
        % Flag if it needs an exernal starttimes-file
        %
        % Defaults to false
        needs_starttimesfile = false;
        
        % Some datasets do not contain a starting time in the filename,
        % even if there are multiple granule per day. To resolve this, in
        % the root of the dataset (e.g. directly in basedir) we store a
        % hashtable (Container.Map) that records the starting time based
        % on a id that is unique per filename (e.g. orbit number). One
        % example of such a dataset is Saphir.
        starttimesfile;

        % Database of starting times for datasets where those are not
        % clear from the filename.
        starttimes
        
        % Field that can be a structure for arbitrary metadata, such as
        % height, channel definitions, or anything. This is not used within
        % the framework of atmlab, but can be used by the user for
        % anything.
        metadata;

        % defaults cannot be set in any subclass, because re-defining a
        % property is not allowed except under special circumstances that
        % cannot be met here. Therefore, defaults should be encompassed in
        % a property, a structure, 'defaults', that is /not/ defined here,
        % but only by the class at the end of the hierarchy

    end
    
    % read-only props (alterable with methods)
    properties (SetAccess = protected)
        % list of CollocatedDatasets using this SatDataset (read-only)
        %
        % This property, which is read-only and automatically filled,
        % contains a list of <a href="matlab:help CollocatedDataset">CollocatedDataset</a>s
        % that use this <a href="matlab:help SatDataset">SatDataset</a>.
        collocated_datasets = [];
        
        % Full path for db containing start-times where applicable.
        %
        % This is simply basedir/starttimesfile
        starttimes_fullpath
    end
    
    % flags
    properties (Constant, GetAccess = protected)
        FL_INITIAL = -5;
        FL_NOTFOUND = -2;
        FL_ALLDUPL = typecast(int32(-1), 'uint32');
        FL_NONEXT = -3;
        FL_NOCUR = -4;
    end
    
    % internally used properties
    properties (Transient, GetAccess = private, SetAccess = private)
        firstlines;
        cachedstarttimes;
    end
    
    methods
        
        %% constructor
        
        function self = SatDataset(varargin)
            % Creates a SatDataset object.
            %
            % For full information on the class, see <a href="matlab:doc SatDataset">doc SatDataset</a>.
            %
            % FORMAT
            %
            %   ds = SatDataset('name', 'MyDataset', ...
            %                   'basedir', '/some/where', ...
            %                   ...);
            %
            % IN
            %
            %   Any pair of key/value arguments, as when creating a
            %   structure. Valid keys are properties. To get a list of
            %   valid properties, call <a href="matlab:properties SatDataset">properties SatDataset</a>
            %   and/or <a href="matlab:doc SatDataset">doc SatDataset</a>.
            %
            % OUT
            %
            %   Valid <a href="matlab:help SatDataset">SatDataset</a> object.
            
            % this may be defined in subclasses
            if isprop(self, 'defaults')
                def_fields = fieldnames(self.defaults); %#ok<*MCNPN>
                for i = 1:length(def_fields)
                    fldnm = def_fields{i};
                    self.(fldnm) = self.defaults.(fldnm);
                end
            end

            for i = 1:2:nargin
                self.(varargin{i}) = varargin{i+1};
            end
            
            if isempty(self.name)
                % give a name
                nm = self.calculate_name();
                warning(['atmlab:' mfilename], ...
                    'You didn''t name me! I''ll name myself %s (for now)', nm);
                self.name = nm;
            end

            if isempty(self.starttimesfile)
                self.starttimesfile = 'granule_start_times.mat';
            end
            
            self.cache = CachedData();

        end
        
        %% things that can be done with datasets
        
        function fulldir = find_datadir_by_date(self, date, varargin)
            % find_datadir_by_date Find directory containing granules
            %
            % For the given datevec and specification, return a string with
            % the path to the directory that contains the granules for this particular
            % datevec.
            %
            % FORMAT
            %
            %   fulldir = ds.find_datadir_by_date(datevec, spec)
            %
            % IN
            %
            %   datevec     vector      [year month day] etc.
            %   spec        any         name of sat or cellstr {sat1 sat2}
            %
            % OUT
            %
            %   fulldir     string      path to directory
            
            % verify basedir is defined and exists
            
            spec = optargs(varargin, {''});
            errid = ['atmlab:' mfilename]; %find_datadir_by_date';
            
            assert(any(self.basedir), errid, 'No basedir initialised for %s %s', class(self), char(self.name));
            assert(exist(self.basedir, 'dir')~=0, errid, ...
                ['Configured data directory for %s is %s, ' ...
                'but this does not exist or is not a directory. ' ...
                'Please define basedir for %s correctly ' ...
                'or create the directory.'], ...
                self.name, self.basedir, self.name);
            
            fulldir = fullfile(self.basedir, self.subdir);
            
            fulldir = self.repvars(fulldir, date, spec);
   
        end
        
        function S = find_info_from_granule(self, fname)
            % find_info_from_granule Extract info from a granule filename
            %
            % Thin shell around <a href="matlab:help regexp">regexp</a>.
            %
            % FORMAT
            %
            %   S = ds.find_info_from_granule(fname)
            %
            % IN
            %
            %   fname   string      (full) path to granule
            %
            % OUT
            %
            %  - structure containing whatever info could be obtained
            if isempty(self.re) % try to convert it
                self.pos2re();
            end
            
            S = regexp(fname, self.re, 'names');
            
        end
        
        function [M, paths] = find_granules_by_date(self, date, varargin)
            % find_granules_by_date Find all granule start times for date/sat/dataset
            %
            % This function finds all granule start times for granules with any coverage
            % for the the indicated for the indicated satellite/dataset pair. This
            % includes the last granule of the date before, unless this is explicitly
            % prohibited. Note that the last granule of the date before may or may not
            % actually contain information for the day requested. The
            % function assumes at most one granule for the previous date
            % contains information for the current date. If two outputs are
            % requested, paths to the granules are also output, as a cell
            % array of strings.
            %
            % FORMAT
            %
            %   [M, paths] = find_granules_by_date(date[, spec[, with_yesterday]])
            %
            % OUT
            %
            %   M     N x 6 matrix     where each row corresponds to one granule.
            %                          The first five columns are year,
            %                          month, day, hour, minute. The last
            %                          column may contain a granule number
            %                          for some datasets, or -1 otherwise.
            %                          
            %   paths cell of strings  Cell array of strings, corresponding full paths
            %
            % IN
            %
            %   date            vector [year month day]
            %   spec            string or cellstr, sat or pair of sats
            %   with_yesterday  (optional) logical, include yesterdays last
            %                   granule or not. Defaults to 'true', as this
            %                   is needed to cover all of the date; but if
            %                   looping over dates, one might not want it.
            %
            % EXAMPLE
            %
            %   >> [grans, paths] = mhs.find_granules_by_date([2010, 9, 8], 'noaa18');
            %
            % $Id: SatDataset.m 8777 2014-02-12 12:45:13Z gerrit $
            
            % errid = 'atmlab:find_granules_by_date';
            
            [spec, with_yesterday] = optargs(varargin, {'', true});
            
            datadir = self.find_datadir_by_date(date, spec);
            
            if self.tryre && ~isequaln(self.re, nan) && ~isempty(self.re)
                matchy = self.re;
            else
                matchy = self.filename; % exact match only
            end
            
            matchy = self.repvars(matchy, date, spec);
            
            files = dir(datadir);
            nfiles = length(files);
            M = zeros(nfiles, 6);
            for i = 1:nfiles
                fname = files(i).name;
                %nam = regexp(fname, matchy, 'names');
                nam = self.find_info_from_granule(fname);
                if ~isempty(nam)
                    % if present, year/month/day should be the same
                    if ~self.infofit(nam, date, spec)
                        continue;
                    end
                    
                    M(i, 1:3) = date(1:3);
                    if isfield(nam, 'hour')
                        M(i, 4) = str2double(nam.hour);
                    end
                    if isfield(nam, 'minute')
                        M(i, 5) = str2double(nam.minute);
                    end
                    if self.needs_starttimesfile
                        if isfield(nam, 'orbitno2') % need both numbers
                            % specifies range, so so product should be
                            % unique
                            M(i, 6) = str2double(nam.orbitno) * ...
                                      str2double(nam.orbitno2);
                        else
                            M(i, 6) = str2double(nam.orbitno);
                        end
                    else
                        M(i, 6) = -1;
                    end
                end
            end
            % all paths
            paths = cellfun(@(f) fullfile(datadir, f), {files.name}, 'UniformOutput', false);
            % remove lines with zeroes (those are not granules)
            nogran = M(:, 1)==0;
            M(nogran, :) = [];
            paths(nogran) = [];
            % sort
            [M, I] = sortrows(M);
            paths = paths(I);
            % add yesterday
            if with_yesterday
                yesterday = datevec(datenum(date)-1);
                [M_yesterday, paths_yesterday] = self.find_granules_by_date(yesterday, spec, false);
                if ~isempty(M_yesterday) % maybe today is genesis/big bang/epoch/birth/1970-01-01
                    M = [M_yesterday(end, :); M];
                    paths = [paths_yesterday(end) paths];
                end
            end
        end
        
        function datafile = find_granule_by_datetime(self, datevec, varargin)   
            % find_granule_by_datetime Return full path of datafile by date/time
            %
            % Returns the full path of the datafile corresponding to the input
            % arguments. There are two modes
            %
            %   - If <a href="matlab:help SatDataset/filename">dataset.filename</a> is defined, the path is
            %     calculated directly from <a href="matlab:help SatDataset">dataset</a> properties and the arguments
            %     passed on. The file may or may not actually exist, so in this case,
            %     you can use it to calculate the path when planning to create it.
            %
            %   - If this is not defined, then <a href="matlab:help SatDataset/re">dataset.re</a> has to
            %     be defined. It will search the filesystem for a file matching the
            %     regular expression and the indicated datevec/spec for this dataset.
            %
            % FORMAT
            %
            %   datafile = dataset.find_granule_by_datetime(date,[ spec[, tol]])
            %
            % IN
            %
            %   datevec     vector  Date/time to find datafile for
            %   spec        string/ Name of satellite. For datasets belonging to one
            %               cellstr satellite, a simple string. For datasets belonging
            %                       to two satellites (such as collocations), a cell
            %                       array of two strings. For
            %                       single-satellite datasets, not needed.
            %
            % OUT
            %
            %   datafile    string     Path to the looked-for datafile.
            %
            % EXAMPLE
            %
            %   >> path = mhs.find_granule_by_datetime([2010 9 8 8 8], 'noaa18');
            
            errid = 'atmlab:find_granule_by_datetime';
            spec = optargs(varargin, {''});
            
            % implementation:
            % 1. find the directory containing the files from basedir/subdir
            % 2. if possible, calculate the filename directly
            % 3. otherwise, list all files and match with regexp+tolerance
            
            datevec(end+1:5) = 0;
            
            fulldir = self.find_datadir_by_date(datevec, spec);
            
            if (nargin() <= 3 && ~isequaln(self.filename, nan) && ~isempty(self.filename)) || ~self.tryre % calculate directly
                fn = self.repvars(self.filename, datevec, spec);
                datafile = fullfile(fulldir, fn);
            else % will search through all granules with find_granules_by_date
                [granules, paths] = self.find_granules_by_date(datevec, spec, false);
                found = granules(:, 4)==datevec(4) & granules(:, 5)==datevec(5);
                
                nfound = sum(found);
                if iscell(spec) % short-string for error message
                    sp = horzcat(spec{:});
                else
                    sp = spec;
                end
                
                if nfound==0
                    error(errid, 'No datafile found for %s %s [%s]', self.name, sp, num2str(datevec));
                elseif nfound > 1
                    error(errid, 'Multiple datefiles found for %s %s', self.name, sp);
                else
                    datafile = paths{found};
                end
                
            end
            
        end        
        
        function datafile = find_granule_by_unixsecs(self, unixsecs, varargin)
            % find_granule_by_unixsecs Find granule starting at indicated time
            %
            % IN
            %
            %   unixsecs    time in seconds since 1970-01-01T00:00:00Z
            %
            % ...remaining arguments passed on to <a href="matlab:help SatDataset/find_granule_by_datetime">find_granule_by_datetime</a>

            [year, month, day, hour, minute, second] = unixsecs2date(unixsecs);
            datafile = self.find_granule_by_datetime([year month day hour minute second], varargin{:});
        end
        
        function [allgrans, allpaths] = find_granules_for_period(self, date1, date2, spec)            
            % find_granules_for_period List all granules for sat/dataset for period
            %
            % For the period between date1 and date2, list all granules (as vectors
            % indicating the starting date/time) available.
            %
            % FORMAT
            %
            %   [allgrans, allpaths] = find_granules_for_period(date1, date2, spec)
            %
            % IN
            %
            %   date1   datevec     starting date   [y,m,d]
            %   date2   datevec     ending date     [y,m,d]
            %   spec    various     (optional)
            %
            % OUT
            %
            %   allgrans matrix     all granules in daterange
            %   allpaths cellstr    all paths to those granules
            %
            % EXAMPLE
            %
            %   >> [allgrans, allpaths] = mhs.find_granules_for_period([2010, 9, 5], [2010 9 7], 'noaa18');
            
            narginchk(3, 4);
            if ~exist('spec', 'var')
                spec = [];
            end
            dates = daterange(date1(1:3), date2(1:3));
            ndates = size(dates, 1);
            
            allgrans = nan*zeros(ndates*15, 6);
            allpaths = cell(size(allgrans));
            
            n = 0;
            for i = 1:ndates
                date = dates(i, :);
                [grans, paths] = self.find_granules_by_date(date, spec, false);
                ngrans = size(grans, 1);
                allgrans(n+1:n+ngrans, :) = grans;
                allpaths(n+1:n+ngrans) = paths;
                n = n + ngrans;
            end
            
            to_remove = isnan(allgrans(:, 1));
            allgrans(to_remove, :) = [];
            allpaths(to_remove) = [];
            [allgrans, I] = sortrows(allgrans);
            allpaths = allpaths(I);
        end
        
        function [gran, path] = find_granule_covering_instant(self, datevec, varargin)
            % For datevec/spec, find granule covering this moment
            %
            % For a combination of a date-vector and a specification
            % (satellite), get the granule that covers this instant.  Note
            % that this method does NOT verify that the instant is really
            % covered, but rather returns the granule that started most
            % recently before the considered moment.
            
            spec = optargs(varargin, {''});
            [grans, paths] = self.find_granules_by_date(datevec(1:3), spec, true);
            grans_unisecs = date2unixsecs(grans(:, 1), grans(:, 2), grans(:, 3), grans(:, 4), grans(:, 5));
            dv_unisecs = date2unixsecs(datevec(1), datevec(2), datevec(3), datevec(4), datevec(5));
            last_i = find(dv_unisecs >= grans_unisecs, 1, 'last');
            gran = grans(last_i, :);
            path = paths(last_i);
            % Not implemented yet.
        end
        
        function data = read_granule(self, date, varargin)
            % read_granule Read any granule
            %
            % High-level function to read a particular granule for a
            % satellite/sensor-pair, if one doesn't know what function is suitable to
            % use to read it. It also gets rid of ballast (duplicates).
            %
            % Uses member <a href="matlab:help SatDataset/reader">reader</a> to find out what function to use to
            % read this particular data. Uses <a href="matlab:help SatDataset/granule_first_line">self.granule_first_line</a>
            % to find out the first scanline to use (e.g. the rest are doubles).
            %
            % FORMAT
            %
            %   M = read_granule(date[, spec[, extra[, remdouble[, force[, reload]]]]])
            %
            % IN
            %
            %   datevec     vector      Date-vector indicating the starting time.
            %   spec        various     (optional) E.g. satellite (noaa18, cloudsat, etc.) 
            %   extra       cellstr (optional)
            %
            %       Extra args to reader. Usually, those are extra fields
            %       that are to be read. Two of those extra fields are a
            %       special-case and taken care of by read_granule, and not
            %       passed on to the reader: 'scanline_position' and
            %       'scanline_number' are assigned according to the
            %       position in the scanline and the scanline number,
            %       accordingly.
            %
            %   remdouble   logical     (optional) Remove duplicates or not? Default true.
            %                           One reason to pass 'false' might be
            %                           when searching for data according
            %                           to line/pos.
            %   force       logical     (optional) rather than throwing an error,
            %                           return [] in case of error. Default false.
            %   reload      logical     (optional) Do not use caching, but
            %                           reload in any case.
            %
            % OUT
            %
            %   data        struct  Contains at least:
            %
            %       - lat       Latitude in degrees
            %       - lon       Longitude in degrees [-180, 180]
            %       - time      Time in seconds since 'epoch'
            %       - epoch     Time in seconds since 1970-01-01
            %       - version   String or float.
            %       
            %       Further fields should be returned depending on
            %       arguments passed to 'extra' and the particular dataset.
            %
            % EXAMPLE
            %
            %   >> data = mhs.read_granule([2010 9 8 8 8], 'noaa18', {}, true, false);
            %
            % $Id: SatDataset.m 8777 2014-02-12 12:45:13Z gerrit $
             
            % optional arguments
            [spec, fields_asked, remdouble, force, reload] = optargs(varargin, {'', {}, true, false, false});
            
            % checks for earlier error detection
            rqre_datatype(date, @isnumeric);
            rqre_datatype(spec, {@ischar, @iscellstr});
            rqre_datatype(fields_asked, @iscell);
            rqre_datatype(remdouble, @islogical);
            rqre_datatype(force, @islogical);
            rqre_datatype(reload, @islogical);
            
            % special case: remove 'scanline_position' and
            % 'scanline_number' from 'extra'. Those are in reality always
            % returned, but readers do not necessarily understand them.
            
            fields_asked(strcmp(fields_asked, 'scanline_number')) = [];
            fields_asked(strcmp(fields_asked, 'scanline_position')) = [];
            
            % these must always be present in reader return
            fields_always = {'time', 'lat', 'lon', 'epoch', 'version'};
            
            %% generate varname for caching
            
            vn = genvarname(DataHash([self.name, date, varargin]));
            
            %% read cached if appropiate
            if ~reload && ~isempty(self.cache) && self.cache.has_entry(vn)
                logtext(atmlab('OUT'), 'Reading %s from cache (entry %s)\n', ...
                    self.name, vn);
                data = self.cache.get_entry(vn);
                return
            end
            
            %% find datafile and function to read it
            datafile = self.find_granule_by_datetime(date, spec);
            
            %% Split extras in fields in data and pseudo-fields
%            pseudos = fieldnames(self.pseudo_fields);
            fields_in_data = {};
            fields_in_pseudo = {};
            fields_in_deps = {}; % only in dependencies
            for i = 1:length(fields_asked)
                field = fields_asked{i};
                if isfield(self.pseudo_fields, field)
                    fields_in_pseudo = [fields_in_pseudo field]; %#ok<AGROW>
                    deps = self.pseudo_fields.(field).dependencies;
                    for j = 1:length(deps)
                        dep = deps{j};
                        if ~any(strcmp(dep, [fields_always(:)' fields_asked(:)' fields_in_deps(:)']))
                            fields_in_deps = [fields_in_deps dep]; %#ok<AGROW>
                        end
                    end
                else
                    fields_in_data = [fields_in_data field]; %#ok<AGROW>
                end
            end
            
            %% read datafile
            %logtext(colloc_config('stdout'), '%s(''%s'')\n', ...
            %    func2str(reader), datafile);
            logtext(atmlab('OUT'), 'Reading %s\n', datafile);
            try
                data = self.reader(datafile, [fields_in_data fields_in_deps]);
            catch ME
                if force
                    switch ME.identifier
                        case {'atmlab:invalid_data', 'atmlab:exec_system_cmd:shell'}
                            logtext(atmlab('ERR'), ...
                                'Unable to read: %s\n', ME.message);
                            return
                        otherwise
                            ME.rethrow();
                    end
                else
                    % deciding to create a new exception, so that readers
                    % further down than catch all
                    ME2 = MException('atmlab:SatDataset:cannotread', ...
                        ['Failure while %s %s was reading %s.  Original error had ' ...
                         'id ''%s'', message ''%s''.  See ''cause'' for details.'], ...
                         class(self), self.name, datafile, ME.identifier, ME.message);
                    ME2 = ME2.addCause(ME);
                    ME2.throw();
                end
            end
            
            %% do further processing
            
            data = self.reader_processor(self, data, fields_in_pseudo);
            
            %% set version from info if not already set
            
            if ~isfield(data, 'version')
                info = self.find_info_from_granule(datafile);
                if isfield(info, 'version')
                    data.version = info.version;
                end
            end
            
            %% check/convert datafile contents
            
            data = rmfield(data, fields_in_deps);
            
            fields_expected = [fields_always fields_in_data fields_in_pseudo];
            ffound = isfield(data, fields_expected);
            if ~all(ffound);
                error(['atmlab:' mfilename ':missingfield'], ...
                    ['After reading with %s and processing with %s, ' ...
                    'the following fields were expected but not found: %s'], ...
                    func2str(self.reader), func2str(self.reader_processor), ...
                    strjoin(fields_expected(~ffound), ', '));
            end
            
            if isinteger(data.time)
                % later functions will suffocate on non-double time
                data.time = double(data.time);
            end
            nlines = size(data.time, 1);
            npos = size(data.lat, 2);
            
            % add scanline_number and scanline_position (before removing
            % duplicates!)
            
            data.scanline_number = uint32(repmat((1:nlines).', [1 npos]));
            data.scanline_position = uint16(repmat(1:npos, [nlines 1]));
            
            if ~isfield(data, 'version') % try from filename
                fileinfo = self.find_info_from_granule(datafile);
                if isfield(fileinfo, 'version')
                    data.version = fileinfo.version;
                end
            end
            
            %% remove duplicates
            if remdouble
                % read ballast
                firstline = self.granule_first_line(date(1:5), spec);
                if firstline > 0 && firstline < intmax(class(firstline))
                    % get rid of ballast in all fields
                    for f = fieldnames(data)'
                        fn = f{1};
                        if isnumeric(data.(fn)) && size(data.(fn), 1) == nlines
                            % magic in next lines explained at
                            % http://www.mathworks.de/matlabcentral/newsreader/view_thread/290890
                            sz = size(data.(fn));
                            data.(fn) = reshape(data.(fn)(firstline:nlines, :), [nlines-firstline+1, sz(2:end)]);
                        end
                    end
                end
            end
            
            %% cache results
            if ~isempty(self.cache)
                self.cache.set_entry(vn, data);
            end
        end
                
        function first = granule_first_line(self, d, varargin)
            % granule_first_line Returns first scanline not present in previous granule
            %
            % For a certain granule, return the number of the first scanline that
            % is not in the previous scanline. This m-file uses a previously created
            % database (a hashtable). This hash-table is cached between subsequent
            % calls of the function.
            %
            % There should exist an entry for each satellite/sensor granule. If it's
            % not found, an error is raised, and there is probably a bug somewhere. If
            % the satellite/sensor granule exists, but there is no (unique) previous
            % granule, line -2 is returned.
            %
            % FORMAT
            %
            %   first = granule_first_line(datevec[, spec[, reload]])
            %
            % IN
            %
            %   d           various     Starting date/time for granule,
            %                           datevec or unixsecs
            %   spec        various     (optional) Might be indicating satellite(s)
            %   reload      logical     (optional) Reload scanline data (i.e. not
            %                           cached). Defaults to false.
            %   force       logical     (optional) If nothing found, don't
            %                           throw an error, but return empty.
            %
            % OUT
            %
            %   first       number      First scanline not in previous granule.
            %                           Special values: -1 (no data found), -2 (no
            %                           previous granule found)
            %
            % EXAMPLE
            %
            %   >> first = mhs.granule_first_line([2010 9 8 8 8], 'noaa18', false);
            
%             if isequal(self.firstlines, []) % first run
%                 self.firstlines = containers.Map(
%                 S = struct;
%             end
            
            [spec, reload, force] = optargs(varargin, {'', false, false});
            
            assert(ischar(spec), ['atmlab:' mfilename], ...
                'function works only for single-satellite datasets');
            if isempty(spec)
                sat = self.satname;
            else
                sat = spec;
            end
            
            if isequal(self.firstlines, []) || ~isfield(self.firstlines, sat) || reload % load first
                scanfile = datasets_config('firstline_data');
                scanfile = strrep(scanfile, '$SAT', sat);
                scanfile = strrep(scanfile, '$SENSOR', self.name);
                
                logtext(atmlab('OUT'), ...
                    ['Reading %s. ' ...
                     '(If this fails, run self.find_granule_first_line ' ...
                     '(SatDataset.find_granule_first_line)).\n'], scanfile);
                try
                    t = load(scanfile);
                catch ME
                    switch (ME.identifier)
                        case {'MATLAB:load:couldNotReadFile'}
                            newME = MException(['atmlab:' mfilename ':failed'], ...
                                ['Unable to locate duplicates for %s. Failed to read file: %s.\n', ...
                                 'You might want to run the ''find_granule_first_line'' method?'], ...
                                self.name, scanfile);
                            newME.addCause(ME);
                            newME.throw();
                        otherwise
                            ME.rethrow();
                    end
                end
                                
                self.firstlines.(sat) = t.first;
            end
            
            if isscalar(d)
                unisecs = uint32(d);
            else
                dv = num2cell(d);
                unisecs = uint32(self.get_starttime(d));
            end
            

            if self.firstlines.(sat).isKey(unisecs)
                first = self.firstlines.(sat)(unisecs);
            elseif force
                first = [];
            else
                error(['atmlab:' mfilename ':missing_firstline'], ['no data found for %s @ %d. ', ...
                    'You may want to run self.find_granule_first_line(...) ', ...
                    'for a sufficiently long period.'], ...
                    self.name, unisecs);
            end
            
        end
        
        function find_granule_first_line(self, startdate, enddate, varargin)
            % find_granule_first_line Create hashtable with scanline overlaps
            %
            % Creates a map (such as used by granule_first_line) that maps for
            % each granule the first scanline not occuring in the previous
            % scanline.
            %
            % The resulting hashtable is written to a file according to
            % datasets_config('firstline_data'), which is also where
            % granule_first_line is looking for it.
            %
            % FORMAT
            %
            %   cd.find_granule_first_line(startdate, enddate, spec)
            %
            % IN
            %
            %   startdate   datevec     start here
            %   enddate     datevec     end here
            %   spec        various     specification
            %
            % OUT
            %
            %   none, but writes a file
            %
            % EXAMPLE
            %
            %   >> mhs.find_granule_first_line([2008 1 1], [2008 12 31], 'noaa18');
            
            spec = optargs(varargin, {''});            
            
            if isempty(spec)
                sat = self.satname;
            else
                sat = spec;    
            end

            scanfile = datasets_config('firstline_data');
            scanfile = strrep(scanfile, '$SAT', sat);

            scanfile = strrep(scanfile, '$SENSOR', self.name);
            
            logtext(atmlab('OUT'), 'Locating granules\n');
            allgrans = self.find_granules_for_period(startdate, enddate, spec);
            ngrans = size(allgrans, 1);
            logtext(atmlab('OUT'), 'Found %d granules\n', ngrans);
            if ngrans == 0
                return
            end
            
            if exist(scanfile, 'file')
                tm = load(scanfile);
                self.firstlines.(sat) = tm.first;
            else
                self.firstlines.(sat) = containers.Map('KeyType', 'uint32', 'ValueType', 'int32');
            end
            
            uni_first = self.get_starttime(allgrans(1, :));
            if ~self.firstlines.(sat).isKey(uni_first)
                logtext(atmlab('OUT'), 'Setting very first to flag: %d:%d\n', ...
                    uni_first, self.FL_INITIAL);
                self.firstlines.(sat)(uni_first) = self.FL_INITIAL;
            end
            next = 0;

            for i = 1:ngrans-1
                uni = self.get_starttime(allgrans(i+1, :));
                uni = uint32(uni);
                                
                [ddv{1:5}] = unixsecs2date(double(uni));
                logtext(atmlab('OUT'), 'granule %d/%d: %d-%02d-%02d %02d:%02d\n', i, ngrans-1, ...
                    ddv{1}, ddv{2}, ddv{3}, ddv{4}, ddv{5});

                if self.firstlines.(sat).isKey(uni) && ...
                   ~any(self.firstlines.(sat)(uni) == ...
                            cellfun(@int64, {self.FL_INITIAL self.FL_NOTFOUND self.FL_ALLDUPL self.FL_NONEXT self.FL_NOCUR}))
                    logtext(atmlab('OUT'), 'Already exists (%d:%d)\n', uint32(uni), self.firstlines.(sat)(uni));
                    continue
                end
                try
                    couldreadcur = false;
                    if isequal(next, 0)
                        cur = self.read_granule(allgrans(i, :), spec, {}, false, false);
                    else
                        cur = next;
                    end
                    couldreadcur = true;
                    couldreadnext = false;
                    next = self.read_granule(allgrans(i+1, :), spec, {}, false, false);
                    couldreadnext = true;
                catch ME
                    switch ME.identifier
                        case {'atmlab:find_datafile_by_date', 'atmlab:atovs_get_l1c:zamsu2l1c',...
                                'atmlab:invalid_data','atmlab:find_granule_by_datetime',...
                                'MATLAB:imagesci:hdfinfo:invalidFile', 'MATLAB:imagesci:validate:fileOpen', 'atmlab:exec_system_cmd:shell', 'atmlab:SatDataset:cannotread'}
                            logtext(atmlab('ERR'), 'Problem: %s\n', ME.message);
                        otherwise
                            ME.rethrow();
                    end
                end
                %uni = date2unixsecs(allgrans(i+1, 1), allgrans(i+1, 2), allgrans(i+1, 3), allgrans(i+1, 4), allgrans(i+1, 5));
                if couldreadcur && couldreadnext
                    t_cur = cur.epoch + cur.time;
                    t_next = next.epoch + next.time;
                    %[t_cur, t_next] = unify_time_axis(cur.time, next.time);
                    if isempty(t_next) || isempty(t_cur)
                        firstline = 0;
                    else
                        % Replaced former by latter because modis L2 can
                        % have nans for time/lat/lon due to the flagging in
                        % the reading routine
                        %firstline = find(t_next > t_cur(end), 1, 'first');
                        firstline = find(t_next > t_cur(find(~isnan(t_cur), 1, 'last')), 1, 'first');
                    end
                    if ~isempty(firstline)
                        logtext(atmlab('OUT'), 'First line: %d\n', firstline);
                        self.firstlines.(sat)(uni) = firstline;
                    else
                        logtext(atmlab('OUT'), 'No first line, setting to flag\n');
                        self.firstlines.(sat)(uni) = self.FL_ALLDUPL;
                    end
                elseif couldreadcur
                    logtext(atmlab('OUT'), 'Could not read next, flagging \n');
                    self.firstlines.(sat)(uni) = self.FL_NONEXT;
                else
                    logtext(atmlab('OUT'), 'Could not read current. flagging\n');
                    self.firstlines.(sat)(uni) = self.FL_NOCUR;
                end
                
                if mod(i, 10)==0 % store
                    self.store_firstline(scanfile, sat);
                end
            end
            
            self.store_firstline(scanfile, sat);
                        
        end
      
        %{
        function outer = find_extreme_granule(self, spec, mode, varargin)
            % find the earliest or latest granule for this dataset
            %
            % Must always be between Unix Genesis (1970-01-01) and current
            % date. Might provide incorrect results if not every day has
            % collocations. Use with caution. A safe but slow alternative
            % is to run <a href="matlab:help SatDataset/find_granules_for_period">.find_granules_for_period</a> for a very long date interval.
            %
            % Second argument is either 'first' or 'last'.
            %
            % EXAMPLE
            %
            %   gran = d.find_extreme_granule('noaa18', 'first')
            %
            % Uses bisection. Works poorly, misses granules if total period
            % is short.
            
            switch mode
                case 'first'
                    a = 1;
                    b = 2;
                    extrema = {[1970 1 1], datevec(now)};
                case 'last'
                    a = 2;
                    b = 1;
                    extrema = {[self.find_extreme_granule(spec, 'first') 0], datevec(now)};
                otherwise
                    error(['atmlab:' mfilename ':InvalidUse', ...
                        '''mode'' must be ''first'' or ''last'', not %s'], ...
                        mode);
            end
            MAXSTEPS = 100;
            %early = [1970 1 1];
            %late = datevec(now);
            mid = [0 0 0];
            
            for i = 1:MAXSTEPS
                oldmid = mid;
                mid = datevec((datenum(extrema{1})+datenum(extrema{2}))/2);
                % ceil to just next date
                mid = mid(1:3);
                if all(oldmid == mid)
                    outer = extrema{b};
                    break
                end
                if any(self.find_granules_by_date(mid, spec, false))
                    extrema{b} = mid;
                else
                    extrema{a} = mid;
                end
                
            end
            
            grans = self.find_granules_by_date(outer, spec, false);
            if isempty(grans)
                if iscell(spec)
                    tt = [spec{:}];
                else
                    tt = spec;
                end
                error(['atmlab:' mfilename ':nogranule'], ...
                    'No granules found for %s %s', self.name, tt);
            end
            
            switch mode
                case 'first'
                    outer = grans(1, :);
                case 'last'
                    outer = grans(end, :);
            end
        end
%}
        
        function start_unixsecs = get_starttime(self, datevec)
            % get starttime for granule/granules
            %
            % This is either taken directly from the datevec, or it is
            % taken from a database.
            %
            % based on datevec, last elem is granule-number
            %
            % FIXME DOC
            
            if ~isvector(datevec) % pseudo-broadcast with recursion
                start_unixsecs = zeros(size(datevec, 1), 1);
                for i = 1:size(datevec, 1)
                    start_unixsecs(i) = self.get_starttime(datevec(i, :));
                end
            else
                
                if self.needs_starttimesfile
                    
                    gran_no = datevec(6);
                    if ~self.starttimes.isKey(gran_no)
                        self.set_starttime(datevec);
                    end
                    start_unixsecs = self.starttimes(gran_no);
                else
                    start_datevec = datevec(1:5);
                    X = num2cell(start_datevec);
                    start_unixsecs = date2unixsecs(X{:});
                end
                
                start_unixsecs = round(start_unixsecs);
            end
        end

        function set_starttime(self, datevec)
            % get starttime from db, if not in file
            %
            % needs datevec including granule number

            gran_no = datevec(6);
            fullpath = self.find_granule_by_datetime(datevec);
            logtext(atmlab('OUT'), 'Reading %s to get start-time\n', ...
                fullpath);
 %           data = read_saphir_l1(fullpath, 'ScanTimestart');
            % Don't remove duplicates, as I need to run this function
            % before I can even begin to /detect/ duplicates!
            success = false;
            try
                S = self.read_granule(datevec, [], {}, false);
                success = true;
            catch ME
                switch ME.identifier
                    case 'atmlab:rqre_in_range:invalid'
                        logtext(atmlab('ERR'), ...
                            'Cannot determine start time, setting to 0: %s\n', ...
                            ME.message);
                    otherwise
                        ME.rethrow();
                end
            end
%             X = textscan(data.data.ScanTimestart(1).Data, '%4d%2d%2d %2d%2d%2d%6d');
%            [year, month, day, hour, minute, second, ~] = deal(X{:});
            if success
                self.starttimes(gran_no) = S.epoch;
                tm = self.starttimes; %#ok<NASGU>
                save(self.starttimes_fullpath, 'tm');

            end

            % since storing a small hashtable is so much quicker than
            % reading a large granule-file, doing this every time is a
            % small price to pay for easier programming
            % might add a conditional here?
        end

        function [gridmean, lat, lon] = level3(self, date1, date2, spec, fields, gridsize, varargin)
            % Calculate level3 (gridded mean) for period
            %
            %
            % IN
            %
            % date1
            % date2
            % spec
            % fields
            % gridsize
            % (optional) limiters
            %   Cell array.  Each element is either a function handle
            %   (passed directly to binned_statistics, or a two-element
            %   cell array with {{fields}, limiter} where gridded
            %   data will be limited by calling limiter on {fields}.
            %   Can be used e.g. to grid only day-time data with the help
            %   of sun_angles.  In the latter case the limiter must take a
            %   struct with {fields}.
            % (optional) struct with options to binning_fast
            %
            % Returns:
            %
            % - gridmean: 3-D matrix, [nlat nlon nfield]
            %
            % FIXME DOC
            
            [limiters, data] = optargs(varargin, {{}, struct()});
            %data.gridsize = gridsize;
            allgrans = self.find_granules_for_period(date1, date2, spec);
            allstats = {};
            % sort limiters
            if ~iscell(limiters)
                limiters = {limiters};
            end
            limit_binnedstats = {};
            limit_other = {};
            also_fields = {};
            j = 1;
            k = 1;
            for i = 1:length(limiters)
                limiter = limiters{i};
                if isfunction_handle(limiter)
                    limit_binnedstats{j} = limiter;
                    j = j + 1;
                elseif iscell(limiter)
                    limit_other{k} = limiter;
                    k = k + 1;
                    also_fields = union(also_fields, setdiff(limiter{1}, {'lat', 'lon', 'time', 'epoch'}));
                end
            end
            i = 0;
            while i < size(allgrans, 1)
                
                data.lat = zeros(1e6, 1, 'single');
                data.lon = zeros(1e6, 1, 'single');
                data.data = zeros(1e6, length(fields), 'single');
                
                N = 1;
                X = whos('data');
                while X.bytes < 2e8 && i < size(allgrans, 1)
                    i = i + 1;
                    try
                        grandata = self.read_granule(allgrans(i, :), spec, union(fields, also_fields));
                    catch ME
                        switch ME.identifier
                            case 'atmlab:SatDataset:cannotread'
                                logtext(atmlab('ERR'), ...
                                    'Cannot read granule: %s', ...
                                    ME.identifier);
                                continue
                            otherwise
                                ME.rethrow();
                        end
                    end
                    % apply limiters
                    mask = true(size(grandata.lat));
                    for k = 1:length(limit_other)
                        lim = limit_other{k};
                        mask = mask & lim{2}(getfields(grandata, lim{1}{:}));
                    end
                    grandata.lat = grandata.lat(mask);
                    grandata.lon = grandata.lon(mask);
                    for k = 1:length(fields)
                        field = fields{k};
                        grandata.(field) = grandata.(field)(mask);                    
                    end
                        
                    nnew = size(grandata.lat, 1);
                    new = N:(N+nnew-1);
                    if nnew==0 % no data
                        continue
                    end
                    if new(end) > size(data.lat, 1)
                        % double allocation
                        data.lat = [data.lat; zeros(size(data.lat, 1), 1, 'single')];
                        data.lon = [data.lon; zeros(size(data.lon, 1), 1, 'single')];
                        data.data = [data.data; zeros(size(data.data, 1), length(fields), 'single')];
                    end
                    data.lat(new) = grandata.lat;
                    data.lon(new) = grandata.lon;
                                    
                    C = cellfun(@(f) single(grandata.(f)), fields, 'UniformOutput', false);
                    data.data(new, :) = horzcat(C{:});
                    N = N + nnew;

                    X = whos('data');
                end
                data.lat = data.lat(1:N-1);
                data.lon = data.lon(1:N-1);
                data.data = data.data(1:N-1);
                
%                 data.lat = grandata.lat;
%                 data.lon = grandata.lon;
%                 C = cellfun(@(f) double(grandata.(f)), fields, 'UniformOutput', false);
%                 data.data = horzcat(C{:});
                logtext(atmlab('OUT'), 'Binning\n');
                %[binned, lat, lon] = binning_fast(data);
                indces = bin_nd({data.lat, data.lon}, {-90:gridsize:90, -180:gridsize:180});
                binned = cellfun(@(ii) data.data(ii), indces, 'UniformOutput', false);
                stats = binned_statistics(binned, {@(x)(size(x,1)), @(x)(sum(x,1))}, limit_binnedstats);
                logtext(atmlab('OUT'), 'Calculating statistics\n');
                stats.statistic1 = cell2mat(stats.statistic1);
                % cell2mat on multi-dim will flatten 2nd dimension,
                % unflatten and put this dimension at the end again
                stats.statistic2 = permute(reshape(cell2mat(stats.statistic2), [size(stats.statistic2, 1) size(stats.statistic2{1, 1}, 2), size(stats.statistic2, 2)]), [1 3 2]);
                allstats = [allstats {stats}];
            end
            logtext(atmlab('OUT'), 'Finalising\n');
            % calculate total count
            allcount = cellfun(@(x) x.statistic1, allstats, 'UniformOutput', false);
            allcount = cat(3, allcount{:});
            totalcount = sum(allcount, 3);
            
            % calculate total sum
            %allsums = cellfun(@(x) bsxfun(@times, x.statistic1, x.statistic2), allstats, 'UniformOutput', false);
            allsums = cellfun(@(x) x.statistic2, allstats, 'UniformOutput', false);
            allsums = cat(4, allsums{:});
            totalsum = sum(allsums, 4);
            
            % calculate overall mean
            gridmean = bsxfun(@ldivide, totalcount, totalsum);
        end
                
        %% getters and setters for properties
        
        function path = get.starttimes_fullpath(self)
            path = fullfile(self.basedir, self.starttimesfile);
        end
        
        function times = get.starttimes(self)
            if ~self.needs_starttimesfile
                times = [];
            else
                if isequaln(self.cachedstarttimes, []) % not initialised
                    try
                        self.cachedstarttimes = loadvar(self.starttimes_fullpath, 'tm');
                    catch ME
                        switch ME.identifier
                            case {'MATLAB:load:couldNotReadFile', 'MATLAB:load:notBinaryFile'}
                                logtext(atmlab('OUT'), ...
                                    ['Unable to read starttimes-file at %s ' ...
                                    '(%s). Initialising new.\n'], ...
                                    self.starttimes_fullpath, ME.message);
                                self.cachedstarttimes = containers.Map('KeyType', 'uint32', 'ValueType', 'int64');
                        end
                    end
                end
                
                times = self.cachedstarttimes;
            end
        end

        function set.starttimes(self, val)
            if ~isa(val, class(containers.Map))
                error(['atmlab:' mfilename ':invalid'], ...
                    'starttimes should be a containers.Map, found %s', ...
                    class(val));
            end
            logtext(atmlab('OUT'), 'Writing %s\n', self.starttimes_fullpath);
            save(self.starttimes_fullpath, 'val');
        end
        
        function set.name(self, value)
            % setter for 'name' property.
            if ~isempty(self.name)
                % deregister old name
                datasets('delete', self);
            end
            self.name = value;
            datasets(self);
        end

        %% overloading stuff
        
        function sobj = saveobj(self)
%             sobj = saveobj@handle(self); 
             warning(['atmlab:' mfilename ':nostoring'], ...
                ['You tried to store %s %s, but serialisation is not implemented. ' ...
                 'Attempts to load will not yield a valid object.  Sorry.'], ...
                 class(self), self.name);
             sobj = [];
        end
    end
    
    methods (Access = protected)
        function pos2re(~)
            error(['atmlab:' mfilename ':cannotconvert'], ...
                ['The regular expression self.re was not defined, so ' ...
                 'I tried to convert it automagically from location '...
                 'information.  However, I don''t know how to do this. ' ...
                 'I give up.  Please help me: either implement ' ...
                 'a pos2re() method, or define a re member.']);
        end
        
        function nm = calculate_name(self)
            % calculate_name Return automated name if name is not given
            %
            % This function is called by the constructor if no name is
            % given. You may wish to override it in a subclass.
            
            existing_names = fieldnames(datasets);
            while true
                nm = sprintf([class(self) '_%d_%d'], uint64(date2unixsecs()),round(rand(1, 1)*10000));
                if ~any(strcmp(nm, existing_names))
                    break
                end
            end
        end
        
        function add_collocated_dataset(ds, cd)
            % Adds a collocated dataset. INTERNAL USE ONLY!
            %
            % This is called by the CollocatedDataset constructor.
            ds.collocated_datasets = [ds.collocated_datasets cd];
        end
        
        function s_out = repvars(self, s, datevec, spec)
            % repvars Replace 'magic' variables
            %
            % Replace the 'magic' variables:
            %
            % $YEAR4
            % $YEAR2
            % $MONTH
            % $DAY
            % $DOY
            % $SAT  or  $SAT1 and $SAT2
            % $HOUR
            % $MINUTE
            %
            % For more replacements, overload this function.
            %
            % FORMAT
            %
            %   s_out = self.repvars(s, datevec, satname)
            %
            % IN
            %
            %   s       string  where magic is replaced
            %   datevec vector  date-vector [year month day]
            %   spec    string/ name of satellite/satellites
            %           cellstr
            %
            % OUT
            %
            %   s_out   string  with magic replaced
            
            year = num2str(datevec(1), '%04d');
            month = num2str(datevec(2), '%02d');
            day = num2str(datevec(3), '%02d');
            if length(datevec)>3
                hour = num2str(datevec(4), '%02d');
                minute = num2str(datevec(5), '%02d');
            else
                hour = '0';
                minute = '0';
            end
            year02 = year(3:4);
            doy = num2str(round(dayofyear(datevec(1), datevec(2), datevec(3))), '%03d');
            
            to_replace = {'$YEAR4', year, '$MONTH', month, '$DAY', day, ...
                '$YEAR2', year02, '$DOY', doy, '$HOUR', hour, '$MINUTE', minute};
            
            if iscellstr(spec)
                to_replace = [to_replace {'$SAT1', spec{1}, '$SAT2', spec{2}}];
            else
                if strfind(s, '$SAT1')
                    warning('atmlab:strrep_variables', ...
                        ['replacing $SAT, but having $SAT1; are you sure you don''t ' ...
                        'want to pass TWO satellites?']);
                end
                to_replace = [to_replace {'$SAT', spec}];
            end
            
            s_out = strrep_multi(s, to_replace{:});
            
        end
        
        function matches = infofit(self, is, datevec, spec)
            yearstr = num2str(datevec(1), '%04d'); % for comparing easily with 2digit years
            
            if (isfield(is, 'year02') && ~isempty(is.year02) && ~strcmp(is.year02, yearstr(3:4))) || ...
                    (isfield(is, 'year04') && ~isempty(is.year04) && str2double(is.year04)~=datevec(1)) || ...
                    (isfield(is, 'year') && ~isempty(is.year) && str2double(is.year)~=datevec(1)) || ...
                    (isfield(is, 'month') && ~isempty(is.month) && str2double(is.month)~=datevec(2)) || ...
                    (isfield(is, 'day') && ~isempty(is.day) && str2double(is.day)~=datevec(3)) || ...
                    (isfield(is, 'doy') && ~isempty(is.doy) && str2double(is.doy)~=dayofyear(datevec(1), datevec(2), datevec(3)) || ...
                    (isfield(is, 'satname') && ~isempty(is.satname) && ~isequal(is.satname, spec)));
                matches = false;
            else
                matches = true;
            end
        end

    end
    
    methods (Access = private)
        function store_firstline(self, scanfile, sat)
            logtext(atmlab('OUT'), ...
                'Writing %s\n', scanfile);
            first = self.firstlines.(sat); %#ok<NASGU>
            save(scanfile, 'first');
        end
    end
end
