classdef AssociatedPOESPlusCPR < FieldMultiInstrumentCopier
    % Add AMSU-A, HIRS to MHS-CPR
    %
    % WORK IN PROGRESS!
    
    % $Id: AssociatedPOESPlusCPR.m 8516 2013-06-26 21:33:48Z gerrit $
    
    properties (Transient)
                
        % For instruments sharing a platform with the primary
        %
        % FIXME DOC
        fieldcopier_other_primary = struct();
        
        % For instruments sharing a platform with the secondary
        %
        % FIXME DOC
        fieldcopier_other_secondary = struct();
        
%        members;
    end
    
    methods
        %% constructor
        
        function self = AssociatedPOESPlusCPR(pparent, f_mhs, f_amsua, f_hirs, f_cpr, varargin)
            % Create AssociatedPoesPlusCPR object
            %
            % IN
            %
            %   parent      either mhs_cpr or amsub_cpr
            %   f_mhs       struct      fields from MHS
            %   f_amsua     struct      fields from AMSUA
            %   f_hirs      struct      fields from HIRS
            %   f_cpr       struct      fields from CPR
            %
            % FIXME DOC
            
            %d = datasets;
            self = self@FieldMultiInstrumentCopier(pparent, {}, varargin{:});
            
            self.dynamic_members = true;
            
            self.parent = pparent;
            self.fieldcopier_core = FieldCopier(self.parent, f_mhs, f_cpr, 'name', [self.name '_sub_mhs_cpr'], 'visible', false);
            self.fieldcopier_other_primary.amsua = FieldCopier(self.parent, f_amsua, struct(), 'name', [self.name '_sub_amsua'], 'visible', false);
            self.fieldcopier_other_primary.hirs = FieldCopier(self.parent, f_hirs, struct(), 'name', [self.name '_sub_hirs'], 'visible', false);
            
            if length(fieldnames(self.members)) < (...
                    length(fieldnames(self.fieldcopier_other_primary.amsua.members)) + ...
                    length(fieldnames(self.fieldcopier_other_primary.hirs.members)) + ...
                    length(fieldnames(self.fieldcopier_core.members)))
                error(['amtlab:' mfilename], 'Duplicate fieldnames found!');
            end
            
            %            self.fieldstruct_mhs = f_mhs;
%            self.fieldstruct_amsua = f_amsua;
%            self.fieldstruct_hirs = f_hirs;
        end               
       
        %% overload parent methods
        
        function store(self, varargin)
            store@FieldMultiInstrumentCopier(self, varargin{:});
        end
        
    end
    
    methods (Access = protected)
        %% implementation of abstract methods
                
        function [newline, newpos] = translate(self, processed_core, data_orig, dsname, data_other)
                        
            origline = processed_core(:, self.parent.cols.LINE1);
            origpos = processed_core(:, self.parent.cols.POS1);

            if size(origline, 1)==0
                newline = origline;
                newpos = origpos;
                return
            end

            switch dsname
                case 'amsua'
                    [aah, aaw] = size(data_other.lon);
                    newline = min(max(round(origline/3), 1), aah);            
                    newpos = min(max(round(origpos/3), 1), aaw);
                case 'hirs'
                    newline = arrayfun(...
                        @(v) self.mini(abs(data_other.time-v)), ...
                        data_orig.time(origline));
                    newpos = arrayfun(...
                        @(i) self.mini(...
                        (data_other.lat(newline(i), :)-processed_core(i, self.parent.cols.LAT2)).^2 + ...
                        (data_other.lon(newline(i), :)-processed_core(i, self.parent.cols.LON2)).^2 ...
                        ), 1:size(processed_core, 1));
                otherwise
                    error(['atmlab:' mfilename ':sorry'], ...
                        'I don''t know what to do with %s', dsname);
            end

        end
    end
    
    methods (Access = {?HomemadeDataset})
        function mem = dynamically_get_members(self)
%            logtext(atmlab('OUT'), 'Getting APPC-mems\n');
            % FIXME! This should be better implemented.  This wastes a HUGE
            % amount of time!
            mem = catstruct(self.fieldcopier_core.members, ...
                self.fieldcopier_other_primary.amsua.members, ...
                self.fieldcopier_other_primary.hirs.members);
%             mem = self.members;
        end
    end
    
    methods (Static, Access = private)
        function i = mini(v)
            % mini return index for minimum of v (arrayfun wants 1 output)
            [~, i] = min(v);
        end
    end

end
