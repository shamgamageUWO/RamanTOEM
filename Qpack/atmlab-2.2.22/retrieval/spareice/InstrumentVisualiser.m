classdef InstrumentVisualiser < handle
    
    % mixin with functionality to visualise performance etc.
    %
    % InstrumentVisualiser Methods:
    %
    %   plot_performance_with_requirements - 
    %   plot_channels_bt - 
    %
    % See also: IceMusicNNIWP, RetrievalDatabaseProducte, NNTrainedProduct

    
    properties (Abstract)
        opts
    end
    
%     properties (Constant, Abstract)
%         detect_limit 
%         accuracy 
%     end
    
    methods (Abstract)
        evaluate_test_data(self, noise_level)
        get_performance(self, noise_level)
    end    
    
    methods
        %         function self = InstrumentVisualiser(varargin)
        %             self = self@DBIWP(varargin{:});
        %         end
        
        
        function plot_performance_with_requirements(self, noise_level, varargin)
            
            % Plots performance with requirements.
            %
            % Makes two plots; absolute and relative scales.
            %
            % Single argument is basename for output files.
            %
            % if given, detect_limit and accuracy are structures describing
            % the detection limit and accuracy
            
            [detect_limit, accuracy] = optargs(varargin, {[], []});
            doreq = nargin > 2;
            
%             [x, y] = self.evaluate_test_data(0.1);
%             filt = (x>0) & (y>0) & isfinite(x) & isfinite(y);
%             
%             x = x(filt);
%             y = y(filt);
%             
%             % calculate different ways to get performance
%             abs_medad = cellfun(@(yy) mad(yy, 1), bin(log10(x), y, self.opts.bins));
%             abs_meanad = cellfun(@(yy) mad(yy, 0), bin(log10(x), y, self.opts.bins));
%             abs_rmeanse = cellfun(@(dy) rms(dy), bin(log10(x), y-x, self.opts.bins));
%             abs_rmedse = cellfun(@(dy) sqrt(median(dy.^2)), bin(log10(x), y-x, self.opts.bins));
%             abs_ir = cellfun(@iqr, bin(log10(x), y, self.opts.bins));
%             rel_medfracerr = cellfun(@median, bin(log10(x), abs(y-x)./x, self.opts.bins));
%             abs_medfracerr = rel_medfracerr .* (10.^self.opts.bins);
%             rel_rmeanse_frac = cellfun(@(dy) rms(dy), bin(log10(x), abs(y-x)./x, self.opts.bins));
%             abs_rmeanse_frac = rel_rmeanse_frac .* (10.^self.opts.bins);
%             
%             xx = 10.^(self.opts.bins);
            %           self.binned_mad(x(filt), y(filt), self.opts.bins);
            
            %% make "absolute" plot
            
