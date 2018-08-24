function splitax(oldax, N, varargin)

% splitax Split axes h in N vertical subplots
%
% Cuts x-axis in N equally sized parts and plots data from axes h in N
% subplots below each other. Will create a new figure.
%
% FORMAT
%
%   splitax(ax, N[, opts])
%
% IN
%
%   ax      handle to axes to be copied
%   N       number of subplots to split it in
%   opts    structure with options:
%       legend      copy legend, defaulte false
%
%

% $Id: splitax.m 7900 2012-09-26 16:28:14Z gerrit $

extra = optargs(varargin, {struct()});
opts = optargs_struct(extra, ...
    struct('legend', 0));

fig = figure('Visible', get(get(oldax, 'Parent'), 'Visible'));
newax = zeros(1, N);
oldlim = get(oldax, 'XLim');
oldrange = oldlim(2) - oldlim(1);

if opts.legend
    Ntot = N+1;
else
    Ntot = N;
end

for i = 1:N
    newax(i) = subplot(Ntot, 1, i);
    % copy all children of 'h' to new subplot
    copyobj(get(oldax, 'Children'), newax(i));
    % set xlim correctly
    set(newax(i), 'xlim', [oldlim(1) + (i-1)*oldrange/N, ...
                           oldlim(2) - (N-i)*oldrange/N], ...
                  'XGrid', get(oldax, 'XGrid'), ...
                  'YGrid', get(oldax, 'YGrid'));
    % copy labels
    %xlabel(get(get(h, 'XLabel'), 'String'));
    ylabel(get(get(oldax, 'YLabel'), 'String'));
    ylim(get(oldax, 'YLim'));
end

if (opts.legend)
    leg = findobj('Tag', 'legend', 'Parent', get(oldax, 'Parent'));
    if isempty(leg)
        error(['atmlab:' mfilename ':nolegend'], ...
            ['Legend was requested to be copied ' ...
            'but no legend was found in ' ...
            'parent figure!']);
    end
    copyobj(leg, fig);
    newleg = findobj('Tag', 'legend', 'Parent', fig);
    % make invisible new subplot to check where to place legend
    sp = subplot(Ntot, 1, Ntot);
    set(sp, 'Visible', 'off');
    spNpos = get(sp, 'Position');
    legpos = get(newleg, 'Position');
    legpos(1) = spNpos(1);
    legpos(2) = 0;
    set(newleg, 'Position', legpos);
end

%xlabel(get(get(h, 'XLabel'), 'String'));

% suptitle calls axes() which sets figure to visible, may not want that!
vis = get(gcf(), 'Visible');
suptitle(get(get(oldax, 'Title'), 'String'));
set(gcf(), 'Visible', vis);
%htax = get(ht, 'Parent');
xlabel(newax(N), get(get(oldax, 'XLabel'), 'String'));
%ylabel(htax, get(get(h, 'YLabel'), 'String'));

end
