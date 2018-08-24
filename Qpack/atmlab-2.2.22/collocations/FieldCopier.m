classdef FieldCopier < AssociatedDataset
    % class to copy fields from original datasets to collocated datasets
    %
    % A common task associated with <a href="matlab:help CollocatedDataset">collocating</a> different <a href="matlab:help SatDataset">dataset</a>s
    % is to copy fields from the original datasets to use with the collocations.
    % FieldCopier implements <a href="matlab:help AssociatedDataset">AssociatedDataset</a>, meaning that it has at
    % least all the properties and methods that are indicated by AssociatedDataset.
    % Therefore, it can be used wherever documentation describes the need
    % for an AssociatedDataset.
    %
    % To copy fields as-is, create an instance of FieldCopier and pass this
    % on to the CollocatedDataset methods <a href="matlab:help CollocatedDataset/collocate_granule">collocate_granule</a>,
    % <a href="matlab:help CollocatedDataset/collocate_date">collocate_date</a>, <a href="matlab:help CollocatedDataset/collocate_and_store_date">collocate_and_store_date</a>, or <a href="matlab:help CollocatedDataset/collocate_and_store_date_range">collocate_and_store_date_range</a>.
    % Fieldnames are taken upon creation from two structures passed on to the
    % constructor: one for the primary, and one for the secondary. The
    % fieldnames of those structures are passed on to the respective
    % <a href="matlab:help SatDataset/reader">reader</a>s, who are expected to return structures with the
    % appropiate data stored in them with the same fieldnames.
    % The values for the fields in the structures passed on to the
    % constructor contain information on how to store the data, among other
    % things. See also the example below.
    %
    % When a FieldCopier is created, it is automatically registered with
    % the <a href="matlab:help CollocatedDataset">CollocatedDataset</a> to which it belongs, in <a href="matlab:help CollocatedDataset/associated">CollocatedDataset.associated</a>.
    % Therefore, only for some tasks involving a FieldCopier, one needs to
    % pass the reference to the method using it. For other tasks, this is
    % taken care of automatically.
    %
    % FieldCopier Properties:
    %
    %   fieldstruct_primary -   Describes what is copied from primary
    %   fieldstruct_secondary - Describes what is copied from secondary
    %  (remaining properties inherited from <a href="matlab:help AssociatedDataset">AssociatedDataset</a>.
    %   Use <a href="matlab:properties FieldCopier">properties</a> for a complete listing)
    %
    % FieldCopier Methods:
    %
    %   FieldCopier -           Create FieldCopier object
    %  (remaining methods implemented based on <a href="matlab:help AssociatedDataset">AssociatedDataset</a>)
    %
    % Example:
    %
    % % obtain object for <a href="matlab:help CollocatedDataset">CollocatedDataset</a>
    % >> D = <a href="matlab:help datasets">datasets</a>;
    % >> mhscpr = D.CollocatedDataset__1_mhs__2_cpr;
    % % define structures to be passed on when creating FieldCopier
    % % For this to work, the <a href="matlab:help SatDataset">SatDataset</a> in <a href="matlab:help CollocatedDataset/primary">mhscpr.primary</a>
    % % must have a <a href="matlab:help SatDataset/reader">reader</a> that accepts {'tb'} as a second argument,
    % % and then returns a structure containing a field 'tb' with appropriate
    % % data. Similarly, <a href="matlab:help CollocatedDataset/secondary">mhscpr.secondary</a>.reader shall take
    % % {'RO_ice_water_path'} as a second argument and return a structure
    % % with a field 'RO_ice_water_path'.
    % >> fc1 = struct('tb', struct('type', 'float', 'atts', struct('long_name', 'My BT')));
    % >> fc2 = struct('RO_ice_water_path', struct('type', 'int', 'atts', struct('long_name', 'My IWP')));
    % % create FieldCopier object with minimum of information
    % >> fc = FieldCopier(mhscpr, fc1, fc2, 'basedir', '/tmp/testing', ...
    %                     'subdir', '$YEAR4/$MONTH/$DAY', ...
    %                     'filename', 'collocations_$SAT.nc.gz');
    % % Collocate along with FieldCopier
    % >> mhscpr.collocate_and_store_date_range([2009 7 1], [2009 7 5], ...
    %                                          'noaa18', '', {fc});
    %
    % This code now creates two files for each date in the daterange (ten
    % files in total): one for the <a href="matlab:help CollocatedDataset">CollocatedDataset</a>, containing the very
    % core information, and one for the FieldCopier, containing two fields;
    % one copied from the primary <a href="matlab:help SatDataset">dataset</a>, and one copied from the secondary
    % <a href="matlab:help SatDataset">dataset</a>.
    %
    % TODO:
    %  - set some (but not all!!) clever properties for NetCDF
    %
    % See also: AssociatedDataset (abstract superclass), CollocatedDataset, SatDataset, Collapser, datasets
    %
    % See also the Collocation User's Guide.
    %
    % $Id: FieldCopier.m 8522 2013-07-02 13:13:41Z gerrit $
    
    properties (Transient, SetAccess = protected)
        
        % Structure with fields corresponding to primary
        %
        % The names of the fields correspond to fields as they will be
        % stored in the collocated NetCDF file. Unless otherwise indicated,
        % the same field name will be read from the primary dataset.
        %
        % The value for each field is itself a structure containing
        % information on (among other things) how to store the
        % field in the final NetCDF file. This structure can have
        % the following fields:
        %
        %   type    string, NetCDF-3 type, such as 'int',
        %           'float'. Full list <a href="http://www.unidata.ucar.edu/software/netcdf/docs/netcdf-c/NetCDF_002d3-Variable-Types.html#NetCDF_002d3-Variable-Types">in NetCDF docs</a>.
        %           This field is mandatory.
        %
        %   atts    structure, fields and values are all
        %           strings and are stored as NetCDF
        %           attributes. I suggest to use <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/cf-conventions.html">CF</a>
        %           conventions.
        %
        %           NOTE: in the future, attributes not
        %           provided may possibly be guessed based on
        %           original data.
        %
        %   dataset string. This can be used in case the field
        %           is not in the same dataset, but in a different
        %           dataset based on the same instrument. This dataset
        %           must have exactly the same number of scanlines and
        %           scanpositions. For a dataset with less data but the
        %           same number of collocations (for example, a different
        %           instrument on the same satellite), use
        %           <a href="matlab:help FieldMultiInstrumentCopier">FieldMultiInstrumentCopier</a>
        %
        %   realname string. This can be passed if the field
        %           should be stored under a different name in
        %           the FieldCopier dataset than in the
        %           original dataset, for example, when
        %           different fields have the same name. Here,
        %           'realname' is the name as stored in the
        %           original data, and the structure fieldname
        %           is the name as stored in the FieldCopier data.
        fieldstruct_primary = struct;
        
        % Structure with fields corresponding to secondary.
        %
        % See <a href="matlab:help FieldCopier/fieldstruct_primary">fieldstruct_primary</a> for info.
        fieldstruct_secondary = struct;
        
        % Structure with all fields and info on how to store the NetCDF
        %
        % See also <a href="matlab:help AssociatedDataset.members">AssociatedDataset.members</a>
        %members = struct(); % set by constructor
        
        % Parent <a href="matlab:help CollocatedDataset">CollocatedDataset</a>.
        %
        % See also <a href="matlab:help AssociatedDataset.parent">AssociatedDataset.parent</a>
        parent = [];
        
        % FieldCopier has no dependencies
        %
        % See also <a href="matlab:help AssociatedDataset.dependencies">AssociatedDataset.dependencies</a>
        dependencies = {};
    end
    
    properties (Access = private)
        oldlocalcols;
    end
    
    methods
        %% constructor
        
        function self = FieldCopier(cd, fieldstruct1, fieldstruct2, varargin)
            % Creates a FieldCopier object
            %
            % Used to create a <a href="matlab:help FieldCopier">FieldCopier</a> object.
            %
            % FORMAT
            %
            %   fc = FieldCopier(cd, fs1, fs2, 'name', 'MyFC', ...
            %                    'basedir', '/some/where', ...
            %                    ...) % etc.
            %
            % IN
            %
            %   cd      CollocatedDataset   <a href="matlab:help CollocatedDataset">CollocatedDataset</a> that this FieldCopier belongs to.
            %
            %   fs1     structure
            %
            %       Full definition of fields and information on how to
            %       store. For full instructions on fields and values,
            %       see <a href="matlab:help FieldCopier/fieldstruct_primary">property documentation</a>.
            %
            %   fs2     structure
            %
            %       Like fs1, but corresponding to the secondary.
            %
            %   ...remaining arguments passed on to <a href="matlab:help SatDataset">SatDataset</a>,
            %   so those indicate name, where to store, etc.
            %
            % OUT
            %
            %   A FieldCopier object.
            
            self = self@AssociatedDataset(cd, {}, varargin{:}); % call parent constructor
            
            self.fieldstruct_primary = fieldstruct1;
            self.fieldstruct_secondary = fieldstruct2;
            
            
            % check consistence of fieldstructs
            
            allfields = catstruct(fieldstruct1, fieldstruct2);
            assert(length(fieldnames(fieldstruct1))+length(fieldnames(fieldstruct2))==length(fieldnames(allfields)), ...
                ['atmlab:' mfilename ':duplicates'], [...
                'Duplicate fieldnames between datasets are not permitted, but were found. ' ...
                'I suggest to use the ''realname'' attribute for the <a href="matlab:help FieldCopier/fieldstruct_primary">fieldstruct</a>.']);
            self.members = allfields;
            
        end
    end
    
    methods (Access = {?SatDataset})
        %% implementation of abstract methods
        
        function args = primary_arguments(self, varargin)
            fields = optargs(varargin, {'all'});
            args = self.arguments(self.fieldstruct_primary, self.parent.primary, fields);
        end
        
        function args = secondary_arguments(self, varargin)
            fields = optargs(varargin, {'all'});
            args = self.arguments(self.fieldstruct_secondary, self.parent.secondary, fields);
        end
        
        function fields = fields_needed_for_dependency(~, ~, ~)
            fields = {}; % no dependencies
        end
        
        function [result, localcols] = process_granule(self, processed_core, data1, date1, spec1, data2, date2, spec2, ~, ~, varargin)
            fields = optargs(varargin, {'all'});
            allnames = fieldnames(self.members);
            if isequal(fields, 'all')
                localnames = allnames;
            else
                %localnames = intersect(allnames, fields);
                % intersect destroys order, order is important...
                localnames = allnames(cellfun(@(X)ismember(X, fields), allnames));
                rqre_subset(fields, allnames); % if this fails, some fields do not exist
            end
            n_inprim = length(intersect(fieldnames(self.fieldstruct_primary), localnames));
            dimsizes = struct();
            % other datasets that may be required (structs filled as needed)
            D = datasets();
            % `also_read` keeps track of fields that need to be read from
            % sibling-datasets for the primary and the secondary,
            % respectively
            also_read = {struct(), struct()};
            dat_other = {struct(), struct()};
            reflat = {[], []};
            % will loop through all the names in total 3 times...
            % in the first loop, check:
            % - what names should be used to read
            % - if data should be from
            % sibling-datasets, i.e. datasets not occuring in the original
            % collocation, but on the same size (e.g. CPR RO or RVOD)
            for i = 1:length(localnames)
                fieldnam = localnames{i};
                if ~isfield(self.members.(fieldnam), 'realname')
                    self.members.(fieldnam).realname = fieldnam;
                end
                % if it has a 'dataset' defined, the field may be from a
                % sibling-dataset
                if isfield(self.members.(fieldnam), 'dataset')
                    ds = self.members.(fieldnam).dataset;
                    if i <= n_inprim
                        j = 1;
                    else
                        j = 2;
                    end
                    % add field to read from this DS to
                    % also_read{j}.(dataset_name)
                    % here, store the realname as it has in the original
                    % dataset, because that will in any case be the
                    % fieldname in the data-structure returned by
                    % .read_granule.
                    if ~isfield(also_read{j}, ds.name)
                        logtext(atmlab('OUT'), ...
                            'Shall read field %s (stored as %s) from sibling-dataset %s\n', ...
                            fieldnam, self.members.(fieldnam).realname, ds.name);
                        also_read{j}.(ds.name) = {self.members.(fieldnam).realname};
                    else
                        logtext(atmlab('OUT'), ...
                            'Shall also read field %s (stored as %s) from sibling-dataset %s\n', ...
                            fieldnam, self.members.(fieldnam).realname, ds.name);
                        also_read{j}.(ds.name) = [also_read{j}.(ds.name) self.members.(fieldnam).realname];
                    end
                end % end of `if field from sibling`
            end % end of loop through all fields
            
            % Loop through primary, secondary to do two things:
            % - read siblings, if any
            % - set reflat:
            % Later, we may need to reshape some fields, for example if
            % they have more than one measurement per footprint. Therefore,
            % we need to know the number of scanlines and the number of
            % measurements per scanline. For this, we use the field `lat`
            % because it should always be there and have exactly one value
            % per footprint.

            for j = 1:2
                if j == 1
                    dt = date1;
                    spc = spec1;
                    dat = data1; % for setting reflat
                else
                    dt = date2;
                    spc = spec2;
                    dat = data2;
                end
                siblings_to_read = fieldnames(also_read{j});
                for k = 1:length(siblings_to_read)
                    dsnm = siblings_to_read{k};
                    % read fields from this dataset as indicated by
                    % also_read{j}.(dataset_name)
                    logtext(atmlab('OUT'), ...
                        'Reading dataset %s to grab %d fields: %s\n', ...
                        dsnm, length(also_read{j}.(dsnm)), strjoin(also_read{j}.(dsnm), ', '));
                    % in this reading, do not remove duplicates, or there will
                    % be a mis-match between indices as provided by the
                    % collocations and indices as determined here
                    try
                        dat_other{j}.(dsnm) = D.(dsnm).read_granule(dt, spc, also_read{j}.(dsnm), false, false);
                    catch ME
                        switch ME.identifier
                            case {'atmlab:find_granule_by_datetime', 'atmlab:exec_system_cmd:shell', 'MATLAB:imagesci:validate:fileOpen'}
                                warning(['atmlab:' mfilename ':nosibling'], ...
                                    'I tried to collect fields from dataset %s, but failed: %s\n', ...
                                    dsnm, ME.message);
                                dat_other{j}.(dsnm) = 'failed';    
                            otherwise
                                ME.rethrow();
                        end
                    end
                    % if this sibling has a reflat, store it in case we
                    % need it later
                    if isfield(dat_other{j}.(dsnm), 'lat')
                        % verify that no different reflat already there
                        if ~isempty(reflat{j}) && nanmax(abs(reflat{j} - dat_other{j}.(dsnm).lat)) > 0.01
                            logtext(atmlab('ERR'), ...
                                ['Inconsistent latitude-fields between ' ...
                                 'sibling-datasets!  Up to %f different...\n'], ...
                                nanmax(abs(reflat{j} - dat_other{j}.(dsnm).lat)));
                            dat_other{j}.(dsnm) = 'failed';
                        else
                            reflat{j} = dat_other{j}.(dsnm).lat;
                        end
                    end
                end % loop through all siblings to read for prim or sec
                
                if isfield(dat, 'lat')
                    if ~isempty(reflat{j}) && nanmax(abs(reflat{j} - dat.lat)) > 0.01
                        logtext(atmlab('ERR'), ...
                            ['Inconsistent latitude-fields in core vs. ' ...
                             'sibling-dataset!\n']);
                        dat_other{j}.(dsnm) = 'failed';
                    else
                        reflat{j} = dat.lat;
                    end
                end
            end % loop through primary, secondary
            
            % now all needed datasets have been read
            
            % In the second loop, we reshape data so that they all have
            % a dimension equal to the number of scan positions, and we
            % collect dimension data for other fields.  We also define the
            % localcols structure used to address the columns in 'result'
            % (note that this should be equal to self.cols if getting all
            % fields)

            localcols = struct();
            n_tot = 0;
            for i = 1:length(localnames)
                fieldnam = localnames{i};
                if i<=n_inprim
                    j = 1;
                    dat = data1;
                else
                    dat = data2;
                    j = 2;
                end
