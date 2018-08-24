function [info, files] = test_gmt(in)
% TEST_GMT To test various aspecs of gmt_plot
%
% PURPOSE: To test various aspecs of gmt_plot. Especially before commiting
%          changes
%
% USAGE: [info,files] = test_gmt(in)
%
% IN   structure of arguments to be additionally used
%      in the test_gmt call/s. I.e. it will use the default values for each
%      test and the addional options added by the user (which have precedence).
%      -----------
%      in.test: If you only want to run a subset of tests, e.g. in.test =
%      [1,3,4] runs tests 1,3,4. The default behaviour is to run all tests ([1:7])
%
%      -----------
%
%
% OUT: files = cellarray of paths to created figures
%      info  = cellarray of information about each test. The information is
%              also displayed at the end of the run.
%
% created by Salomon Eliasson
% $Id: test_gmt.m 8570 2013-08-10 18:36:48Z seliasson $

if ~exist('in','var'); in=struct([]); end

% SET some defaults
alltests = 1:16;
default.test      = alltests; % which tests to do (default=all)

in = optargs_struct(in,default);
testDataResolution=1;
[gridded,ungridded] = test_generate_data_sin_cos(testDataResolution);

[files,info]           = TEST(in,gridded,ungridded);
default.display   = true;
default.filename  = 'all_tests' ;
od = isfield(in,'outdir');
default.outdir    = gmtlab('OUTDIR');
in = optargs_struct(in,default);

% for the final pdfs

if isequal(in.test,alltests) % if all tests
    default.cols = [3 3 3 2 1 3 1];
else
    default.cols = 2;
end

in = optargs_struct(in,default);

if ~ischar(in.outdir)
    in.outdir = tempdir;
    in.outdir = in.outdir(1:end-1);
end

warning('off','catstruct:DuplicatesFound') %I'm intentially doing this often

% PUT all figure in one pdf
files{end+1} = combine_pdfs(files,struct('title','GMT plots: testing its functionality','fontsize','1cm','filename',[in.filename,'.pdf'],'cols',in.cols,'valign','b','outdir',in.outdir,'display',in.display));

% DISPLAY information about the tests
disp(' ')
disp(' ')
cellfun(@fprintf,info,'uniformoutput',false)
disp('Look at help gmt_plot for more detailed descriptions of options ')
disp('specified here. I suggest looking at the call for each test in test_gmt')
disp('if you want to see an example on how to create these figures.')
disp(' ')
disp('All the tests where merged onto one pdf using combine_pdfs.m.')

warning('on','gmtcatstruct:DuplicatesFound')

if ~od && ~ischar(gmtlab('OUTDIR'))
    a = sprintf('Files are saved in your tempdir (%s)',in.outdir);
    in.outdir = in.outdir(1:end-1);
    b = 'It is better to set a default directory.';
    c = 'I.e by setting gmtlab(''OUTDIR'',''<Somewhere>''), e.g. in startup.m';
    d = 'Setting this, or inputting a valid directory: in.outdir will suppress this message.';
    fprintf(2,'Warning: %s\n%s\n%s\n%s',a,b,c,d);
end

if nargout==0
    clear info files
end
fprintf('Output file saved at: %s/%s.pdf\n',in.outdir,in.filename)

end
%%%%%%%%%%%%%%%%%
% SUB FUNCTIONS
%    |||||||
%    vvvvvvv

function [files,info]           = TEST(in,gridded,ungridded)

info = cell(1,length(in.test));
files = cell(1,length(in.test));
default.display = false;
in = optargs_struct(in,default);

