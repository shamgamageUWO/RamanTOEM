function command = grdimage(file,in)
% GRDIMAGE appends options to GMT grdimage
%
% purpose: Appends options to a short script and calls the GMT
%
% IN    file      %s              .ps-file created/appened to by command
%       cptfile   %s              .cpt-file used for grdimage from makecpt.m
%
% OUT   command   %s              string command to be used in system call
%
% Created by Salomon Eliasson
% $Id: grdimage.m 7157 2011-09-18 10:38:57Z seliasson $

grdimage = 'grdimage';

%location of file, region and projection
grdimage = sprintf('%s %s -R -J',grdimage,in.grdfile);

%Use nearestneigbour interpolation, only use the nearest grid point
%Otherwise the default bicubic interpolation introduces artifacts.
grdimage = sprintf('%s -S-n/0',grdimage);

grdimage = sprintf('%s %s',grdimage,in.plotPlacement);

% selects Overlay plot mode and assuming more pscode will be appended
grdimage = sprintf('%s -O -K',grdimage);

%colortable
grdimage = sprintf('%s -C%s',grdimage,in.plot.color.cptfile);

command = sprintf('%s >> %s.ps',grdimage,file);