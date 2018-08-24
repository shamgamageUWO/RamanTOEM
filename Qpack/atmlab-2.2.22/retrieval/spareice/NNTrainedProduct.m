classdef NNTrainedProduct < RetrievalDatabaseProduct
    % base class for any ANN-trained product
    %
    % NNTrainedProduct properties:
    %
    %   targets - fields to be used as training targets
    %
    % NNTrainedProduct Methods:
    %
    %   make_and_train_network - 
    %   loadnet - 
    %   storenet - 
    %   evaluate_test_data - 
    %   evaluate_and_summarise_testdata - 
    %
    % See also: RetrievalDatabaseProduct, IceMusicNNIWP, CollocatedNNIWP,
    % compare_ice_retrievals, compare_collocated_iwp_products,
    % InstrumentVisualiser
    
    % Changes in SPARE-ICE:
    %
    % version 0.1: fixed bug in storage P_CLOUD: should be float, not int
    % version 0.2: fixed bug in lacking filtering for various flagged values
    % version 0.3: added surface elevation
    % version 0.4: set surface elevation to 0 if z<0
    % version 0.5: include some measure of std.dev of z
    % version 0.5b: fixed re-introduced bug lacking filtering, new network
    % version 0.6: use less info for patternnet than for fitnet
    % version 0.7: add corrected meta-info
    % version 0.8:
   
    properties
        %selection
        
        net
        trdat
                
        % options for plotting scatter-plot
        opts = struct('trans', @(x)log10(x), ...
           'invtrans', @(x)10.^(x), ...
           'axprops', struct(...
                'xscale', 'log', ...
                'yscale', 'log', ...
                'xgrid', 'on', ...
                'xminorgrid', 'off', ...
                'ygrid', 'on', ...
                'yminorgrid', 'off'), ...
           'bins', linspace(-1, 4, 50), ...
           'medprops', struct('LineWidth', 2, 'LineStyle', '-', 'Color', [0 0 0]), ...
           'diagonal', struct('LineWidth', 1, 'LineStyle', ':', 'Color', [0 0 0]))

%        chanstr;
%        freqstr;

        % hackish way; if an earlier version of the product had what's
        % needed, don't need to recollocate
        altfilename;
        altbasedir;
        
        % different versions with different network paths.
        % may be set to cell array of strings.
        networks;        
        
        % to homog or not to homog, that is the question
        homog;
    end
    
    properties (Abstract)
        % How many entries to use at most in the training?  If you have
        % more data, the rest will go into the testing data.  The data in
        % maxsize will be divided between training and validation.
        maxsize
        
        % Structure with one field for each target.
        % Must have:
        %   - transform     transformation to apply, i.e. log10
        %   - invtransform  inverse therefor, i.e. @(x)10.^x
        %   - lims          limits to apply before doing anything
        % May have:
        %   - classify        Also train a classification net with this as
        %                     the cloudy/cloudfree cutoff.
        %   - bins            Default bins over which to do statistics.
        %   - relevant        Minimum x-value to consider in bestnet.
        %   - optimise_field  What field (as returned by get_performance)
        %                     to optimise for in 'bestnet'.
        %
        % targets.IWP.transform = @log10
        % targets.IWP.invtransform = @(x)10.^(x)
        % targets.IWP.lims = [realmin realbax]
        % targets.IWP.classify = 10;
        targets
        
        % Structure with one field for each input.
        % 
        %
        inputs
    end
        
    methods
        function self = NNTrainedProduct(varargin)
            self = self@RetrievalDatabaseProduct(varargin{:});
                       
            self.setmembers();
            self.setcols();
