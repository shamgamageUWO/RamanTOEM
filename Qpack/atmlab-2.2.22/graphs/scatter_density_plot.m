function [h_ax, h_cb] = scatter_density_plot(x, y, varargin)

%% scatter_density_plot Create scatter density plot in style of Eliasson et. al (2013)
%
% Create a scatter-density plot in the style of Eliasson et. al (2013).
% This routine plots a 2-dimensional histogram between the provided
% variables, optionally plotting median y(x), median x(y) and the actual
% measurement points in the same graph.
%
% Adding labels, titles, axes-properties etc. is not done in this function,
% but should be done by the user manually, or by passing the 'axprops'
% option. See below for an example.
%
% IN
%
%   x       vector  data on x-axis
%   y       vector  data on y-axis
%   opts    structure with options:
%       bins        no. bins or vector with all bins (see hist2d)
%       xbins       bins for x only (default: equal to bins)
%       ybins       bins for y only (default: equal to bins)
%       trans       transformation, e.g. @(x)log10(x) on both axis
%       invtrans    inverse of trans, e.g. @(x)10.^(x) on both axis
%       transx       transformation, e.g. @(x)log10(x)
%       invtransx    inverse of trans, e.g. @(x)10.^(x)
%       axprops     structure with axes properties
%       ncolour     number of unique colours
%       scatprops   if defined, structure with props for scatter-points
%       diagonal    if defined, structure with props for diag-line
%       medprops    if defined, structure or array of two structures
%                   with props for median-lines.  If those are two
%                   structures, the first is used for medians as a
%                   function of x, the second for medians as a function
%                   of y.
%                   Additional fields that can be included in opts.medprops:
%                   'atleastN'    Only calculate median where there are
%                                 atleast N binned values. 
%                   legend.names  = {names} to be displayed in a legend related to the median lines
%              e.g. legend.Location = 'NorthWest'
%                   etc. (except for legend.names, fieldnames and options must be valid for legend() )
%       linreg      if defined, structure with props for linreg-line
%       normalise   string representing how to normalise, if at all:
%                   'none'  (default) just write collocs
%                   'x'     normalise per x-bin
%                   
%       ...
%   
% OUT
%
%   h_ax     handle to main axes
%   h_cb     handle to colourbar-axes
%
% EXAMPLE
%
%   To compare IWP products with logarithmic axes, one may use e.g.:
%
%   opts.trans = @(x)log10(x);   % provide transformation on both axis
%   opts.invtrans = @(x)10.^(x); % inverse transformation on both axis
%   opts.transx = @(x)log10(x);   % provide transformation
%   opts.invtransx = @(x)10.^(x); % inverse transformation
%   opts.axprops.xscale = 'log'; % logarithmic x-scale
%   opts.axprops.yscale = 'log'; % idem dito
%   opts.medprops = struct('LineWidth', 3, 'LineStyle', '-', 'Color', [0 0 0]);
%   [h_ax, h_cb] = scatter_density_plot(x, y, opts);
%
% $Id: scatter_density_plot.m 8777 2014-02-12 12:45:13Z gerrit $
% Created by Gerrit Holl based on code from Salomon Eliasson
%
% See also: hist, hist2d, bin, median

% set default values and handle options
defaults = struct(...
    'bins', 50, ...
    'xbins', [], ...
    'ybins', [], ...
    'trans', @(x)x, ...
    'transx',[],...
    'transy',[],...
    'invtrans', @(x)x, ...
    'invtransx', [], ...
    'invtransy', [], ...
    'axprops', struct(), ...
    'ncolour', 20, ...
    'medprops', [], ...
    'scatprops', [], ...
    'diagonal', [], ...
    'linreg', [], ...
    'normalise', '(none)');
opts = optargs(varargin, {defaults});

opts = optargs_struct(opts, defaults);

if isempty(opts.xbins)
    opts.xbins = opts.bins;
end

if isempty(opts.ybins)
    opts.ybins = opts.bins;
end

if isempty(opts.transx)
   opts.transx = opts.trans;
   opts.invtransx = opts.invtrans;
end

if isempty(opts.transy)
   opts.transy = opts.trans;
   opts.invtransy = opts.invtrans;
end


% create the actual 2-d histogram. Apply forward transformation upon data,
% then inverse transformation upon plotting. This allows for, e.g.
% logarithmic representations.
[N, BX, BY] = hist2d(opts.transx(x), opts.transy(y), opts.xbins, opts.ybins);
xbins = BX(1, :);
ybins = BY(:, 1);

