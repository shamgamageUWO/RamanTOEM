function command = grdcontour(file,in)
% GRDCONTOUR appends options to GMT grdcontour
%
% PURPOSE:  Appends options to a short script and calls the GMT
% 
% IN    file      %s              .ps-file created/appened to by command
%       in        struct          options here (see help gmt_plot)
%
% OUT   command   %s              string command to be used in system call
%
% Created by Salomon Eliasson
% $Id: grdcontour.m 8362 2013-04-20 18:30:35Z seliasson $

%location of file, region and projection
grdcontour = sprintf('grdcontour %s -R -J',in.grdfile);

grdcontour = sprintf('%s %s',grdcontour,in.plotPlacement);

if isfield(in,'spacing')
    grdcontour = sprintf('%s -A%g',grdcontour,in.spacing);
end

if isfield(in,'fontsize')
    grdcontour = sprintf('%s+s%g',grdcontour,num2str(in.fontsize));
end

if isfield(in,'range')
    grdcontour = sprintf('%s -L%g-%g',grdcontour,in.range(1),in.range(2));
end

if isfield(in,'label_placement')
    grdcontour = sprintf('%s -G%s',grdcontour,in.label_placement);
else
    % 4 inches apart, no closer than .5cm from each other in xy plane
    grdcontour = sprintf('%s -Gd4i+r.5c',grdcontour); 
end

if isfield(in,'more') && ~isempty(in.more)
    grdcontour = sprintf('%s %s',grdcontour,in.more);
end

% selects Overlay plot mode and assuming more pscode will be appended
grdcontour = sprintf('%s -O -K',grdcontour);

command = sprintf('%s >> %s.ps',grdcontour,file);