% SCALE_FIG   Resizes a figure and the text size.
%
%    The function changes the size of the current figure with the given 
%    scaling factor.
%
%    The same scaling is applied vertically and horisontally. The scaling
%    is further applied on all text objects. 
%
%    The idea is that a figure could be given any size maintaining the same
%    relative appearence. This works for re-scaling with factors not deviating
%    too much from 1, but as the space between e.g. axes and labels is not
%    scaled in the same way by Matlab (which is done automatically), larger
%    size changes distorts the appearence of the figure. For example, if a 
%    larger figure is made small it is a risk that axes labels will be moved
%    outside the figure, despite that the font size is made small.
%
% FORMAT   scale_fig(scfac)
%        
% IN    scfac   Scaling factor (1 results in no effective scaling).


% 2002-12-12   Created by Patrick Eriksson.


function scale_fig(scfac)


%=== Check input
%
rqre_nargin( 1, nargin );
%
if ~isscalar( scfac )  |  scfac <= 0
  error('The scaling factor must be a scalar >= 0.');
end


%=== Get figure position
%
h = gcf;
%
pos = get( h, 'Position' );


%=== Re-size without moving centre point
%
dx = ( scfac - 1 ) * pos(3);
dy = ( scfac - 1 ) * pos(4);
%
set( h, 'Position', [pos(1)-dx/2 pos(2)-dy/2 pos(3)+dx pos(4)+dy] );


%=== Scale text
%
scale_text( h, scfac );