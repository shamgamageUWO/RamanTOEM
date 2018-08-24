% SET_FIGSIZE   Sets the figure to a specified size.
%
%    The size is applied to both screen and paper version. The size refers
%    to the complete size (not the size of the axes area).
%
% FORMAT   set_figsize(width,height)
%        
% IN    width   Width of figure in mm.
%       height  Height of figure in mm.

% 2006-04-06   Created by Patrick Eriksson.


function set_figsize(width,height)


%=== Basic check of input
%
rqre_nargin( 2, nargin );


%=== Store present units
%
h = gcf;
%
unit1 = get( h, 'Unit' );
unit2 = get( h, 'PaperUnit' );


%=== Set unit cm
%
set( h, 'Unit', 'ce' );
set( h, 'PaperUnit', 'ce' );


%=== Scale set lengths
%
width   = width / 10;
height  = height / 10;


%= Get current positions
%
pos1 = get( h, 'Position' );
pos2 = get( h, 'PaperPosition' );


%=== Set positions
%
set( h, 'Position', ...
        [pos1(1)+pos1(3)/2-width/2 pos1(2)+pos1(4)/2-height/2 width height] );
set( h, 'PaperPosition', ...
        [pos2(1)+pos2(3)/2-width/2 pos2(2)+pos2(4)/2-height/2 width height] );


%=== Re-set units
set( h, 'Unit', unit1 );
set( h, 'PaperUnit', unit2 );
