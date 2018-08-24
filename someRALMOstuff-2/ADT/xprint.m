% xprint(filename,[format])
%
% xprint saves the current figure as filename.fig, filename.eps and
% filename.pdf
%
% if format is specified ('fig','eps','pdf','png'), only the this format is
% generted.
%
function xprint(filename,format)

if nargin==1
    format='qqq';
end

% save figure as matlab fig
if nargin==1 || strcmp(format,'fig')==1
    saveas(gcf,filename,'fig');
end

if strcmp(format,'fig')==1
    return
end

% create eps
if nargin==1 || strcmp(format,'eps') || strcmp(format,'pdf')
    set( gcf, 'Renderer', 'Painters');
    drawnow;
    print( '-depsc2', '-loose', filename );
end

% create pdf
if nargin==1 || strcmp(format,'pdf')==1
    unix(['epstopdf ' filename '.eps']);
end

if strcmp(format,'pdf')==1
    unix(['rm ' filename '.fig']);
    unix(['rm ' filename '.eps']);
    return
end

% create png
if strcmp(format,'png')==1
     print( '-dpng','-r600','-loose', filename );
end