paddedx = [xbins(1)-diff(xbins(1:2)),xbins,xbins(end)+diff(xbins(1:2))];
paddedy = [ybins(1)-diff(ybins(1:2));ybins;ybins(end)+diff(ybins(1:2))];
paddedN = [zeros(1,size(N,2)+2);[zeros(size(N,1),1),N,zeros(size(N,1),1)];zeros(1,size(N,2)+2)];

switch opts.normalise
    case '(none)' % do nothing
    case 'x'
        newpaddedN = bsxfun(@rdivide, paddedN, sum(paddedN, 1));
        newpaddedN(:, sum(paddedN, 1)==0) = 0;
        paddedN = newpaddedN;
    otherwise
        error(['atmlab:' mfilename ':invalid', ...
            'Invalid option for normalise: %s. See help.'], opts.normalise);
end

%% plot the actual 2d-histogram
pcolor(opts.invtransx(paddedx), opts.invtransy(paddedy), paddedN);
%pcolor(opts.invtransx(xbins), opts.invtransy(ybins), N);

set(gca(), opts.axprops);
shading('flat');

% use a custom colour-table, most notably with white as the base colour
largecolour = getColourTable(length(unique(N)),opts);
set(gcf(), 'colormap', largecolour);

%% plot medians

%plot_quantiles();
hold('on');
if ~isempty(opts.medprops)
    plot_medians(x, y, paddedx, paddedy, opts);
end

%% plot actual measurements

if ~isempty(opts.scatprops)
    plot(x, y, opts.scatprops);
end

%% plot diagonal

if ~isempty(opts.diagonal)
    plot([1e-3 1e6], [1e-3 1e6], opts.diagonal);
end
%plot_medians(y, x, ybins, opts);

%% plot linreg

if ~isempty(opts.linreg)
    p = polyfit(x, y, 1);
    xx = linspace(min(x), max(x), 10);
    yy = polyval(p, xx);
    plot(xx, yy, opts.linreg);
end



%% tweak the looks

axis('square');
grid('on');
set(gca(), 'layer', 'top'); % otherwise grid is below everything

h_ax = gca();
h_cb = colorbar();

hold('off');
end

function plot_medians(x, y, xbins, ybins, opts)

binned_x = bin(opts.transx(x), opts.transy(y), xbins);
binned_y = bin(opts.transy(y), opts.transx(x), ybins);

if isfield(opts.medprops,'atleastN')
    binned_x(cellfun(@numel,binned_x)<opts.medprops(1).atleastN)={NaN};
    binned_y(cellfun(@numel,binned_y)<opts.medprops(1).atleastN)={NaN};
    opts.medprops = rmfield(opts.medprops,'atleastN');
end
medians_x = cellfun(@median, binned_x);
medians_y = cellfun(@median, binned_y);

% do some extra things related to median lines before passing options to
% the plot function
if isfield(opts.medprops,'legend')
    leg = opts.medprops.legend;
    opts.medprops = rmfield(opts.medprops,'legend');
end



t(1) = plot(opts.invtrans(xbins), opts.invtrans(medians_x), opts.medprops);
t(2) = plot(opts.invtrans(medians_y), opts.invtrans(ybins), opts.medprops(length(opts.medprops)));

if exist('leg','var')
    lh = legend(t,leg.names);
    leg = rmfield(leg,'names');
    for F = fieldnames(leg)'
        set(lh,F{1},leg.(F{1}))
    end
end

end

function largecolor = getColourTable(Nunique,opt)
%% getColorTable Make custom colourtable with white for 0 
%
% Custom colour-table
% Nunique should be the number of unique values. This is so that every
% thing except 0 gets a colour

% greentoblue
% blue to red
%COLORS
tot = ceil(Nunique);
ncolour = min([opt.ncolour,tot]);
white = [1 1 1];
w2b=[(.93:-.93/(ceil(ncolour/3) -1):0)',...
    (.93:-.93/(ceil(ncolour/3) -1):0)',...
    ones(ceil(ncolour/3),1)]; % white2blue

b2r=[(0:1/(2*ceil(ncolour/3)-1):1)',...
    zeros(2*ceil(ncolour/3),1),...
    (1:-1/(2*ceil(ncolour/3)-1):0)']; %blue2red

colours=[w2b;b2r(2:end,:,:)];
largecolor = zeros(tot,3);
n=0;
step = ceil(tot/ncolour);
for t = 1:size(colours,1)%ncolor
    largecolor(n+1:n+step,:) = ...
        repmat(colours(t,:),length(n+1:n+step),1);
    n = step+n;
end

largecolor(1,:) = white;

end
