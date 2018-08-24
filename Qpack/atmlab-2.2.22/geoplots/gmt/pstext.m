function command = pstext(file,in,placement)
% PSTEXT Make text to overlay GMT plot
% (x, y, size, angle, fontno, justify, text) see help gmt_plot
% IN      file     %s       file to append to
%         in       struct   options here (see help gmt_plot)
%         placement %s      string command about where to pu the map
%         (common to all commands)
%
% OUT     command str     string command for systemcall of pstext
%
% Created by Salomon Eliasson
% $Id: pstext.m 7954 2012-10-28 20:57:41Z seliasson $

lat     = {in.lat};
lon     = {in.lon};
thick   = {in.thick};
angle   = {in.angle};
fontnum = {in.fontnum};
justify = {in.justify};
txt     = {in.text};

% Create an intermediate file that contains the required input per
% row/entry
txtfile = 'pstextfile.d';
fid=fopen(txtfile,'w'); cleanup = onCleanup(@() fclose(fid));
for i = 1:numel(txt)
    annotstr = sprintf('%s %s %s %s %s %s %s\n',...
        getAnnotFormat(lon{i}),getAnnotFormat(lat{i}),'%.0f',...
        getAnnotFormat(angle{i}),'%.0f','%.0f','%s');
    fprintf(fid,annotstr,lon{i},lat{i},thick{i},angle{i},...
        fontnum{i},justify{i},txt{i});
end

%load file and color (currently only one color)
command = sprintf('pstext %s -R -J -G%s',txtfile,in(1).color);
command = sprintf('%s -K -O %s >> %s.ps',command,placement,file);
