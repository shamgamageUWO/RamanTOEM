function command = pslocations(file,in,command)
% PSLOCATIONS Adds location markers to a GMT plot.
%
% IN      file     %s       file to append to
%         in       struct   options here (see help gmt_plot)
%         command  cell     cell of string commands for systemcall
%
% OUT     command  cell     cell of string commands for systemcall
%
% Created by Oliver Lemke & Salomon Eliasson
% $Id: pslocations.m 8362 2013-04-20 18:30:35Z seliasson $

for loc = in.locations
    psloc = sprintf('echo "%g %g" | psxy ', loc.lon, loc.lat);
    psloc = sprintf('%s -R -J',psloc);
    psloc = sprintf('%s %s',psloc,in.plotPlacement);
    
    
    
    if isfield(loc,'shape')
        shape = loc.shape;
    else
        shape = 'c'; % default shape (circle)
    end
    
    if isfield(loc,'size')
        sze = loc.size;
        if isnumeric(sze)
            sze = [num2str(sze),'c']; %assume cm
        end
    else
        sze   = '.08i'; %default size
    end
    
    psloc = sprintf('%s -S%s%s',psloc,shape,sze);
    
    color = 'white'; % default color
    if isfield(loc,'color') && ~isempty(loc.color)
        color = loc.color;
    end
    psloc = sprintf('%s -G%s -Wthinner',psloc,color);
    
    % selects Overlay plot mode and assume more pscode will be appended later
    psloc = sprintf('%s -O -K',psloc);
    if ~isempty(shape)
        command{end+1} = sprintf('%s >> %s.ps',psloc,file);
    end
    if isfield(loc,'name') && ~isempty(loc.name)
        tsize=15;
        if isfield(loc,'textsize') && ~isempty(loc.textsize)
            tsize = loc.textsize;
        end
        talign='LT';
        if isfield(loc,'textalign') && ~isempty(loc.textalign)
            talign = loc.textalign;
        end
        pstxt = sprintf('echo "%g %g %g 0 1 %s %s" | pstext ', ...
            loc.lon, loc.lat, tsize, talign, loc.name);
        
        % Offset text from data point
        pstxt = sprintf('%s -Dj0.05i/0.05i',pstxt);
        
        pstxt = sprintf('%s -R -J',pstxt);
        
        pstxt = sprintf('%s %s',pstxt,in.plotPlacement);
        
        if isfield(loc,'textcolor') && ~isempty(loc.textcolor)
            color = loc.textcolor;
        end
        pstxt = sprintf('%s -G%s',pstxt,color);
        
        % selects Overlay plot mode and assume more pscode will be appended later
        pstxt = sprintf('%s -O -K',pstxt);
        
        command{end+1} = sprintf('%s >> %s.ps',pstxt,file);
    end
end