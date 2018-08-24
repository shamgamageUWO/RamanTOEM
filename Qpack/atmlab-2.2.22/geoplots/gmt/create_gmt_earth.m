function commands = create_gmt_earth(in)
% CREATE_GMT_EARTH Main wrapper to gmt interface
%
% See help gmt_plot for input details
%
% PURPOSE: Create cell strings that will be used in a system call.
%
% Created by Salomon Eliasson
% $Id: create_gmt_earth.m 8570 2013-08-10 18:36:48Z seliasson $

assert(exist('in','var')==1,'gmtlab:badInput',...
    'This is an internal function to be used by gmt_plot.m')

in = setup_create_gmt_earth(in);

F = in.filename;

% Remove earlier .ps and gmt residules
commands{1} = sprintf('rm -f %s.ps',F);
%commands{end+1} = sprintf('rm -f .gmtcommands4 .gmtdefaults');

% Set paper size
commands{end+1} = 'gmtset PAPER_MEDIA A0+';

% Annotations of axis
commands{end+1} = sprintf('gmtset ANNOT_FONT_SIZE_PRIMARY %s',num2str(in.annot_font_size_primary));
commands{end+1} = sprintf('gmtset BASEMAP_AXES %s',in.basemap_axis);
commands{end+1} = sprintf('gmtset HEADER_OFFSET=%s',num2str(in.header_offset));
commands{end+1} = sprintf('gmtset HEADER_FONT %s',num2str(in.header_font));
commands{end+1} = sprintf('gmtset HEADER_FONT_SIZE %s',num2str(in.header_fontsize));
commands{end+1} = sprintf('gmtset MEASURE_UNIT=%s',in.measure_unit);

% other gmtset-commands you might have
if isfield(in,'gmtset')
    for i = length(in.gmtset)
        commands{end+1} = in.gmtset{i}; %#ok<*AGROW>
    end
end

% PSBASEMAP (open PS-file)
commands{end+1} = in.plot.basemap;

% NEARNEIGHBOR
if isfield(in,'nearneighbor') && ~isstruct(in.nearneighbor)
    commands{end+1} = in.nearneighbor;
    in.grdfile = [in.filename '.grd'];
elseif ~in.gridded && isfield(in.plot,'grid')
    in.grdfile = [in.filename '.grd'];
    commands{end+1} = nearneighbor(in.grdfile,in.plot.grid);
end

% IMAGE (plot data)
if isfield(in,'grdimage')
    commands{end+1} = in.grdimage;
elseif ~in.nodata
    commands{end+1} = grdimage(F,in);
end

% LEGEND
if isfield(in,'psscale')
    commands{end+1} = in.psscale;
elseif ~isempty(in.plot.legend)
    commands{end+1} = psscale(F,in.plot.legend);
end
if isfield(in,'psscale_extra')
    commands{end+1} = in.psscale_extra;
elseif ~isempty(in.plot.extralegend)
    commands{end+1} = in.plot.extralegend;
end

% COASTLINES
if isfield(in,'pscoast')
    commands{end+1} = in.pscoast;
elseif ~isempty(in.plot.coast)
    commands{end+1} = pscoast(F,in.plot.coast);
end

% LOCATION MARKERS
if isfield(in,'locations')
    commands = pslocations(F,in,commands);
end

% CONTOURLINES
if isfield(in,'grdcontour')
    commands{end+1} = in.grdcontour;
elseif isfield(in.plot,'grdcontour')
    for i = 1:length(in.plot.grdcontour) %can have more than 1 set
        commands{end+1} = grdcontour(F,in.plot.grdcontour(i));
    end
end

% PSBOX & PSPOLY (draw boxes or shapes on map)
if isfield(in,'psxy')
    commands{end+1} = in.psxy;
elseif isfield(in,'psbox') || isfield(in.plot,'psbox')
    commands = psbox(F,in,commands);
elseif isfield(in.plot,'pspoly')
    commands = pspoly(F,in,commands);
end

% PSTEXT
if isfield(in,'pstext') && ~isstruct(in.pstext)
    commands{end+1} = in.pstext;
elseif isfield(in.plot,'pstext')
    commands{end+1} = pstext(F,in.plot.pstext,in.plotPlacement);