%            [xx, S] = self.get_performance_with_requirements(0.1);
            [xx, S] = self.get_performance(noise_level);
          
            figure();
            % plot various ways to visualise error
            plot(xx, S.abs_medad, ...
                xx, S.abs_meanad, ...
                xx, S.abs_rmeanse, ...
                xx, S.abs_rmedse, ...
                xx, S.abs_ir, ...
                xx, S.abs_medfracerr, ...
                xx, S.abs_rmeanse_frac);
            legend('median absolute deviation', ...
                'mean absolute deviation', ...
                'root mean square error', ...
                'root median square error', ...
                'inter-quantile range', ...
                'median fractional error', ...
                'root mean square fractional error', ...
                'Location', 'NorthWest');
            
            hold on;
            
            if doreq
                crit_treshhold = detect_limit.treshhold / accuracy.treshhold;
                crit_target = detect_limit.target / accuracy.target;
                
                % make sure target/treshhold lines are continuous
                xxx = sort([xx; crit_target; crit_treshhold]);
                
                % calculate upper treshhold = 10 g/m^2
                acc_tresh = xxx.*accuracy.treshhold;
                acc_targ = xxx.*accuracy.target;
                
                % plot target and treshhold
                plot(xxx(acc_tresh>=detect_limit.treshhold), acc_tresh(acc_tresh>=detect_limit.treshhold), 'k--')
                plot(xxx(acc_targ>=detect_limit.target), acc_targ(acc_targ>=detect_limit.target), 'k--');
                
                % plot detection limits
                plot([1e-1, crit_treshhold], [detect_limit.treshhold detect_limit.treshhold], 'k--');
                plot([1e-1, crit_target], [detect_limit.target detect_limit.target], 'k--');
            end
            
            % xx*(1+self.accuracy.target)=10
            
            set(gca(), 'YScale', 'log', 'XScale', 'log', 'XLim', [5*1e-1 1e3], 'YLim', [5*1e-1 1e3])
            
            title([self.name ' performance, trop. nad. all chans']);
            xlabel('IWP [g/m^2]');
            ylabel('IWP error [g/m^2]');
            grid('on');
            
            [~, b] = fileparts(self.net.userdata.stored);
            save_figure_multi(gcf(), ...
                fullfile(cscol('plot_base'), [b '_abs']), ...
                'png', 'eps', 'fig');
            
            %% make "relative" plot
            
            figure();
            plot(xx, 100*S.rel_medfracerr);
            
            % plot target and treshhold
            %           plot(xxx(acc_tresh>=self.detect_limit.treshhold), self.detect_limit.treshhold, 'k--')
            %           plot(xxx(acc_targ>=self.detect_limit.target), acc_targ(acc_targ>=self.detect_limit.target), 'k--');
            
            legend('median fractional error');
            ylim([0 100]);
            xlim([0 3000]);
            xlabel('IWP [g/m^2]');
            ylabel('IWP error [%]');
            title([ self.name ' performance, trop. nad. all chans']);
            grid('on');
            save_figure_multi(gcf(), ...
                              fullfile(cscol('plot_base'), [b '_rel']), ...
                              'png', 'eps', 'fig');
            
        end
        
        function plot_channels_bt(self)
            % for all channels, plot BT vs. log10(IWP)
            
            ff = self.data(:, self.localcols.IWP)>0;
            op.transx = @(x)log10(x);
            op.invtransx = @(x)10.^(x);
            op.axprops.xscale = 'log';
            
            for i = self.chans
                figure();
                scatter_density_plot(self.data(ff, self.localcols.IWP), self.data(ff, self.localcols.BT(i)), op);
                xlabel('IWP [g/m^2]');
                ylabel('BT [K]');
                title(sprintf('BT/IWP Ch. %d (%s GHz)', self.chans(i), self.freqs{i}));
                print('-depsc', fullfile(cscol('plot_base'), sprintf('icemusic_btiwp_ch%d.eps', i)));
            end
        end
        
        function iwc_profile_errorhist(self, varargin)
            % visualise IWC error as a function of height, statistically
            
            % get data to go into histogram plot
            [x, y_ref, y_retr, x_cols, y_cols] = self.evaluate_test_data(varargin{:});
            dlogy = log10(y_ref(:, y_cols.IWC)) - log10(y_retr(:, y_cols.IWC));
            bins = linspace(-4, 4, 40);
            y_axis = linspace(4.5, 15, 21); % FIXME: read from data
            [N, X] = arrayfun(@(i) hist(dlogy(:, i), bins), 1:size(dlogy, 2), 'UniformOutput', false);
            
            % plot everything
            pcolor(10.^(X{1}), y_axis, vertcat(N{:}));
            shading('flat');
            hold('all');
            grid('on');
            plot(10.^median(dlogy, 1), y_axis, 'k-', 'LineWidth', 2);
            set(gca, 'XScale', 'log', ...
                     'layer', 'top', ...
                     'XLim', [1e-2 1e2]); 
            title(strrep([self.name ' IWC error'], '_', ' '));
            xlabel('IWC retrieved / reference');
            ylabel('Height [km]');
            cb = colorbar;
            ylabel(cb, 'No. profiles');
            [~, b] = fileparts(self.net.userdata.stored);
            save_figure_multi(gcf(), fullfile(cscol('plot_base'), [b '_iwchist']), 'eps', 'png', 'fig');

        end
    end
    
end
