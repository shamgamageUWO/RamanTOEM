function varargout = taylor_diagram(STDs,RMSs,CORs,opt)
%% taylor_diagram (creates Taylor diagram)
%
%
% REFERENCE TO: 	K. Taylor , Summarizing multiple aspects of model
%                   performance in a single diagram Journal of Geophysical
%                   Research-Atmospheres, 2001, V106, D7. 
%
%
% [hp ht axl] = taylordiag(STDs,RMSs,CORs,['option',value])
%
% Plot a Taylor diagram from statistics values given
% by STDs (standard deviations), RMSs (centered root mean
% square difference) and CORs (correlation)
%
% Each of STDs, RMS and CORs are one dimensional tables
% with N variables. The 1st value corresponds to the observation
% statistics to compair with the others.
%
% OUTPUTS:
% 	hp: returns a handle to the plotted points
%	ht: returns a handle to the text legend of points
%  axl: returns a structure of handles of axis labels
%
% LIST OF OPTIONS:
%
% 'Npan'
%		1 or 2: Panels to display (1 for positive correlations,
%				2 for positive and negative correlations)
%				Default value depends on CORs
%
% 'tickRMS'
% 		RMS values to plot gridding circles from observation point
% 'colRMS'
%		RMS grid and tick labels color
%		Default: green
% 'showlabelsRMS'
%		0 / 1 (default): Show or not the RMS tick labels
% 'tickRMSangle'
%		Angle for RMS tick lables with the observation point
%		Default: 135 deg.
% 'styleRMS'
%		Linestyle of the RMS grid
% 'widthRMS'
%		Line width of the RMS grid
% 'titleRMS'
%		0 / 1 (default): Show RMSD axis title
%
% 'tickSTD'
%		STD values to plot gridding circles from origin
% 'colSTD'
%		STD grid and tick labels color
%		Default: black
% 'showlabelsSTD'
%		0 / 1 (default): Show or not the STD tick labels
% 'styleSTD'
%		Linestyle of the STD grid
% 'widthSTD'
%		Line width of the STD grid
% 'titleSTD'
%		0 / 1 (default): Show STD axis title
%
% 'tickCOR'
%		CORRELATON grid values
% 'colCOR'
%		CORRELATION grid color
%		Default: blue
% 'showlabelsCOR'
%		0 / 1 (default): Show or not the CORRELATION tick labels
% 'styleCOR'
%		Linestyle of the COR grid
% 'widthCOR'
%		Line width of the COR grid
% 'titleCOR'
%		0 / 1 (default): Show CORRELATION axis title
%
%
% Created: G. Maze (07/02/2008)
%%%%
%Extra options (added by Salomon)
% 'pointnames' {%s,%s,...}    Names associated with points to be plotted
%                             alongside the points. Default = {'A','B',...}
%
% 'pointcolor' {%s,%s,} or {[%f rgb],[%f rgb],}
%                             Color of the individual points. Can be given
%                             as vector
%                        
% 'pointsymbols' ['.','s',..] Symbol associated with point
%
% $Id$

%% CHECK THE INPUT FIELDS TO BE SURE WE HAVE:
% rms^2 = st.^2 + st(end)^2 - 2*st*st(end).*co
apro = 100;
di = fix(RMSs*apro)/apro - fix(sqrt(STDs.^2 + STDs(1)^2 - 2*STDs*STDs(1).*CORs)*apro)/apro;
assert(all(di==0),'atmlab:taylor_diagram:badInput',['Something''s wrong with the datas\n'...
    'We must have:\n','RMSs - sqrt(STDs.^2 + STDs(1)^2 - 2*STDs*STDs(1).*CORs) = 0 !'])
assert(nargin>=3,'atmlab:taylor_diagram:badInput','USAGE: taylor_diagram(STDs,RMSs,CORs,opt)')
if nargin ==3, opt = struct; end

%% IN POLAR COORDINATES:
if isfield(opt,'normalize')&&opt.normalize
    STDs = STDs./STDs(1);
end
rho   = STDs;
theta = acos(CORs);
dx = rho(1);	% Observed STD

%% BEGIN THE PLOT HERE TO GET AXIS VALUES:
hold off
cax = gca;
tc = get(cax,'xcolor');
next = lower(get(cax,'NextPlot'));