end

% CLOSE PS + GRID
commands{end+1} = in.plot.lastbasemap;

%%%%%%%%%%%%%%%%%
%  SUBFUNCTIONS
%      |||||
%      vvvvv
function in = setup_create_gmt_earth(in)
%% setup_create_gmt_earth %%

in.plot.region = in.region;

% PROJECTION
if ~isfield(in,'proj')
    in.plot.proj = setup_projection(in);
else in.plot.proj = in.proj;
end

in.plot.basemap = setupbasemap(in);

% GRIDDING
if ~in.gridded && ~in.nodata
    in.plot.grid = mkgrid(in);
end

% COLOR TABLE
if ~in.nodata
    in.plot.color = create_colortables(in);
end

% COAST
if ~isfield(in,'pscoast')
    in.plot.coast = mkcoast(in);
end

% PSBOX
if isfield(in,'psbox')
    in.plot.psbox = setup_psboxpoly(in, 'psbox');
end

if isfield(in,'pspoly')
    in.plot.pspoly = setup_psboxpoly(in, 'pspoly');
end

% CONTOUR LINES
if isfield(in,'contourline')
    in.plot.grdcontour = mkgrdcontour(in);
end

% PSTEXT
if isfield(in,'pstext') && isstruct(in.pstext)
    in.plot.pstext = setup_pstext(in.pstext);
end

% LEGEND/S
[in.plot.legend,in.plot.extralegend] = mklegend(in);

% Close file with this
in.plot.lastbasemap = last_psbasemap(in);

function proj = setup_projection(in)
%% setup_projection %%

if isempty(in.center) || ~strcmp(in.plot.region(1:9),'-180/180/')
    logtext(1,'Data is not cyclic, choosing in.centre for projection from center longitude...\n')
    x = sscanf(in.plot.region,'%f/%f/%f/%f');
    C = (x(1)+x(2))/2;
else C = in.center;
end

proj = sprintf('%s%g/%s',in.projection,C,num2str(in.map_width));

function basemap = setupbasemap(in)
%% setupbasemap

if ~isempty(in.header)
    basemap = sprintf('psbasemap -R%s -J%s %s -G -P -K --COLOR_FOREGROUND=%s --COLOR_BACKGROUND=%s -B:."%s": > %s.ps',...
        in.plot.region,in.plot.proj,in.plotPlacement,in.color_foreground,in.color_background,gmt_unicode_converter(in.header),in.filename);
    
else
    basemap = sprintf('psbasemap -R%s -J%s %s -G -P -K > %s.ps',...
        in.plot.region,in.plot.proj,in.plotPlacement,in.filename);
end

function a = mkgrid(in)
%% mkgrid %%
% If nothing is given the resolution and search radius is loosely based on the
% density of the data points. nearneighbour uses the command: grdimage

if isfield(in,'nearneighbor') && ~isstruct(in.nearneighbor)
    a='';
    return
end
a.ungriddedfile = in.ungriddedfile;
a.plotPlacement = in.plotPlacement;

% ----------------------
% AREA

% get number of 1deg boxes in region
x            = sscanf(in.region,'%f/%f/%f/%f');
oneDegRegion = ( x(2)-x(1) )*( x(4)-x(3) );


% ---------------------
% Maximum resolution

% memGB = freeRAM()/1024; % How much RAM is available? TO LARGE
% some reasonable maximum default
% apparently it costs 1200bytes per point

memGB = .1;
maxpoints = memGB*1024^3  / 1200;
maxres = oneDegRegion/maxpoints;

% -----------------------------------------------------
% Resolution inferred by data, or by user defined

%data
res = max([ abs(median(diff(in.lat)));abs(median(diff(in.lon)))]) ;

%user
if isfield(in,'nearneighbor') &&...
        isstruct(in.nearneighbor) &&...
        isfield(in.nearneighbor,'resolution')
    res = in.nearneighbor.resolution;
end

% check if res is acceptable
if res < maxres
    logtext(atmlab('OUT'), ['Automatically picked the maximum resolution of: ',...
        '%.4fdeg instead of %.4fdeg defined by measurement density\n'],maxres,res)
    res = maxres;
else
    logtext(atmlab('OUT'), 'Plot resolution: %.4f Deg\n',res)
