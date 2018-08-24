function filename = gmt_plot(in,field)
% GMT_PLOT plotting interface for GMT (Generic Mapping Tools)
%
% The function is basically a wrapper that calls gmt shell commands using easy
% to use matlab arguments. Try test_gmt.m for some examples on how to use the function.
% Preferably, the data should be CENTERED if the data is gridded (fastest performance).
%
% OUT   filename  The filename of the figure.
%
% IN    in        A structure with input data and options. See below for
%                 a detailed description of the structure.
%
% OPT   field     The string name of the structure element that contains
%                 the data to be plotted. If no field is given, 'data'
%                 is assumed.
%
% Easy example: If you just want to plot some data..
%                 in.somefield = data2plot
%                 in.lon  = longitudes
%                 in.lat  = latitudes
%
%                 file = gmt_plot(in,'somefield');
%
% see STRUCTURE CONTENTS below for the rest of the available arguments
%
% VIEWING THE PLOT:
% The easiest thing to do is to define a viewer in your startup file.
%
% Add something like the following to your startup file')
% gmtlab( 'OUTDIR', '/name/a/favorite' ) %% The default directory to put plots
% gmtlab( 'PSVIEWER','gv');             %% set viewer for .ps files
% gmtlab( 'PDFVIEWER','xpdf -z width'); %% set viewer for .pdf files
% gmtlab( 'OPEN_COMMAND','gnome-open'); %% set a general open command
% gmtlab( 'VERBOSITY',1); %% This outputs stdout on the screen.
%
% Structure contents:
%
% MANDATORY INPUT
%
% 1) in.(field) % the data (default is field='data' i.e. in.data)
% 2) in.lat     % the corresponding latitudes
% 3) in.lon     % the corresponding longitudes
%
% If your data is ungridded the dimensions of the manditory input
% (lat,lon.data) must be the same.
% i.e isequal(size(in.lat),size(in.lon),size(in.data))
%
% If your data is gridded the data MUST have the dimensions:
% [length(in.lat),length(in.lon)] == size(in.(field));
%  << transpose: in.(field) = in.(field)'; if this is not the case >>
%
% NOTE: 1) If your data is UNGRIDDED I recommend setting
%          in.nearneighbor.resolution = Deg (something suitable).
%       2) gmt_plot automatically detects if the data is gridded or not
%
%
% HOW TO READ VARIABLE DESCRIPTION OF OPTIONAL VARIABLES:
% KEY:  in.variable   in: = expect input type, ex: = Explanation/Example, de: = Default value/behavior
% NOTE: If "def" is missing for a variable it means the variable is not used by default
%
%                  types: %s=character or string
%                         %f=numeric/logical
%                         {}=cell
%--------------------------------------------------------------------------
%
% GENERAL:
%
% in.annot_font_size_primary
%                   in:     %s or %f (if %f, unit is assumed from in.measure_unit)
%                   ex:     The size of the font, e.g., '2c'=2cm for e.g., the axis.
%                           Setting this will also change the size of the
%                           fonts of the annotations for the legend. If you
%                           want a different size for the legend
%                           annotations, set in.legend.font_size.
%                   def:    '14p'
% in.basemap_axis   in:     %s
%                   ex:     'WSne', annotates West and South of the map,
%                           but not North or East
%                   def:    'WSne'
%                   ------------
% in.display        in:     %f
%                   ex:     If false, file created but not displayed
%                   def:    true
%                   ------------
% in.filename       in:     %s
%                   ex:     'yourfilename', or 'yourfilename.jpg'
%                   def:    Generated from title. The filetype is determined by the file
%                           ending given by your filename, e.g., any of bla.{pdf,jpg,eps,tif,png,ps}
%                     ------------
% in.figuretype     in:     %s
%                   ex:     'eps','pdf','BMP','jpg','PNG','PPM' (not recommended), or 'tif'.
%                           If the figure type is included in the filename,
%                           e.g., file.png, or file.jpg, then that file type is
%                           used, however defining in.figuretype will
%                           override this.
%                   def:    'pdf'
%                     ------------
% in.gmtset         in:     {%s,%s,...}
%                   ex:     Cell with one or more gmtset commands.
%                           E.g. in.gmtset={'gmtset D_FORMAT %3.1e','gmtset ...'}
%                     ------------
% in.header         in:     %s
%                   ex:     Title of plot
%                   def     ''
%                     ------------
% in.header_font    in: %s or %f
%                   ex: There are 35 fonts to choose from. Either provide a
%                       number 1-35 or a string (case sensitive) of the
%                       font to use. E.g., 'Helvetica' (0), 'Times-Roman' (4),
%                       'Courier' (8), etc. See "gmtdefault" man page for the
%                       whole list
%                   def: 'Helvetica' ('0')
%                     ------------
% in.header_fontsize in:    %s or %f (if %f, unit is assumed from in.measure_unit)
%                   ex:     Title size
%                   def:    '36p' (points)
%                     ------------
% in.header_offset  in:     %s or %f (if %f, unit is assumed from in.measure_unit)
%                   ex:     Moves the title in y-dir on the page
%                   def:    '0.5c' (cm)
%                     ------------
% in.keep_files     in:     %f
%                   ex:     If you don't want to delete intermediate files
%                   def:    false
%                     ------------
% in.measure_unit   in:     %s
%                   ex:     You can explicitly specify the unit used for
%                       distances and lengths by appending c (cm), i (inch), m
%                       (meter), or p (points). When no unit is indicated the
%                       value will be assumed to be in the unit set by
%                       MEASURE_UNIT. The default unit to use for all commands
%                       if none is given.
%                   def:    'c'
%                     ------------
% in.nodata         in:     %f
%                   ex:     If you only want a map (compatible with all options)
%                   def:    false
%                     ------------
% in.outdir         in:     %s
%                   ex:     'name/a/directory'
%                   def:    gmtlab('OUTDIR')  ('.' if not set)
%                       ------------
% in.plotPlacement  in:     %s
%                   ex:     String of global plotPlacements (see "man grdimage" for info)
%                   def:    '-Ya5 -Xa5'
%                       ------------
% in.ticks          in:     %s
%                   ex:     '60g30/30g15'. The first value for both axis
%                           denotes the tick interval to annotate, the second
%                           value is the interval to draw the gridlines. xaxis and
%                           yaxis are separated by '/'. i.e (x-axis: 'annot'g'grid'/ y-axis: 'annot'g'grid')
%                           Note: To remove gridlines set the second value to 0.
%                   def:    Determined by input lat/lon range.
%                     ------------
% in.unit           in:     %s
%                   ex:     String displayed on the y-axis of a legend
%                   def:    ''
%                     ------------
% in.xunit          in:     %s
%                   ex:     String displayed on the x-axis of a legend
%                   def:    ''
%                     ------------
%
% NOTE:               For special characters in the string refer to the
%                     section on character escape sequences (4.16 in GMT
%                     cookbook v4.5.7).
%                     e.g. for unit (or title) \Delta r^{-2} should be
%                     written '@~D@~r@+-2' (see GMT_manpages under plotting
%                     text (p207 GMT 5.0)
%
%--------------------------------------------------------------------------
%
% PROJECTION, GRID, COASTLINES:
%
% in.region         in:     %s
%                   ex:     '-180/180/-90/90'=global range, defined from
%                           sprintf('%f/%f/%f/%f',lon1,lon2,lat1,lat2)
%                   def:    determined by input lat/lon range
%                     ------------
% in.nearneighbor   in:     %s
%                   ex:     'nearneighbor OPT > filename.ps', explicitly sets
%                           the nearneighbor GMT command directly. If
%                           in.nearneighbor is a structure, it'll use the
%                           structure arguments to generate the command.
%                     ----------------------
%
% in.nearneighbor.    | STRUCTURE with one or more of the following fields:
%
%  search           in:     %s
%                   ex:     '30m' Search for data within 30 [arcmin]
%                   def:    Loosely based on the density of the data points
%                     ------------
%  resolution       in:     %f [degree]
%                   ex:     1˚ (== 60minuntes) looks for values withing 1˚
%                   def:    Loosely based on the density of the data points, or avialable memory
%
%                     ----------------------
%
% in.projection     in:     %s
%                   ex:     See available projections in GMT manual.
%                   def:    'Q' (cylindric equidistant)
%                     ------------
% in.center         in:     %f
%                   ex:     Center map at given longitude
%                   def:    0˚
%                     ------------
% in.map_width      in:     %s or %f (if %f, unit is assumed from in.measure_unit)
%                   ex:     Set width of map, e.g., '20c'=20cm
%                   def:    20 (cm)
%                     ------------
% in.proj           in:     %s
%                   ex:     Describes the projection, center, and map_width
%                   def:    'Q0/20' (see above)
%                     ------------
% in.pscoast        in:     %s
%                   ex:     'pscoast OPT > filename.ps', explicitly sets the
%                           pscoast GMT command.
%                     ----------------------
% in.coast          in:     %f
%                   ex:     If you don't want coastlines, set to false. If
%                           in.coast is a structure, it'll use the structure
%                           arguments to generate the pscoast command.
%                   def:    To generate coastlines
%                     ----------------------
%
% in.coast.           | STRUCTURE with one or more of the following fields:
%
%  features         in:     %f
%                   ex:     Don't plot features < in.features [km²]
%                   def:    determined by lon/lat range
%                     ------------
%  resolution       in:     %s
%                   ex:     (f)ull, (h)igh, (i)ntermediate, (l)ow, and (c)rude
%                   def:    determined by lon/lat range
%                     ------------
%  rivers           in:     %s
%                   ex:     Display rivers. pscoast -Ioption (1-10, a,r,i,c)
%                   def:    '1' (=major rivers)
%                     ------------
%  width            in:     %f [points]
%                   ex:     Width of coastlines
%                   def:    .3
%                     ----------------------
%  color            in:     %s
%                   ex:     Color of coast and rivers in rgb e.g. '255/255/255'
%                           gives white coastlines
%                   def:    COLOR_BACKGROUND
%                     ----------------------
%
% (for grid, see in.ticks)
%
%--------------------------------------------------------------------------
%
% COLORS & DATA REPRESENTATION:
%
% in.datarange      in:     [%f, %f]
%                   ex:     Min and max range of data values to display
%                     ------------
% in.grdimage       in:     %s
%                   ex:     'grdimage OPT > filename.ps', explicitly sets
%                           the grdimage GMT command directly.
%                     ------------
% in.makecpt        in:     %s
%                   ex:     'makecpt OPT > filename.ps', explicitly sets the
%                           makecpt GMT command directly.
%                     ------------
% in.cptfile        in:     %s
%                   ex:     Path to any .cpt file generated previously
%                     ------------
% in.ctable         in:     %s
%                   ex:     See GMT color palettes
%                   def:    'rainbow'
%
%                     NOTE: 'mypolar' is a nice colortable for difference
%                     plots, and there are two additional optional
%                     arguments for this color table:
%                                   ------------
%                     in.reference:  in:    %d
%                                    ex:    Where to center the white color
%                                    def:   mean(data(:))
%
%                           Note:    Recommend set in.reference = 0 for
%                                    difference plots, but any reference
%                                    will work.
%                                   ------------
%
%                     in.nwhite:     in:    %d
%                                    ex:    The number of white contours around
%                                           a reference value
%                                    def:   determined by number of levels
%
% in.color_background   in:  %s
%                       ex:  Set the background color (values less than range)
%                       def: '0/0/0' ('black')
%                     ------------
% in.color_foreground   in:  %s
%                       ex:  Set the foreground color (values greater than range)
%                       def: '255/255/255' ('white')
%                     ------------
% in.color_nan          in:     %s
%                       ex:     Set the color of NaNs
%                       def:    '125/125/125' ('grey')
%                     ------------
% in.nlevels            in:     %d
%                       ex:     Refers to the number of contour levels (converted to
%                           stepsize using datarange)
%                       def:    20
%                     ------------
% in.force_nlevels      in:     (logical)
%                       ex:     If set to true, keep nlevels even if it
%                               exceeds  the number of unique values.  If
%                               set to false, nlevels is reduced to the
%                               number of unique values if it exceeds it.
%                       def:    false
%                      ------------
% in.stepsize           in:     %f
%                       ex:     The stepsize between data values. This overrides
%                               nlevels (-T/min/max/stepsize in makecpt)
%                       def:    determined by nlevels
%                     ------------
%
% in.tickval            in:     %f
%                       ex:     Vector of values to be used for ticks and data interval
%                       def:    Determined by datarange and stepsize
%                     ------------
%
% NOTE: For your own CUSTOM COLORTABLE use in.colorrange.colors
% (see below). Assign a color to a relative value, e.g between 0-1, where
% 0 is for the minimum of the datarange and 1 is for the color of the
% maximum datarange. For example,
% in.colorrange.colors = {{0,'250/0/0''},{.3,'0/0/0'},{0.5,'0/255/0'},{1,'0/0/255'}},
% makes a colortable that goes from red to black to green to blue.
% Naturally you can also use the 'contour values' directly as long as you
% assign all levels a color.
%
%                     ----------------------
% in.colorrange.      | STRUCTURE with one or more of the following fields:
%
%  colors           in:     {{%d,%s},{%d,%s},etc.} %d is the data value, %s is the color
%                   ex:     {20,'255/0/0'} (red in RGB)
%                     ------------
%  color_model      in:     %s
%                   ex:     'RGB', 'HSV'
%                   def:    'RGB'
%                     ----------------------
%
%------------------------------------------------------------------------------------
% LEGENDS:
%
% in.extra_legend     structure containing:
%       name        in:     %s
%                   ex:     An associated string name. E.g., 'NaN','masked', etc...
%                   def:    mandatory
%                     ------------
%       type        in:     %s
%                   ex:     'bg','fg', or 'nan', means use the color for the background,
%                            foreground, or nan, given in in.color_background, in.color_foreground,
%                            in.color_nan. So far these are the only 3 options.
%                   def:    mandatory
%                     ------------
%       position    in:     %s
%                   ex:     '9.7i/2.3i/0.8c/0.8c' ('x-displacement/y-displacement/height/width') (i = inch , c = cm)
%                           Append 'h' for horisontal legend.
%                   def:    Placement otherwise determined by the placement of the main legend
%                     ------------
%      fontsize     in:     %s or %f (if %f, unit is assumed from in.measure_unit)
%                   ex:     '10c'
%                     ----------------------
% in.pscale         in:     %s
%                   ex:     'psscale OPT > filename.ps', explicitly sets the
%                            psscale GMT command for the legend directly.
%                     ------------
% in.pscale_extra   in:     %s
%                   ex:     'psscale OPT > filename.ps', explicitly sets the
%                           psscale GMT command for the extra legend directly.
%                     ------------
% in.savelegend     in:     %f
%                   ex:     Controls separate PDF for the legend.  If value
%                           is 0, only 1 file will be generated containing
%                           map+legend.  If value is 1, one file will be
%                           generated for map+legend and one file for
%                           legend only.  If value is 2, one file will be
%                           generated containing ONLY the map, and one
%                           containing ONLY the legend.  The legend will be
%                           stored in [in.filename '_legend.' extension] in
%                           the output directory.
%                   def:    false
%                     ------------
% in.legend         in:     %f
%                   ex:     Set to false if you don't want a legend. if in.legend
%                           is a structure, it's equivalent to in.legend = true
%                   def:    true
%                     ----------------------
%
% in.legend.          | STRUCTURE with one or more of the following fields:
%
%  font_size
%                   in:     %s or %f (if %f, unit is assumed from in.measure_unit)
%                   ex:     Size of annotations in legend, e.g., '1c'=1cm
%                   def:    '14p'
%                     ------------
%  box_spacing      in:     %f
%                   ex:     Space between legend boxes
%                   def:    0 (side by side)
%                     ------------
%  position         in:     %s
%                   ex:     '9.7i/2.3i/10c/0.8c' (i = inch , c = cm)
%                           ('x-displacement/y-displacement/height/width'). Append 'h'
%                           for horisontal legend.
%                   def:    Determined by map dimensions
%                     ------------
%  equalboxwidth    in:     %f
%                   ex:     If the legend color boxes have to be the same size, 1
%                   def:    false (-L option)
%                     ------------
%  length           in:     %s or %f (if %f, unit is assumed from in.measure_unit)
%                   ex:     Toggle the length of the legend bar (e.g., '3.9i'=3.9 inch). Use negative value to reverse the
%                           legend. See also width,xpos,ypos,orientation for legend
%                   def:    '3.9i'
%                     ------------
%  orientation      in:     %s
%                   ex:     If you want a horizontal/vertical legend input 'h'/'v'.
%                   def:    Determined by map dimensions
%                     ------------
%  shift_tick_annotations
%                   in:     %s
%                   ex:     Move tick annotations to the right by x units, e.g. '.5i' (.5 inches)
%                     ------------
%  sidebar          in:     %f
%                   ex:     Input scalar 0, 1, 2, or 3. Indicates none,
%                           below range only, above range, or both
%                   def:    Determined from data
%                     ------------
%  tick_annotations
%                   in:     {%s,%s,...}
%                   ex:     {'','','middle','',''}. Number of annotations must be = nlevels, and all
%                           cell elements must be strings (or empty strings)
%                     ------------
%  tick_annotation_format
%                   in:     %s
%                   ex:     '%3.1e'
%                     ------------
%  tick_centering   in:     %f
%                   ex:     Have tick annotation at the center of the boxes
%                   def:    false (edges)
%                     ------------
%  tick_length      in:     %s or %f (if %f, unit is assumed from in.measure_unit)
%                   ex:     The length of the ticks, e.g., '.5c'=.5cm
%                     ------------
%  tick_spacing     in:     %f
%                   ex:     If you want to manually decide how the ticks in the
%                           legend should be spread. x=> every xth data value,
%                           1=>same number of ticks as datarange
%                   def:    One tick per data level
%
%                   NOTE: This option is desirable if you have many
%                           data levels.
%                     ------------
%  width            in:     %s or %f (if %f, unit is assumed from in.measure_unit)
%                   ex:     Toggle the width of the legend bar. See also length,xpos,ypos, orientation for legend
%                   def:    '.2i'
%                     ------------
%  xpos             in:     %s or %f (if %f, unit is assumed from in.measure_unit)
%                   ex:     Toggle the x-position of the center of the
%                           legend bar. See also length,width,ypos, orientation for legend
%                   def:    '9.8i' for verticle
%                     ------------
%  ypos             in:     %s or %f (if %f, unit is assumed from in.measure_unit)
%                   ex:     Toggle the y-position of the center of the legend bar.
%                           See also length,width,xpos, orientation for legend
%                   def:    '2.3i' for verticle
%------------------------------------------------------------------------------------
% PLOT LOCATION MARKERS:
%
%  for multiple locations define all fields according to :
%  in.locations(1).name = 'x',
%  in.locations(2).name = 'y', etc...
%
%                     ----------------------
%
% in.locations.       | Structure with one or more of the following fields:
%
%  lat              in:     %f
%                   ex:     Latitude of marker
%                   def:    mandatory user input
%                     ------------
%  lon              in:     %f
%                   ex:     Longitude of marker
%                   def:    manditory user input
%                     ------------
%  name             in:     %s
%                   ex:     Name of marker
%                     ------------
%  shape            in:     %s
%                   ex:     Shape of marker
%                   def:    'c' c=filled circle
%                     ------------
%  size             in:     %f
%                   ex:     Size of shape.
%                   def:    .08
%                     ------------
%  color            in:     %s
%                   ex:     Color of marker
%                   def:    'white'
%                     ------------
%  textsize         in:     %f
%                   ex:     Size of name
%                   def:    15
%                     ------------
%  textcolor        in:     %s
%                   ex:     Color of name
%                   def:    in.location.color
%                     ------------
%  textalign        in:     %s
%                   ex:     Two letters for the position of marker relative
%                           to the text. 1st letter for horizontal
%                           position: L, C, R. 2nd letter for vertical
%                           position: T, M, B
%                   def:    'LT'
%--------------------------------------------------------------------------
%
% PLOT CONTOURS:
%
% in.grdcontour     in:     %s
%                   ex:     'grdcontour OPT > filename.ps', explicitly sets
%                           the grdcontour GMT command directly.
%                     ------------
%
% in.contourline.     | Structure with one or more of the following fields:
%
% spacing           in:     %f
%                   ex:     Data interval between contours
%                     ------------
% range             in:     [%f %f]
%                   def:    in.datarange
%                     ------------
% linethick         in:     %f
%                     ------------
% more              in:     %s
%                   ex:     Additional commands for GMT's grdcontour.
%                           E.g. '-T1c/0.001c:LH'
%                     ----------------------
%
% If several contour plots should overlap define all fields according to:
%  in.grdcontour(1).spacing = x,
%  in.grdcontour(2).spacing = y, etc...
%--------------------------------------------------------------------------
%
% DRAW SHAPES ON MAP:
% in.psbox = [%f %f %f %f]
% in.psbox.           | Structure with one or more of the following fields:
%
%                     ----------------------
%  box              in:     [%f %f %f %f]
%                   ex:     E.g. for box regions: [lon11 lat11 lon12 lat12;lon21 lat21 lon22 lat22]=
%                           [Bottom left corner1, Top right corner1;
%                           Bottom left corner2, Top right corner2]|
%                     ------------
%  boxes            in:     [%f %f ...]
%                   ex:     The index of the last row of the regions. e.g 3 7, if
%                           you have 2 regions defined by 3 resp 4 boxes. This is
%                           useful for defining psboxcolor. Each index is defines
%                           the last corner of a region, where a region is
%                           essentially made up of many smaller boxes regions.
%                     ------------
% boxcolor          in:     {[%f %f %f]}
%                   ex:     RGB color or every region
%                   def:    {[0 0 0]} for every region
%                     ------------
% boxthick          in:     {%f}
%                   ex:     Thickness of lines
%                   def:    20 for every region boundary
%                     ------------
%
% in.pspoly (%double)
%                   in:     {[%f %f;%f %f;...] [%f %f;...]}
%                   ex:     Draws a polygon. Use one cell row per polygon:
%                           {[p1lon1 p1lat1; p1lon2 p1lat2| ...];...}
%                     ------------
% in.pspolycolor    ex:     See in.psboxcolor
%                     ------------
% in.pspolythick    ex:     See in.psboxthick
%                     ------------
%
%--------------------------------------------------------------------------
% DRAW TEXT ON A MAP
%
% in.pstext         in:     %s
%                   ex:     'pstext OPT > filename.ps', explicitly sets
%                           the pstext GMT command directly. If in.pstext is a
%                           structure, it'll use the structure arguments to
%                           generate the command.
%                     ----------------------
%
% in.pstext.          | STRUCTURE with one or more of the following fields:
%
%  for multiple text entries define all fields according to :
%  in.pstext(1).text = 'example',
%  in.pstext(2).text = 'example2', etc...
%
%  lat              in:     %f
%                   ex:     Centre word at this latitude
%                   def:    manditory user input
%
%  lon              in:     %f
%                   ex:     Centre word at this longitude
%                   def:    manditory user input
%
%  text             in:     %s
%                   ex:     String to appear at lat/lon
%                   def:    manditory user input
%
%  thick            in:     %f
%                   ex:     Text size in points
%                   def:    20
%
%  angle            in:     %f
%                   ex:     degrees counter-clockwise from horizontal
%                   def:    0˚
%
%  fontnum          in:     %f
%                   ex:     Sets the font type
%                   def:    1
%
%  justify          in:     %f
%                   ex:     Sets the alignment
%                   def:    6
%
%  color            in:     %s
%                   ex:     RGB text color
%                   def:    '0/0/0'
%--------------------------------------------------------------------------
%
% QUICK TEST
%
% in.lat  = -89.5:89.5;
% in.lon  = -179.5:179.5
% in.data = rand(length(in.lat),length(in.lon))
% file = gmt_plot(in);
%
%
% Created by Salomon Eliasson (s.eliasson@ltu.se) and Oliver Lemke
% $Id: gmt_plot.m 8941 2014-09-15 11:04:40Z olemke $

if ~exist('field','var') && isfield(in,'data')
    field = 'data';
end

assert(logical(exist('field','var')) || (isfield(in,'nodata')&&in.nodata) ,...
    ['atmlab:' mfilename ':badInput'],...
    'I need a "field".\nIf you want to plot the map with no data, input in.nodata=true')

check_input(in)

if isfield(in,'nodata')&&in.nodata
    out = set_GMT_plot(in);
else out = set_GMT_plot(in,field);
end

% make TEMPDIR and set atmlab('VERBOSITY') to gmtlab('VERBOSITY')
% cleanup after I'm done
out.tmpdir = create_tmpfolder();
p = pwd(); V = atmlab('VERBOSITY');
cleanupObject = onCleanup(@() gmtcleanup(out.tmpdir,p,out.keep_files,V));

atmlab('VERBOSITY',gmtlab('VERBOSITY'));

cd(out.tmpdir);

if out.gridded
    out.grdfile = [out.filename '.grd'];
    gmt_nc_save_gridded(out.lon,out.lat,out.(field),out.grdfile);
    logtext(1,'Writing grdfile: %s sucessfull\n',out.grdfile)
else
    if ~out.nodata
        out.ungriddedfile = [out.filename '.nc'];
        gmt_nc_save_ungridded(out.ungriddedfile,double(out.(field)),out.lat,out.lon);
    end
end

% main function
commands = create_gmt_earth(out);

% finalize

filename=sort_figures(out,commands);

end
%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
%     ||||
%     vvvv
function in = set_GMT_plot(in,field)
%% SETUP %%


% Test is GMT is installed and in the path
[a,b] = system('which gmtset');
if a == 1
    error(['gmtlab:' mfilename ':shell'],[ [ b '\n\n'],...
        'Either GMT is not installed\n',...
        'or\n',...
        'You need to add its installation directory to your PATH\n',...
        'e.g. in Matlab you can add the PATH via \n',...
        'setenv(''PATH'',[getenv(''PATH'') '':<GMTINSTALLDIR>/bin''])'])
end

% SET DEFAULTS
% general
default.annot_font_size_primary = '14p';     % size of axis labels (include legend if not set differently by in.legend.font_size)
default.basemap_axis    = 'nSeW';           % Annotates West and South of the map.
default.display         = true;             % Display figure to screen
default.center          = 0;                % The center longitude of the map. The region has to be -180:180 (cyclic)
default.color_background= '0/0/0';
default.color_foreground= '255/255/255';
default.color_nan       = '150/150/150';
default.header          = '';               % no title by default
default.header_font     = 'Helvetica';      % one of 35 available fonts
default.header_fontsize = '36p';
in = optargs_struct(in,default);
% how far the title is removed from the top of the map (depends on 'N' or 'n')
default.header_offset   = [num2str(-0.4+0.6*ismember('N',in.basemap_axis)) 'c'];
default.keep_files      = false;            % keep intermediate files (debugging)
default.map_width       = 20;
default.measure_unit    = 'cm';             % Choose between cm, inch, m, and point.
default.nlevels         = 20;               % Use 20 color levels by default
default.force_nlevels   = false;            % do not force, e.g. reduce if uniques are less
default.nodata          = false;            % true if you only want the map
default.outdir          = gmtlab('OUTDIR'); % where to put the figure
default.plotPlacement   = '-Xa5 -Ya5';      % String of global plotPlacements
default.projection      = 'Q';              % Cylindrical Equidistant Projection.
default.savelegend      = false;            % make an additional pdf-file only containing the legend
default.unit            = '';               % unit displayed with legend
default.xunit           = '';               % xlabel for the legend

in = optargs_struct(in,default);

in.outdir = sanitise(in.outdir);

if strcmp(in.outdir(1),'~')
    % netcdffunctions don't like ~ for home
    in.outdir = [getenv('HOME') '/' in.outdir(2:end)];
end

if system(sprintf('test -d %s -a -w %s',in.outdir,in.outdir))
    error(['gmtlab:' mfilename ':BadInput'],...
        'Either %s doesn''t exist, or atmlab does not have write access to %s',in.outdir,in.outdir)
end

% backward compatibility
if isfield(in,'header_size')
    warning('atmlab:temporary','in.header_size has been renamed to in.header_fontsize. in.header_size will be removed in future releases')
    in.header_fontsize = in.header_size; in=rmfield(in,'header_size');
end

if ~isempty(in.header)
    default.filename = ['gmtfile_' in.header '.pdf'];
else default.filename = 'default.pdf';
end

in = optargs_struct(in,default);

% find default figuretype
b = regexp(in.filename,'\.');
if ~isempty(b)
    ft = in.filename(b(end)+1:end);
    if ismember(lower(ft),lower({'eps','pdf','BMP','JPEG','jpg','PNG','PPM','tif'}))
        default.figuretype = ft;
    else
        logtext(atmlab('OUT'),'figuretype: %s is not an available type. Will produce .pdf\n',ft);
        default.figuretype = 'pdf';
    end
    if ~isfield(in,'figuretype')
        in.filename=in.filename(1:b(end)-1);
    end
else
    default.figuretype = 'pdf';
end

in = optargs_struct(in,default);

in.filename = sanitise(in.filename);
in.header = regexprep(in.header,'([()])','\\$1');
in.header = regexprep(in.header,':',' ');

%coast
if ~isfield(in,'coast') || isstruct(in.coast) || in.coast
    if ~isfield(in,'coast'), in.coast=struct([]);end
    default.rivers      = '1';  % '1' displays major rivers only. 'a' displays all.
    default.width       = .3;   % width of the coast
    
    in.coast            = optargs_struct(in.coast,default); clear default
end

if in.nodata
    % If I only want an empty map, get the essentials and leave here.
    in = nodata(in);
    return
end

if ~ismember(field,fieldnames(in))
    error(['gmtlab:' mfilename ':BadInput'],...
        'no field by the name of "%s" in struct',field)
else
    in.fieldname  = field;
end

% is the data plotable?
in = isdata(in,field);

% Check to see if the data is gridded or not
in = isgridded(in,field);

% Also get rid of NaNs in the geodata (This only applies to ungridded data)
in = rmNaNsGeo_and_standardize_geodata(in,field);

% REGION
in = assign_region(in,field);

in = specialregion(in,field); %in case the region covers the dateline and is not continuous


% DATARANGE
if ~in.nodata
    default.datarange     = getdatarange(in,field); %
    if any(isnan(in.(field)(:)))
        default.extra_legend = struct('name','NaN','type','nan'); % include NaNs in the legend
    end
end
in = optargs_struct(in,default);
in.datarange = double(in.datarange);

% COLORS & DATA REPRESENTATION
default.ctable      = 'rainbow';          % color palette
[default.stepsize,default.tick_annotation_format]    = getstepsize(in,field);    % color level datastep interval
in = optargs_struct(in,default); clear default

% LEGEND
in = setupLegend(in);

end


%% SUBFUNCTIONS FOR SETUP
%      ||||||
%      VVVVVV

function check_input(in)
%% CheckInput
% Checks the input type of all options. If the field is in the list of
% available options, it will be tested against a anomynous function (e.g.
% in.region should pass @(x)(ischar(x)) ). The field names and their
% corresponding test functions are listed in gmt_inputs.

errID = ['gmtlab:' mfilename ':BadInput'];
assert(isstruct(in),errID,'"in" must be a structure')

[GSE,GSSE] = gmt_inputs;

Fields = fieldnames(in)';

for F = Fields
    % See if the in.(field) is a listed option
    test = GSE(ismember(GSE(:,2),F{1}),:);
    
    if ~isempty(test)
        % corresponding test function
        fun = test{1};
        strfun = func2str(fun);
        
        assert(fun(in.(test{2})),errID,...
            'Input type is incorrect. in.%s should pass test: %s',test{2},strfun);
        
        % If in.(field) is itself a structure, do it again (more or less)
        if isstruct(in.(test{2})) && ismember(test{2},fieldnames(GSSE))
            Fields2 = fieldnames(in.(test{2}))';
            for F2 = Fields2
                test2 = GSSE.(test{2})(ismember(GSSE.(test{2})(:,2),F2{1}),:);
                if ~isempty(test2)
                    fun = test2{1};
                    strfun = char(fun);
                    assert(fun(in.(test{2})(1).(test2{2})),errID,...
                        'Input type is incorrect. in.%s.%s should pass the test: @%s',...
                        test{2},test2{2},strfun);
                else
                    warning(errID,'in.%s.%s is not a valid field in in.%s ',...
                        test{2},F2{1},test{2})
                end
            end
        end
    end
end

end

function in = assign_region(in,field)

errId = ['gmtlab:' mfilename ':badInput']; % common error ID

if ~isfield(in,'region')
    if in.gridded
        % check if the data is probably global
        
        dn = diff(in.lon);
        dt = diff(in.lat);
        if isempty(dt), dt = mean(dn);end %incase there's only one latitude
        
        % make the region str, keeping in min the 'resolution' of the grid
        annot_format = {getAnnotFormat(mean(diff(in.lon))),...
            getAnnotFormat(mean(diff(in.lat)))};
        
        % check to see if lon-dlon is out side the boundary. If so, fix the
        % region to the edges. Same goes for lat...
        cond1 = abs(-180-in.lon(1)) <= dn(1);
        cond2 = 180-in.lon(end) <= dn(end);
        cond3 = abs(-90-in.lat(1)) <= dt(1);
        cond4 = 90-in.lat(end) <= dt(end);
        
        af = annot_format{1};
        if cond1 && cond2 && cond3 && cond4
            in.region = '-180/180/-90/90';
        elseif cond1 && cond2
            fstr = sprintf('-180/180/%s/%s',af,af);
            in.region = sprintf(fstr,in.lat(1)-dt(1)/2,in.lat(end)+dt(end)/2);
        elseif cond3 && cond4
            fstr = sprintf('%s/%s/-90/90',af,af);
            in.region = sprintf(fstr,in.lon(1)-dn(1)/2,in.lon(end)+dn(end)/2);
        else
            fstr = sprintf('%s/%s/%s/%s',af,af,af,af);
            in.region = sprintf(fstr,...
                in.lon(1)-dn(1)/2,in.lon(end)+dn(end)/2,...
                in.lat(1)-dt(1)/2,in.lat(end)+dt(end)/2);
        end
    else
        in.region = sprintf('%g/%g/%g/%g',...
            min(in.lon(:)),max(in.lon(:)),...
            min(in.lat(:)),max(in.lat(:)));
    end
else
    in.userDefinedRegion = true;
    % remove frivolous data for memory and speed performance in that case
    x = sscanf(in.region,'%f/%f/%f/%f');
    lt = in.lat >= x(3) & in.lat <=x(4); %logical vector
    ln = in.lon >= x(1) & in.lon <=x(2); %logical vector
    if in.gridded
        in.(field) = in.(field)(lt,ln);
        in.lat = in.lat(lt);
        in.lon = in.lon(ln);
    else
        in.(field) = in.(field)(lt&ln);
        in.lat = in.lat(lt&ln);
        in.lon = in.lon(lt&ln);
    end
    assert(~isempty(in.lat) && ~isempty(in.lon),...
        errId,'lat or lon are empty')
end

end

function datarange = getdatarange(in,field)
%% getdatarange

tmp = in.(field)(:);
d = double([min(tmp(~isinf(tmp))) max(tmp(~isinf(tmp)))]);

% Do some tricks to get the most useful datarange. (rounded, but preserve precision)
x = log10(d(2)-d(1));

datarange = [10^(round(x)-1) * round(d(1) * (1/10^(round(x)-1))),...
    10^(round(x)-1) * round(d(2) * (1/10^(round(x)-1)))];


end

function [stepsize,annot_format] = getstepsize(in,field)
%% getstepsize

if in.nodata
    stepsize = 0;
    annot_format='';
    return
end

% default number of levels
if length(unique(in.(field)))<in.nlevels && ~in.force_nlevels
    logtext(atmlab('OUT'),'unique values < %d\n',in.nlevels)
    in.nlevels = length(unique(in.(field)));
    logtext(atmlab('OUT'),'setting in.nlevels =  length(unique(in.(field)) (%d)\n',...
        length(unique(in.(field))))
end

if isfield(in,'stepsize')
    % warning('gmtlab:input','in.stepsize overrides in.nlevels')
    stepsize = in.stepsize;
elseif ~isfield(in,'stepsize')
    stepsize = (in.datarange(2)-in.datarange(1))/in.nlevels;
end
annot_format = getAnnotFormat(stepsize);

end

function in = nodata(in)
%% NODATA
% if you want to only plot coastlines

in.sidebar = false;
in.legend  = false;
in.gridded = false;
in.nlevels = 1;
if isfield(in,'region')
elseif ~isfield(in,'region') && all(isfield(in,{'lat','lon'}))
    in.region = sprintf('%g/%g/%g/%g/%g',...
        min(in.lon(:)),max(in.lon(:)),...
        min(in.lat(:)),max(in.lat(:)));
else
    in.region='-180/180/-90/90';
end

end

function in = isdata(in,field)
%% is there any useable data?

Id  = ['gmtlab:' mfilename ':badInput'];
Eps = 1e-10;

% silently squeeze the data
in.(field)=squeeze(in.(field));
assert(isfield(in,field), Id,'The field: "%s" is not in the structure',field)
assert(any(~isnan(in.(field)(:))),'gmtlab:gmt_plot:noData',...
    '%s%s','Data does not contain any valid',...
    ' values for contour levels to be based on...')
assert(~(~ismatrix(in.(field))),Id,'in.%s must not be more than 2 dimensional',field)
assert((max(in.(field)(:))-min(in.(field)(:))>Eps),Id,...
    'min(data) must not be equal to max(data)')

% check for lat and lons
if ~isfield(in,'lat')
    l = {'Latitude','latitude'};
    assert(any(isfield(in,l)),Id,'No latitudes present')
    in.lat = in.(l{isfield(in,l)});
elseif any(isfield(in,{'Latitude','latitude'}))
    disp('Several latitude vectors present. Using in.lat')
end
if ~isfield(in,'lon')
    l = {'Longitude','longitude','long'};
    assert(any(isfield(in,l)),Id,'No longitudes present')
    in.lon = in.(l{isfield(in,l)});
elseif any(isfield(in,{'Longitude','longitude','long'}))
    disp('Several longitude vectors present. Using in.lon')
end

end

function in = isgridded(in,field)
%% ISGRIDDED: Test if the data is gridded
%  If it is not gridded, flatten the data

if isempty(in.(field))
    error(['gmtlab:' mfilename ':BadInput'],....
        'The data variable: in.%s is empty',field)
end

if ndims(in.(field))==3
    in.(field) = squeeze(in.(field));
end

[a,b]=size(in.(field));
pos1 = a==length(in.lat)&b==length(in.lon); %(lat,lon)
pos2 = b==length(in.lat)&a==length(in.lon); %(lon,lat)

% if (pos1 && pos2) && (pos1 || pos2), then we dont know if it gridded, but
% assume it's not.
if ~isfield(in,'gridded')
    ig = ~ (isequal(size(in.(field)(:)),size(in.lat(:)),size(in.lon(:))));
    if ~ig
        in.(field) = in.(field)(:);
        in.lat     = in.lat(:);
        in.lon     = in.lon(:);
        in.gridded = false;
    else
        if pos2 && (pos2 ~= pos1)
            % want it in (lat,lon)
            in.(field)=in.(field)';
        end
        in.gridded = true;
    end
end

end

function in = rmNaNsGeo_and_standardize_geodata(in,field)
%% rmNaNsGeo
% Also get rid of NaNs in the geodata
% This only applies to ungridded data

errId = ['gmtlab:' mfilename ':badInput']; % common error ID

if ~in.gridded

index = in.lat >= -90 & in.lat <= 90 & in.lon >= -180 & in.lon <= 360;
if any(~index)
    logtext(1,'Data with dodgy geodata will be ignored (%.2f%%)\n',100*sum(~index)/numel(index))
    in.lat = in.lat(index);
    in.lon = in.lon(index);
    in.(field) = in.(field)(index);
end

else
    % make sure that the lons,lats and data are ordered in ascending and data(lat,lon)
    assert(length(in.lat)*length(in.lon)==numel(in.(field)),...
        errId,'numel(data) must length(lat)*length(lon)')
    [~,in.lat,in.lon,in.(field)] = standardize_geodata(in.lat,in.lon,in.(field));
    
end

end

function in = setupLegend(in)
% SETUP LEGEND

errId = ['gmtlab:' mfilename ':badInput']; % common error ID
if isfield(in,'legend') && (~isstruct(in.legend) && ~in.legend)
    % If in.legend = false, do nothing
    return
end
if ~isfield(in,'legend') || ~isstruct(in.legend)
    in.legend=struct([]);
end

% apply defaults to legend
if ~isfield(in.legend,'position')
    % ORIENTATION
    
    x = sscanf(in.region,'%f/%f/%f/%f');
    f = 2*( x(4)-x(3))/ ( x(2)-x(1) ); %something between 0->1 equivalent to 180/360->120/360 lats/lons
    myHcondition = f < 0.5; tmp = ['v','h']; %vertical,horisontal

    if in.savelegend
        default.orientation = 'h'; % because usually you want this.
    else
        default.orientation = tmp(myHcondition+1);
    end
    defThick=.2; %thickness of legend bar
    
    % I use map_width to find the defaults.
    [mw,mwu] = separate_integer_and_unit(in.map_width);
    in.legend           = optargs_struct(in.legend,default); %need orientation now
    switch in.legend.orientation
        case 'v'
            vec = [10.11+(.5*defThick+0.44*ismember('E',in.basemap_axis)) ... % could use annot_font_size_primary for better precision
                2.44*f ...
                5.22*f ...
                defThick]/10;
            
        case 'h'
            
            vec = [5 ...
                -0.1-(0.5*defThick+0.4*ismember('S',in.basemap_axis))...
                10.55 ...
                defThick]/10;
            
        otherwise
            error(errId,'orientation should be "v" or "h", not "%s"',in.legend.orientation)
    end
    default.xpos   = sprintf('%.2f%s',vec(1)*mw,mwu);
    default.ypos   = sprintf('%.2f%s',vec(2)*mw,mwu);
    default.length = sprintf('%.2f%s',vec(3)*mw,mwu);
    default.width  = sprintf('%.2f%s',vec(4)*mw,mwu);
else
    default = regexp(in.legend.position,'(?<xpos>.+)/(?<ypos>.+)/(?<length>.+)/(?<width>.+)(?<orientation>\w{1})','names');
end
default.tick_annotion_format = in.tick_annotation_format;
default.sidebar     = getsidebar(in); % coloroured triangles using in.datarange
in.legend           = optargs_struct(in.legend,default);

end

function sidebar = getsidebar(in)
%% color level datastep interval
% sidebar can have the values 0,1,2,3 (none, bellow only, above only, both).

sidebar =  ( min(in.(in.fieldname)(:))<in.datarange(1) ) + ...
    2* ( max(in.(in.fieldname)(:))>in.datarange(2) );

end

function in = specialregion(in,field)

if in.gridded
    % DO some special treatment of data crossing the dateline that is not continuous
    % after changing to -180:180 regime OR if in.region is in 0:360 mode
    
    if any(diff(in.lon)==0)
        % in case a longitude appears twice. e.g., if the grid was originally
        % lon = 0:360
        cond = diff(in.lon)~=0;
        in.lon = in.lon(cond);
        in.(field) = in.(field)(:,cond);
    end
    if max(diff(in.lon))>5*min(diff(in.lon)) || ...
            structfun(@str2double,regexp(in.region,'.+/(?<lnmax>.+)/.+/.+','names')) > 180 % this is a 360 test
        
        in.lon = in.lon+(in.lon < 0)*360;
        [in.lon,lnindex] = sort(in.lon);
        in.(field) = in.(field)(:,lnindex);
        % if diff equal 0 somewhere then at best the data is repeated e.g.
        % at 0˚ and 360˚
        if any(diff(in.lon)==0)
            if isequal(in.(field)(:,find(diff(in.lon)==0)),in.(field)(:,find(diff(in.lon)==0)+1)) %#ok<FNDSB>
                % then remove duplicate line
                in.lon      = in.lon(diff(in.lon)~=0);
                in.(field)  = in.(field)(:,diff(in.lon)~=0);
            else
                error(['atmlab:' mfilename],'Same longitudes are repreated but the data are not the same there')
            end
        end
        % Do the region part again
        if ~isfield(in,'userDefinedRegion') || ~in.userDefinedRegion
            in = rmfield(in,'region');
            in = assign_region(in,field);
        end
    end
    
    
    assert(max(diff(in.lon))<5*min(diff(in.lon)),['atmlab:' mfilename, ':Error'],...
        'The longitudes are not continuous. FIXME: put workaround in place')
    
    if length(in.lat) == size(in.(field),1)+1 || length(in.lon) == size(in.(field),2)+1
        logtext(1,'Data does not appear to be centered. Internally ')
        in = centerGeoData(in,field);
    end
end

end

% ----------------
% Other subfunctions
%

function filename = sort_figures(in,command)
%% SORT FIGURES


%'eps','pdf','BMP','jpg','PNG','PPM','TIFF', ot 'tif'
switch lower(in.figuretype)
    case 'pdf'
        T = '-Tf';
    case 'bmp'
        T = '-Tb -Qg -Qt';
    case 'eps'
        T = '-Te';
    case 'jpg'
        T = '-Tj -Qg -Qt';
    case 'png'
        T = '-Tg -Qg -Qt'; %-Q is for no antialiaing 'g'raphics and 't'ext
    case 'tif'
        T = '-Tt -Qg -Qt';
    case 'ppm' % is not recommended
        T = '-Tm -Qg -Qt';
    otherwise
        error(['gmtlab:' mfilename ':FigureType'],...
            '%s: not supported',in.figuretype)
end
command{end+1} = sprintf('ps2raster %s.ps -A -P %s',in.filename,T);
command{end+1} = sprintf('mv %s.%s %s',in.filename,in.figuretype,in.outdir);

if in.savelegend
    % MAKE a separate file for the legend
    findPsScale = ~cellfun('isempty',regexp(command,'psscale'));
    if ~any(findPsScale)
        v = atmlab('VERBOSITY');
        atmlab('VERBOSITY',1);
        logtext(atmlab('ERR'),'psscale, which is used to make the legend was never called. Maybe legend=0 or there was no input data?\n')
        atmlab('VERBOSITY',v);
        filename = '';
        
        return
    end
    in.filename_legend = makelegendpdf(in.filename, command(findPsScale));
    if in.savelegend==2 % store legend ONLY in external file
        command = command(~findPsScale);
    end
    command{end+1} = sprintf('mv %s.%s %s',in.filename_legend,in.figuretype,in.outdir);
end

% Assemble open command
openwith = NaN;
if strcmp(in.figuretype,'pdf')
    openwith = gmtlab('PDFVIEWER');
elseif strcmp(in.figuretype,'eps')
    openwith = gmtlab('PSVIEWER');
end
if isnan(openwith)
    openwith = gmtlab('OPEN_COMMAND');
end
if in.display && ~any(isnan(openwith))
    command{end+1} = sprintf('%s %s/%s.%s >/dev/null &',...
        openwith,in.outdir,in.filename,in.figuretype);
end

out = exec_system_cmd(command,gmtlab('verbosity')); % execute all gathered commands

filename = sprintf('%s/%s.%s',in.outdir,in.filename,in.figuretype);

% If no viewer is defined, check for xpdf, then evince, then okular
if in.display && any(isnan(openwith)) && strcmp(in.figuretype,'pdf')
    disp('No pdfviewer defined.')
    disp('Set gmtlab(''PDFVIEWER'',''<e.g. xpdf>'') in your startup file')
    if ~system('which xpdf')
        openwith = 'xpdf';
    elseif ~system('which evince')
        openwith = 'evince'; % for gnome users
    elseif ~system('which okular')
        openwith  = 'okular'; % for kde users
    end
    if ~any(isnan(openwith))
        logtext(1,'Opening file with %s for now\n',openwith)
        system(sprintf('%s %s &',openwith,filename));
    end
end

hunt_down_errors(command,out) % look for system call errors in the gmt calls

logtext(atmlab('OUT'), 'GMT plot stored at:  %s\n',filename)

end

function file = makelegendpdf(basename, command)
%% Make a separate pdf for the legend
% Only allowed to have 1 or 2 psscale commands in the commad list. the first one
% is the regular legend. The second is for the nan legend (if it exists)

file = [basename '_legend'];

%make sure it's not here
exec_system_cmd(sprintf('rm -f %s.ps',file),gmtlab('verbosity'));

% Make the page large enough to fit most legends
cmd = {'gmtset PAPER_MEDIA a0'};
command = [cmd, command{1}];

%Remove trailing .ps entry
crop=regexp(command,'>>');

% Additional adjustments
for i = 2:length(command)
    command{i} = sprintf('%s -P >> %s.ps', command{i}(1:crop{i}-1), file );
    if i == 2
        command{i} = regexprep(command{i},'-O','');
    end
    if i == length(command)
        command{i} = regexprep(command{i},'-K','');
    end
end

% This forces it to be a pdf
command{end+1} = sprintf('ps2raster %s.ps -A -P -Tf',file);
exec_system_cmd(command,gmtlab('verbosity'));

end

function hunt_down_errors(command,errors)
%% Hunt down any errors encounted using GMT

% messages containing any of these are exempted
error_exeptions = {'warning','not set'};
definite_errors = {'illegal','error'};

% this gives cell{1:nerrors}{1:nerr_exp}
found_err_exp = cellfun(@(x)(regexp(x,error_exeptions,'ignorecase','once')),errors,'uniformoutput',0);
found_def_err = cellfun(@(x)(regexp(x,definite_errors,'ignorecase','once')),errors,'uniformoutput',0);

windex = cellfun(@(x)(any(cell2mat(x))),found_err_exp);
eindex = cellfun(@(x)(any(cell2mat(x))),found_def_err);

Warnings             = errors(windex);
associated_w_warning = command(windex);
Errors               = errors(eindex);
associated_w_errors  = command(eindex);

% display GMT calls containing warning
if ~isempty(Warnings)
    V = atmlab('VERBOSITY'); atmlab('VERBOSITY',1);
    logtext(atmlab('OUT'),'GMT completed with the following warning messages:\n')
    tmp = cellfun(@(x,y)(sprintf('%s\n%s\n',x,y(1:end-1))),associated_w_warning,Warnings,'UniformOutput',0);
    logtext(atmlab('OUT'),'%s\n',[tmp{:}])
    atmlab('VERBOSITY',V);
end

% error on GMT errors
if ~isempty(Errors)
    tmp = cellfun(@(x,y)(sprintf('%s\n%s\n',x,y(1:end-1))),associated_w_errors,Errors,'UniformOutput',0);
    error(['gmtlab:' mfilename ':GMT'],...
        'GMT encountered the following errors:\n%s',[tmp{:}])
end

end

function gmtcleanup(tmpdir,curdir,keepfiles,V)
%% cleanUp

if keepfiles
    logtext(1,'in.keep_files = true;\nTemporary files are stored at %s.\n',pwd)
    logtext(2,'Remember to delete the directory when you are done\n')
else
    % cd back to the original directory
    cd(curdir);
    rmdir(tmpdir,'s')
    logtext(1,'%s is now removed\n',tmpdir)
    atmlab('VERBOSITY',V);
end

end
