%------------------------------------------------------------------------
% NAME:    interp360
%
%    Interpolation of data where y and y+360 are identical points. A typical
%    application is interpolation of longitudes.
%    
%    Before the interpolation, the data points are shifted with n*360 in order
%    to avoid jumps from 0 to 360 (or reversed). These jumps are identified
%    by looking for abs(y(i+1)-y(i))>180. A caveat of the function is then
%    that the input data must be suffiently dense that steps > 180 only
%    occur when going between 0 and 360.
%
%    An example (note that cubic interpolation works despite the step
%    structure of y):
%      x=0:1000; y=rem(x,360); xi=0.5:900;
%      yi=interp1cyclic(x,y,xi,'cubic');
%      plot(x,y,xi,yi,'.')
%
% FORMAT:  As for interp1, beside that y is only allowed to be a vector.
%------------------------------------------------------------------------

% HISTORY: 20111-08-09  Created by Patrick Eriksson.


function yi = interp360(x,y,xi,varargin)

rqre_datatype( y, @isvector );

ind = find( abs( diff( y ) ) > 180 );
while ~isempty(ind)
  i = ind(1);
  if y(i+1) > y(i)
    y(i+1:end) = y(i+1:end) - 360; 
  else
    y(i+1:end) = y(i+1:end) + 360; 
  end
  ind = find( abs( diff( y ) ) > 180 );
end
  

yi = interp1( x, y, xi, varargin{:} );


% Make sure all data are inside [0 and 360]
n  = round( (yi-180)/360 );
yi = yi - 360*n;

