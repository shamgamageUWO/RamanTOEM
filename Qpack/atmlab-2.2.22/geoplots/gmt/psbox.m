function commands = psbox(file,in,commands)
% PSBOX Makes boxes in gmtplot
%
% IN      file     %s       file to append to
%         in       struct   options here (see help gmt_plot)
%         command  cell     cell of string commands for systemcall
%
% OUT     command  cell     cell of string commands for systemcall
%
% Created by Salomon Eliasson
% $Id: psbox.m 8362 2013-04-20 18:30:35Z seliasson $

colors = in.plot.psbox.colors;
thick = in.plot.psbox.thick;
pb = in.plot.psbox.psbox;
region = in.plot.region;
proj = in.plot.proj;

a=cell(5,1);
for i = 1:size(pb,1)
    b = pb(i,1:2);
    t = pb(i,3:4);
    
    %stdin
    %% get full coordinates
    a{1}=sprintf('%g %g',b(1),b(2));
    a{2}=sprintf('%g %g',b(1),t(2));
    a{3}=sprintf('%g %g',(t(1)+b(1))/2,t(2));
    a{4}=sprintf('%g %g',t(1),t(2));
    a{5}=sprintf('%g %g',t(1),b(2));
    a{6}=sprintf('%g %g',(t(1)+b(1))/2,b(2));
    a{7}=a{1};

    stdin=[a{1},' M\n',a{2},' D\n',a{3},' D\n',a{4},' D\n',a{5},' D\n',a{6},' D\n',a{7},' D'];
    box = sprintf('echo -e "%s" |',stdin);
    box = sprintf('%s psxy -R%s -J%s -A',box,region,proj);
    box = sprintf('%s %s',box,in.plotPlacement);
    
    % color and size of box
    
    c = colors{i};
    s = thick{i};
    box = sprintf('%s -W%g/%g/%g/%g',box,s,c(1),c(2),c(3));
    
    % selects Overlay plot mode and assume more pscode will be appended later
    box = sprintf('%s -K -O >> %s.ps',box,file);
    commands{end+1} = box;
end
