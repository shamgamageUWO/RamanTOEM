function save_figure_multi(fig, pathbase, varargin)

% save figure in multiple formats
%
% Save a figure in multiple formats.  Pass the basename and this function
% will write basename.{png,eps,fig}, for example.
%
% FORMAT
%
%   save_figure_multi(fig, pathbase, format1, format2, ...)
%
% IN
%
%   fig         Figure handle, figure to be stored
%   format1     String of first format to store to.  The string is equal to
%               the extention: 'png', 'pdf', 'eps', etc.  Special cases:
%               - 'fig' will store a Matlab figure object
%               - 'ps' and 'eps' will store psc and epsc, respectively
%
% OUT
%
%   none, but writes a file
%
% EXAMPLE
%
%   >> save_figure_multi(gcf(), 'plots/this_plot', 'png', 'eps', 'fig');

formats = varargin;
if isempty(formats)
    logtext(atmlab('OUT'), 'No formats specified, not writing any files\n');
end
for i = 1:length(formats)
    format = formats{i};
    outname = [pathbase '.' format];
    logtext(atmlab('OUT'), 'Storing %s\n', outname);
    switch format
        case {'ps', 'eps'}
            print(fig, sprintf('-d%sc', format), outname);
        case {'fig'}
            hgsave(fig, outname);
        otherwise
            print(fig, sprintf('-d%s', format), outname);
    end
end

end