end
a.increment = sprintf('%fm',60*res); % 60min x resolution

% use increment to decide the search radius, unless given
if ~isfield(in,'nearneighbor') || ~isfield(in.nearneighbor,'search')
    a.search = sprintf('%fm', 1.25*str2double(a.increment(1:end-1)));
else
    a.search = in.nearneighbor.search;
end

function a = create_colortables(in)
%% create color tables %%

if isfield(in,'cptfile')
    a.cptfile = in.cptfile;
    return
end

% NOTE: remember that I am currently standing in a temporary directory

% MAKE a custom colour table based on manually input color values
if isfield(in,'colorrange')
    in.ctable = 'colorrange';
end

if isfield(in,'tickval')
    % make temporary tickval file
    fid=fopen('tickvalues.txt','w');
    if isfield(in,'tick_annotation_format')
        fprintf(fid,in.tick_annotation_format,in.tickval);
    else
        fprintf(fid,sprintf('%s\n',getAnnotFormat(in.tickval)),in.tickval);
    end
    fclose(fid);
end

% generate cpt files
switch in.ctable
    case 'mypolar'
        if ~isfield(in,'tickval')
            tickval = ownctable(in);
        else tickval = in.tickval;
        end
        a.cptfile = makepolar(tickval,in);
    case 'colorrange'
        % make ctable to be input to makecpt -C%s
        if isfield(in.colorrange,'colors')
            cpt_from_colorrange(in.colorrange);
            a.cptfile = makecpt(in);
        elseif isfield(in.colorrange,'discrete_colors')
            a.cptfile = cpt_discrete_colors(in);
        end
        
    otherwise
        logtext(1,'Processing makecpt\n')
        if ~isfield(in,'makecpt')
            a.cptfile = makecpt(in);
        else
            exec_system_cmd(in.makecpt);
            tmp = splitstring(in.makecpt,'> ');
            a.cptfile = tmp{2};
        end
end

% extra legend box for missing values
if isfield(in,'extra_legend')
    a.cptextra = extra_legend(in);
end

function a = mkcoast(in)
%% mkcoast

if ~isstruct(in.coast)
    a='';
    return
end
a.plotPlacement = in.plotPlacement;

% Set resolution of coastal features
rg=sscanf(in.plot.region,'%f/%f/%f/%f');
ln=rg(2)-rg(1);
lt=rg(4)-rg(3);
if ~isfield(in.coast,'features')
    const = 65;%constant => features ~1000km for full map
    a.features = ln*lt/const;
else a.features = in.coast.features;
end
if ~isfield(in.coast,'resolution')
    if ln < 20
        a.resolution = 'h';
    elseif ln < 45
        a.resolution = 'i';
    elseif ln < 90
        a.resolution = 'l';
    else a.resolution = 'c';
    end
else a.resolution = in.coast.resolution;
end

if isfield(in.coast,'color')
    a.color = in.coast.color;
end
a.rivers = in.coast.rivers;
a.width = in.coast.width;

function a = mkgrdcontour(in)
%% mkgrdcontour

default.cptfile  = in.plot.color.cptfile;
default.grdfile  = in.grdfile;

for i = 1:length(in.contourline)
    a(i) = catstruct(default,in.contourline(i));
    a(i).plotPlacement = in.plotPlacement;
end

function out = setup_pstext(in)
%% setup_pstext

assert(all(isfield(in,{'text','lat','lon'})),['gmtlab:' mfilename ':BadInput'],...
    'in.pstext.{text,lat,lon} are the minimum input requirements for in.pstext')

default.thick   = 20;      % text size in points
default.angle   = 0;       % degrees counter-clockwise from horizontal
default.fontnum = 1;       % sets the font type
default.justify = 6;       % sets the alignment
default.color   = '0/0/0'; % textcolor (black)
for i = 1:length(in)
    out(i) = optargs_struct(in(i),default);
end

function [a,b] = mklegend(in)
%% mklegend

