% COLORSET   Gives a datalevel the specified color
%
%    The range around value *x* is given the color *c*. The size of the
%    range depends on the color axis scaling and the number of levels in the
%    color map. The colored range follows the way Matlab sets the colers,
%    and the range is most likely not centred around *x*. If *x* is exactly
%    at the limit between two color ranges, both ranges are set to *c*.
%
% FORMAT   colorset(x[,c])
%        
% IN    x   Data level to mark.
% OPT   c   Color. Default is white ([1 1 1]).

% 2007-03-12   Created by Patrick Eriksson.


function colorset(x,c)
  
if nargin < 2
  c = [1 1 1];
end


[cranges,cmap] = colorspec;

ind = find( x>=cranges(:,1)  &  x<=cranges(:,2) );

for i = 1:length(ind)

  cmap(ind(i),:) = c;
  
end

colormap( cmap );