classdef CollocatedMicrowaveOnlyIWP < HomemadeDataset
    % Class holding functionality for Gerrits most primivite IWP dataset
    %
    % This class performs two major roles:
    %
    % - Reading and locating granules, mostly inherited from SatDataset
    % - Retrieving IWP
    %
    % The second task depends on the Neural Network Toolbox, tested with
    % version 7.0.3 (R2012a).
    %
    % TODO:
    %
    %   - Add info on data used for training
    %   - Study performance using LESS input data
    %   - fix problem with discontinuities per lat (and lza?)
    %   - use a land-water-mask?
    
    % $Id: CollocatedMicrowaveOnlyIWP.m 8516 2013-06-26 21:33:48Z gerrit $
    
    properties (Transient)
        nets = struct();
        nchannels = 3;
        data;
        localcols;
    end
       
    properties (Transient, GetAccess = private, SetAccess = private)
       selection; 
       maxsize = 20000; % max number of entries for neural net
       retrieval_limits;
%        target_limits = ...
%             struct(...
%                 'retrieval', struct(...
%                     'MEAN_ROIWP', [eps inf], ... % positive
%                     'NO_ROIWP', [10 inf], ... % at least 10
%                     'FRAC1_ROIWP', [1 1], ... % fully cloudy
%                     'CV_ROIWP', [0 1]), ... % sd <= mean
%                 'classification', struct());
            
       fromfile;
    end
    
    properties (Transient, Constant)
        %version = 0.6;
        changelog = sprintf([...
            'version 0.0: initial version, negative IWP, linear all\n' ...
            'version 0.1: cf [0, 1], log-IWP retrieved, more descriptive atts\n', ...
            'version 0.2: more descriptive atts, cf -> cf100, improved training sel\n' ...
            'version 0.3: added lza, pos, line, fromfile; apply more lims; apply same lims to retrieved as to trained (afap)\n', ...
            'version 0.4: more flexible approach, store more fields, retrieve globally with many networks\n', ...
            'version 0.5: made global, better error checks\n', ...
            'version 0.6: don''t store when flagged, fix bug for nhpolar ...\n']);
        lims_always = struct('B_BT', [100 400]);
    end
    
    methods
        function self = CollocatedMicrowaveOnlyIWP(varargin)
            self = self@HomemadeDataset(varargin{:});
            self.setcols();
            self.setmembers();
            self.reader = @(varargin) (satreaders.netcdf_dataset(self, varargin{:}));
            self.version = 0.6;
        end
        
        function getdata(self, start_date, end_date)
            d = datasets;
            
