% ADD_PLOT_ROW   Adds a row of plots to a figure.
%
%    This function works in a similar way as *subplot*, but this function
%    can be called repeatedly, and each row of plots can have a different
%    number of plots.
%
%    The size allocated for the plots is specified by giving lengths with
%    respect to the vertical size of the figure area. This is valid both
%    for widths and height. This means that if the width and height are set
%    to the same value, the plot will be square. All plots have the same height
%    but the width can differ. Note that the size given does not include the
%    space used for axis numbering and label text, it includes only the actual
%    plot area. This means that if there shall be any space left for y-labels
%    the plot widths cannot add up to 1.
%
%    The plots can either be flushed to the right (flush='r'), flushed to
%    the left (flush='l'), or be centered (flush='c'). For left and right
%    flushing, 10% of the figure width at the end of the flushing. 
%    The horisontal position of the plots can be fine tuned by the optional
%    arguments *hspacefac* and *hshift*.
%
%    For normal plotting with the y-axis to the left, right flushing should
%    be the standard choice, and it is also default.
%
%    Some examples:
%       h1 = add_plot_row(0.3,[0.25 0.4 0.25]);
%       h2 = add_plot_row(0.3,1.1);
%    Make sure that the figure window has sufficient height for both plot rows
%    before trying this example. The width must be increased before creating
%    the first rows the widths set are normalised to the size, and the size of
%    the plots will change if the size of the figure is changed.
%
% FORMAT   h = add_plot_row(height,widths,vspacing,hspacing,flush,hshift)
%        
% OUT   h          Handles to the created plots (axes).
% IN    height     Height of plots. This length is given in fractions of the 
%                  vertical size. 
%       widths     Widths of each plot as a vector. This lengths are given in
%                  fractions of the vertical size. 
% OPT   vspacing   Vertical spacing to plots above, or to the top of figure
%                  area. This length is given in fractions of the vertical
%                  size. Default is 0.1.
%       hspacing   Horisontal spacing of plots in row,. This length is given 
%                  in fractions of the vertical size. Default is 0.1.
%       flush      Flushing of plots. See further above. Default is 'r'.
%       hshift     Horisontal shift of plots. Same unit as above. Default is 0.

% 2002-12-11   Created by Patrick Eriksson.


function h = add_plot_row(height,widths,varargin)
%
[vspacing,hspacing,flush,hshift] = optargs( varargin, { 0.1, 0.1, 'r', 0 } );

  
%=== Basic check of input
%
if ~isscalar( height )
  error(' The argument *height* must be a scalar.');
end
%
if ~isvector( widths )
  error(' The argument *width* must be a vector.');
end
%
if ~isscalar( vspacing )
  error(' The argument *vspacing* must be a scalar.');
end
%
if  ~isscalar( hspacing )
  error( 'The argument *hspacing* must be a scalar.');
end
%
if  ~( strcmp(flush,'l') | strcmp(flush,'c') | strcmp(flush,'r') )
  error('The argument *flush* must be ''l'', ''c'' or ''r''.');
end 
%
if ~isscalar( hshift )
  error(' The argument *hshift* must be a scalar.');
end



%=== Handle to figure
%
hf = gcf;


%=== Convert horisontal sizes.
%
%- The case of unit='norm' forces the conversion to be done in a more tricky
%- way, than required for other units.
%
%- Save unit and change to cm
unit1 = get( hf, 'unit' );
set( hf, 'unit', 'ce' );
%
pos      = get( hf, 'Position' );
widths   = widths * pos(4) / pos(3);
hspacing = hspacing * pos(4) / pos(3);
hshift   = hshift * pos(4) / pos(3);
%
%- Reset unit
set( hf, 'unit', unit1 );




%=== Check at what height the plot row shall be placed
%
%- Handle to childrens of the figure
hc = get( hf, 'Children' );
%
if isempty( hc )
  vbase = 1;
else
  %- Loop children and look at what height they start
  vbase = pos(2) + pos(4);
  for ic = 1 : length(hc)
    cpos = get( hc(ic), 'position' );
    if cpos(2) < vbase
      vbase = cpos(2);
    end 
  end
end
%
vbase = vbase - vspacing - height;
%
if vbase < 0
  error('The given height is larger than free vertical space.');
end




%=== Place the axes
%
nplots = length( widths );
%
if flush == 'l'
  hbase = 0.1;
elseif flush == 'c'
  hbase = 0.5 - (sum(widths) + hspacing*(nplots-1))/2;
else
  hbase = 0.9 - (sum(widths) + hspacing*(nplots-1));
end
%
hbase = hbase + hshift;


h     = zeros( nplots, 1 );
%
for ip = 1 : nplots
  h(ip) = axes( 'position', [hbase vbase widths(ip) height] );
  hbase = hbase + widths(ip) + hspacing;
end