% make a radial grid
hold(cax,'on');
maxrho = max(abs(rho(:)));
hhh=line([-maxrho -maxrho maxrho maxrho],[-maxrho maxrho maxrho -maxrho],'parent',cax);
xlim([0 maxrho])
ylim([0 maxrho])
set(cax,'dataaspectratio',[1 1 1],'plotboxaspectratiomode','auto')
% Salomons
%v = [get(cax,'xlim') get(cax,'ylim')];
a = get(cax,'xtick');b = get(cax,'ytick');
v = [a(1) a(end)+a(2) b(1) b(end)+b(2)];

%% cont..
ticks = sum(get(cax,'ytick')>=0);
delete(hhh);

% check radial limits and ticks
rmin = 0;
rmax = v(4);
rticks = max(ticks-1,2);
if rticks > 5   % see if we can reduce the number
    if rem(rticks,2) == 0
        rticks = rticks/2;
    elseif rem(rticks,3) == 0
        rticks = rticks/3;
    end
end
rinc  = (rmax-rmin)/rticks;
tick  = (rmin+rinc):rinc:rmax;

%% LOAD DEFAULT PARAMETERS:
default.Npan = 1+any(CORs<0); %double panel?
default.tickRMSangle  = 135;
default.showlabelsRMS = true;
default.showlabelsSTD = true;
default.tickRMS = tick;
default.rincRMS = rinc;
default.tickSTD = tick;
default.colSTD = [0 0 0];
default.colRMS = [0 .6 0];
default.colCOR = [0 0 1];
default.tickCOR(1).val = [1 .99 .95 .9:-.1:0];
default.tickCOR(2).val = [1 .99 .95 .9:-.1:0 -.1:-.1:-.9 -.95 -.99 -1];
default.widthSTD = .8;
default.widthRMS = .8;
default.widthCOR = .8;
default.styleSTD = ':';
default.styleRMS = '--';
default.styleCOR = '-.';
default.titleSTD = true;
default.titleRMS = true;
default.titleCOR = true;

% Salomon's added options
default.pointnames    ={'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',...
    'P','Q','R','S','T','U','V','W','X','Y','Z'};
default.pointcolor    = repmat({[1 0 0]},length(STDs),1);
default.pointsymbols  = repmat('.',1,length(STDs));

opt = optargs_struct(default,opt);

%% CONTINUE THE PLOT WITH UPDATED OPTIONS:

% define a circle
th = 0:pi/150:2*pi;
xunit = cos(th);
yunit = sin(th);
% now really force points on x/y axes to lie on them exactly
inds = 1:(length(th)-1)/4:length(th);
xunit(inds(2:2:4)) = zeros(2,1);
yunit(inds(1:2:5)) = zeros(3,1);
% plot background if necessary
if ~ischar(get(cax,'color')),
    %		ig = find(th>=0 & th<=pi);
    ig = 1:length(th);
    patch('xdata',xunit(ig)*rmax,'ydata',yunit(ig)*rmax, ...
        'edgecolor',tc,'facecolor',get(cax,'color'),...
        'handlevisibility','off','parent',cax);
end

% DRAW RMS CIRCLES:
% ANGLE OF THE TICK LABELS
c82 = cos(opt.tickRMSangle*pi/180);
s82 = sin(opt.tickRMSangle*pi/180);
for ic = 1 : length(opt.tickRMS)
    i = opt.tickRMS(ic);
    iphic = find( sqrt(dx^2+rmax^2-2*dx*rmax*xunit) >= i ,1);
    ig = find(i*cos(th)+dx <= rmax*cos(th(iphic)));
    hhh = line(xunit(ig)*i+dx,yunit(ig)*i,'linestyle',opt.styleRMS,'color',opt.colRMS,'linewidth',opt.widthRMS,...
        'handlevisibility','off','parent',cax);
    if opt.showlabelsRMS
        text((i+opt.rincRMS/20)*c82+dx,(i+opt.rincRMS/20)*s82, ...
            ['  ' num2str(i)],'verticalalignment','bottom',...
            'handlevisibility','off','parent',cax,'color',opt.colRMS,'rotation',opt.tickRMSangle-90)
    end
end

% DRAW DIFFERENTLY THE CIRCLE CORRESPONDING TO THE OBSERVED VALUE
%      hhh = line((cos(th)*dx),sin(th)*dx,'linestyle','--','color',opt.colSTD,'linewidth',1,...
%                   'handlevisibility','off','parent',cax);


