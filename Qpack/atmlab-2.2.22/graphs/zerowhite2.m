% ZEROWHITE2   Creates a colormap with white for 0
%
%    This function creates a color map that gives white for values around
%    zero. An alternative version is found in *zerowhite*. This version is
%    easier to use with Matlab's *colorbar*. Example on usage:
%       pcolor(rand(10,20));
%       caxis([-1 1]),zerowhite2(0.1,'pnz',0.4,0.5),colorbar
%
%    Each color is set to correspond to a data range of *dx*. The white
%    color covers always the range [-dx/2,dx/2[, even though data are either
%    strictly positive or negative. As many ranges as possible are created
%    without going outside range given by *caxis*.
%
%    The function sets both *caxis* and *colormap*. As the number of color
%    ranges is based on settings in *caxis*, the plot can change if the
%    function is called twice with exactly same settings, if not *caxis* is
%    re-set in between.
%
% FORMAT   zerowhite2(dx[,rgb,pbl,nbl])
%        
% IN    dx       Step in data corresponding to each color.
% OPT   rgb      Coding for red, green and blue color by a string of length 3.
%                The character 'p' means that positive values will be weighted
%                with the corresponding color. The character 'n' refer to
%                negative values. The character 'z' means max weight at zero.
%                Default is 'nzp'.
%       pbl      Level of blackness on positive side. A value between 0 and
%                1, where 0 means that no black is blended in for high
%                values, and 1 means that max positive value will be 
%                completely black. Default is 0.5.
%       nbl      Level of blackness on negative side. As *pbl* but for
%                negative values.
%
% See also: zerowhite, zerobright

% 2007-03-12   Created by Patrick Eriksson.


function zerowhite2(dx,varargin)
%
[rgb,pbl,nbl] = optargs( varargin, { 'nzp', 0.5, 0.5 } );

  
if dx <= 0
  error( 'Argument *dx* must be positive.' );
end



ca = caxis;
%
if ca(1) > 0  |  ca(2) < 0
  error( 'Zero is not inside present color range.' );
end


%- Centre point for color interval and corresponding color axis
%
x = unique( [ 0:-dx:ca(1)+dx/2 0:dx:ca(2)-dx/2 ] );
%
ca = [ x(1)-dx/2 x(end)+dx/2];



%- Color distance
%
d = x';
%
ind = find( x > 0 );
d(ind) = (1+pbl) * x(ind)/ca(2);
%
ind = find( x < 0 );
d(ind) = (1+nbl) * x(ind)/abs(ca(1));



%--- Create color map

%- Set colors first strictly from color distance
%
cmap = ones( length(x), 3 );
%
for i = 1:3

  if rgb(i) == 'p'
    cmap(:,i) = 1 + d;
  elseif rgb(i) == 'n'
    cmap(:,i) = 1 - d;
  elseif rgb(i) == 'z'
    cmap(:,i) = 1 - abs(d);
  else
    error( 'Unknown selection in *rgb*.' );
  end
  
end

%- Cut all values above 1
%
cmap( find(cmap>1) ) = 1;


%- Use negative values to determine blending towards black
%
for i = 1 : size(cmap,1)
  
  minv = min( cmap(i,:) );
  
  if minv < 0
    cmap(i,:) = cmap(i,:) + minv;
  end
end
%
cmap( find(cmap<0) ) = 0;



%--- Set  colors
%
caxis( ca );
colormap( cmap );

  
  