%            self.retrieval_limits = ...
%                struct('LAT1', [-30 30], ...
%                       'POS1', [40 50], ...
%                       'B_BT', [0 400]);
            
            [M, c] = d.CollocatedDataset_mhs_cpr.read(...
                start_date, end_date, 'noaa18', ...
                {'LAT1', 'LON1', 'POS1', 'TIME1', 'B_BT', 'B_LZA', ...
                 'NO_ROIWP', 'MEAN_ROIWP', 'CV_ROIWP', 'FRAC1_ROIWP', 'FRAC10_ROIWP', 'FRAC100_ROIWP', 'FRAC1000_ROIWP'}, ...
                 self.lims_always);
             
             self.data = M;
             self.localcols = c;
             if size(M, 1) > self.maxsize
                 self.selection = unique(round(linspace(1, size(M, 1), self.maxsize)));
             else
                 self.selection = 1:size(M, 1);
             end
        end
        
        function make_and_train_network(self, name, source, kind, target, varargin)
            % name: (string)
            % source: e.g. {'B_LAT', 'B_BT', 3:5, 'B_POS'}
            % kind: @fitnet, @patternnet, ...
            % target: (string), fieldname in data to train against
            % lims_retrieval: (optional) structure, default empty
            % lims_overall: (optional), structure, default empty
            % {transform, inverse_transform} (optional): function_handle
            % for target, e.g. log10, and its inverse
            
            
            narginchk(5, 8);
            [lims_retrieval, lims_overall, transform] = optargs(varargin, {struct(), struct(), {@(x)x, @(x)x}});
            rqre_datatype(name, @ischar);
            rqre_datatype(source, @iscell);
            rqre_datatype(target, @ischar);
            rqre_datatype(kind, @isfunction_handle);
            rqre_datatype(lims_retrieval, @isstruct);
            rqre_datatype(lims_overall, @isstruct);
            rqre_datatype(transform, @iscell);
            rqre_datatype(transform{1}, @isfunction_handle);
            rqre_datatype(transform{2}, @isfunction_handle);
            
            lims = catstruct(lims_retrieval, lims_overall);
            % fill source with numbers where not present, so that each
            % string is followed by a 1, e.g.
            % {'LAT1', 'BT', 3:5} --> {'LAT1', 1, 'BT', 3:5}
            isaname = cellfun(@ischar, source);
            namewithoutno = diff([isaname true])==0;
            filler = cell(size(source));
            filler(namewithoutno) = {1};
            source = [source; filler];
            source = source(:).';
            source(cellfun(@isempty, source)) = [];
            sstruct = struct(source{:});
            % get appropiate columns in self.data
            allpos = cellfun(@(X) self.localcols.(X)(sstruct.(X)), fieldnames(sstruct), 'UniformOutput', false);
            allpos = [allpos{:}];
            
            self.needsbox();
            if isempty(self.data)
                error(['atmlab:' mfilename ':nodata'], ...
                    'No data found. Did you run .getdata(...)?');
            end

            dat = self.data;
            dat = dat(collocation_restrain(dat, limstruct2limmat(lims, self.localcols)), :);
                        
            if size(dat, 1) == 0
                logtext(atmlab('OUT'), 'Cannot train network, no data, stopping now\n');
                return
            elseif size(dat, 1) > self.maxsize
                subsel = unique(round(linspace(1, size(dat, 1), self.maxsize)));
                logtext(atmlab('OUT'), 'Reducing %d -> %d points before training\n', size(dat, 1), self.maxsize);
                dat = dat(subsel, :);
            end

            sourcedat = dat(:, allpos); % might include BT, lat, angle...
            targetdat = dat(:, self.localcols.(target));
            
            net = kind(6);
                        
            net.trainParam.showWindow = false;
            logtext(atmlab('OUT'), 'Training %s(data)...\n', func2str(transform{1}));
            net = train(net, sourcedat.', transform{1}(targetdat).');
            logtext(atmlab('OUT'), 'Trained\n');

            self.nets.(name) = net;
            self.nets.(name).userdata.name = name;
            self.nets.(name).userdata.target = target;
            self.nets.(name).userdata.kind = func2str(kind);
            self.nets.(name).userdata.source = source; % store cell-array, makes me feel safer than struct because of order
            self.nets.(name).userdata.lims = ...
                struct('retrieval', lims_retrieval, ...
                       'training', lims_overall);
            % store with func2str, otherwise entire workspace is stored
            % along with it. This is not only too large, it also causes
            % problems with 'self', which will be recreated upon
            % deserialization, causing "already exists" errors.
            self.nets.(name).userdata.transform = {func2str(transform{1}) func2str(transform{2})};
            
        end
        
        function [M, c] = retrieve(self, input_data, cols)
           % get whatever can be retrieved from all known nets
           %
           % for each row, go through each network, and if conditions are
           % met, retrieve
           %
           % cols fields must be as <network>.userdata.source
                     
           % single row impl.
           netnames = fieldnames(self.nets);
           M = zeros(size(input_data, 1), length(netnames));
           for i = 1:length(netnames)
               netname = netnames{i};
               net = self.nets.(netname);
               % apply same limitations as upon retrieval
               limmat = limstruct2limmat(catstruct(self.lims_always, net.userdata.lims.retrieval), cols);
               % logical true for rows where conditions are OK
               OK = collocation_restrain(input_data, limmat);
               % initialise matrix
               M(:, i) = nan(size(input_data, 1), net.numOutputs);
               c.(netname) = i;
               
               fnms = net.userdata.source(1:2:end);
               src = net.userdata.source;
               sstruct = struct(src{:});
               colnos = cellfun(@(X) cols.(X)(sstruct.(X)), fnms, 'UniformOutput', false);
               % apply the network
               retr = net(input_data(OK, [colnos{:}]).');
               % inverse transform
               ivt = str2func(net.userdata.transform{2});
               M(OK, i) = ivt(retr);
           end
        end

        %{
        function make_retrieval_net(self, lims)
            % prepare neural network with BT and IWP
            %
            % takes BT, IWP. Warning; each row is a channel, each column a
            % collocation. This is opposite of Collocations Toolbox.
            
            self.needsbox();
            if isempty(self.data)
                error(['atmlab:' mfilename ':nodata'], ...
                    'No data found. Did you run .getdata(...)?');
            end
            
            dat = self.data;
            dat = dat(collocation_restrain(dat, limstruct2limmat(self.target_limits.retrieval, self.localcols)), :);
            dat = dat(collocation_restrain(dat, limstruct2limmat(lims, self.localcols)), :);
            
            if size(dat, 1) > self.maxsize
                subsel = unique(round(linspace(1, size(dat, 1), self.maxsize)));
                dat = dat(subsel, :);
                logtext(atmlab('OUT'), 'Reducing to %d points before training\n', self.maxsize);
            end
            
            BT = dat(:, self.localcols.B_BT(3:5));
            IWP = dat(:, self.localcols.MEAN_ROIWP);

            net = fitnet(6);
            net.trainParam.showWindow = false;
            logtext(atmlab('OUT'), 'Training...\n');
            net = train(net, BT.', log10(IWP).');
            logtext(atmlab('OUT'), 'Trained\n');
            
            self.nets.retrieval = net;
            self.nets.retrieval.userdata.retrieval_limits = self.retrieval_limits;
            self.nets.retrieval.userdata.training_limits = self.training_limits;
        end
        
        function make_classification_net(self)
            % prepare neural net with BT and cloudfrac
            
            self.needsbox();
            BT = self.data(self.selection, self.localcols.B_BT(3:5)).';
            cloudfrac100 = self.data(self.selection, self.localcols.FRAC100_ROIWP).';
            net = patternnet(6);
            net.trainParam.showWindow = false;
            logtext(atmlab('OUT'), 'Training...\n');
            net = train(net, BT, cloudfrac100);
            logtext(atmlab('OUT'), 'Trained\n');
            self.nets.classification100 = net;
            self.nets.classification100.userdata.retrieval_limits = self.retrieval_limits;
            self.nets.classification100.userdata.training_limits = self.training_limits;
        end
%}        
        
        function makenets(self)
            % make many nets, quite hardcoded
            
            latrange.antarctic = [-90 -60];
            latrange.shmidlat = [-60 -30];
            latrange.tropical = [-30 30];
            latrange.nhmidlat = [30 60];
            latrange.nhpolar = [60 90];
            
            angrange.nadir = [0 5];
            angrange.smallang = [5 15];
            angrange.midang = [15 25];
            angrange.bigang = [25 35];
            
            train_iwp.MEAN_ROIWP = [realmin realmax];
            train_iwp.NO_ROIWP = [10 intmax];
            train_iwp.FRAC1_ROIWP = [1 1];
            train_iwp.CV_ROIWP = [0 1];

            train_cf = struct();
            
            lrfn = fieldnames(latrange);
            arfn = fieldnames(angrange);
            for i = 1:length(lrfn)
                for j = 1:length(arfn)
                    lr = lrfn{i};
                    ar = arfn{j};
                    retr_lims.LAT1 = latrange.(lr);
                    retr_lims.B_LZA = angrange.(ar);
                                        
                    logtext(atmlab('OUT'), 'Training %s %s FIWP\n', lr, ar);

                    self.make_and_train_network(...
                        [lr '_' ar '_fiwp'], ...
                        {'B_BT', 3:5}, ...
                        @fitnet, ...
                        'MEAN_ROIWP', ...
                        retr_lims, ...
                        train_iwp, ...
                        {@log10, @(x)10.^x});
                                        
                    logtext(atmlab('OUT'), 'Training %s %s CF100\n', lr, ar);

                    self.make_and_train_network(...
                        [lr '_' ar '_fc100'], ...
                        {'B_BT', 3:5}, ...
                        @patternnet, ...
                        'FRAC100_ROIWP', ...
                        retr_lims, ...
                        train_cf, ...
                        {@(x)x, @(x)x});
                end
            end

        end
        function storenets(self, fl)
            self.needsbox();
            self.fromfile = fullfile(self.basedir, fl);
            logtext(atmlab('OUT'), 'Storing networks to %s\n', self.fromfile);
            fns = fieldnames(self.nets);
            for i = 1:length(fns)
                if isa(self.nets.(fns{i}), 'network')
                    self.nets.(fns{i}).userdata.stored = self.fromfile;
                end
            end
            nt = self.nets; %#ok<NASGU>               
            save(self.fromfile, 'nt');
        end
        
        function loadnets(self, fl)
            self.needsbox();
            self.fromfile = fullfile(self.basedir, fl);
            logtext(atmlab('OUT'), 'Loading networks from %s\n', self.fromfile);
            self.nets = loadvar(self.fromfile, 'nt');
        end
        
        function retrieve_and_store_gran(self, dt, spec)
            self.needsbox();
            if isempty(self.fromfile)
                error(['atmlab:' mfilename ':nonet'], ...
                    'First get network from or store network to file!');
            end
            d = datasets;
            ds = d.(amsub_or_mhs(spec));
            grandata = ds.read_granule(dt, spec);
            %graninfo = ds.find_info_from_granule(ds.find_granule_by_datetime(dt, spec));
            grandata.pos = repmat((1:size(grandata.lat, 2)), [size(grandata.lat, 1), 1]);
            grandata.line = repmat((1:size(grandata.lat, 1)).', [1 size(grandata.lat, 2)]);
            grandata.time = repmat(grandata.time, [1 90]);
            
            mytb = reshape(grandata.tb, [numel(grandata.lat) size(grandata.tb, 3)]);
            
            % need LAT1, B_LZA, B_BT
            cols.LAT1 = 1;
            cols.B_LZA = 2;
            cols.B_BT = 3:7; % for retrieve, have to provide all, even if only 3 used, because of storing of limitations struct
            M_in = zeros(numel(grandata.lat), 7);
            M_in(:, cols.LAT1) = grandata.lat(:);
            M_in(:, cols.B_LZA) = grandata.lza(:);
            M_in(:, cols.B_BT) = mytb;
            logtext(atmlab('OUT'), 'Retrieving values\n');
            [M_retr ~] = self.retrieve(M_in, cols);
            fiwp = nanmean(M_retr(:, 1:2:size(M_retr, 2)), 2);
            cf100 = nanmean(M_retr(:, 2:2:size(M_retr, 2)), 2);
            ciwp = uint16(fiwp .* cf100);
            %cf100 = self.nets.classification100(mytb(:, 3:5).');
            %fiwp = 10.^self.nets.retrieval(mytb(:, 3:5).');
            %ciwp = cf100 .* fiwp;
            logtext(atmlab('OUT'), 'Post-processing\n');
            unflagged = isfinite(fiwp) & isfinite(cf100);
            M = zeros(numel(grandata.lat), max(structfun(@(x)max(x), self.cols)));
            M(:, self.cols.mhs_bt_345) = mytb(:, 3:5);
            M(:, self.cols.lat) = grandata.lat(:);
            M(:, self.cols.lon) = grandata.lon(:);
            M(:, self.cols.time) = grandata.time(:);
            M(:, self.cols.cf100) = cf100;
            M(:, self.cols.fiwp) = fiwp;
            M(:, self.cols.ciwp) = ciwp;
            M(:, self.cols.lza) = grandata.lza(:);
            M(:, self.cols.pos) = grandata.pos(:);
            M(:, self.cols.line) = grandata.line(:);
            M = M(unflagged, :);
%            storelims.lat = self.nets.retrieval.userdata.retrieval_limits.LAT1;
%            storelims.pos = self.nets.retrieval.userdata.retrieval_limits.POS1;
%            storelims.mhs_bt_345 = self.nets.retrieval.userdata.retrieval_limits.B_BT;
%            M = M(collocation_restrain(M, limstruct2limmat(storelims, self.cols)), :);
            M = sortrows(M, [self.cols.time, self.cols.pos]);
            info.title = 'MW-only IWP from ANN trained with CPR collocs';
            info.version = sprintf('%03.1f', self.version);
            info.history = self.changelog;
            info.source = 'Retrieved from collocated CPR/MHS MW-only-trained ANN';
            info.nnet = self.fromfile;
%            info.stored_lims = struct2string_compact(storelims);
            % FIXME: more additional info
            logtext(atmlab('OUT'), 'Storing\n');
            self.store(dt, spec, M, info);
        end
        
        function setcols(self)
            self.cols.lat = 1;
            self.cols.lon = 2;
            self.cols.time = 3;
            self.cols.cf100 = 4;
            self.cols.fiwp = 5;
            self.cols.ciwp = 6;
            self.cols.lza = 7;
            self.cols.mhs_bt_345 = 7:9;
            self.cols.pos = 10;
            self.cols.line = 11;
        end
        
        function setmembers(self)
            self.members.lat.type = 'float';
            self.members.lat.atts.long_name = 'Latitude';
            self.members.lat.atts.valid_range = [-90 90];
            self.members.lat.atts.units = 'degrees_north';
            
            self.members.lon.type = 'float';
            self.members.lon.atts.long_name = 'Longitude';
            self.members.lon.atts.units = 'degrees_east';
            self.members.lon.atts.valid_range = [-180 180];
            
            self.members.time.type = 'int';
            self.members.time.atts.long_name = 'Measurement time';
            self.members.time.atts.units = 'Seconds since 1970-01-01 00:00:00';
            
            self.members.cf1.type = 'float';
            
            self.members.cf10.type = 'float';
            
            self.members.cf100.type = 'float';
            self.members.cf100.atts.long_name = 'Cloud fraction >= 100 g/m^2';
            self.members.cf100.atts.valid_range = [0 1];
            self.members.cf100.atts.description = ...
                ['Estimate of fraction of footprint with cloud ' ...
                 '> 100 g/m^2. Retrieved with ANN trained against ' ...
                 'number of CPR > 100 g/m^2 within AMSUB/MHS ' ...
                 'footprint.'];
             
            self.members.fiwp.type = 'float';
            self.members.fiwp.atts.long_name = 'Full uncorrected Ice Water Path';
            self.members.fiwp.atts.description = ...
                ['Uncorrected Ice Water Path. Does not take into' ...
                 'account whether a cloud is present or not.'];
            self.members.fiwp.atts.units = 'g/m^2';
            
            self.members.ciwp.type = 'int';
            self.members.ciwp.atts.units = 'g/m^2';
            self.members.ciwp.atts.long_name = 'CF-corrected IWP';
            self.members.ciwp.atts.description = ...
                ['CF-Corrected Ice Water Path. This is the product ' ...
                 'of fiwp and cf100. This is a more conservative ' ...
                 'estimate of IWP than fiwp, guessing closer to 0 ' ...
                 'if presence of a cloud is not sure.'];
             
            self.members.lza.type = 'float';
            self.members.lza.atts.long_name = 'Local zenith angle';
            self.members.lza.atts.description = ...
                ['Local zenith angle from AMSU-B/MHS granule. See ' ...
                 'KLM User Guide for details.'];
            self.members.lza.atts.units = 'degrees';
            
            self.members.mhs_bt_345.type = 'float';
            self.members.mhs_bt_345.dims = {'CHANNELS', 3};
            self.members.mhs_bt_345.atts.long_name = 'MHS brightness temperatures for the used channel 3, 4 and 5';
            self.members.mhs_bt_345.atts.units = 'Kelvin';
            
            self.members.pos.type = 'byte';
            self.members.pos.atts.long_name = 'AMSU-B/MHS scanline position';
            
            self.members.line.type = 'int';
            self.members.line.atts.long_name = 'AMSU-B/MHS scanline number';
        end
        
    end
    
    methods (Access = private, Static)
        function needsbox()
            v = ver('nnet');
            if isempty(v)
                ST = dbstack;
                error(['atmlab:' mfilename ':needsNNet'], ...
                    ['Method ' ST(2).name ' needs the Neural Network toolbox']);
            end
        end
    end
    
end