%                 if isempty(fieldnames(dat))
%                     logtext(atmlab('OUT'), 'No fields from either primary or secondary, hopefully sibling has same number of lats\n');
%                     % test if they both are there. If there is no primary
%                     % or secondary dataset, on e will be empty
%                     testE = [~isempty(fieldnames(dat_other{1})) ~isempty(fieldnames(dat_other{2}))];
%                     if all(testE)
%                         reflat = cellfun(@(x) x.(self.members.(fieldnam).dataset.name).lat, dat_other, 'UniformOutput', false);
%                     else
%                         reflat = {dat_other{testE}.(self.members.(fieldnam).dataset.name).lat};
%                         % workaround since relat{2} is called for later on
%                         reflat(2) = reflat;
%                     end
%                 else
%                     reflat = {data1.lat, data2.lat};
%                 end
                n_scanlines = size(reflat{j}, 1);
                n_scanpos = size(reflat{j}, 2);
                
                % data either from prim/sec or from 'sibling'
                if isfield(self.members.(fieldnam), 'dataset')
                    if isequal(dat_other{j}.(self.members.(fieldnam).dataset.name), 'failed')
                        % this happens if core existed, but sibling didn't
                        % remainder of loop is only used to enlarge fdata
                        % or set NetCDF props, problem persists further down
                        % when collecting data.
                        % Need to set localcols before proceeding.
                        % Alternative would be to look into persistency,
                        % did we have a previous localcols?
                        if isfield(self.members,  fieldnam) && isfield(self.members.(fieldnam), 'dims')
                            n = self.members.(fieldnam).dims{2};
                        elseif ~isempty(self.oldlocalcols)
                            n = length(self.oldlocalcols.(fieldnam));
                        else
                            warning(['atmlab:' mfilename ':unknownsize'], ...
                                ['I couldn''t find field %s and ' ...
                                 'I''m not sure about it''s size. ' ...
                                 'I''ll guess 1 per measurement. ' ...
                                 'If I''m wrong, you''ll get trouble. ' ...
                                 'Consider defining %s.members.%s.dims.'], ...
                                 self.name, fieldnam);
                            n = 1;
                        end
                        localcols.(fieldnam) = (n_tot+1):(n_tot+n);
                        n_tot = n_tot + n;
                        continue
                    else
                        fdata = dat_other{j}.(self.members.(fieldnam).dataset.name).(self.members.(fieldnam).realname);
                    end
                else
                    fdata = dat.(self.members.(fieldnam).realname);
                end
                % special case: fields with one value per scanline
                if size(fdata, 1) == n_scanlines && size(fdata, 2) == 1
                    fdata = repmat(fdata, [1 n_scanpos]);
                end
                % 'n' is the number of measurements per lat/lon, e.g. the
                % number of channels, number of height-bins, etc. Should be
                % scalar...
                n = numel(fdata)/(n_scanlines*n_scanpos);
                assert(iswhole(n), ['atmlab:' mfilename ':dimensions'], ...
                    ['Dimension mismatch: scanlines: %d, scanpos: %d, ' ...
                    'field %s (stored as %s): %s'], n_scanlines, n_scanpos, fieldnam, ...
                    self.members.(fieldnam).realname, num2str(size(fdata)));
                %% if needed, add dimension info to self.members
                if (n>1)
                    % need to specify dimension in NetCDF, if it doesn't
                    % exist yet, we will need to create the dimension. To
                    % tell the writing routine that it needs to do so, add
                    % a field with a name and a number, but only if this
                    % dimension size is new
                    
                    % iff self.members.(fieldnam).dims is there
                    if ~(isfield(self.members, fieldnam) && ...
                            isfield(self.members.(fieldnam), 'dims'))
                        % find dimension name from dimension size
                        alldimnames = fieldnames(dimsizes);
                        alldimvalues = structfun(@(x)x, dimsizes);
                        if ismember(n, alldimvalues)
                            nm = alldimnames{alldimvalues==n};
                        else
                            nm = sprintf('AUTO_DIM%d_%d', length(alldimvalues)+1, n);
                            dimsizes.(nm) = n;
                        end
                        % store dimension name and size
                        self.members.(fieldnam).dims = {nm, n};
                    end
                    
                end
                localcols.(fieldnam) = (n_tot+1):(n_tot+n);
                n_tot = n_tot + n;
            end
            
            self.members2cols();
            if isequal(fields, 'all')
                assert(isequal(localcols, self.cols), ...
                    ['atmlab:' mfilename ':wrongcols'], ...
                    'Ambiguity in cols-structure.  This is a bug.  Stop');
            end
            self.oldlocalcols = localcols;
            
            ncollocs = size(processed_core, 1);
            nfields = max(cell2mat(struct2cell(localcols).'));
            %fields = fieldnames(self.cols);
            result = nan*zeros(ncollocs, nfields, self.mattype);
            %n_inprim = length(fieldnames(self.fieldstruct_primary));
            
            r1 = processed_core(:, self.parent.cols.LINE1);
            r2 = processed_core(:, self.parent.cols.LINE2);
            c1 = processed_core(:, self.parent.cols.POS1);
            c2 = processed_core(:, self.parent.cols.POS2);
%            if (self.needs_primary_data() || ~isempty(fieldnames(dat_other{1})))
            if ~isempty(reflat{1})
                i1 = sub2ind(size(reflat{1}), r1, c1);
            end
%            if (self.needs_secondary_data() || ~isempty(fieldnames(dat_other{2})))
            if ~isempty(reflat{2})
                i2 = sub2ind(size(reflat{2}), r2, c2);
            end
            
            % in the third loop, collect the data
            
            for i = 1:length(localnames)
                field = localnames{i};
                
                % an empty reflat means I couldn't read any core or
                % sibling, so I won't need the indices either
                if i <= n_inprim
                    if ~isempty(reflat{1})
                        data = data1;
                        ii = i1;
                    end
                    j = 1;
                else
                    if ~isempty(reflat{2})
                        data = data2;
                        ii = i2;
                    end
                    j = 2;
                end
                
                % data either from prim/sec or from 'sibling'
                if isfield(self.members.(field), 'dataset')
                    %logtext(atmlab('OUT'), ...
                    %    'Grabbing field %s from sibling-dataset %s\n', ...
                    %    field, self.members.(field).dataset.name);
                    if isequal(dat_other{j}.(self.members.(field).dataset.name), 'failed')
                        logtext(atmlab('ERR'), ...
                            ['But there''s a field I failed to read :(, ' ...
                            'so I''ll write a filler instead\n']);
                        if ~isfield(self.members.(field).atts, 'missing_value')
                            error(['atmlab:' mfilename ':missingmissing'], ...
                                ['You asked me to collect field %s from sibling ' ...
                                'dataset %s, but I couldn''t find any datafile (see above). ' ...
                                'Therefore, I decided to set the ''filler'' value as ' ...
                                'ought to be defined in %s.members.%s.atts.missing_value. Unfortunately, ' ...
                                'there is no such field `missing_value`, so I don''t know how to ' ...
                                'flag the missing data. Please define %s.members.%s.atts.missing_value ' ...
                                'and try again.'], ...
                                field, self.members.(field).dataset.name, ...
                                self.name, field, self.name, field);
                        end
                        result(:, localcols.(field)) = self.members.(field).atts.missing_value;
                        %result(:, self.cols.(field)) = self.members.(field).atts.missing_value;
                        continue
                    end
                    fdata = dat_other{j}.(self.members.(field).dataset.name).(self.members.(field).realname);
                else
                    fdata = data.(self.members.(field).realname);
                end
                
                % if this fails, data.(field) may not be a column-vector as
                % required
                sz = size(fdata);
                if isequal(sz, size(reflat{j}))
                    DD = fdata(:); % 1 point per lat/lon
                elseif sz(1) == size(reflat{j}, 1) && sz(2) == 1 % e.g. time
                    DD = repmat(fdata, [1 size(data.lat, 2)]);
                    DD = DD(:);
                else % multi-point per lat/lon
                    DD = reshape(fdata, prod(sz(1:end-1)), sz(end));
                end
                result(:, localcols.(field)) = DD(ii, :);
                %result(:, self.cols.(field)) = DD(ii, :);
                %result(:, self.cols.(field)) = data.(field)(ii, :);
            end
        end
        
        function out = needs_primary_data(self, varargin)
            fields = optargs(varargin, {'all'});
            out = self.needs_data(self.fieldstruct_primary, self.parent.primary, fields);            
        end
        
        function out = needs_secondary_data(self, varargin)
            fields = optargs(varargin, {'all'});
            out = self.needs_data(self.fieldstruct_secondary, self.parent.secondary, fields);            
        end
        
    end
    
    methods (Static, Access = private)
        function fargs = fieldargs(fieldstruct, coreparent)
            % determine from a fieldstruct what arguments to pass
            names = fieldnames(fieldstruct);
            fargs = {};
            k = 0;
            for i = 1:length(names)
                if ~isfield(fieldstruct.(names{i}), 'dataset') || ...
                        strcmp(fieldstruct.(names{i}).dataset.name, coreparent.name)
                    k = k + 1;
                    if isfield(fieldstruct.(names{i}), 'realname')
                        fargs{k} = fieldstruct.(names{i}).realname; %#ok<AGROW>
                    else
                        fargs{k} = names{i}; %#ok<AGROW>
                    end
                end
            end
        end
        
        function nm = get_realname_from_fieldstruct(nm)
            
        end
    end
    
    methods (Access = private)
        function out = needs_data(self, fs, parent, fields)
            % helper for needs_primary_data, needs_secondary_data
            all_fields = self.fieldargs(fs, parent);
            if isequal(fields, 'all')
                fields = all_fields;
            end
            out = ~isempty(intersect(all_fields, cellfun(@(X) safegetfield(self.members.(X), 'realname', X), fields, 'UniformOutput', false)));
        end           
            
        function args = arguments(self, fs, parent, fields)
                        
            fargs = self.fieldargs(fs, parent);
            if isequal(fields, 'all')
                args = fargs;
            else
                %args = intersect(cellfun(@(X) safegetfield(self.members.(X), 'realname', X), fields, 'UniformOutput', false), fargs);
                args = intersect(...
                    cellfun(...
                        @(X) safegetfield(self.members.(X), 'realname', X), ...
                        intersect(fieldnames(self.members), fields), ...
                        'UniformOutput', false), ...
                    fargs);
            end
        % cellfun(@(X) safegetfield(self.members.(X), 'realname', X), intersect(fields, fieldnames(self.members)), 'UniformOutput', false)
        end
    end
end
