function commands = pspoly(file,in,commands)
% PSPOLY Make polygons to plot with GMT
%
% IN      file     %s       file to append to
%         in       struct   options here (see help gmt_plot)
%         command  cell     cell of string commands for systemcall
%
% OUT     command  cell     cell of string commands for systemcall
%
% Created by Oliver Lemke
% $Id: pspoly.m 7157 2011-09-18 10:38:57Z seliasson $

colors = in.plot.pspoly.colors;
thick = in.plot.pspoly.thick;
pp = in.plot.pspoly.pspoly;

for i = 1:size(pp,1)    
    %stdin
    %% get full coordinates
    ppcur = pp{i};
    a=cell(size(ppcur,1)+1,1);
    for j = 1:size(ppcur,1)
        a{j}=sprintf('%d %d',ppcur(j,1), ppcur(j,2));
    end
    a{size(ppcur,1)+1}=a{1};
    
    stdin = [a{1},' M\n'];
    for j = 2:size(ppcur,1)
        stdin = [stdin,a{j},' D\n'];
    end
    stdin = [stdin,a{size(ppcur,1)+1},' D'];
    
    command = sprintf('echo -e "%s" |',stdin);
    command = sprintf('%s psxy -R -J -A',command);
    command = sprintf('%s %s',command,in.plotPlacement);
    
    % color and size of box
    
    c = colors{i};
    s = thick{i};
    command = sprintf('%s -W%d/%d/%d/%d',command,s,c(1),c(2),c(3));
    commands{end+1} = sprintf('%s -K -O >> %s.ps',command,file);
end