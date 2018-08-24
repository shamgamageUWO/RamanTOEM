classdef FieldMultiInstrumentCopier < AssociatedDataset
    % Add others
    %
    % This class is for getting fields from other instruments on the same
    % satellite that do not have the same resolution but do have a 1-to-1
    % relation with the instrument originally used for collocating.
    % An example is to collocate with mhs, then get hirs and amsu-a.
    % This does not apply if there are several instruments or datasets
    % with exactly the same footprints; in this case, one should use an
    % ordinary FieldCopier and use siblings instead.
    %
    % This is an abstract class. One implementation is
    % <a href="matlab:help AssociatedPOESPlusCPR">AssociatedPOESPlusCPR</a>.
    %
    % WORK IN PROGRESS
    %
    % FIXME DOC
    
    % $Id: FieldMultiInstrumentCopier.m 8720 2013-10-21 20:41:39Z gerrit $
    
    properties (Transient, Abstract)
                
        % For instruments sharing a platform with the primary
        %
        % FIXME DOC
        fieldcopier_other_primary
        
        % For instruments sharing a platform with the secondary
        %
        % FIXME DOC
        fieldcopier_other_secondary

    end
    
    
    properties (Transient)
        % This is for fields that are copied from the core
        %
        % FIXME DOC
        fieldcopier_core
        
        
        % FIXME DOC
        fieldstruct_other
    end
    
    
    properties (Transient, SetAccess = protected)
        %members
        parent
        dependencies
    end
        
    methods (Abstract, Access = protected)
        % FIXME DOC
        [newline, newpos] = translate(self, processed_core, data_orig, dsname, data_other)
    end
    
    methods
        %% constructor
        
         function self = FieldMultiInstrumentCopier(varargin)
             self = self@AssociatedDataset(varargin{:});
%             if isempty(self.members)
%                 self.members = struct(); % temporary default
%             end
         end
    end
    
    methods (Access = {?SatDataset})
        
        %% implementation of abstract methods
        
        function args = primary_arguments(self, varargin)
            args = self.fieldcopier_core.primary_arguments(varargin{:});
        end
        
        function args = secondary_arguments(self, varargin)
            args = self.fieldcopier_core.secondary_arguments(varargin{:});
        end
        
        function bool = needs_primary_data(self, varargin)
            fields = optargs(varargin, {'all'});
            if isequal(fields, 'all')
                bool = self.fieldcopier_core.needs_primary_data(fields);
            else
                bool = self.fieldcopier_core.needs_primary_data(...
                    intersect(fieldnames(self.fieldcopier_core.members), fields));
            end
        end
        
        function bool = needs_secondary_data(self, varargin)
            fields = optargs(varargin, {'all'});
            if isequal(fields, 'all')
                bool = self.fieldcopier_core.needs_secondary_data(fields);
            else
                bool = self.fieldcopier_core.needs_secondary_data(...
                    intersect(fieldnames(self.fieldcopier_core.members), fields));
            end
        end
        
        function fields = fields_needed_for_dependency(~, ~, ~)
            fields = {}; % no dependencies
        end
        
        function [out, localcols] = process_granule(self, processed_core, data1, date1, spec1, data2, date2, spec2, dependencies, depcols, fields)
            D = datasets();
            
            %% copy fields for original instruments
            
            if isequal(fields, 'all')
                fields_core = fieldnames(self.fieldcopier_core.members);
            else
                fields_core = intersect(fieldnames(self.fieldcopier_core.members), fields);
            end
            [out_core, core_fc_cols] = self.fieldcopier_core.process_granule(...
                processed_core, data1, date1, spec1, data2, date2, spec2, ...
                dependencies, depcols, fields_core);
            if isequal(fields, 'all')
                assert(isequal(self.fieldcopier_core.cols, core_fc_cols), ...
                    ['atmlab:' mfilename ':wrongcols'], ...
                    'Bug in cols :(');
                fields = fieldnames(self.members);
            end
            allmembers = self.fieldcopier_core.members;
            
            %% get fields for other instruments on primary
            
            % (ab)use a FieldCopier also for other instruments on primary
            % by editing processed_core and putting in the line/pos for the
            % other instruments instead of the original ones
            % the abstract method 'translate' is responsible for actually
            % performing this conversion
            
            modes = {'primary', 'secondary'};

            for k = 1:length(modes)
                m = modes{k};
                
                other_instruments{k} = fieldnames(self.(['fieldcopier_other_' m]));
                out_other{k} = {};
                
                switch m
                    % sometimes it's the primary where other instruments
                    % are considered, sometimes it's the secondary. Prepare
                    % all that's differente here to avoid code-repetition
                    % later.
                    case 'primary'
                        data_orig = data1;
                        date = date1;
                        spec = spec1;
                        line_i = self.parent.cols.LINE1;
                        pos_i = self.parent.cols.POS1;
                        fc_other = self.fieldcopier_other_primary;
                        arg_i_other = 2;
                    case 'secondary'
                        data_orig = data2;
                        date = date2;
                        spec = spec2;
                        line_i = self.parent.cols.LINE2;
                        pos_i = self.parent.cols.POS2;
                        fc_other = self.fieldcopier_other_secondary;
                        arg_i_other = 5;
                    otherwise
                        error('BUG! CRASH! This place ought to be unreachable!');
                end
                
                for i = 1:length(other_instruments{k})
                    other_instrument = other_instruments{k}{i};
                    %fields_from_other_instrument = intersect(fields, fieldnames(fc_other.(other_instrument).members));
                    fields_from_other_instrument = cellfun(@(X) safegetfield(fc_other.(other_instrument).members.(X), 'realname', X), intersect(fields, fieldnames(fc_other.(other_instrument).members)), 'UniformOutput', false);
                    if isempty(fields_from_other_instrument)
                        logtext(atmlab('OUT'), 'No need for %s this time\n', other_instrument);
                        continue
                    end
                    logtext(atmlab('OUT'), 'Also taking same-satellite instrument %s\n', ...
                        other_instrument);
                    try
                        % do not remove duplicates
                        data_other = D.(other_instrument).read_granule(date, spec, fields_from_other_instrument, false);
                    catch ME
                        switch ME.identifier
                            case {'atmlab:invalid_data'}
                                logtext(atmlab('ERR'), 'Unable to read %s data, skipping and setting filler values\n', ...
                                    other_instrument);
                                % return something of the right width
                                flds = fieldnames(fc_other.(other_instrument).members);
                                nrows = size(processed_core, 1);

                                for fi = 1:length(flds)
                                    fld = flds{fi};
                                    if ~isfield(fc_other.(other_instrument).members.(fld).atts, 'missing_value')
                                        error(['atmlab:' mfilename ':missingmissing'], ...
                                            ['Could not find %s.members.%s.atts.missing_value. ' ...
                                             'Please define, I need this as a filler (see above).' ...
                                             'Missing for the following fields: %s'], ...
                                            fc_other.(other_instrument).name, fld, ...
                                            sprintf('%s ', flds{cellfun(@(x) ~isfield(fc_other.(other_instrument).members.(x).atts, 'missing_value'), flds)}));
                                    end
                                    out_other{k}{i}(1:nrows, fc_other.(other_instrument).cols.(fld)) = ...
                                        fc_other.(other_instrument).members.(fld).atts.missing_value;
                                end
