% SCALE_AXES   Changes the size of a axes frame.
%
%    The function allows to change the size of a axes frame by giving
%    a scaling factor for the horisontal and vertical directions. 
%
%    A scaling factor of 1.2 means that the frame will be 20% larger in the
%    direction of concern. For example, if *h* is a handle to a legend
%    that you want to make broader, execure:
%       scale_axes( h, 1.2 );
%
%    Vertical scaling of legends can result in that plotting symbols and text
%    are not aligned.
%
%    The centre point of the axes will be not be moved.
%
% FORMAT   scale_axes(h,hscfac[,vscfac])
%        
% IN    h        Handle to the legend.
%       hscfac   Horisontal scaling factor.
% OPT   vscfac   Vertical scaling factor. Default is 1.

% 2002-12-12   Created by Patrick Eriksson.


function scale_axes(h,hscfac,vscfac)


%=== Check input and defaults
%
rqre_nargin( 2, nargin );
%
if ~isscalar( hscfac )  |  hscfac <= 0
  error('The horisonal scaling factor must be a scalar >= 0.');
end
%
if nargin < 3
  vscfac = 1;
else
  if ~isscalar( vscfac )  |  vscfac <= 0
    error('The vertical scaling factor must be a scalar >= 0.');
  end
end


pos = get( h, 'position' );


dx = (hscfac-1) * pos(3);
dy = (vscfac-1) * pos(4);

set( h, 'position', [pos(1)-dx/2 pos(2)-dy/2 pos(3)+dx pos(4)+dy] );