%             self.freqstr = sprintf('%s ', self.freqs{self.chans});
%             self.chanstr = sprintf('%d', self.chans);

            if isempty(self.homog)
                self.homog = false;
            end
        end
         
        
        function make_and_train_network(self, varargin)
            % make_and_train_network Create and train NN with self.data
            %
            % FORMAT
            %
            %   nniwp.make_and_train_network([noise_level[, count]])
            %
            % IN
            %
            %   noise_level     double      Gaussian noise, σ.  If
            %                               given, constant for all inputs.
            %                               If not given or [], take from
            %                               self.inputs.(field).noise.
            %
            %   count           integer     Number of networks to train.
            %                               Defaults to 1.  Can be set
            %                               higher to choose e.g. 'best of
            %                               5'.
            
            [noise_level, count] = optargs(varargin, {[], 1});
            if isempty(self.data)
                error(['atmlab:' mfilename ':nodata'], ...
                    'No data found. Did you run .getdata(...)?');
            end
            
            
            %% prepare data, including noise (perhaps)
            
            logtext(atmlab('OUT'), 'Preparing data\n');
            self.limit_data();
            dat = self.data; %(self.selection, :);
            if self.homog
                dat = self.homog_inputs(dat, self.localcols);
            end
            [x_all, x_all_cols] = self.select_and_prepare_data(dat, self.localcols, self.inputs);
            [y, y_cols] = self.select_and_prepare_data(dat, self.localcols, self.targets);
            try
                y_class = self.get_classification(dat);
                classify = true;
            catch ME
                switch ME.identifier
                    case {['atmlab:' mfilename ':noclassify']}
                        classify = false;
                    otherwise
                        ME.rethrow();
                end
            end
            % get rid of data ALREADY nan before flagging anything
            valid_overall = ~any(isnan(x_all), 1);
            % limit further to finite data
            % test using imag~=0 because isreal will return a scalar when
            % given an array
            x_all(imag(x_all)~=0) = NaN;
            y(imag(y)~=0) = NaN;
            %fin = all(isfinite(x_all), 1) & all(isfinite(y), 1);
            fin = all(isfinite(x_all), 1) & ...
                  self.select_for_regression(y, y_cols);
            all(isfinite(y), 1);
            if ~all(fin)
                logtext(atmlab('OUT'), 'Further reducing to %d for finiteness\n', sum(fin));
            end
            %x = x(:, fin);
            %y = y(:, fin);
            
            % Seed random number generator so I can later obtain the exact
            % some noise, should I want to
            seed = now();
            rng(seed);
            if isempty(noise_level) % apply per field
                noise = bsxfun(@times, randn(size(x_all)), self.get_noise_vector(x_all_cols).');
            elseif isscalar(noise_level)
                noise = randn(size(x_all)) * noise_level;
            else
                noise = bsxfun(@times, randn(size(x_all)), noise_level.');
            end
            % make sure I keep track of noiseless data, store this along
            % with seed
            x_orig = x_all;
            x_all = x_all + noise;
            
            % might not use same inputs for both nets
            % any field in self.inputs that has self.inputs.(field).net =
            % 'fit' will only be used for fitting, and any field that has
            % 'pat' will only be used for pattern-matching
            [x_fit, x_fit_cols] = self.subselect_inputs(x_all, x_all_cols, self.inputs, 'fit');
            [x_orig_fit, ~] = self.subselect_inputs(x_orig, x_all_cols, self.inputs, 'fit');

            if classify
                [x_pat, x_pat_cols] = self.subselect_inputs(x_all, x_all_cols, self.inputs, 'pat');
                [x_orig_pat, ~] = self.subselect_inputs(x_orig, x_all_cols, self.inputs, 'pat');
            end
           
            logtext(atmlab('OUT'), 'Getting %d network(s)\n', count);
%            loaded = false;           
            for net_count = 0:count-1
                %% Bail out if no need for any network
                
                f = self.calculate_network_file_name(noise_level, net_count);
                if exist(f, 'file') && self.overwrite==0
%                    if loaded
%                        continue
%                    else
                    logtext(atmlab('OUT'), 'Already exists, loading from file %s\n', f);
                    self.loadnets(f);
                    if isa(self.net, 'network') || (classify && ~isfield(self.net, 'pat'))
                        logtext(atmlab('OUT'), ...
                            'On second thought, I lack a pattern net, retraining!\n');
%                         elseif length(self.net.pat.divideParam.trainInd) + length(self.net.pat.divideParam.valInd) + length(self.net.pat.divideParam.testInd) < length(self.data)
%                             logtext(atmlab('OUT'), ...
%                                 'On second thought, we have different data now, retraining"\n');
                    else
                        loaded = true;
                        continue;
                    end
%                    end
                end
                
                %% parallelise
                
                if matlabpool('size') == 0
                    matlabpool('open', 6);
                end
                
                %% Set up neural networks
                
                % Create a Fitting and a Pattern Network
                hiddenLayerSize = 10; %min([size(x, 1) 10]);
                logtext(atmlab('OUT'), 'Creating networks to store at %s, hidden layer %d nodes\n', f, hiddenLayerSize);
                fitter = fitnet(hiddenLayerSize);

                % Choose Input and Output Pre/Post-Processing Functions
                % For a list of all processing functions type: help nnprocess
                %self.net.inputs{1}.processFcns = {'removeconstantrows','mapminmax'};
                %self.net.outputs{2}.processFcns = {'removeconstantrows','mapminmax'};
                fitter.inputs{1}.processFcns = {'removeconstantrows','mapstd'};
                fitter.outputs{2}.processFcns = {'removeconstantrows','mapstd'};
                
                
                % Setup Division of Data for Training, Validation, Testing
                % For a list of all data division functions type: help nndivide
                
                fitter.divideFcn = 'divideind';
                fitter.divideMode = 'sample';  % Divide up every sample

                % make my own division
                divall = zeros(1, size(y, 2));
                rr = rand(1, size(y, 2));
                trfrac = min([(self.maxsize * (2/3)) / size(y, 2), 0.5]);
                divall(rr <= trfrac) = 1; % train
                divall(rr > trfrac & rr <= trfrac*1.5) = 2; % val
                divall(rr > trfrac * 1.5) = 3; % test (not used in training)
                % but for the fitter, exclude nonfinite values
                fitter.divideParam.trainInd = find(divall==1 & fin);
                fitter.divideParam.valInd = find(divall==2 & fin);
                fitter.divideParam.testInd = find(divall==3 & fin);
%                 fitter.divideParam.trainRatio = 50/100;

                if classify
                    patter = patternnet(hiddenLayerSize);
                    patter.divideFcn = 'divideind';
                    patter.divideMode = 'sample';
                    % for the patter, I should include cloud-free cases
                    patter.divideParam.trainInd = find(divall==1 & valid_overall);
                    patter.divideParam.valInd = find(divall==2 & valid_overall);
                    patter.divideParam.testInd = find(divall==3 & valid_overall);
                    patter.trainParam.show = 10;
                end

                % For help on training function 'trainlm' type: help trainlm
                % For a list of all training functions type: help nntrain
                % See http://www.mathworks.se/help/nnet/ug/speed-and-memory-comparison-for-training-multilayer-networks.html
                fitter.trainFcn = 'trainlm';  % Levenberg-Marquardt
                % choose trainscg, lower on memory.
                % self.net.trainFcn = 'trainscg';
                %            self.net.trainFcn = 'trainbr';  % Bayesian regularisation
                %            self.net.trainFcn = 'trainbfg';  % BFGS quasi-Newton backpropagation
                
                fitter.trainParam.show = 10;
                fitter.efficiency.memoryReduction = 50;
                
                % Choose a Performance Function
                % For a list of all performance functions type: help nnperformance
                fitter.performFcn = 'mse';  % Mean squared error
                
                fitter.userdata.inputs = self.inputs;
                fitter.userdata.targets = self.targets;
                
                % Train the Networks
                
                logtext(atmlab('OUT'), 'Training fitting network (%d inputs, %d hidden, %d target; %d/%d/%d training elements)\n', ...
                    size(x_fit, 1), fitter.layers{1}.size, ...
                    size(y, 1), length(fitter.divideParam.trainInd), ...
                    length(fitter.divideParam.valInd), ...
                    length(fitter.divideParam.testInd));
                [fitter, fit_trdat] = train(fitter, double(x_fit), double(y), ...
                    'useParallel', 'yes', ...
                    'showResources', 'yes', ...
                    'reduction', 100);
                
                if classify

                    logtext(atmlab('OUT'), 'Training cloud-filter pattern network (%d inputs, %d hidden, %d target; %d/%d/%d training elements)\n', ...
                        size(x_pat, 1), patter.layers{1}.size, ...
                        size(y_class, 1), length(patter.divideParam.trainInd), ...
                        length(patter.divideParam.valInd), ...
                        length(patter.divideParam.testInd));
                    
                    % for some reason, training a patternnet really doesn't
                    % like to see NaNs even in part of the data that aren't
                    % used, but set aside for testing or even not used at all.
                    % As a workaround, put zeroes here instead, they aren't
                    % used anyway...!
                    new_y_class = zeros(size(y_class), 'double');
                    new_y_class(:, patter.divideParam.trainInd) = y_class(:, patter.divideParam.trainInd);
                    new_y_class(:, patter.divideParam.valInd) = y_class(:, patter.divideParam.valInd);
                    new_x_pat = zeros(size(x_pat), 'double');
                    new_x_pat(:, patter.divideParam.trainInd) = x_pat(:, patter.divideParam.trainInd);
                    new_x_pat(:, patter.divideParam.valInd) = x_pat(:, patter.divideParam.valInd);
                    
                    [patter, pat_trdat] = train(patter, new_x_pat, new_y_class, ...
                        'useParallel', 'yes', ...
                        'showResources', 'yes', ...
                        'reduction', 60);

                end
                
                %[self.net, self.trdat] = train(self.net, x, y, 'useParallel', 'no', 'showResources', 'yes');
                
                % storing full traindata, valdata, testdata with network.
                % The trainInd, valInd, testInd are only useful if I'm 100%
                % sure that I get the same data, and with making
                % subselections or getting more collocations, this is not
                % the case
                fitter.userdata.alldata = [x_orig_fit; y];
%                fitter.userdata.traindata = [x_orig_fit(:, fit_trdat.trainInd); y(:, fit_trdat.trainInd)];
%                fitter.userdata.valdata = [x_orig_fit(:, fit_trdat.valInd); y(:, fit_trdat.valInd)];
%                fitter.userdata.testdata = [x_orig_fit(:, fit_trdat.testInd); y(:, fit_trdat.testInd)];
                fitter.userdata.x_cols = x_fit_cols;
                fitter.userdata.y_cols = ...
                    structfun(@(x)x+size(x_orig_fit, 1), ...
                              y_cols, 'UniformOutput', false);
                
                if classify
                    patter.userdata.traindata = ...
                        [x_orig_pat(:, pat_trdat.trainInd); ...
                         y_class(:, pat_trdat.trainInd)];
                    patter.userdata.valdata = ...
                        [x_orig_pat(:, pat_trdat.valInd); ...
                         y_class(:, pat_trdat.valInd)];
                    patter.userdata.testdata = ...
                        [x_orig_pat(:, pat_trdat.testInd); ...
                         y_class(:, pat_trdat.testInd)];
                    patter.userdata.cols = x_pat_cols;

                    patter.userdata.randseed = seed;
                    patter.userdata.noiselevel = noise_level;
                end

                fitter.userdata.randseed = seed;
                fitter.userdata.noiselevel = noise_level;

                logtext(atmlab('OUT'), 'Storing network\n');
                logtext(atmlab('OUT'), 'Output: %s\n', f);
                fitter.userdata.stored = f;
                fitter.userdata.no = net_count;
                fitter.userdata.note = self.name;

                self.net = struct();
                self.net.fit = fitter;
                self.trdat.fit = fit_trdat;

                if classify
                    patter.userdata.stored = f;
                    patter.userdata.no = net_count;
                    patter.userdata.note = fitter.userdata.note;
                    self.net.pat = patter;
                    self.trdat.pat = pat_trdat;
                end
                
                self.storenets(f);
            end
            
        end
        
        function [y_class, y_dat] = get_classification(self, dat)
            % from data subselection, get classification targets
            %
            % must have exactly one classification target
            %
            % two outputs:
            % y_class   [2 x N] matrix, cloud/cloudfree
            % y_data    [1 x N] vector, corresponding measurement
            self.localcols;
            tgs = fieldnames(self.targets);
            y_class = zeros(2, size(dat, 1));
            done = false;
            for i = 1:length(tgs)
                tg = tgs{i};
                if isfield(self.targets.(tg), 'classify') && self.targets.(tg).classify
                    if done
                        error(['atmlab:' mfilename ':twofields'], ...
                            'Two fields with classify?!');
                    end
                    y_class(1, :) = dat(:, self.localcols.(tg))<=self.targets.(tg).classify;
                    y_class(2, :) = dat(:, self.localcols.(tg))>self.targets.(tg).classify;
                    y_dat = dat(:, self.localcols.(tg));
                    % FIXME: why do I get any where both are false?
                    done = true;
                end
            end
            if ~done
                error(['atmlab:' mfilename ':noclassify'], ...
                    'No fields with classify?!');
            end
        end

        
        function storenets(self, path)
            % store artificial neural network and training data to 'path'
           nt = self.net; %#ok<NASGU>
           tr = self.trdat; %#ok<NASGU>
           save(path, 'nt', 'tr');
        end        
        
        function loadnets(self, varargin)
            % Loads previously-trained neural-net
            %
            % FORMAT
            %
            %   nn.loadnets(p)
            %
            % IN
            %
            %   p    either full path or string corresponding to one of the
            %        members of self.networks, which translates to a full
            %        path.  Can also be omitted completely, will then try
            %        to load the latest version based on self.version.
            if isempty(self.version)
                narginchk(2, 2);
                p = varargin{1};
            else
                narginchk(1, 2);
                p = optargs(varargin, {['version_', strrep(self.version, '.', '_')]});
            end
            if isfield(self.networks, p)
                path = self.networks.(p);
            else
                path = p;
            end
            logtext(atmlab('OUT'), 'Loading network and training info from %s\n', ...
                path);
            self.net = loadvar(path, 'nt');
            self.trdat = loadvar(path, 'tr');
        end
        
        function [best, perfs] = bestnet(self, noise_level)
            % when multiple nets were trained, select the best one
            
            logtext(atmlab('OUT'), 'Selecting best-performing network\n');
            % consider all targets
            targs = fieldnames(self.targets);

            % infinite loop to count how many networks we have
            total = 0;
            while true
                f = self.calculate_network_file_name(noise_level, total);
                if ~exist(f, 'file')
                    break
                end
                total = total + 1;
            end

            perfs = cell(total, length(targs));
            %perf = zeros(total, length(targs));
            perf_fit = zeros(total, length(targs));
            classify = zeros(length(targs), 1);
            for i = 0:total-1
                f = self.calculate_network_file_name(noise_level, i);
                self.loadnets(f);
                % What input to test the performance for?  How to
                % weigh 'best' when there are different inputs?
                for t = 1:length(targs)
                    targ = targs{t};
                    [xx, p] = self.get_performance(noise_level, targ, ...
                        self.targets.(targ).bins);
                    perfs{i+1, t} = {xx, p};
                    perf(i+1, t) = p;
                    classify(t) = self.targets.(targ).classify;
                    if classify(t)
                        [~, fp, fn] = self.test_patternnet_performance();
                        classify(t) = true;
                        perf_fit(i+1, t) = mean(fp+fn);
                    end
                end
            end
            quals = cell(length(targs), 1);
            for t = 1:length(targs)
                targ = targs{t};
                relevant = (all([perf(:, t).count]>100, 2));
                if isfield(self.targets.(targ), 'relevant')
                    relevant = relevant & (perfs{1, t}{1}>self.targets.(targ).relevant);
                end
                allperf = [perf(:, t).(safegetfield(self.targets.(targ), 'optimise_field', 'rel_medfracerr'))];
                quals{t} = mean(allperf(relevant, :));
                if classify(t)
                    quals{t} = quals{t} + vec2row((perf_fit(:, t)./median(perf_fit(:, t)) > 1.2) * 100); % this means the cloud filter went horribly wrong
                end
            end
            [~, best] = min(mean(vertcat(quals{:}), 1));
            best = best - 1; % count from 0
            % load the best net
            self.loadnets(self.calculate_network_file_name(noise_level, best));
        end
        
        
        function [x, y_ref, y_retr, x_cols, y_cols, y_retr_nonoise] ...
                = evaluate_test_data(self, varargin)
            % evaluates test-data for NN
            %
            % FORMAT
            %
            %   [x, y_ref, y_retr, x_cols, y_cols, y_retr_nonoise] = prod.evaluate_test_data(noise_level)
            %
            % IN
            %
            %   noise_level     double      noise, optional, defaults to
            %                               training noise
            %
            % OUT
            %
            %   x
            %   y_ref
            %   y_retr
            %   x_cols
            %   y_cols
            
            ud = self.net.fit.userdata;
            indy_dat = self.data(self.trdat.fit.testInd, :);
            [y_ref, y_cols] = get_columns(indy_dat, ...
                                          self.localcols, ...
                                          fieldnames(ud.targets));
            [x, x_cols] = self.select_and_prepare_data(indy_dat, self.localcols, self.inputs);
            x = x.';
            %[x, x_cols] = get_columns(indy_dat, ...
            %                          self.localcols, ...
            %                          structfun(@(X) safegetfield(X, 'chans', -1), ud.inputs, 'UniformOutput', false));

            if isfield(ud, 'alldata')
                x_cols = ud.x_cols;
                seed = ud.randseed;
                [xx, xx_cols] = self.select_and_prepare_data(...
                    ud.alldata.', ud.x_cols, ud.inputs);
                xx = xx(:, self.trdat.fit.testInd).';
                [yy_ref, yy_cols] = self.select_and_prepare_data(...
                    ud.alldata.', ud.y_cols, ud.targets);
                yy_ref = yy_ref(:, self.trdat.fit.testInd).';
                assert(isequal(xx, x));
%                targs = fieldnames(y_cols);
%                for t=1:length(targs)
%                    targ = targs{t};
%                    y_ref(:, t) = self.targets.(targ).invtransform(y_ref(:, t));
%                end
            end
            rng('shuffle');
            noise_level = optargs(varargin, {ud.noiselevel});
            % FIXME: vertical correlation in error...
            if isempty(x)
                noise = x;
            elseif isscalar(noise_level)
                noise = randn(size(x)) * noise_level;
            elseif isempty(noise_level)
                noise = bsxfun(@times, randn(size(x)), self.get_noise_vector(x_cols));
            else
                noise = bsxfun(@times, randn(size(x)), noise_level);
            end
            y_retr_raw = sim(self.net.fit, (x + noise).').';
            y_retr_raw_nonoise = sim(self.net.fit, x.').';
            % invert for each retrieved field
            y_retr = y_retr_raw;
            y_retr_nonoise = y_retr_raw_nonoise;
            fns = fieldnames(ud.targets);
            for i = 1:length(fns)
                fn = fns{i};
                y_retr(:, y_cols.(fn)) = ud.targets.(fn).invtransform(y_retr_raw(:, y_cols.(fn)));
                y_retr_nonoise(:, y_cols.(fn)) = ud.targets.(fn).invtransform(y_retr_raw_nonoise(:, y_cols.(fn)));
            end
            
            %y_retr = invtrans(y_retr_raw);
            %y_retr = y_retr(:);
        end
           
        function dev_selftest = evaluate_and_summarise_testdata(self, varargin)
           % evaluate test-data and perform several statistical tests
           %
           % 
           % - make a scatter density plot
           %
           % IN
           %    
           %    noise_level
           %
           %        optional, defaults to same as training.
           %        Can be either a scalar, or a
           %        vector corresponding to the number of channels, or []
           %        which means same as training.
           %
           % See also: scatter_density_plot, plot_scatter_perf
           
           noise_simul = optargs(varargin, {self.net.userdata.noiselevel});
           
           %% self-test
           
           figure('visible', 'off');
           [x, y] = self.evaluate_test_data(noise_simul);      
           filt = all(x>0, 2) & ...
                  all(y>0, 2) & ...
                  all(isfinite(x), 2) & ...
                  all(isfinite(y), 2);

           [h_ax, h_cb] = self.plot_scatter_perf(x(filt), y(filt));
                     
           ylabel(h_cb, 'Number of retrievals');
           xlabel(h_ax, 'Independent IWP [g/m^2]');
           ylabel(h_ax, 'Retrieved IWP [g/m^2]');
 
           if isfield(self.net.userdata, 'realnoise') && self.net.userdata.realnoise
               train_noise_str = 'realnoise';
           elseif isscalar(self.net.userdata.noiselevel)
               train_noise_str = sprintf('%.2fK', self.net.userdata.noiselevel); 
           else
               train_noise_str = [sprintf('%.2f,', self.net.userdata.noiselevel) 'K'];
           end
           
           if isequal(noise_simul, self.net.userdata.noiselevel)
               simul_noise_str = 'trainnoise';
           elseif isscalar(noise_simul)
               simul_noise_str = sprintf('%.2fK', noise_simul);
           else
               simul_noise_str = [sprintf('%.2f,', noise_simul) 'K'];
           end
           
           title(sprintf('NN-IWP self-test, Evans data, noise %s/%s\nchannels %s', train_noise_str, simul_noise_str, self.freqstr));
           print(gcf(), '-depsc', fullfile(cscol('plot_base'), sprintf('nniwp_evansdb_selftest_noise%s_%s_chans%s.eps', ...
               train_noise_str, simul_noise_str, self.chanstr)));

           %% calculate median fractional error per bin, store results in plotdata
           
           xbins = self.opts.bins;
           dev_selftest = self.binned_median_fractional_error(x(filt), y(filt), xbins);
           M = [xbins.', dev_selftest.']; %#ok<NASGU>
           of = fullfile(cscol('plotdata_base'), sprintf('nniwp_evansdb_selftest_fracerr_noise%s_%s_chans%s.dat', ...
               train_noise_str, simul_noise_str, self.chanstr));
           save(of, 'M', '-ascii');
        end
       
        function [xx, S] = get_performance(self, noise_level, varargin)
            % get many performance statistics
            %
            % Default, old-style, is hard-coded logarithmically for IWP.
            % For new behaviour, pass appropriate variables.
            %
            % IN
            %
            %   noise_level
            %   variable        (must be in self.targets)
            %   bins

            [x, y_ref, y_retr, x_cols, y_cols] = self.evaluate_test_data(noise_level);
            filt = (y_ref>0) & (y_retr>0) & isfinite(y_ref) & isfinite(y_retr);
            
            [variable, bins] = optargs(varargin, {'IWP', []});

            y_ref = y_ref(all(filt, 2), y_cols.(variable));
            y_retr = y_retr(all(filt, 2), y_cols.(variable));
            
            if isempty(bins)
                bins = floor(min(log10(y_ref(:)))):.2:ceil(max(log10(y_ref(:))));
            end

            bins = vec2col(bins);

            func = self.targets.(variable).transform;
            defunc = self.targets.(variable).invtransform;
            % calculate different ways to get performance
            S.abs_medad = cellfun(@(yy) mad(yy, 1), bin(func(y_ref), y_retr, bins));
            S.abs_meanad = cellfun(@(yy) mad(yy, 0), bin(func(y_ref), y_retr, bins));
            S.abs_rmeanse = cellfun(@(dy) rms(dy), bin(func(y_ref), y_retr-y_ref, bins));
            S.abs_rmedse = cellfun(@(dy) sqrt(median(dy.^2)), bin(func(y_ref), y_retr-y_ref, bins));
            S.abs_ir = cellfun(@iqr, bin(func(y_ref), y_retr, bins));
            %S.rel_medfracerr = cellfun(@median, bin(func(y_ref), abs(y_retr-y_ref)./y_ref, bins));
            S.rel_medfracerr = cellfun(@median, bin(func(y_ref), defunc(abs(func(y_retr) - func(y_ref)))-1, bins));
            S.abs_medfracerr = S.rel_medfracerr .* defunc(bins);
            S.rel_rmeanse_frac = cellfun(@(dy) rms(dy), bin(func(y_ref), abs(y_retr-y_ref)./y_ref, bins));
            S.abs_rmeanse_frac = S.rel_rmeanse_frac .* defunc(bins);
            S.count = cellfun(@(yy) size(yy, 1), bin(func(y_ref), y_retr, bins));
            xx = defunc(bins);
        end

        function [bn, fp, fn, fp_med_ref, fp_med_retr, fn_med_ref, fn_med_retr] = test_patternnet_performance(self)
            % Test how well the cloudy/cloudfree recognition works
            %
            %p = self.net.pat;
            %
            % Returns:
            %
            % bins, false positives, false negatives
            [y_class, y_class_data] = self.get_classification(self.data);
            ref_clear = y_class(1, self.net.pat.divideParam.testInd);
            ref_cloudy = y_class(2, self.net.pat.divideParam.testInd);
            ref_data = y_class_data(self.net.pat.divideParam.testInd);
            [x, x_cols] = self.select_and_prepare_data(self.data, self.localcols, self.inputs);
            x_pat = self.subselect_inputs(x, x_cols, self.inputs, 'pat');
            x_fit = self.subselect_inputs(x, x_cols, self.inputs, 'fit');

            yclrt = self.net.pat(x_pat(:, self.net.pat.divideParam.testInd));
            % use the pattern testInd for the fit network here, because I'm
            % interested in retrieved IWP in particular where the reference
            % is 0
            ydatrt = 10.^self.net.fit(x_fit(:, self.net.pat.divideParam.testInd));
            
            valid = (isfinite(ref_data)&ref_data>=0).';
            
            bn = linspace(0, 1, 70);
            fp = zeros(size(bn));
            fn = zeros(size(bn));
            fp_med_ref = zeros(size(bn));
            fp_med_retr = zeros(size(bn));
            fn_med_ref = zeros(size(bn));
            fn_med_retr = zeros(size(bn));
            for i = 1:length(bn)
                frc = bn(i);
                retr_cloudy = yclrt(2, :) > frc;
                retr_clear = ~retr_cloudy;
                fp(i) = sum(retr_cloudy & ref_clear & valid)./length(find(valid));
                fn(i) = sum(retr_clear & ref_cloudy & valid)./length(find(valid));
                fp_med_ref(i) = median(ref_data(valid & retr_cloudy & ref_clear));
                fp_med_retr(i) = median(ydatrt(valid & retr_cloudy & ref_clear));
                fn_med_ref(i) = median(ref_data(valid & ref_cloudy & retr_clear));
                fn_med_retr(i) = median(ydatrt(valid & ref_cloudy & retr_clear));
            end
        end
        
        function [ptls, ptls_nonoise] = iwc_profile_performance(self, ptiles)
            % get profile performance, return percentiles for ratio iwc/ref
            %
            % profile_performace([1, 25, 50, 75, 99])
            %
            % See also: prctile
            [x, y_ref, y_retr, x_cols, y_cols, y_retr_nonoise] = self.evaluate_test_data();
            fy = y_ref(:, y_cols.IWC) ./ y_retr(:, y_cols.IWC);
            fy_nonoise = y_ref(:, y_cols.IWC) ./ y_retr_nonoise(:, y_cols.IWC);
            ptls = prctile(fy, ptiles);
            ptls_nonoise = prctile(fy_nonoise, ptiles);
        end
        
        function dy = akm(self)
            % get averaging kernel matrix for all testdata
            %
            % OUT
            %
            %   dy  matrix of size (N, p, q) with averaging kernel matrix
            %       per measurement, perturbed per noise-level.  Resulting
            %       fractional change in IWC.
            
            % construct a N x p x p matrix where each page is 
            n_inputs = self.net.inputs{1}.size;
            n_outputs = self.net.outputs{end}.size;
            n_ret = length(self.trdat.testInd);
            [x_unpert, x_cols] = get_columns(self.data(self.trdat.testInd, :), ...
                                             self.localcols, ...
                                             fieldnames(self.inputs));
            dx = self.get_noise_vector(x_cols);
            bsxfun(@times, eye(n_inputs), dx);
            x_pert = bsxfun(@plus, ...
                            repmat(x_unpert, [1, 1, n_inputs]), ...
                            reshape(bsxfun(@times, eye(n_inputs), dx), ...
                                    [1, n_inputs, n_inputs]));
                            
%             x_pert = bsxfun(@times, ...
%                             repmat(x_unpert, [1, 1, n_inputs]), ...
%                             reshape(1 + eye(n_inputs)*pert_frac, [1, n_inputs, n_inputs]));
            y_unpert = sim(self.net, x_unpert.').';
            y_pert = permute(reshape(self.net(reshape(permute(x_pert, [2, 3, 1]), ...
                                                     [n_inputs, n_inputs*n_ret, 1])), ...
                                     [n_outputs, n_inputs, n_ret]), ...
                             [3, 1, 2]);

            dy = 10.^bsxfun(@minus, y_pert, y_unpert)-1;
        end
        
        function plot_akm(self, dy)
            % plot akm
            
            % FIXME: move to other class
            n_inputs = size(dy, 2);
            n_outputs = size(dy, 1);
            %pcolor(1:n_inputs, linspace(4.5, 15, n_outputs), squeeze(dy(1, :, :)));
            sanepcolor(1:n_inputs, linspace(4.5, 15, n_outputs), dy);
            shading faceted;
            colormap(drywet(0.1));
            cb = colorbar();
            ylabel(cb, '%IWC change per noise level measurement');
            zerobright();
            hold on;
            %plot([12, 12], [4.5, 15], 'LineWidth', 2.5, 'Color', 'black');
            xlabel(sprintf('Channel (%s)', strjoin(vec2row(fieldnames(self.inputs)), ', ')));
            ylabel('Height [km]');
            title(['Sensitivity analysis ' strrep(self.name, '_', ' ')]);            
            save_figure_multi(gcf(), fullfile(cscol('plot_base'), [self.name '_mean_akm']), 'png', 'eps', 'fig');
        end
        
        function nm = calculate_network_file_name(self, noise_level, i)
            inps = fieldnames(self.inputs);
            tgts = fieldnames(self.targets);

            inpcell = cell(size(inps));
            for k = 1:length(inpcell)
                inp = inps{k};
                if isfield(self.inputs.(inp), 'chans')
                    inpcell{k} = sprintf('%s,%s', ...
                        inp, ...
                        strjoin(arrayfun(@num2str, ...
                                        self.inputs.(inp).chans, ...
                                        'UniformOutput', false), ...
                                ','));
                else
                    inpcell{k} = inp;
                end
            end

            tgtcell = cell(size(tgts));
            for k = 1:length(tgtcell)
                tgt = tgts{k};
                if isfield(self.targets.(tgt), 'regression_range')
                    tgtcell{k} = sprintf('%s,%.4g-%.4g', ...
                        tgt, ...
                        self.targets.(tgt).regression_range(1), ...
                        self.targets.(tgt).regression_range(2));
                else
                    tgtcell{k} = tgt;
                end
            end
            
            if length(unique(noise_level))==1
                noise_str = sprintf('%.2f', unique(noise_level));
            else
                noise_str = sprintf('%2f,', noise_level);
            end
            nm = sprintf('/storage3/user_data/gerrit/neuralnets/%s_%s_to_%s_noise%s_v%s_%d.mat', ...
                self.name, ...
                sprintf('%s,', strjoin(vec2row(inpcell), ',')), ...
                sprintf('%s,', strjoin(vec2row(tgtcell), ',')), ...
                noise_str, ...
                self.version, ...
                i);
            
        end
        
        function res = retrieve(self, data, cols, varargin)
            % retrieve data
            %
            % iwp = ccniwp.retrieve(data, cols[, cutoff])
            %
            % This method:
            % 
            %  - applies limitations (lat/lon)
            %  - applies transforms and invtransforms
            %  - applies both neural networks
            %  - decides cloud/cloudfree with 'cutoff'
            %  - returns retrieved IWP in g/m^2
            %
            % IN
            %
            %   data    matrix with data, must have at least lat/lon and
            %           all the inputs
            %   cols    description of columns. NB: must match 'inputs'
            %   cutoff  cloud/nocloud?  Defaults to 0.5
            %
            % OUT
            %
            %   res - structure with many fields, depends on the exact
            %   product
           
            cutoff = optargs(varargin, {0.5});
            
            if isequal(self.net, [])
                logtext(atmlab('OUT'), 'No networks loaded yet, will load default one for this version\n');
                self.loadnets();
            end
            
            ud = self.net.fit.userdata;
            
            [x, x_cols] = self.select_and_prepare_data(data, cols, ud.inputs);
            
            flds = fieldnames(x_cols);
            for i = 1:length(flds)
                fld = flds{i};
                if isfield(ud.inputs.(fld), 'lims')
                    lims.(fld) = ud.inputs.(fld).lims;
                end
            end

            % FIXME still hardcoded; somtimes wrong in neural net
            lims.B_SZA = [0, 85]; 
            lims.B_LAA = [-180, 180];
            lims.B_SAA = [-180, 180];
            %limmer = collocation_restrain(inp, limstruct2limmat(lims, inp_cols));
            limmer = collocation_restrain(x.', limstruct2limmat(getfields(lims, intersect(fieldnames(lims), fieldnames(x_cols))), x_cols));
            %inp = inp(limmer, :);
            x = x(:, limmer);
            data = data(limmer, :); % for lat/lon/time still ekep track
            lat = data(:, cols.LAT1);
            lon = data(:, cols.LON1);

            %cloudpat = self.net.pat(inp.').';
            cloudpat = self.net.pat(self.subselect_inputs(x, x_cols, ud.inputs, 'pat')).';
            cloudy = cloudpat(:, 2)>cutoff;
            
            %iwp = self.net.fit(inp.').';
            iwp = self.net.fit(self.subselect_inputs(x, x_cols, ud.inputs, 'fit')).';

            % FIXME: not so hardcoded to MEAN_IWP_2C please?
            res.raw_iwp = ud.targets.MEAN_IWP_2C.invtransform(iwp);
            res.iwp = res.raw_iwp;
            res.iwp(~cloudy) = 0;
            res.cloud_probability = cloudpat(:, 2);
            res.lat = lat;
            res.lon = lon;
            res.time = data(:, cols.TIME1);
            
            % also put inputs here
            
            inps = fieldnames(self.inputs);
            for i = 1:length(inps)
                inp = inps{i};
                if isfield(cols, inp)
                    res.(inp) = data(:, cols.(inp));
                else
                    res.(inp) = x(x_cols.(inp), :);
                end
            end
            
%             res.MEAN_AVHRR_Y = data(:, cols.MEAN_AVHRR_Y);
%             res.AVHRR_FLAG_3AB = data(:, cols.AVHRR_FLAG_3AB);
%             res.MHS = data(:, cols.B_BT(3:5));
%             res.B_LZA = data(:, cols.B_LZA);
%             res.B_LAA = data(:, cols.B_LAA);
%             res.B_SZA = data(:, cols.B_SZA);
%             res.B_SAA = data(:, cols.B_SAA);
%             res.Surface_elevation = x(x_cols.Surface_elevation, :);
%             if isfield(x_cols, 'Surface_elevation_std')
%                 res.Surface_elevation_std = x(x_cols.Surface_elevation_std, :);
%             end
           
        end
        
        function [data, info] = retrieve_granule(self, granule, spec)
            % res = retrieve_granule(granule, spec)
            %
            % See also: retrieve, retrieve_and_store_granule
            
            altfile = self.get_alt_file(granule, spec);
            if isempty(altfile)
                gotdata = false;
            else
                S = self.read_alt_granule(granule, spec);
                if isempty(S.TIME)
                    logtext(atmlab('OUT'), 'Read no data, skipping\n')
                    data = [];
                    info = struct();
                    return
                else
                    gotdata = true;
 %                   [M, cc] = self.struct2mat(getfields(S, intersect(fieldnames(S), fieldnames(self.cols))));
                    [M, cc] = self.struct2mat(S);
                end
            end
            
            if ~gotdata
                D = datasets();
                
                [result, additional_results, ~] = D.collocation_mhs_avhrr.collocate_granule(granule, spec, spec, {D.associated_mhs_avhrr, D.collapsed_mhs_avhrr}, false);
%                 lockfile = get_lock(atmlab('WORK_AREA'), 'collocations.lock');
%                 cl1 = onCleanup(@()delete(lockfile));
                if isempty(result)
                    logtext(atmlab('ERR'), 'Found no data, skipping\n');
                    data = [];
                    info = struct();
                    return
                end
                [M, cc] = D.associated_mhs_avhrr.merge_matrix(result, D.collocation_mhs_avhrr.cols, additional_results{1}, D.associated_mhs_avhrr.cols);
                clear result;
                [M, cc] = D.collapsed_mhs_avhrr.merge_matrix(M, cc, additional_results{2}, D.collapsed_mhs_avhrr.cols);
                clear additional_results;
%                 logtext(atmlab('OUT'), 'Clearing lockfile\n');
%                 delete(lockfile);
            end
            
            logtext(atmlab('OUT'), 'Retrieving %d values\n', size(M, 1));
            res = self.retrieve(M, cc, 0.5);
            logtext(atmlab('OUT'), 'Done\n');
            
            
            % FIXME: make this more flexible, for going back to older
            % versions etc.
            data = zeros(size(res.iwp, 1), max(structfun(@(X)max(X), self.cols)));
            data(:, self.cols.LAT) = res.lat;
            data(:, self.cols.LON) = res.lon;
            data(:, self.cols.TIME) = res.time;
            data(:, self.cols.P_CLOUD) = res.cloud_probability;
            data(:, self.cols.IWP_RAW) = res.raw_iwp;
            data(:, self.cols.IWP) = res.iwp;
            %data(:, self.cols.MEAN_AVHRR_Y) = res.MEAN_AVHRR_Y;
            
            % and the inputs
            inps = fieldnames(self.inputs);
            for i = 1:length(inps)
                inp = inps{i};
                if isfield(self.cols, inp)
                    if (min(size(res.(inp))) ~= size(self.cols.(inp), 2)) && max(size(res.(inp))) > 3
                        data(:, self.cols.(inp)) = res.(inp)(:, self.inputs.(inp).chans);
                    else
                        data(:, self.cols.(inp)) = res.(inp);
                    end
                end
            end
            
%             data(:, self.cols.AVHRR_FLAG_3AB) = res.AVHRR_FLAG_3AB;
%             data(:, self.cols.MHS) = res.MHS;
%             data(:, self.cols.B_LZA) = res.B_LZA;
%             data(:, self.cols.B_LAA) = res.B_LAA;
%             data(:, self.cols.B_SZA) = res.B_SZA;
%             data(:, self.cols.B_SAA) = res.B_SAA;
%             data(:, self.cols.Surface_elevation) = res.Surface_elevation;
%             if isfield(res, 'Surface_elevation_std') && isfield(self.cols, 'Surface_elevation_std')
%                 data(:, self.cols.Surface_elevation_std) = res.Surface_elevation_std;
%             end
            
            % FIXME: less hard-coded please
            info.Conventions = 'CF-1.6';
            info.title = 'AVHRR+MHS IWP trained by collocations with 2C-ICE';
            info.version = self.version;
            %info.history = self.changelog;
            info.source = 'Retrieved from collocated CPR/MHS 2C-ICE-trained ANN';
            info.nnet = self.net.pat.userdata.stored;
            info.references = 'Holl, G., S. Eliasson, J. Mendrok, and S. A. Buehler (submitted 2013), SPARE-ICE: synergistic IWP from passive operational sensors, J. Geophys. Res.';
            
            %            info.stored_lims = struct2string_compact(storelims);
            % FIXME: more additional info
            
            
        end
        
        function retrieve_and_store_granule(self, granule, spec)
            % ccniwp.retrieve_and_store_granule(granule, spec)
            %
            % Apply neural network retrieval to 'granule' / 'spec' and
            % store result according to self.find_granule_by_datetime.
            % If a retrieval has been performed previously for this
            % granule, this method reads the input data from the earlier
            % version.  Otherwise, it will read all inputs needed, perform
            % collocations (this will take some minutes).  Then, it applies
            % the neural network (loaded via self.loadnets) and stores the
            % result.
            %
            % IN
            %
            %   granule     datetime-vector describing granule start time
            %   spec        string describing satellite (e.g. 'noaa18')
            %
            % See also: retrieve, loadnets
            %
            % Example: D.col_syn_iwp.retrieve_and_store_granule([2007, 8, 1, 1, 48], 'noaa18');
            outfile = self.find_granule_by_datetime(granule, spec);
            
            if exist(outfile, 'file') && ~self.overwrite
                logtext(atmlab('OUT'), 'Already exists: %s, continue\n', outfile);
                return
            end
            
%             if exist(outfile, 'file')
%                 switch self.overwrite
%                     case 0
%                     case 1 % continue normally
%                         gotdata = false;
%                     case 2
%                         S = self.read_granule(granule, spec, fieldnames(self.cols));
%                         if isempty(S.time) % no data
%                             logtext(atmlab('OUT'), 'Read no data, skipping\n')
%                             return
%                         end
%                         [M, cc] = self.struct2mat(S);
%                         gotdata = true;
%                 end
%             else
%                 altfile = self.get_alt_file(granule, spec);
%                 if isempty(altfile)
%                     gotdata = false;
%                 else
%                     S = self.read_alt_granule(granule, spec);
%                     if isempty(S.TIME)
%                         logtext(atmlab('OUT'), 'Read no data, skipping\n')
%                         
%                         return
%                     else
%                         gotdata = true;
%                         [M, cc] = self.struct2mat(S);
%                     end
%                 end
%             end
%             if ~gotdata
%                 D = datasets();
%                 
%                 [result, additional_results, also] = D.collocation_mhs_avhrr.collocate_granule(granule, spec, spec, {D.associated_mhs_avhrr, D.collapsed_mhs_avhrr}, false);
%                 lockfile = get_lock(atmlab('WORK_AREA'), 'collocations.lock');
%                 cl1 = onCleanup(@()delete(lockfile));
%                 if isempty(result)
%                     logtext(atmlab('ERR'), 'Found no data, skipping\n');
%                     return
%                 end
%                 [M, cc] = D.associated_mhs_avhrr.merge_matrix(result, D.collocation_mhs_avhrr.cols, additional_results{1}, D.associated_mhs_avhrr.cols);
%                 clear result;
%                 [M, cc] = D.collapsed_mhs_avhrr.merge_matrix(M, cc, additional_results{2}, D.collapsed_mhs_avhrr.cols);
%                 clear additional_results;
%                 logtext(atmlab('OUT'), 'Clearing lockfile\n');
%                 delete(lockfile);
%             end
%             
%             logtext(atmlab('OUT'), 'Retrieving %d values\n', size(M, 1));
%             res = self.retrieve(M, cc, 0.5);
%             logtext(atmlab('OUT'), 'Done\n');
%             
%             
%             % FIXME: make this more flexible, for going back to older
%             % versions etc.
%             data = zeros(size(res.iwp, 1), 20);
%             data(:, self.cols.LAT) = res.lat;
%             data(:, self.cols.LON) = res.lon;
%             data(:, self.cols.TIME) = res.time;
%             data(:, self.cols.P_CLOUD) = res.cloud_probability;
%             data(:, self.cols.IWP_RAW) = res.raw_iwp;
%             data(:, self.cols.IWP) = res.iwp;
%             data(:, self.cols.MEAN_AVHRR_Y) = res.MEAN_AVHRR_Y;
%             data(:, self.cols.AVHRR_FLAG_3AB) = res.AVHRR_FLAG_3AB;
%             data(:, self.cols.MHS) = res.MHS;
%             data(:, self.cols.B_LZA) = res.B_LZA;
%             data(:, self.cols.B_LAA) = res.B_LAA;
%             data(:, self.cols.B_SZA) = res.B_SZA;
%             data(:, self.cols.B_SAA) = res.B_SAA;
%             data(:, self.cols.Surface_elevation) = res.Surface_elevation;
%             data(:, self.cols.Surface_elevation_std) = res.Surface_elevation_std;
% 
%             % FIXME: less hard-coded please
%             info.title = 'AVHRR+MHS IWP trained by collocations with 2C-ICE';
%             info.version = 1;
%             %info.history = self.changelog;
%             info.source = 'Retrieved from collocated CPR/MHS 2C-ICE-trained ANN';
%             info.nnet = self.net.pat.userdata.stored;
% %            info.stored_lims = struct2string_compact(storelims);
%             % FIXME: more additional info
            
            [data, info] = self.retrieve_granule(granule, spec);
            if isempty(data) % no data
                logtext(atmlab('OUT'), 'Got no data, therefore not storing\n');
                return
            end
            logtext(atmlab('OUT'), 'Storing\n');
            % ugly hack; I don't want to extend, but rewrite this one,
            % therefore temporarily changing self.overwrite
            if self.overwrite == 2
                self.overwrite = 1;
                self.store(granule, spec, data, info);
                self.overwrite = 2;
            else
                self.store(granule, spec, data, info);
            end
        end
        
        function retrieve_and_store_period(self, date1, date2, spec)
            D = datasets();
            % weirdness, see http://stackoverflow.com/q/19406551/974555
            m = D.mhs;
            allgrans = cached_evaluation(@m.find_granules_for_period, date1, date2, spec, 'EXTRA', self.name, m.name);
            
            for i = 1:size(allgrans, 1)
                logtext(atmlab('OUT'), 'Processing: %s\n', num2str(allgrans(i, :)));
                
                try
                    self.retrieve_and_store_granule(allgrans(i, :), spec);
                catch ME
                    switch ME.identifier
                        case {'atmlab:find_granule_by_datetime', 'atmlab:collocate', 'atmlab:CollocatedDataset:noother', 'MATLAB:nomem'}
                            logtext(atmlab('ERR'), 'Cannot retrieve for %s %s: %s\n', ...
                                spec, num2str(allgrans(i, :)), ME.message);
                            continue
                        otherwise
                            ME.rethrow();
                    end
                end
            end
            
        end
        
        function setcols(self)
            fs = fieldnames(self.members);
            N = 1;
            for i = 1:length(fs)
                f = fs{i};
                if isfield(self.members.(f), 'dims')
                    L = self.members.(f).dims{2};
                else
                    L = 1;
                end
                self.cols.(f) = N:(N+L-1);
                N = N + L;
            end
        end
        
        function setmembers(self)
            % FIXME: this should be more flexible...
            
            self.members.LAT.type = 'float';
            self.members.LAT.atts.long_name = 'Latitude';
            self.members.LAT.atts.valid_range = [-90 90];
            self.members.LAT.atts.units = 'degrees_north';
            
            self.members.LON.type = 'float';
            self.members.LON.atts.long_name = 'Longitude';
            self.members.LON.atts.units = 'degrees_east';
            self.members.LON.atts.valid_range = [-180 180];
            
            self.members.TIME.type = 'int';
            self.members.TIME.atts.long_name = 'Measurement time';
            self.members.TIME.atts.units = 'seconds since 1970-01-01 00:00:00';
           
            self.members.P_CLOUD.type = 'float';
            self.members.P_CLOUD.atts.long_name = 'Cloud probability';
            self.members.P_CLOUD.atts.valid_range = [0, 1];

            self.members.IWP_RAW.type = 'float';
            self.members.IWP_RAW.atts.long_name = 'Raw retrieved Ice Water Path, not considering cloud probability';
            self.members.IWP_RAW.atts.valid_min = 0;
            self.members.IWP_RAW.atts.units = 'g/m^2';
            self.members.IWP_RAW.atts.standard_name = 'atmosphere_cloud_ice_content';

            self.members.IWP.type = 'float';
            self.members.IWP.atts.long_name = 'Ice Water Path';
            self.members.IWP.atts.valid_min = 0;
            self.members.IWP.atts.units = 'g/m^2';
            self.members.IWP.atts.standard_name = 'atmosphere_cloud_ice_content';

            inp_fields = setdiff(fieldnames(self.inputs), {'LAT1'});
            for i = 1:length(inp_fields)
                f = inp_fields{i};
                if isfield(self.inputs, f) && isfield(self.inputs.(f), 'stored')
                    self.members.(f) = self.inputs.(f).stored;
                    if isfield(self.inputs.(f), 'chans')
                        self.members.(f).dims = {[f, '_CHANS'], length(self.inputs.(f).chans)};
                    end
                end
            end
            
%             self.members.MEAN_AVHRR_Y.type = 'float';
%             self.members.MEAN_AVHRR_Y.atts.long_name = 'AVHRR measurement averaged over MHS footprint';
%             self.members.MEAN_AVHRR_Y.atts.valid_min = 0;
%             self.members.MEAN_AVHRR_Y.atts.units = 'reflectance or BT [K]';
%             self.members.MEAN_AVHRR_Y.atts.origin = 'Based on AVHRR l1a data from NOAA CLASS archive';
%             self.members.MEAN_AVHRR_Y.dims = {'AVHRR_CHANS', 5};
% 
%             self.members.AVHRR_FLAG_3AB.type = 'int';
%             self.members.AVHRR_FLAG_3AB.atts.long_name = 'AVHRR-3 flag: 3A/3B';
%             self.members.AVHRR_FLAG_3AB.atts.valid_range = [0, 1];
%             self.members.AVHRR_FLAG_3AB.atts.origin = 'Based on AVHRR L1 data from NOAA CLASS archive';
% 
%             self.members.MHS.type = 'float';
%             self.members.MHS.atts.long_name = 'MHS radiance, channels 3-5';
%             self.members.MHS.atts.valid_range = [100, 400];
%             self.members.MHS.atts.units = 'K';
%             self.members.MHS.atts.origin = 'Copied from MHS L1 data from NOAA CLASS archive';
%             self.members.MHS.dims = {'MHS_HUM_CHANS', 3};
% 
%             self.members.B_LZA.type = 'float';
%             self.members.B_LZA.atts.long_name = 'MHS local zenith angle';
%             self.members.B_LZA.atts.valid_range = [0, 180];
%             self.members.B_LZA.atts.units = 'degrees';
%             self.members.B_LZA.atts.origin = self.members.MHS.atts.origin;
% 
%             self.members.B_LAA.type = 'float';
%             self.members.B_LAA.atts.units = 'degrees';
%             self.members.B_LAA.atts.long_name = 'MHS local azimuth angle';
%             self.members.B_LAA.atts.valid_range = [0, 360];
%             self.members.B_LAA.atts.origin = self.members.MHS.atts.origin;
% 
%             self.members.B_SZA.type = 'float';
%             self.members.B_SZA.atts.units = 'degrees';
%             self.members.B_SZA.atts.long_name = 'Solar zenith angle';
%             self.members.B_SZA.atts.valid_range = [0, 180];
%             self.members.B_SZA.atts.origin = self.members.MHS.atts.origin;
% 
%             self.members.B_SAA.type = 'float';
%             self.members.B_SAA.atts.units = 'degrees';
%             self.members.B_SAA.atts.long_name = 'Solar azimuth angle';
%             self.members.B_SAA.atts.valid_range = [0, 360];
%             self.members.B_SAA.atts.origin = self.members.MHS.atts.origin;
%             
%             self.members.Surface_elevation.type = 'float';
%             self.members.Surface_elevation.atts.units = 'km';
%             self.members.Surface_elevation.atts.long_name = 'Surface_elevation';
%             self.members.Surface_elevation.atts.valid_range = [0, 10];
%             self.members.Surface_elevation.atts.origin = 'NOAA ETOPO1 1 Arc-Minute Global Relief Model';
            
%             self.members.Surface_elevation_std.type = 'float';
%             self.members.Surface_elevation_std.atts.units = 'km';
%             self.members.Surface_elevation_std.atts.long_name = 'Surface_elevation_std';
%             self.members.Surface_elevation_std.atts.description = 'Standard deviation of 9 surface elevations in gridbox + neighbours';
%             self.members.Surface_elevation_std.atts.valid_min = 0;
%             self.members.Surface_elevation.atts.origin = 'Based on NOAA ETOPO1 1 Arc-Minute Global Relief Model';
           
        end
        
        function cc = fix_cols_in_postprocessing(~, cc)
        end
        
        function [x_new, x_new_cols] = subselect_inputs(~, x_all, x_all_cols, inps, mod)
            flds = fieldnames(inps);
            x_new = zeros(size(x_all));
            k = 0;
            for i = 1:length(flds)
                fld = flds{i};
                if isfield(inps.(fld), 'net')
                    if ~isequal(inps.(fld).net, mod)
                        continue
                    end
                end
                % chans are already taken care of in
                % select_and_prepare_data!
%                if isfield(inps.(fld), 'chans')
%                    chans = inps.(fld).chans;
%                else
%                    chans = 1:length(x_all_cols.(fld));
%                end
                %newslc = (k+1):(k+length(x_all_cols.(fld)));
                newslc = (k+1):(k+length(x_all_cols.(fld)));
                %oldslc = par(x_all_cols.(fld), chans);
                x_new(newslc, :) = x_all(x_all_cols.(fld), :);
                x_new_cols.(fld) = newslc;
                k = k + length(x_all_cols.(fld));
            end
            x_new(k+1:end, :) = [];
        end
        

%         function [M, cc] = struct2mat(self, S)
%             % copy it all over to the matrix
%             flds = fieldnames(self.cols);
%             M = zeros(size(S.time, 1), max(cellfun(@(X)max(self.cols.(X)), fieldnames(self.cols))));
%             for i = 1:length(flds)
%                 fld = flds{i};
%                 M(:, self.cols.(fld)) = S.(fld);
%             end
%             cc = self.cols;
%             % column names are different, channels etc...
%             % expand this
%             cc = self.fix_cols_in_postprocessing(cc);
%         end
        
        % attempt (so far) to make this more generic
        %
        function [M, cc] = struct2mat(self, S)
            % copy it all over to the matrix
            flds = fieldnames(S);
            L = max(structfun(@(X) size(X, 1), S));
            %M = zeros(size(S.(flds{1}), 1), sum(structfun(@(X) size(X, 2), S)));
            N = 1;
            for i = 1:length(flds)
                fld = flds{i};
                if ~(size(S.(fld), 1)==L)
                    continue;
                end
                nn = size(S.(fld), 2);
                if isfield(self.inputs, fld) && isfield(self.inputs.(fld), 'chans') && length(self.inputs.(fld).chans) < size(S.(fld), 2)
                    nn = length(self.inputs.(fld).chans);
                end
                nc = N:(N+nn-1);
                N = N + nn;
                cc.(fld) = nc;
                if isfield(self.inputs, fld) && isfield(self.inputs.(fld), 'chans') && length(self.inputs.(fld).chans) < size(S.(fld), 2)
                    M(:, nc) = S.(fld)(:, self.inputs.(fld).chans);
                else
                    M(:, nc) = S.(fld);
                end
            end
            %cc = self.cols;
            % column names are different, channels etc...
            % expand this
            cc = self.fix_cols_in_postprocessing(cc);
        end
        
        function [fn, s, altfile, altbase] = get_alt_file(self, granule, spec)
            % return path to earlier file, if available, and version to
            % which it belongs
            
            
            cr_fn = self.filename;
            cr_bd = self.basedir;
            co1 = onCleanup(@()setfield(self, 'filename', cr_fn)); %#ok
            co2 = onCleanup(@()setfield(self, 'basedir', cr_bd)); %#ok
            
            if ~isempty(self.altfilename)
                self.filename = self.altfilename;
            end
            
            if ~isempty(self.altbasedir)
                self.basedir = self.altbasedir;
            end
            
            % try old versions
           
            curver = self.version;
            co = onCleanup(@()setfield(self, 'version', curver)); %#ok
            for s = {'0.7', '0.6', '0.5b', '0.5', '0.4', '0.3', '0.2', '0.1'}
                s = s{1};
                self.version = s;
                fn = self.find_granule_by_datetime(granule, spec);
                if exist(fn, 'file') % success
                    break
                else % reset
                    fn = [];
                end
            end
            self.version = curver;
            altfile = self.filename;
            altbase = self.basedir;
            
%             if isempty(fn) % no luck yet
%                 
%                 cr_fn = self.filename;
%                 cr_bd = self.basedir;
%                 co1 = onCleanup(@()setfield(self, 'filename', cr_fn));
%                 co2 = onCleanup(@()setfield(self, 'basedir', cr_bd));
%                 self.filename = self.altfilename;
%                 self.basedir = self.altbasedir;
%                 %             cand =
%                 fn = self.find_granule_by_datetime(granule, spec);
%                 if ~exist(fn, 'file')
%                     fn = [];
%                 end
            self.filename = cr_fn;
            self.basedir = cr_bd;
            self.pos2re(); % fix regexp that may have been messed up
%                 s = 0;
%                 altfile = self.altfilename;
%                 altbase = self.altbasedir;
%             end
%             self.filename = cr_fn;
%             if ~b % try with old versions
%                 curver = self.version;
%                 co2 = onCleanup(@()setfield(self, 'version', curver));
%                 for s = {'0.5b', '0.5', '0.4', '0.3', '0.2', '0.1'}
%                     self.version = s;
%                 end
%             end
        end
        
        function S = read_alt_granule(self, granule, spec)
            
%             cr_fn = self.filename;
%             self.filename = self.altfilename;
%             co = onCleanup(@()setfield(self, 'filename', cr_fn)); %#ok<SFLD>
%             ud = self.net.fit.userdata;
%             fields = fieldnames(ud.inputs);
%             needsproc = cellfun(@(X)isfield(ud.inputs.(X), 'process'), fieldnames(ud.inputs));
            [~, vers, altfile, altbase] = self.get_alt_file(granule, spec);
            crvers = self.version;
            crfile = self.filename;
            crbase = self.basedir;
            self.version = vers;
            self.filename = altfile;
            self.basedir = altbase;
            co1 = onCleanup(@()setfield(self, 'version', crvers)); %#ok
            co2 = onCleanup(@()setfield(self, 'filename', crfile)); %#ok
            co3 = onCleanup(@()setfield(self, 'basedir', crbase)); %#ok
            self.pos2re();
            try
                S = self.read_granule(granule, spec, fieldnames(self.members));
            catch ME
                switch ME.identifier
                    case 'atmlab:SatDataset:cannotread'
                        % perhaps it has additional inputs compared to
                        % 'back then'.  Try to read only the ones I really
                        % need, obtain the rest through post-processing
                        inpfields = fieldnames(self.inputs);
%                        flds = [intersect(fieldnames(self.members), ...
                        flds = cellfun(@(X) ...
                                   safegetfield(self.inputs.(X).stored, 'realname', X), ...
                                   inpfields(structfun(@(X) ~isfield(X, 'process'), self.inputs)), ...
                                   'UniformOutput', false);
                        %inpfields(structfun(@(X) ~isfield(X, 'process'), self.inputs))); 'LAT'];
                        S = self.read_granule(granule, spec, flds);
                        S = self.reader_processor(self, S, flds);
                    otherwise
                        ME.rethrow();
                end
            end
            %S = self.read_granule(granule, spec);
            self.version = crvers;
            self.filename = crfile;
            self.basedir = crbase;
            self.pos2re(); % fix regexp that may have been messed up
            %S = self.read_granule(granule, spec, fieldnames(self.members));
            %S.Surface_elevation = get_surface_elevation(S.lat, S.lon);
%             self.filename = cr_fn;
        end
    end
    
    
    methods (Access = {?SatDataset})
        
        function [S, strattr] = read_homemade_granule(self, file, varargin)
            fields = optargs(varargin, {{}});
            fields = union(vec2row(fields), {'LAT', 'LON', 'TIME'});
            [S, strattr] = read_homemade_granule@RetrievalDatabaseProduct(self, file, fields);
            S.lat = S.LAT;
            S.lon = S.LON;
            S.time = S.TIME;
            S = rmfield(S, setdiff({'LAT', 'LON', 'TIME'}, fields));
        end
        
    end
    
    methods (Access = protected)
        function noisevec = get_noise_vector(self, cols)
            % get a noise-vector responding to the columns of input data
            %
            % takes a structure 'cols', each field should correspond to a
            % self.inputs.(field) which must have a 'noise' vector
            inp_fields = fieldnames(self.inputs);
            %noisevec = zeros(self.net.inputs{1}.size, 1);
            for i = 1:length(inp_fields)
                fn = inp_fields{i};
                if isfield(self.inputs.(fn), 'chans')
                    noisevec(cols.(fn)) = self.inputs.(fn).noise(self.inputs.(fn).chans);
                else
                    noisevec(cols.(fn)) = self.inputs.(fn).noise;
                end
            end
        end

        function mask = select_for_regression(self, y, y_cols)
            % get a mask of those y-targets we want for regression
            %
            % If self.targets.(field).regression_range is set, select those
            % inside the range.  Otherwise, select all that are finite.
            %
            % WARNING! Input data from y is expected to have passed
            % through self.select_and_prepare_data, meaning that
            % 'transform' has been applied!
            %
            % IN
            %
            %   y
            %   y_cols
            mask = all(isfinite(y), 1);
            fields = fieldnames(y_cols);
            for i = 1:length(fields)
                field = fields{i};
                if isfield(self.targets.(field), 'regression_range')
                    rng = self.targets.(field).regression_range;
                    % unapply transformation
                    dat = self.targets.(field).invtransform(y(y_cols.(field), :));
                    mask = mask & (dat > rng(1));
                    mask = mask & (dat < rng(2));
                end
            end
        end
    end
    
    methods (Static)
        function dat = homog_inputs(dat, cols)
            % homogeonise in latitude (equal area-density)
            
            % Calculate how many entries to choose per
            % 1°-latitude band.
            bins = -89.5:1:89.5;
            vals = bin(dat(:, cols.LAT1), 1:size(dat, 1), bins);
            %[C, X] = hist(dat(:, cols.LAT1), floor(min(dat(:, cols.LAT2)))-0.5:1:ceil(max(dat(:, cols.LAT2)))+0.5);
            no_entries_per_lat = round(floor(par(cellfun(@length, vals), 45)/1000)*1000*cosd(bins));
            inds = arrayfun(@(i) vals{i}(1:min([length(vals{i}), no_entries_per_lat(i)])), 1:180, 'UniformOutput', false);
            dat = dat(sort(vertcat(inds{:})), :);
        end
    end
end