%                                 hasdim = structfun(@(x)(isfield(x, 'dims')), fc_other.(other_instrument).members);
%                                 sz_singles = sum(~hasdim);
%                                 sz_multid = sum(cellfun(@(x)(fc_other.(other_instrument).members.(x).dims{2}), flds(hasdim)));
%                                 ncols = sz_singles + sz_multid;
                                %nrows = size(processed_core, 1);
%                                 out_other{k}{i} = nan*zeros(nrows, ncols); %#ok<AGROW>
                                continue;
                            otherwise
                                ME.rethrow();
                        end
                    end
                    pc_other = processed_core;
                
                    
                    [other_line, other_pos] = self.translate(processed_core, data_orig, other_instrument, data_other);
                
                    pc_other(:, line_i) = other_line;
                    pc_other(:, pos_i) = other_pos;
       
                    % FieldCopier's process_granule also sets 'cols'-structure
                    args = {pc_other, data1, date1, spec1, data2, spec2, dependencies, depcols, fields_from_other_instrument};
                    args{arg_i_other} = data_other;
                    [out_other{k}{i}, cols_other{k}{i}] = fc_other.(other_instrument).process_granule(args{:}); %#ok<AGROW>
                   
%                    allmembers = catstruct(allmembers, fc_other.(other_instrument).members);
                end
            end
                   
            % merge matrices and cols-structures appropiately
            out = out_core;
            newcols = core_fc_cols;
            for k = 1:length(modes)
                %m = modes{k};
                for i = 1:length(out_other{k})
                    %[out, newcols] = self.merge_matrix(out, newcols, out_other{k}{i}, self.(['fieldcopier_other_' m]).(other_instruments{k}{i}).cols);
                    [out, newcols] = self.merge_matrix(out, newcols, out_other{k}{i}, cols_other{k}{i});

                end
            end
%            self.cols = newcols;
%            self.members = allmembers;
            localcols = newcols;
        end
    end
end