% DRAW STD CIRCLES:
% draw radial circles
for ic = 1 : length(opt.tickSTD)
    i = opt.tickSTD(ic);
    hhh = line(xunit*i,yunit*i,'linestyle',opt.styleSTD,'color',opt.colSTD,'linewidth',opt.widthSTD,...
        'handlevisibility','off','parent',cax);
    if opt.showlabelsSTD
        if opt.Npan == 2
            if isempty(find(opt.tickSTD==0, 1))
                text(0,-rinc/20,'0','verticalalignment','top','horizontalAlignment','center',...
                    'handlevisibility','off','parent',cax,'color',opt.colSTD);
            end
            text(i,-rinc/20, ...
                num2str(i),'verticalalignment','top','horizontalAlignment','center',...
                'handlevisibility','off','parent',cax,'color',opt.colSTD)
        else
            if isempty(find(opt.tickSTD==0, 1))
                text(-rinc/20,rinc/20,'0','verticalalignment','middle','horizontalAlignment','right',...
                    'handlevisibility','off','parent',cax,'color',opt.colSTD);
            end
            text(-rinc/20,i, ...
                num2str(i),'verticalalignment','middle','horizontalAlignment','right',...
                'handlevisibility','off','parent',cax,'color',opt.colSTD)
        end
    end
end
set(hhh,'linestyle','-') % Make outer circle solid

% DRAW CORRELATIONS LINES EMANATING FROM THE ORIGIN:
corr = opt.tickCOR(opt.Npan).val;
th  = acos(corr);
cst = cos(th); snt = sin(th);
cs = [-cst; cst];
sn = [-snt; snt];
line(rmax*cs,rmax*sn,'linestyle',opt.styleCOR,'color',opt.colCOR,'linewidth',opt.widthCOR,...
    'handlevisibility','off','parent',cax)

% annotate them in correlation coef
rt = 1.05*rmax;
parfor i = 1:length(corr)
    text(rt*cst(i),rt*snt(i),num2str(corr(i)),...
        'horizontalalignment','center',...
        'handlevisibility','off','parent',cax,'color',opt.colCOR);
%     if i == length(corr)
%         loc = int2str(0);
%         loc = '1';
%     else
%         loc = int2str(180+i*30);
%         loc = '-1';
%     end
end

% AXIS TITLES
axlabweight = 'bold';
ix = 0;
if opt.Npan == 1
    if opt.titleSTD
        ix = ix + 1;
        ax(ix).handle = ylabel('Standard deviation','color',opt.colSTD,'fontweight',axlabweight);
    end
    
    if opt.titleCOR
        ix = ix + 1;
        clear ttt
        pos1 = 45;	DA = 15;
        lab = 'Correlation Coefficient';
        c = fliplr(linspace(pos1-DA,pos1+DA,length(lab)));
        dd = 1.1*rmax;	ii = 0;
        for ic = 1 : length(c)
            ith = c(ic);
            ii = ii + 1;
            ttt(ii)=text(dd*cos(ith*pi/180),dd*sin(ith*pi/180),lab(ii));
            set(ttt(ii),'rotation',ith-90,'color',opt.colCOR,'horizontalalignment','center',...
                'verticalalignment','bottom','fontsize',get(ax(1).handle,'fontsize'),'fontweight',axlabweight);
        end
        ax(ix).handle = ttt;
    end
    
    if opt.titleRMS
        ix = ix + 1;
        clear ttt
        pos1 = opt.tickRMSangle+(180-opt.tickRMSangle)/2; DA = 15; pos1 = 160;
        lab = 'RMSD';
        c = fliplr(linspace(pos1-DA,pos1+DA,length(lab)));
        dd = 1.05*opt.tickRMS(1);
        dd = .95*opt.tickRMS(2);
        ii = 0;
        for ic = 1 : length(c)
            ith = c(ic);
            ii = ii + 1;
            ttt(ii)=text(dx+dd*cos(ith*pi/180),dd*sin(ith*pi/180),lab(ii));
            set(ttt(ii),'rotation',ith-90,'color',opt.colRMS,'horizontalalignment','center',...
                'verticalalignment','top','fontsize',get(ax(1).handle,'fontsize'),'fontweight',axlabweight);
        end
        ax(ix).handle = ttt;
    end
    
    