ind = 1;
for T = sort(in.test)
    switch T
        case 1
            %% TEST: Difference plot, reference=0, nlevels, sidebar
            test.header        = 'gridded: title² * @~D@~r@+-2@~g@~@+, unit';
            test.unit         = 'kg/m²';
            test.basemap_axis = 'neSW';
            test.legend.tick_spacing = 25;
            
            in.filename = sprintf('Test%g',T);
            files{ind} = gmt_plot(catstruct(gridded,in,test),'data');
            
            info{ind} = ['Test:' num2str(T) ' demonstrates that you can include some special',...
                'characters in in.header and in.unit. This test uses ',...
                'gridded data, where size(data) = [length(lat),length(lon)]',...
                'Use in.header_offset my shift the title wrt the plot',...
                'You can also change the size and position of the legend',...
                '(''x-displacement/y-displacement/height/width''))',...
                'Here the tick-interval is fixed to every 25th level using in.legend.tick_spacing = 25\n\n'];
            
        case 2
            
            test.data = gridded.data-200;  % for difference
                        test.lat = gridded.lat;
            test.lon = gridded.lon;
            test.unit='';
            test.xunit='kg/m@+2';
            test.ctable = 'mypolar';
            test.reference = 0;
            test.legend.sidebar = 3; % both above and below
            test.basemap_axis = 'neSW';
            test.header = 'Diff plot,ref=0,sidebar=3 (above & below)';
            test.legend.tick_spacing = 25;
            in.filename = sprintf('Test%g',T);
            files{ind} = gmt_plot(catstruct(in,test),'data');
            
            info{ind} = ['Test:' num2str(T) ' demonstrates the mypolar-colortable which is similar to polar.cpt',...
                'Using in.ctable=''mypolar'' you can define where the reference value',...
                'should be (here in.reference = 0). The white color is centered around this value.',...
                'in.basemap_axis = ''nSeW'' is tested, and means that the south (S) and west(W)',...
                'axes are labelled. in.sidebar = 3 is tested and means that triangles',...
                'above and below legend-range are shown to indicate the color of data outside the datarange',...
                'defined by in.datarange = [min max]. The title offset is set to -0.5 here (moving it down)',...
                'using in.header_offset = -0.5; See help gmt_plot for more details on these options\n\n'];
            
        case 3

            test.data = gridded.data-200;  % for difference
            test.lat = gridded.lat;
            test.lon = gridded.lon;
            test.unit='';
            test.xunit='kg/m@+2';
            test.ctable = 'mypolar';
            test.reference = 0;
            test.legend.tick_spacing = 25;
            test.legend.sidebar = 2; % above only
            test.basemap_axis = 'Nesw';
            test.nlevels = 15;
            test.nwhite = 6;
            test.header_fontsize = '20p';
            test.header = 'Diff plot,nlevels=15,nwhite=6,sidebar=2 (above only),header';
            in.filename = sprintf('Test%g',T);
            
            %this puts standardize_geodata.m to the test
            test.data=test.data'; test.data = test.data(end:-1:1,end:-1:1);
            test.lat = test.lat(end:-1:1);
            test.lon = test.lon(end:-1:1);
            files{ind} = gmt_plot(catstruct(in,test),'data');
            
            info{ind} = ['Test:' num2str(T) ' demonstrates that you can change the number of intervals that are',...
                'colored white around the reference value when using the mypolar-colortable,',...
                'here in.nwhite = 6. You can also change the number of data intervals ',...
                '(here in.nlevels = 15), change in.headersize (here in.headersize = 20)',...
                'or decide to only have the sidebar for values above the datarange (here in.sidebar=2)\n\n'];
            
        case 4
            
            %% TEST: title, unit (gridded and ungridded)
            test.nearneighbor.resolution = 1;
            test.unit            = 'kg/m@+2';
            test.basemap_axis    = 'nEsW';
            test.header          = sprintf('Font: ''Courier'': ungridded: %.0f [deg]',test.nearneighbor.resolution);
            test.header_font     = 'Courier';
            test.coast.width     = 1;
            test.coast.color     = '255/255/255';
            test.legend.orientation  = 'h';
            in.filename          = sprintf('Test%g',T);
            files{ind} = gmt_plot(catstruct(ungridded,test,in),'data');
            
            info{ind} = ['Test:' num2str(T) ' demonstrates the same data as Test1a except in an ungridded form.',...
                'Test 2a is chosen to show that the user can decide how far to look for the next point',...
                'The search radius, where the values within are used to calculate the grid value,',...
                'is automatically in.nearneighbor * 1.5',...
                'isequal(size(in.data),size(in.lat),size(in.lon))==1. This is e.g. good',...
                'for plotting satellite granule data directly. You can also change the',...
                'color of the coastlines, e.g. in.coast.color = ''255/255/255.''\n\n'];
            
        case 5
            %% test 2b
            test.nearneighbor.resolution = 10;
            test.unit            = 'kg/m@+2';
            test.basemap_axis    = 'nEsW';
            test.coast.width     = 1;
            test.coast.color     = '255/255/255';
            test.legend.orientation  = 'h';
            test.header_font   = 8;
            test.header        = sprintf('Font: 8. ungridded: %.0f [deg]',test.nearneighbor.resolution);
            in.filename        = sprintf('Test%g',T);
            files{ind} = gmt_plot(catstruct(ungridded,test,in),'data');
            
            info{ind} = ['Test:' num2str(T) ' is chosen to show that the user can decide how far to look for the next point',...
                'The search radius, where the values within are used to calculate the grid value,',...
                'is automatically set to in.nearneighbor.resolution * 1.5',...
                'isequal(size(in.data),size(in.lat),size(in.lon))==1. This is e.g. good',...
                'for plotting satellite granule data directly. You can also change the',...
                'color of the coastlines, e.g. in.coast.color = ''255/255/255.''\n\n'];
            
        case 6
            %% test 2c
            test.nearneighbor.resolution = 60;
            test.unit            = 'kg/m@+2';
            test.coast.width     = 1;
            test.coast.color     = '255/255/255';
            test.legend.orientation  = 'h';
            test.header_font   = 'Times-Roman';
            test.basemap_axis    = 'neSW';
            test.header        = sprintf('ungridded: resolution = %g [deg]',test.nearneighbor.resolution);
            test.legend.orientation  = 'v';
            in.filename        = sprintf('Test%g',T);
            files{ind} = gmt_plot(catstruct(ungridded,test,in),'data');
            
            info{ind} = ['Test:' num2str(T) ' is chosen to show that the user can decide how far to look for the next point',...
                'The search radius, where the values within are used to calculate the grid value,',...
                'is automatically set to in.nearneighbor.resolution * 1.5',...
                'isequal(size(in.data),size(in.lat),size(in.lon))==1. This is e.g. good',...
                'for plotting satellite granule data directly. You can also change the',...
                'color of the coastlines, e.g. in.coast.color = ''255/255/255.''\n\n'];
            
        case 7
            
            %% TEST: sidebar, nan, projection, center
            
            gridded.data(20:40,20:80) = NaN;
            test.datarange = [160,250];
            test.nlevels        = 18;
            test.header         = 'upper sidebar, NaN, Hammer projection, center=180';
            test.legend.orientation = 'h';
            test.projection         =  'H';
            test.center             = 180;      % Center map at given center longitude
            in.filename             = sprintf('Test%g',T);
            files{ind} = gmt_plot(catstruct(gridded,test,in),'data');
            
            info{ind} = ['Test:' num2str(T) ' demonstrates the Hammer, Robinsson and sinusoidal projections ',...
                '(using in.projection = ''H''/''R''/''I''), ',...
                'one of many available projections. The test also demonstrates that you can',...
                'easily change the center of the projection to e.g. 180E using in.center = 180.',...
                'The grey region in the map indicates NaN values, and an extra NaN color box',...
                'is automatically added below the vertical legend. You can suppress the extra',...
                'NaN-legend using in.nanlegend = false. The upper sidebar is automatically shown',...
                'if there are data larger than in.datarange(2), given via in.datarange = [v1,v2].',...
                'The color for these values can be changed using',...
                'in.color_foreground (default is ''255/255/255'' (white))',...
                'Test ' num2str(T) ' also shows the use of in.legend.tick_spacing = default,10,15 for a,b,c respectively.\n\n'];
            
        case 8
            
            gridded.data(20:40,20:80) = NaN;
            test.datarange = [160,250];
            test.nlevels        = 18;
            test.legend.orientation = 'h';
            test.header               = 'Robinsson projection, center = 0 ';
            test.projection          = 'N';
            test.center              = 0;
            test.legend.tick_spacing = 10;
            test.extra_legend        = struct('name','nan','type','nan');
            in.filename              = sprintf('Test%g',T);
            
            files{ind} = gmt_plot(catstruct(gridded,test,in),'data');
            
            info{ind} = ['Test:' num2str(T) ' demonstrates the Hammer, Robinsson and sinusoidal projections ',...
                '(using in.projection = ''H''/''R''/''I''), ',...
                'one of many available projections. The test also demonstrates that you can',...
                'easily change the center of the projection to e.g. 180E using in.center = 180.',...
                'The grey region in the map indicates NaN values, and an extra NaN color box',...
                'is automatically added below the vertical legend. You can suppress the extra',...
                'NaN-legend using in.nanlegend = false. The upper sidebar is automatically shown',...
                'if there are data larger than in.datarange(2), given via in.datarange = [v1,v2].',...
                'The color for these values can be changed using',...
                'in.color_foreground (default is ''255/255/255'' (white))',...
                'Test ' num2str(T) ' also shows the use of in.legend.tick_spacing = default,10,15 for a,b,c respectively.\n\n'];
            
        case 9
            
            gridded.data(20:40,20:80) = NaN;
            test.nlevels        = 18;
            test.legend.orientation = 'h';
            test.datarange          = [160,250];% displayed value range. Sidebar triangles shown for data outside range.
            test.extra_legend           = struct('name','nan','type','nan','position','0i/0i/2c/2ch','fontsize','25p');
            test.legend.position        = '12c/0c/20c/2ch';
            test.legend.font_size       = '20p';
            test.legend.tick_spacing    = 15;
            test.header                 = 'Sinusoidal projection, center = 90';
            test.projection             = 'I';
            test.center                 = 90;
            in.filename                 = sprintf('Test%g',T);
            
            files{ind} = gmt_plot(catstruct(gridded,test,in),'data');
            
            info{ind} = ['Test:' num2str(T) ' demonstrates the Hammer, Robinsson and sinusoidal projections ',...
                '(using in.projection = ''H''/''R''/''I''), ',...
                'one of many available projections. The test also demonstrates that you can',...
                'easily change the center of the projection to e.g. 180E using in.center = 180.',...
                'The grey region in the map indicates NaN values, and an extra NaN color box',...
                'is automatically added below the vertical legend. You can suppress the extra',...
                'NaN-legend using in.nanlegend = false. The upper sidebar is automatically shown',...
                'if there are data larger than in.datarange(2), given via in.datarange = [v1,v2].',...
                'The color for these values can be changed using',...
                'in.color_foreground (default is ''255/255/255'' (white))',...
                'Test ' num2str(T) ' also shows the use of in.legend.tick_spacing = default,10,15 for a,b,c respectively.\n\n'];
            
        case 10
            %% TEST: contours, nlevels, annotation format, xunit
            
            test.lat = -90+.5:90-.5;
            test.lon = -180+.5:180-.5;
            for j = test.lat
                for i = test.lon
                    test.data(j+90.5,i+180.5) = ((0.1*sin((j+91)/18*pi))+sin((j+91)/180*pi))*(0.1*cos(i/36*pi)+cos(i/360*pi));
                end
            end
            
            test.header = 'contours, HSV colours, horiz. legend';
            test.projection = 'H';
            test.nlevels = 10;
            test.tick_annotation_format = '%g';
            test.legend.orientation = 'h';
            test.contourline.spacing=0.1;
            test.contourline.range=[0 1];
            test.contourline.linethick=1;
            test.contourline.more='-T1c/0.001c:LH';
            test.datarange = [0, 1];
            test.color_background = '255/0/0';
            test.color_foreground = '255/255/0';
            test.colorrange.colors = {{0,'0/1/1'},{1,'60/1/1'}};
            test.colorrange.color_model = 'HSV';
            test.nlevels = 5;
            
            % TEST pstext aswell
            test.pstext = struct('text',{'Norrland','Australia'},...
                'lat',{67+51/60,-25},'lon',{20+13/60,130},'angle',{0,-15},...
                'color','0/255/0');
            
            in.filename = sprintf('Test%g',T);
            files{ind} = gmt_plot (catstruct(test,in), 'data');
            
            info{ind} = ['Test:' num2str(T) ' demonstrates contour maps (see contour options in help gmt_plot), ',...
                'where you can optionally choose to show highs and lows in the of the data.',...
                'It also demonstrated that you can have x and y-labels',...
                '(in.xunit=''no unit either'' and in.unit=''no unit'') around the legend',...
                'Using the custom colortable (in.colorrange) you can also use',...
                'in.colorrange.color_model = ''HSV'' instead of the default ''RGB''. I also test'...
                'plotting text on top of the map using pstext\n\n'];
            
        case 11
            
            test.lat        = (-30:30)-.5;
            test.lon        = (152:240)-.5;
            test.data       = gridded.data(...
                gridded.lat>=test.lat(1)&gridded.lat<=test.lat(end),...
                (gridded.lon+180)>=test.lon(1)&(gridded.lon+180)<=test.lon(end));
            test.filename     = sprintf('Test%g',T);
            test.header       = 'Region that spans the dateline';
            test.legend.xpos= 20.7;
            files{ind}      = gmt_plot (catstruct(test,in), 'data');
            info{ind}       = ['Test:' num2str(T) ' demonstrates data that crosses the dateline, but is not global\n\n'];
            
            
        case 12
            %% TEST: custom color table, header_size, map_width, grid lines, region
            
            % Add some annotations some intervals.
            if ~isfield(in,{'stepsize','nlevels'})
                % assuming we have 20 levels, test the following
                tmp = repmat({''},1,20);
                tmp{1} = 'blue'; tmp{6} = 'light blue'; tmp{10} = 'green'; tmp{15} = 'black'; tmp{20} = 'red';
                test.legend.tick_annotations = tmp;
            end
            test.header = 'custom legend and sub-region';
            test.ticks = '30g30/15g15'; % annotations (deg) on major lines (e.g 40 xaxis,20 yaxis)
            % and plot minor lines (e.g 20 xaxis & yaxis)
            test.head_size = 20;              % (GMT default = 36p)
            test.map_width = '17i';              % (default is 9 inches)
            test.region    = '-130/130/-30/30'; % 'lonmin/lonmax/latmin/latmax'
            test.basemap_axis = 'NeSW';
            test.legend.tick_centering = true;
            
            % CUSTOM COLOR TABLE ---
            % For your own custom colortable use in.colorrange.colors (see below). Assign a
            % color to a relative value, e.g between 0-1, where 0 is for the minimum of the
            % datarange and 1 is for the color of the maximum datarange. For example,
            test.colorrange.colors  = {{0,'0/0/255'},...
                {0.3,'255/255/255'},...
                {0.5,'0/255/0'},...
                {.7,'0/0/0'},...
                {1,'255/0/0'}};
            test.colorrange.color_model = 'RGB';
            % makes a colortable that goes from blue to white to green to black to red in RGB format.
            % ------------------------
            
            in.filename = sprintf('Test%g',T);
            files{ind} = gmt_plot(catstruct(gridded,test,in),'data');
            
            info{ind} = ['Test:' num2str(T) ' demonstrates that you can easily make your own custom colortable using in.colorrange.',...
                'You can also insert your own legend annotations to be used instead of',...
                'data values using in.legend.tick_annotations. You can also change in.mapwidth,',...
                'in.headersize, the tick spacing for the axis using in.ticks,',...
                'and in this test its demonstrated how to confine the figure to certain',...
                'geographical regions using in.region = ''lonmin/lonmax/latmin/latmax''',...
                'The legend is also automatically made horizontal if the base/height > 3',...
                'This can easily be overridden by setting in.orientation.orientation = ''v'' \n\n'];
            
        case 13
            
            [names,lats,lons,textcolor,color,textalign,textsize,shape,sze] = satGroupLocations;
            
            
            for i = 1:length(names)
                test.locations(i).lat = lats(i);
                test.locations(i).lon = lons(i);
                test.locations(i).name = names{i};
                test.locations(i).shape = shape{i};
                test.locations(i).size = sze{i};
                test.locations(i).color = color{i};
                test.locations(i).textsize = textsize(i);
                test.locations(i).textcolor= textcolor{i};
                test.locations(i).textalign = textalign{i};
            end
            test.basemap_axis = 'neSW';
            test.header = 'SatGroup locations';
            test.nodata = true;
            test.region = '-20/160/-30/70';
            in.filename = sprintf('Test%g',T);
            files{ind} = gmt_plot(catstruct(test,in));
            
            info{ind} = ['Test' num2str(T) ' demonstrates that you can plot points and text on a map using',...
                'in.locations (see help gmt_plot), and demonstrates that there are',...
                'several map resolutions available.',...
                'The available file types in.figuretype are ''pdf'',''eps'',''png'', and ''tif''\n\n'];
            
        case 14
            
            [names,lats,lons,textcolor,color,textalign,~,shape,sze] = satGroupLocations;
            
            for i = 1:length(names)
                test.locations(i).lat = lats(i);
                test.locations(i).lon = lons(i);
                test.locations(i).name = names{i};
                test.locations(i).shape = shape{i};
                test.locations(i).size = sze{i};
                test.locations(i).color = color{i};
                test.locations(i).textsize = 15;
                test.locations(i).textcolor= textcolor{i};
                test.locations(i).textalign = textalign{i};
            end
            test.basemap_axis = 'neSW';
            test.nodata = true;
            test.region     = '-10/30/45/70';
            test.header      = 'SatGroup locations: Europe';
            test.coast.rivers = 'r';
            in.filename = sprintf('Test%g',T);
            files{ind}    = gmt_plot(catstruct(test,in));
            info{ind} = ['Test' num2str(T) ' demonstrates that you can plot points and text on a map using',...
                'in.locations (see help gmt_plot), and demonstrates that there are',...
                'several map resolutions available.',...
                'The available file types in.figuretype are ''pdf'',''eps'',''png'', and ''tif''\n\n'];
            
        case 15
            
            [names,lats,lons,textcolor,color,textalign,~,shape,sze] = satGroupLocations;
            
            for i = 1:length(names)
                test.locations(i).lat = lats(i);
                test.locations(i).lon = lons(i);
                test.locations(i).name = names{i};
                test.locations(i).shape = shape{i};
                test.locations(i).size = sze{i};
                test.locations(i).color = color{i};
                test.locations(i).textsize = 15;
                test.locations(i).textcolor= textcolor{i};
                test.locations(i).textalign = textalign{i};
            end
            test.basemap_axis = 'neSW';
            test.nodata = true;
            
            
            % TEST: smallregion
            test.header = 'SatGroup locations: Kiruna';
            test.region = '16/22/66.2/70';
            test.coast.rivers = 'a';
            in.filename = sprintf('Test%g',T);
            files{ind} = gmt_plot(catstruct(test,in));
            
            
            info{ind} = ['Test' num2str(T) ' demonstrates that you can plot points and text on a map using',...
                'in.locations (see help gmt_plot), and demonstrates that there are',...
                'several map resolutions available.',...
                'The available file types in.figuretype are ''pdf'',''eps'',''png'', and ''tif''\n\n'];
            
        case 16
            %% TEST: pspolygon
            
            % REGIONS FROM eliasson11:assessing_acp
            a = [-12    80    16   100;...
                -8   100    14   155;...
                -12   155    10   175;...
                35   -70    45   -40;...
                45   -55    60   -10;...
                33   145    40   180;...
                40   160    50   180;...
                36  -180    50  -160;...
                40  -160    55  -135;...
                -27  -110   -18   -72;...
                -18  -130     2   -82;...
                -30   -15    -5    10;...
                -20   -30    -5   -15;...
                -16    15    -5    30;...
                -5    11     0    33;...
                0     0     8    34;...
                -14   -72    -5   -50;...
                -5   -79     0   -56;...
                0   -80    10   -60];
            
            reg = polygoninize_regions(a);
            
            % special for swl
            swl = {[-180  -60; -180 -45],[-180  -45; -80 -45],[-80  -45; -80 -60],...
                [-80  -60; -180 -60],[-50  -60; -50 -45],[-50  -45; 60 -45],...
                [60  -45; 180 -45],[180  -45; 180 -60],[180  -60; 60 -60],[60  -60; -50 -60],...
                [-180  -60; -180 -45],[-180  -45; -80 -45],[-80  -45; -80 -60],[-80  -60; -180 -60],...
                [-50  -60; -50 -45],[-50  -45; 60 -45],[60  -45; 180 -45],...
                [180  -45; 180 -60],[180  -60; 60 -60],[60  -60; -50 -60]}';
            
            test.pspoly = [reg;swl];
            swlcols = repmat({'g'},1,length(swl));
            test.pspolycolor = {'g' 'k' 'r' 'g' 'k' 'r' 'b' 'g' swlcols{:}};
            test.nodata=true;
            test.basemap_axis='nWeS';
            in.filename = sprintf('Test%g',T);
            files{ind} = gmt_plot(catstruct(test,in));
            
            info{ind} = ['Test:' num2str(T) ' demonstrates that you can draw polygons on a map, using in.pspoly.',...
                'E.g. useful if you want to draw regions of interest on a map\n\n'];
            
        otherwise
            error(['atmlab:' mfilename],'Test %g has no entry',T)
    end
    ind = ind+1;
    clear test
end

end

function [names,lats,lons,textcolor,color,textalign,textsize,shape,sze] = satGroupLocations()
% List of home towns for people from the SatGroup

names    = {'Kiruna','Brisbane','Stuttgart','Bremen','Idukki',...
    'Oberstdorf','Amsterdam','Lauchhammer','Freiburg','Hyderabad'};

% Missing: Eskilstuna, Huskvarna

lats     = [67.85 -27.48 48.83 53.1 9.9 47.3 52.4 51.5 48 17.36];
lons     = [20.216 153 9.2 8 77 10.22 4.77 13.77 7.85 78.48];

textcolor= repmat({'black'},1,length(names)); textcolor{1} = 'red';
color    = repmat({'green'},1,length(names)); color{3} = 'yellow';
textalign= {'LM','RB','LM','LB','CB','LT','RM','LM','RM','RM'};
textsize = [15,15,7,7,15,7,7,7,7,7];
shape    = repmat({'c'},1,length(names));shape{3} = 'd';
sze      = repmat({.08},1,length(names)); sze{3} = .1;

end