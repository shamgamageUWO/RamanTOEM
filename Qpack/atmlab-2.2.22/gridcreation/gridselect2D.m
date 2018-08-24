% GRIDSELECT2D   Simple selection of 2D grids
%
%    The function needs a set of realisations of the quantity for which the
%    grids shall be selected. These realisations are given along dim. 3 of the
%    3D variable *Af*, are provided on a sufficient fine grid that 
%    representation errors can be neglected and shall span the possible cases 
%    that shall be represented. 
%
%    The dimension of Af shall be [ xf, yf, number of realisation ]
%
%    The grid is selected by first including the end points of *xf* and *yf*. 
%    The coarse representation is transformed to the fine one, and a new grid 
%    point is included where the maximum deviation is found (where all
%    realisations are considered in parallel). The point is included in
%    either *xc* or *yc*, depending on which that most effectively reduces
%    the deviation. This procedure is repeated until the coarse and 
%    representations deviates less then *tol*.
%
%    See also GRIDSELECT1D and GRIDSELECT3D.
%
% FORMAT   [xc,yc,Ac] = gridselect2D( xf, yf, Af, tol, repr, abs_or_rel )
%        
% OUT   xc          Obtained coarse grid for x dimension.
%       yc          Obtained coarse grid for y dimension.
%       Ac          Af at grid points xc and yc.
% IN    xf          Reference fine grid for x dimension.
%       yf          Reference fine grid for y dimension.
%       Af          Reference data (a matrix) on fine grid.
%       tol         Acceptable tolarance.
%       repr        String describing representation used. Possible choices
%                   are equal to allowed 'methods' for *interp1*.
% OPT   abs_or_rel  String telling if tolarance is in absolute ('abs') or
%                   relative ('rel') units. Default is 'abs'.

% 2004-09-23   Created by Patrick Eriksson.


function [xc,yc,Ac] = gridselect2D( xf, yf, Af, tol, repr, abs_or_rel )

if nargin < 6
  abs_or_rel = 'abs';
end

nx = length( xf );
ny = length( yf );


%=== Check input
%
if ~isvector( xf )
  error( 'Input argument *xf* must be a vector.' );
end
%
if ~isvector( yf )
  error( 'Input argument *yf* must be a vector.' );
end
%
if ~( ndims( Af ) == 2  |  ndims( Af ) == 3 )  |  ~isnumeric( Af )
  error( 'Input argument *Af* must be a 3D matrix.' );
end
%
if size( Af, 1 ) ~= nx  &&  size( Af, 2 ) ~= ny
  error( 'Sizes of *xf*/*yf* and *Af* do not match.' );
end
%
if strcmp( abs_or_rel, 'rel' )  &  any( Af == 0 )
   error( 'With *abs_or_rel* = ''rel'', *Af can not contain zeros.' );
end

xind = [1 nx];
yind = [1 ny];

xf = vec2row( xf );
yf = vec2row( yf );

Ac   = zeros( size( Af ) );

Ac = do_interp( xf(xind), yf(yind), Af(xind,yind,:), xf, yf, repr );
[e,xip,yip] = get_max_dev( Af, Ac, abs_or_rel );

while e > tol

  %= Test to put in xip
  if ~any( xip == xind )
    xindtmp = sort( [ xind xip ] );
    Ac = do_interp( xf(xindtmp), yf(yind), Af(xindtmp,yind,:), xf, yf, repr );
    [e1,xip1,yip1] = get_max_dev( Af, Ac, abs_or_rel );
  else
    e1 = Inf;
  end

  %= Test to put in yip
  if ~any( yip == yind )
    yindtmp = sort( [ yind yip ] );
    Ac = do_interp( xf(xind), yf(yindtmp), Af(xind,yindtmp,:), xf, yf, repr );
    [e2,xip2,yip2] = get_max_dev( Af, Ac, abs_or_rel );
  else
    e2 = Inf;
  end
  
  if e1 <= e2
    xind = xindtmp;
    xip  = xip1;
    yip  = yip1;
    e    = e1;
  else
    yind = yindtmp;
    xip  = xip2;
    yip  = yip2;
    e    = e2;
  end
end

xc = xf(xind);
yc = yf(yind);

if nargout > 2
  Ac = Af(xind,yind,:);
end


return


function Ac = do_interp( xc, yc, A, xf, yf, repr )
  %
  for i = 1 : size(A,3)
    Ac(:,:,i) = interp2( yc, xc, A(:,:,i), yf, xf', repr );
  end
  %
return


function [e,xip,yip] = get_max_dev( Af, Ac, abs_or_rel );
  %
  if strcmp( abs_or_rel, 'abs' )
    [e,xip] = max( max( max( abs( Ac - Af ), [], 3 ), [], 2 ) );
    [e,yip] = max( max( max( abs( Ac - Af ), [], 3 ), [], 1 ) );
  elseif strcmp( abs_or_rel, 'rel' )
    [e,xip] = max( max( max( abs( (Ac - Af)./Af ), [], 3 ), [], 2 ) );
    [e,yip] = max( max( max( abs( (Ac - Af)./Af ), [], 3 ), [], 1 ) );
  else
    error( ...
      sprintf('Unknown error type (%s). Can only be ''abs'' or ''rel''.', ...
                                                                abs_or_rel ) );
  end
  %
return