if isfield(in,'fieldname') && isstruct(in.legend) %if not field then nodata.
    a = in.legend;
    % get what is in the in-structure, i.e one level up from in.legend
    % structure where they really belong
    F = {'xunit','unit','cptfile','plotPlacement'};
    for f = F(ismember(F,fieldnames(in)))
        switch f{1}
            case {'unit','xunit'}
                a.(f{1}) = gmt_unicode_converter(in.(f{1}));
            otherwise
                a.(f{1}) = in.(f{1});
        end
    end
    % Also needed
    a.cptfile = in.plot.color.cptfile;
    if isfield(in,'extra_legend') && isstruct(in.extra_legend)
        if ~isfield(in.extra_legend,'position')
            [w,wu]=separate_integer_and_unit(in.legend.width); %thickness of legend bar
            [x,xu]=separate_integer_and_unit(in.legend.xpos);
            [y,yu]=separate_integer_and_unit(in.legend.ypos);
            [l,~]=separate_integer_and_unit(in.legend.length);
            if ~isequal(wu,xu,yu),warning(['atmlab:' mfilename],'miss-matching units will cause strange default placements of extra_legend');end
            if strcmp(in.legend.orientation,'v')
                vec = [x, y-0.5*l-2*w, w, w];
                lsize = sprintf('%g%s/%g%s/%g%s/%g%s',...
                    vec(1),xu,vec(2),wu,vec(3),wu,vec(3),wu);
            elseif strcmp(in.legend.orientation,'h')
                vec = [x+0.5*l+2*w, y, w, w];
                lsize = sprintf('%g%s/%g%s/%g%s/%g%s',...
                    vec(1),wu,vec(2),yu,vec(3),wu,vec(3),wu);
            end
        else
            lsize = in.extra_legend.position;
        end
        if isfield(in.extra_legend,'fontsize')
            fz = in.extra_legend.fontsize;
        else fz = in.annot_font_size_primary;
        end
        b = sprintf('psscale -D%s -Xa5 -Ya5 -Li -O -K -C%s --ANNOT_FONT_SIZE_PRIMARY=%s >> %s.ps',...
            lsize,in.plot.color.cptextra,fz,in.filename);
    end
    if isfield(in.legend,'tick_annotations')
        append_tickannotations(in.plot.color.cptfile,in.legend.tick_annotations);
    end
end
if ~exist('b','var'), b = struct([]);end
if ~exist('a','var'), a = struct([]);end

function tickval = ownctable(in)
%% ownctable %%

minn = in.datarange(1);maxx = in.datarange(2);
if minn==maxx
    maxx=maxx+1;
end
tickval = minn:in.stepsize:maxx;

function out = setup_psboxpoly(in, field)
%% ps box

el = size(in.(field),1);
if isfield(in,[field 'color'])
    if length(in.([field 'color']))~=el
        error(['atmlab:' mfilename],'Need same number of colors as boxes')
    end
else in.([field 'color'])(1:l) = {'k'}; %default is black
end

if isfield(in,([field 'thick']))
    if length(in.([field 'thick']))~=el
        error(['atmlab:' mfilename],'Need same number of sizes as boxes')
    end
else out.thick(1:el)={10}; %default size=10
end
c = list_colors('colors',in.([field 'color']));
colors = cell(length(c),1);
for i=1:length(c)
    colors{i}=c{i}.*255; % instead of from 0:1
end
out.colors=colors;
out.(field)=in.(field);

function basemap = last_psbasemap(in)
%% last_psbasemap

% default.ticks = '60g60/30g30' (global)
% in.plot.region has this format: 'lon1/lon2/lat1/lat2'
rg=sscanf(in.plot.region,'%f/%f/%f/%f');
lon=rg(2)-rg(1);
lat=rg(4)-rg(3);

% for nice step lengths

% lons
as   = [240 180 120 90 60 30 15];
step = [60 40 30 20 15 10 5];
a = step(~(as>lon));
if isempty(a), a = lon/6; end

%lats
bs   = [120 60 90 40 30 20 15];
step = [60 40 30 20 10 5 2.5];
b = step(~(bs>lat));
if isempty(b), b = lat/3; end

default.ticks = sprintf('%gg%g/%gg%g',a(1),b(1),a(1)/2,b(1)/2);
in = optargs_struct(in,default);

basemap = sprintf('psbasemap -B%s',in.ticks);

basemap = sprintf('%s -R -J %s -O >> %s.ps',basemap,in.plotPlacement,in.filename);