else
    if opt.titleSTD
        ix = ix + 1;
        ax(ix).handle =xlabel('Standard deviation','fontweight',axlabweight,'color',opt.colSTD);
    end
    
    if opt.titleCOR
        ix = ix + 1;
        clear ttt
        pos1 = 90;	DA = 15;
        lab = 'Correlation Coefficient';
        c = fliplr(linspace(pos1-DA,pos1+DA,length(lab)));
        dd = 1.1*rmax;	ii = 0;
        for ic = 1 : length(c)
            ith = c(ic);
            ii = ii + 1;
            ttt(ii)=text(dd*cos(ith*pi/180),dd*sin(ith*pi/180),lab(ii));
            set(ttt(ii),'rotation',ith-90,'color',opt.colCOR,'horizontalalignment','center',...
                'verticalalignment','bottom','fontsize',get(ax(1).handle,'fontsize'),'fontweight',axlabweight);
        end
        ax(ix).handle = ttt;
    end
    
    if opt.titleRMS
        ix = ix + 1;
        clear ttt
        pos1 = 160; DA = 10;
        lab = 'RMSD';
        c = fliplr(linspace(pos1-DA,pos1+DA,length(lab)));
        dd = 1.05*opt.tickRMS(1); ii = 0;
        for ic = 1 : length(c)
            ith = c(ic);
            ii = ii + 1;
            ttt(ii)=text(dx+dd*cos(ith*pi/180),dd*sin(ith*pi/180),lab(ii));
            set(ttt(ii),'rotation',ith-90,'color',opt.colRMS,'horizontalalignment','center',...
                'verticalalignment','bottom','fontsize',get(ax(1).handle,'fontsize'),'fontweight',axlabweight);
        end
        ax(ix).handle = ttt;
    end
end


% VARIOUS ADJUSTMENTS TO THE PLOT:
set(cax,'dataaspectratio',[1 1 1]), axis(cax,'off'); set(cax,'NextPlot',next);
set(get(cax,'xlabel'),'visible','on')
set(get(cax,'ylabel'),'visible','on')
%    makemcode('RegisterHandle',cax,'IgnoreHandle',q,'FunctionName','polar');
% set view to 2-D
view(cax,2);
% set axis limits
if opt.Npan == 2
    axis(cax,rmax*[-1.15 1.15 0 1.15]);
    line([-rmax rmax],[0 0],'color',tc,'linewidth',1.2);
    line([0 0],[0 rmax],'color',tc);
else
    axis(cax,rmax*[0 1.15 0 1.15]);
    %	    axis(cax,rmax*[-1 1 -1.15 1.15]);
    line([0 rmax],[0 0],'color',tc,'linewidth',1.2);
    line([0 0],[0 rmax],'color',tc,'linewidth',2);
end


% FINALY PLOT THE POINTS:
hold on
pp=zeros(length(STDs),1);
for ii = 1 : length(STDs)
    pp(ii)=polar(theta(ii),rho(ii));
    if strcmp(opt.pointsymbols(ii),'s')
        set(pp(ii),'marker',opt.pointsymbols(ii),'MarkerEdgeColor',opt.pointcolor{ii},'MarkerFaceColor',opt.pointcolor{ii},'markersize',10);
    else
        set(pp(ii),'marker',opt.pointsymbols(ii),'markersize',40);
    end
    set(pp(ii),'color',opt.pointcolor{ii});
    if length(STDs)<=26
        tt(ii)=text(rho(ii)*cos(theta(ii)),rho(ii)*sin(theta(ii)),opt.pointnames{ii},'color',opt.pointcolor{ii});
    else
        tt(ii)=text(rho(ii)*cos(theta(ii)),rho(ii)*sin(theta(ii)),lower(opt.pointnames{ii}),'color',opt.pointcolor{ii});
    end
end
set(tt,'verticalalignment','bottom','horizontalalignment','right')
set(tt,'fontsize',12)
hold off

%%% OUTPUT
switch nargout
    case 1
        varargout(1) = {pp};
    case 2
        varargout(1) = {pp};
        varargout(2) = {tt};
    case 3
        varargout(1) = {pp};
        varargout(2) = {tt};
        varargout(3) = {ax};
end








