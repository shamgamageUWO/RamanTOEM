classdef RetrievalDatabaseProduct < HomemadeDataset
    % base class for any product based on some atmospheric DB
    %
    % Subclasses may be NN-based, MCI-based, etc.
    %
    % See also: NNTrainedProduct, IceMusicNNIWP, InstrumentVisualiser
    
    properties
        
        % data means different things for different implementations.
        % e.g. for ANN, it's training data
        % for MCI, it's the database used in retrievals; even if these
        % classes don't retrieve, it's still of interest for reference
        data
        ice_axis;
        localcols
        selection
        
%        chans
        
        chanstr
        freqstr
    end
    
    
    properties (Abstract, Constant)
        chans
        freqs
    end
    
    methods (Abstract)
        % set self.data, self.localcols
        
        [x, y] = evaluate_test_data(self, noise_level)
        
        getdata(self, varargin)
    end
    
    methods
        function self = RetrievalDatabaseProduct(varargin)
            self = self@HomemadeDataset(varargin{:});
            
            self.freqstr = sprintf('%s ', self.freqs{self.chans});
            self.chanstr = sprintf('%d', self.chans);
            
        end
         
        function limit_data(self)
            % sets self.selection to list of indices
            lims = struct();
            for fnc = fieldnames(self.targets)
                fn = fnc{1};
                if isfield(self.targets.(fn), 'lims')
                    lims.(fn) = self.targets.(fn).lims;
                end
            end
            
            idx = collocation_restrain(self.data, limstruct2limmat(lims, self.localcols));
            
            % convert from logical to list-of-indices so I can more easily
            % sub-sample it
            %
            % 2013-06-12: stop this, just set trainInd directly instead
            
            idx = find(idx);
% 
%             if length(idx) > self.maxsize
%                 logtext(atmlab('OUT'), 'Reducing %d -> %d points\n', length(idx), self.maxsize);
%                 self.selection = idx(unique(round(linspace(1, length(idx), self.maxsize))));
%             else
                self.selection = idx;
%             end
        end            
        
        function [h_ax, h_cb] = plot_scatter_perf(self, x, y)
            
            %            freqstr = sprintf('%s ', self.freqs{self.chans});
            %            chanstr = sprintf('%d', self.chans);
            
            %           filt = (x>0) & (y>0) & isfinite(x) & isfinite(y);
            % build options-structure for scatter_density_plot
            op = self.opts;
            op.scatprops = []; % no scatter
            [h_ax, h_cb] = scatter_density_plot(x, y, op);
            
        end
        
    end
    
    methods (Static)
        function perf = binned_median_fractional_error(x, y, bins)
            % median fractional error
            perf = cellfun(@median, bin(log10(x), abs(y-x)./x, bins));
        end
        
        function perf = binned_mad(x, y, bins)
            % binned median absolute distance
            % see also: mad
            perf = cellfun(@(xx) mad(xx, 1), bin(log10(x), y, bins));
        end
    end
    
    
    methods (Static, Access = protected)
                
        function [y, newcols] = select_and_prepare_data(dat, cols, S, homog)
            % select and transform fields
            %
            % IN
            %
            %   dat     matrix, typically single or double
            %   cols    structure describing columns of matrix
            %   S       structure with fields to be selected, each field
            %           must have a 'transform' member that is a function
            %           to be applied, or a 'process' member with
            %           {function, input_structures}
            %   homog   homogenise input, yes or no
            %
            % OUT
            %
            %   y       new data
            %   newcols correspondings cols
            
            fields = fieldnames(S);
            newcols = struct();
            %y = zeros(sum(cellfun(@(X) length(cols.(X)), fields)), size(dat, 1), class(dat));
            y = zeros(0, size(dat, 1), class(dat));
            i = 1;
            for k = 1:length(fields)
                fn = fields{k};
                %colrange = i:((i+length(cols.(fn)))-1);
                % the user may want to input something to the neural
                % network that is actually a combination of other fields,
                % such as the difference between two fields.  To do so,
                % they create 'process' which contains {processor(x, y),
                % {struct_for_x, struct_for_y}} as a value.
                if isfield(S.(fn), 'process') 
                    proc_input_names = fieldnames(S.(fn).process{2});
                    proc_inputs = cell(size(proc_input_names));
                    for n=1:length(proc_input_names)
                        name = proc_input_names{n};
                        srccols = cols.(name);
                        if isfield(S.(fn).process{2}.(name), 'chans')
                            srccols = srccols(S.(fn).process{2}.(name).chans);
                        end
                        proc_inputs{n} = S.(fn).process{2}.(name).transform(dat(:, srccols));
                    end
                    field_data = S.(fn).process{1}(proc_inputs{:});
                    if isfield(S.(fn), 'transform')
                        field_data = S.(fn).transform(field_data);
                    end
                    colrange = i:(i+min(size(field_data))-1);
                    y(colrange, :) = field_data.';
                    i = i + length(colrange);    
                    newcols.(fn) = colrange;
                else
                    srccols = cols.(fn);
                    if isfield(S.(fn), 'chans') && length(S.(fn).chans) < length(srccols)
                        %colrange = colrange(S.(fn).chans);
                        srccols = srccols(S.(fn).chans);
                    end
                    colrange = i:(i+length(srccols)-1);
                    newcols.(fn) = colrange;
                    y(colrange, :) = S.(fn).transform(dat(:, srccols)).';
                    i = i + length(colrange);
                end
            end
        end
                
    end
end
