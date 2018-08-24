% FIT_TO_PAPER   Resizes a figure to fill the paper.
%
%    The function sets the size of the current figure to match the size of
%    the given paper format, considering the specified borders. The figure
%    is centered on the paper.
%
%    For landscape papers, the figure is prepared for printing by the call:
%       orient('landscape');
%
% FORMAT   fit_to_paper(psize[,hborder,vborder])
%        
% IN    psize     The paper size as a string. Valid options are:
%                    a4 or a4p
%                    a4l
%                    a5 or a5p
%                    a5l
%                 where p and l stand for portrait and landscape, respectively.
% OPT   hborder   Horisontal border. Unit is [mm]. This border width is 
%                 applied on both sides of the figure. Default is 15 mm.
%       vborder   Vertical border. Unit is [mm]. This border height is 
%                 applied both above and below the figure. Default is 25 mm.

% 2002-12-11   Created by Patrick Eriksson.


function fit_to_paper(psize,vborder,hborder)


%=== Basic check of input
%
rqre_nargin( 1, nargin );


%=== Default values
%
if nargin < 2
  vborder = 25;   % mm
end
if nargin < 3
  hborder = 15;   % mm
end


%=== Get paper size (in mm)
%
do_orient = 0;   % True for landscape 
%
if strcmp( psize, 'a4' )  |  strcmp( psize, 'a4p' )
  width  = 210;
  height = 297;

elseif strcmp( psize, 'a4l' )
  width     = 297;
  height    = 210;
  do_orient = 1;

elseif strcmp( psize, 'a5' )  |  strcmp( psize, 'a5p' )
  width  = 148;
  height = 210;

elseif strcmp( psize, 'a5l' )
  width     = 210;
  height    = 148;
  do_orient = 1;

else
  error( sprintf( 'Invalid paper type (%s).', psize ) );
end


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
hborder = hborder / 10;
vborder = vborder / 10;


%=== Set positions
%
set( h, 'Position', [hborder vborder width-2*hborder height-2*vborder] );
set( h, 'PaperPosition', [hborder vborder width-2*hborder height-2*vborder] );


%=== Re-set units
set( h, 'Unit', unit1 );
set( h, 'PaperUnit', unit2 );


%=== Landscape?
if do_orient
  orient('landscape');
end