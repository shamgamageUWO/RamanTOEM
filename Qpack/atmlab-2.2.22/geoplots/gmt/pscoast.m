function command = pscoast(file,in)
% PSCOAST appends options to GMT pscoast
%
% PURPOSE:  Appends options to a short script and calls the GMT
% 
% IN    file      %s              .ps-file created/appened to by command
%       in        struct          options here (see help gmt_plot)
%
% OUT   command   %s              string command to be used in system call
%
% Created by Salomon Eliasson
% $Id: pscoast.m 8362 2013-04-20 18:30:35Z seliasson $

pscoast = sprintf('pscoast -R -J');

pscoast = sprintf('%s %s',pscoast,in.plotPlacement);

% selects Overlay plot mode and assuming more pscode will be appended
pscoast = sprintf('%s -O -K',pscoast);

% set the minimal area of features to plot
if isfield(in,'features')
    pscoast = sprintf('%s -A%g',pscoast,in.features);
end

if isfield(in,'resolution')
    pscoast = sprintf('%s -D%s',pscoast,in.resolution);
end

if isfield(in,'rivers')
    pscoast = sprintf('%s -I%s',pscoast,in.rivers);
    if isfield(in,'color') % for rivers
        pscoast = sprintf('%s/%s',pscoast,in.color);
    end
end

%Draw coastlines. Append attributes [Defaults: width = 1, color = black, texture = solid].
if isfield(in,'width')
    pscoast = sprintf('%s -W%gp',pscoast,in.width);
else pscoast = sprintf('%s -W',pscoast);
end
if isfield(in,'color') %for coast
    pscoast = sprintf('%s/%s',pscoast,in.color);
end

command = sprintf('%s >> %s.ps',pscoast,file);