classdef AssociatedDataset < HomemadeDataset
    % Defines data associated with CollocatedDataset
    %
    % The data stored with a <a href="matlab:help CollocatedDataset">CollocatedDataset</a> is only the
    % very core needed to retrieve collocations. Any other data needs to be
    % stored by using one or more AssociatedDataset objects.
    %
    % Classes derived from AssociatedDataset describe datasets with data
    % associated with <a href="matlab:help CollocatedDataset">CollocatedDataset</a>s.
    % The class AssociatedDataset itself is an abstract class, and can
    % therefore not be instantianed directly. However, it may be subclassed
    % for the implementation of an arbitrary AssociatedDataset.
    % Full implementations of AssociatedDataset that come with atmlab are
    % <a href="matlab:help FieldCopier">FieldCopier</a> and <a
    % href="matlab:help Collapser">Collapser</a>.
    %
    % The properties and methods are documented here, because subclasses
    % provide mere implementations; the signature does not change.
    %
    % AssociatedDataset Properties:
    %
    %  abstract properties:
    %
    %   members -       Describes how data are stored in NetCDF
    %   parent -        SatDataset that this AssociatedDataset belongs to
    %   dependencies -  Other AssociatedDataset that must be processed first
    %
    %  (remaining properties from <a href="matlab:help HomemadeDataset">HomemadeDataset</a>)
    %
    % AssociatedDataset Methods: (partial overview)
    %
    %  Constructor:
    %
    %   AssociatedDataset -     Create AssociatedDataset object
    %  
    %  Abstract methods:
    %
    %   primary_arguments -     Get args for primary reader
    %   secondary_arguments -   Get args for secondary reader
    %   needs_primary_data -    Need data from primary?
    %   needs_secondary_data -  Need data from secondary?
    %   process_granule -       Process a single granule
    %
    %  Implemented methods:
    %
    %   process_delayed -       Process data when core read from disk
    %   merge -                 Combine core and associated
    %   get_mergefields -       Return fields needed to merge
    %   concatenate -           Vertically concatenate data
    %
    %  (remaining methods from <a href="matlab:help HomemadeDataset">HomemadeDataset</a>)
    %
    %  See also: FieldCopier (implementation), Collapser (implementation),
    %            HomemadeDataset (superclass), CollocatedDataset, SatDataset.
    %   
    % $Id: AssociatedDataset.m 8516 2013-06-26 21:33:48Z gerrit $
    
    % need to know:
    % - additional arguments to reader primary
    % - additional arguments to reader secondary
            
    properties (Transient, Abstract, SetAccess = protected)
        % Describes how data are stored in NetCDF files
        %
        % This property gives a full description of how data are stored in
        % NetCDF files. The value of the property may be different for
        % different instances (objects) of any subclass, so the property
        % has no predefined value (unlike <a href="matlab:help CollocatedDataset/members">CollocatedDataset.members</a>).
        %members;
        % Parent dataset that this AssociatedDataset is associated with
        %
        % Pointing to a <a href="matlab:help CollocatedDataset">CollocatedDataset</a>,
        % this property describes what the AssociatedDataset relates to.
        parent;
        % Other AssociatedDatasets that need to be considered first.
        %
        % Contains a collection of other AssociatedDataset objects that
        % need to be considered first. For example, to process a
        % <a href="matlab:help Collapser">Collapser</a>, one first needs a <a href="matlab:help FieldCopier">FieldCopier</a>.
        %
        % See also method fields_needed_for_dependency.
        dependencies;
    end
    
    properties (Transient)
        % priority is dynamically set when sorting for dependencies
        priority = 0;
    end
    
    methods
        %% constructor
        
        function self = AssociatedDataset(varargin)
            % constructor for AssociatedDataset
            %
            % Note that AssociatedDataset can not be constructed, but some
            % sub-classes may be. In the examples below the class is called
            % AssociatedDataset, but replace this by whatever class you are
            % using to construct your object.
            %
            % FORMAT
            %
            %   ad = AssociatedDataset(cd, ...)
            %
            % IN
            %
            %   cd  CollocatedDataset
            %
            %       This argument is only present for dynamic subclasses,
            %       such as <a href="matlab:help FieldCopier">FieldCopier</a>.
            %       Contains <a href="matlab:help CollocatedDataset">CollocatedDataset</a> to which this
            %       AssociatedDataset belongs.
            %
            %   dp  cell array
            %
            %       This arguments is only present for dynamic subclasses.
            %       Cell array of other AssociatedDataset objects on which
            %       this AssociatedDataset depends, e.g., that have to be
            %       calculated first.
            %   
            % Remaining arguments passed on to parent. For static
            % subclasses, all arguments are directly passed on to the
            % parent.
            %
            % OUT
            %
            %   AssociatedDataset-derived object.
            if nargin>0 && isa(varargin{1}, 'CollocatedDataset') % dynamic style
                style = 'dynamic';
                cd = varargin{1};
                dp = varargin{2};
                [subargs{1:nargin-2}] = varargin{3:end};
            else
                style = 'static';
                [subargs{1:nargin}] = varargin{:};
            end
            self = self@HomemadeDataset(subargs{:}); % call parent constructor
            if strcmp(style, 'dynamic')
                self.parent = cd;
                self.dependencies = dp;
            end
            if self.visible
                self.parent.add_associated(self);
            end
        end
        
        %% implement new methods
        
        function [M, M_cols] = merge_matrix(self, M_core, cols_core, M_self, cols_self)
            % horizontally combine core and associated
            %
            % Combine core data, core 'cols', associated data and
            % associated 'cols'.  This may or may not be trivial depending
            % on the actual data.  If more than two matrices need to be
            % merged, apply this method iteratively.
            %
            % FORMAT
            %
            %   [M_new, M_cols] = ad.merge_matrix(M_core, cols_core, M_here, cols_here)
            %
            % IN
            %
            %   M_core      matrix      selection from core collocations
            %   cols_core   structure   structure describing M_core
            %   M_here      matrix      selection of associated data
            %   cols_here   structure   structure describing M_here
            %
            % OUT
            %
            %   M_new       matrix      combination M_core, M_here
            %   cols_new    structure   structure describing M_new
            
            M = [M_core M_self];
            M_cols = self.merge_new_cols(M_core, cols_core, cols_self);
        end
        
    end
    
    methods (Access = {?SatDataset})
        %% implement new methods
        
        function [out, localcols] = process_delayed(self, processed_core, spec1, spec2, varargin)
            % process associated data when core data is already there
            %
            % Sometimes, core collocations already exist, but one or more
            % associated datasets do not exist yet. This method, that is
            % not designed to be called directly by the end user, takes
            % care of this.
            %
            % This method just splits a day of collocations into segments
            % and passes each segment to <a href="matlab:help AssociatedDataset/process_granule">process_granule</a>.
            % That's where the actual processing is done, and for
            % process_granule there is no difference between processing
            % directly and processing later.
            %
            % FORMAT
            %
            %   out = ad.process_delayed(processed_core, spec1, spec2[, depies])
            %
            % IN
            %   
            %   processed_core      matrix
            %
            %       Matrix with processed core collocation data. The
            %       columns are described by self.parent.cols.
            %
            %   spec1               various     sat (or so) for primary
            %   spec2               various     sat (or so) for secondary
            %   depies              cell array
            %
            %       Contains output for all previous dependencies.
            %
            %   depcols             cell array
            %
            %       Contains column-descriptions for depies
            %
            %   fields              cell array or 'all'
            %
            %       Contains fields that are to be processed.
            %
            % OUT
            %
            %   out                 matrix
            %
            %       Data matrix with columns described by self.cols
            %
            %   localcols           structure, describes columns of 'out'
 
            [depies, depcols, fields] = optargs(varargin, {{}, {}, 'all'});
            % data checks
            errid = ['atmlab:' mfilename ':InvalidFormat'];
            errmes = ['Data are not properly sorted: %s %s field %s has descending elements.  ' ...
                      'One possible cause is that %s %s granule N is entirely contained ' ...
                      'in preceding granule N-1, but that granule N was not present ' ...
                      'when the firstline-db was generated for %s %s, although it was ' ...
                      'present when %s %s was generated.  This means that granule N as collocated really ' ...
                      'is mostly duplicates of N-1, resulting in the secondary potentially going ' ...
                      '''back in time'' for the collocations.  This problem is detected ' ...
                      'if additionals are obtained seperately.  The solution is ' ...
                      'to rerun find_granule_first_line for %s %s for today, and then ' ...
                      'redo collocations for %s %s for the entire day.'];
            assert(all(diff(processed_core(:, self.parent.cols.START1))>=0), ...
                errid, errmes, ...
                class(self.parent), self.parent.name, 'START1', ...
                class(self.parent.primary), self.parent.primary.name, ...
                class(self.parent.primary), self.parent.primary.name, ...
                class(self.parent), self.parent.name, ...
                class(self.parent.primary), self.parent.primary.name, ...
                class(self.parent), self.parent.name);
            assert(all(diff(processed_core(:, self.parent.cols.START2))>=0), ...
                errid, errmes, ...
                class(self.parent), self.parent.name, 'START2', ...
                class(self.parent.primary), self.parent.primary.name, ...
                class(self.parent.primary), self.parent.primary.name, ...
                class(self.parent), self.parent.name, ...
                class(self.parent.primary), self.parent.primary.name, ...
                class(self.parent), self.parent.name);
            % divide in segments where new primary, new secondary starts
            [~, newprim] = unique(processed_core(:, self.parent.cols.START1), 'rows', 'first');
            [~, newsec] = unique(processed_core(:, self.parent.cols.START2), 'rows', 'first');
            % also add 'end' to it, because want to determine segments
            newseg = unique([newprim; newsec]);
            % empty data-structs are all I pass to processors not needing
            % data
            data1 = struct();
            data2 = struct();
            primseg = 0;
            seconseg = 0;
            out = [];
            
            logtext(atmlab('OUT'), 'Processing %d segments\n', length(newseg));
            for segcount = 1:length(newseg)
                logtext(atmlab('OUT'), 'Processing segment %d/%d\n', segcount, length(newseg));
                segstart = newseg(segcount);
                % end of segment: either beginning of next, or end of data
                if segcount < length(newseg)
                    segend = newseg(segcount+1)-1;
                else
                    segend = size(processed_core, 1);
                end
                % keep track of 'primary segment' and 'secondary segment'
                % to know corresponding date1, data1, etc.
                if primseg<length(newprim) && segstart == newprim(primseg+1)
                    primseg = primseg + 1;
                    [dv{1:6}] = unixsecs2date(processed_core(newprim(primseg), self.parent.cols.START1));
                    date1 = cell2mat(dv);
                    if self.needs_primary_data(fields)
                        data1 = self.parent.primary.read_granule(date1, spec1, self.primary_arguments(fields), false, false);
                    end
                end
                if seconseg<length(newsec) && segstart == newsec(seconseg+1)
                    seconseg = seconseg + 1;
                    [dv{1:6}] = unixsecs2date(processed_core(newsec(seconseg), self.parent.cols.START2));
                    date2 = cell2mat(dv);
                    if self.needs_secondary_data(fields)
                        try
                            data2 = self.parent.secondary.read_granule(date2, spec2, self.secondary_arguments(fields), false, false);
                        catch ME
                            switch ME.identifier
                                case {'atmlab:SatDataset:cannotread', 'atmlab:find_granule_by_datetime'}
                                    ME2 = MException('atmlab:AssociatedDataset:cannolongerread', ...
                                        ['%s %s trying to postprocess %s %s, in the past could read ' ...
                                         '%s %s, but no longer :('], ...
                                         class(self), self.name, class(self.parent.secondary), self.parent.secondary.name, ...
                                         num2str(date2), spec2);
                                    ME2 = ME2.addCause(ME);
                                    ME2.throw();
                                otherwise
                                    ME.rethrow();
                            end
                        end
                    end
                end
                %                 if local_success
                depies_seg = cellfun(@(X)X(segstart:segend, :), depies, 'UniformOutput', false);
                [new_out, localcols] = self.process_granule(...
                    processed_core(segstart:segend, :), data1, date1, ...
                    spec1, data2, date2, spec2, depies_seg, depcols, ...
                    fields);
                %                 else
                %                     new_out = nan * zeros(length(rows), length(cls));
                %                 end
                if isempty(out)
                    out = new_out;
                else
                    out = [out; new_out]; %#ok<AGROW>
                end
            end
        end
                
        
        function S = merge_struct(self, S_core, S_self)
            % merge structures as obtained from read_homemade_granule
            %
            % In most cases this is a simple structure-concatenation, but
            % for Collapsers and some other AssociatedDatasets it's more
            % involved.
            
            % Note: this uses undocumented behaviour
            status = warning('error', 'catstruct:DuplicatesFound');
            S = catstruct(S_core, S_self);
            warning(status);
        end
        
        function C = get_mergefields(self) %#ok<MANU>
            % Get minimum fields required to do merging
            %
            % In some cases, <a href="matlab:help AssociatedDataset/merge">merge</a> requires a certain minimum
            % of fields in order to perform the merging. This method
            % returns the minimum for a particular object (usually constant
            % per class).
            %
            % FORMAT
            %
            %   C = ad.get_mergefields();
            %
            % IN
            %
            %   (none)
            %
            % OUT
            %
            %   C       cell array of strings   names of needed fields
            %
            C = {};
        end       
        
        function new = concatenate(self, old_core_result, old_additional_result, new_additional_result)
            % to concatenate old and new data matrices
            %
            % To concatenate old and new data matrices, sometimes some
            % fields need to be corrected, otherwise this is trivial.
            % However, always use this method to concatenate data, just in
            % case date have to be corrected. An example where this is
            % necessary is for a <a href="matlab:help Collapser">Collapser</a>, where FIRST and LAST need to be
            % corrected.
            %
            % FORMAT
            %
            %   new = ad.concatenate(old_core, old_addi, new_addi)
            %
            % IN
            %
            %   old_core    matrix      old core result
            %   old_addi    matrix      old additional result
            %   new_addi    matrix      new additional result
            %
            % OUT
            %
            %   new         matrix      concatenated additional result
            if isempty(new_additional_result)
                new = old_additional_result;
            elseif isempty(old_additional_result)
                new = new_additional_result;
            else
                new = [old_additional_result; new_additional_result];
            end
        end
        
        function members2cols(self)
            % converts self.members to corresponding self.cols
            %
            % Assumes sizes in self.members are correct. This may not
            % always be the case before the first data is read!
            % This has no input or output, because it operates entirely on
            % the own object.
            %
            % FORMAT
            %
            %   ad.members2cols()
            %
            % IN
            %
            %   (none, but uses <a href="matlab:help AssociatedDataset.members">members</a>)
            %
            % OUT
            %
            %   (none, but sets <a href="matlab:help AssociatedDataset.cols">cols</a>)
            allnames = fieldnames(self.members);
            tot = 1;
            for i = 1:length(allnames)
                fname = allnames{i};
                fl = self.members.(fname);
                if isfield(fl, 'dims')
                    no = self.members.(fname).dims{2};
                else
                    no = 1;
                end
                % self.cols is in HomemadeDataset
                self.cols.(fname) = tot:(tot+no-1);
                tot = tot + no;
            end
        end
        
    end
    
    methods (Static, Access = {?SatDataset})       
        function M_cols = merge_new_cols(M_core, cols_core, cols_self)
            % merge different cols-structures describing matrix of data
            %
            % This static method merges two cols-structure that describe a
            % matrix of data.
            %
            % FORMAT
            %
            %   cols_new = merge_new_cols(M, cols_core, cols_self)
            %
            % IN
            %
            %   M           matrix      original data
            %   cols_core   structure   describing M
            %   cols_self   structure   describing new
            %
            % OUT
            %
            %   M_cols      matrix      new structure describing merged
            
            M_cols = catstruct(cols_core, ...
                structfun(@(x)x+size(M_core, 2), cols_self, 'UniformOutput', false));
        end
        
        function do = redo_all(~)
            % redo_all(software_version)
            %
            % overload and return true if some changes require that a
            % dataset must be overwritten (overwrite=1) even if requested
            % to be appended (overwrite=2)
            do = false;
        end
    end
    
    % those methods must be implemented by subclasses
    methods (Abstract, Access = {?SatDataset})
        % Arguments to pass on to primary reader
        %
        % This method returns a cell array with arguments that shall be
        % passed on to the primary reader.
        %
        % FORMAT
        %
        %   args = ad.primary_arguments(fields)
        %
        % IN
        %
        %   cell array of strings with fields or 'all' (default)
        %
        % OUT
        %
        %   cell array with arguments passed on to primary reader.
        args = primary_arguments(self, varargin)
        
        % Arguments to pass on to secondary reader
        %
        % See <a href="matlab:help AssociatedDataset/primary_arguments">primary_arguments</a>.
        args = secondary_arguments(self, varargin)
        
        % Whether primary data is used at all.
        %
        % This method is used in 'late' processing, e.g. when the
        % collocations already exist, but associated data does not. For
        % late processing, not all original data may need to be re-read.
        % This method tells whether the primary data should be re-read.
        %
        % FORMAT
        %
        %   reread = ad.needs_primary_data('all')
        %
        % IN
        %
        %   optionally, cell array of strings with fields; defaults to
        %   'all'
        %
        % OUT
        %
        %   logical scalar (boolean), true if data must be reread
        bool = needs_primary_data(self, varargin)
        
        % Whether secondary data is used at all
        %
        % See <a href="matlab:help AssociatedDataset/needs_primary_data">needs_primary_data</a>.
        bool = needs_secondary_data(self, varargin)

        % Process a single granule
        %
        % This is the core method for any AssociatedDataset implementation.
        % It takes collocations as <a href="matlab:help CollocatedDataset/process">processed</a> by a <a href="matlab:help CollocatedDataset">CollocatedDataset</a>,
        % as well as original data from the primary and the secondary (if
        % so requested by <a href="matlab:help AssociatedDataset.needs_primary_data">needs_primary_data</a> and <a href="matlab:help AssociatedDataset.needs_secondary_data">needs_secondary_data</a>).
        % It then does the necessary processing (such as copying in the
        % case of <a href="matlab:help FieldCopier">FieldCopier</a>).
        % It must also set self.cols correctly.
        %
        % This method is not normally called directly by the user. However,
        % it is to me re-implemented in any special-purpose
        % AssociatedDataset.
        %
        % FORMAT
        %
        %   out = ad.process_granule(processed_core, ...
        %               data1, date1, spec1, ...
        %               data2, date2, spec2, ...
        %               dependencies)
        %
        % IN
        %
        %   processed_core  matrix
        %
        %       matrix with one row for each collocation and columns
        %       described by <a href="matlab:help CollocatedDataset/cols">CollocatedDataset.cols</a>.
        %       This is the output of <a href="matlab:help CollocatedDataset/process">CollocatedDataset.process</a>.
        %
        %   data1           structure
        %
        %       Full data for the primary, as output by the primary reader.
        %
        %   date1           datevec     date/time for primary granule
        %   spec1           various     specification (e.g. sat) for primary.
        %   data2           like data1, but for secondary
        %   date2           like date1, but for secondary
        %   spec2           like spec1, but for secondary
        %
        %   dependencies    cell array
        %
        %       Cell array with elements corresponding to
        %       <a href="matlab:AssociatedDataset.dependencies">AssociatedDataset.dependencies</a>. For each
        %       dependency, this cell array contains an element with the
        %       output of the process_granule method for that particular
        %       <a href="matlab:help AssociatedDataset">AssociatedDataset</a>. For example, for a <a href="matlab:help Collapser">Collapser</a>
        %       it will contain a single element with the output of
        %       FieldCopier.process_granule.
        %
        %   depcols         cell array of structures describing columns of
        %                   dependencies
        %
        %   fields          cell array
        %
        %       Fields to process.  'all' for all fields (only way until
        %       recently)
        %
        %  OUT
        %
        %   data        Matrix containing data
        %
        %   localcols   Cols describing columns.  If all fields, this is
        %               simply self.cols.
        [out, localcols] = process_granule(self, processed_core, data1, date1, spec1, data2, date2, spec2, dependencies, depcols, fields)
        %store(self, date, spec, result)
        
        fields = fields_needed_for_dependency(self, fields, dependency)
    end
    
end
