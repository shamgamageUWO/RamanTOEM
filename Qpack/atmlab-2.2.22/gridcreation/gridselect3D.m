% GRIDSELECT3D   Simple selection of 3D grids
%
%    The function needs a set of realisations of the quantity for which the
%    grids shall be selected. These realisations are given along dim. 4 of the
%    4D variable *Af*, are provided on a sufficient fine grid that 
%    representation errors can be neglected and shall span the possible cases 
%    that shall be represented. 
%
%    The dimension of Af shall be [ xf, yf, zf, number of realisation ]
%
%    The grid is selected by first including the end points of *xf/yf/zf*. 
%    The coarse representation is transformed to the fine one, and a new grid 
%    point is included where the maximum deviation is found (where all
%    realisations are considered in parallel). The point is included in
%    either *xc*, *yc* or *zc*, depending on which that most effectively 
%    reduces the deviation. This procedure is repeated until the coarse and 
%    representations deviates less then *tol*.
%
%    See also GRIDSELECT1D and GRIDSELECT2D.
%
% FORMAT   [xc,yc,zc,Ac] = gridselect3D( xf, yf, zf, Af, tol, repr, abs_or_rel)
%        
% OUT   xc          Obtained coarse grid for x dimension.
%       yc          Obtained coarse grid for y dimension.
%       zc          Obtained coarse grid for z dimension.
%       Ac          Af at grid points xc, yc and zc.
% IN    xf          Reference fine grid for x dimension.
%       yf          Reference fine grid for y dimension.
%       zf          Reference fine grid for y dimension.
%       Af          Reference data (a matrix) on fine grid.
%       tol         Acceptable tolarance.
%       repr        String describing representation used. Possible choices
%                   are equal to allowed 'methods' for *interp1*.
% OPT   abs_or_rel  String telling if tolarance is in absolute ('abs') or
%                   relative ('rel') units. Default is 'abs'.

% 2004-09-23   Created by Patrick Eriksson.


function [xc,yc,zc,Ac] = gridselect3D( xf, yf, zf, Af, tol, repr, abs_or_rel )

if nargin < 7
  abs_or_rel = 'abs';
end


nx = length( xf );
ny = length( yf );
nz = length( zf );


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
if ~isvector( yf )
  error( 'Input argument *zf* must be a vector.' );
end
%
if ~( ndims( Af ) == 3  |  ndims( Af ) == 4 )  |  ~isnumeric( Af )
  error( 'Input argument *Af* must be a 4D matrix.' );
end
%
if size( Af, 1 ) ~= nx  &&  size( Af, 2 ) ~= ny  &&  size( Af, 3 ) ~= nz
  error( 'Sizes of *xf*/*yf* and *Af* do not match.' );
end
%
if strcmp( abs_or_rel, 'rel' )  &  any( Af == 0 )
   error( 'With *abs_or_rel* = ''rel'', *Af can not contain zeros.' );
end

xind = [1 nx];
yind = [1 ny];
zind = [1 nz];

xf = vec2row( xf );
yf = vec2row( yf );
zf = vec2row( zf );

Ac   = zeros( size( Af ) );

Ac = do_interp( xf(xind), yf(yind), zf(zind), Af(xind,yind,zind,:), ...
                                                            xf, yf, zf, repr );
[e,xip,yip,zip] = get_max_dev( Af, Ac, abs_or_rel );

while e > tol

  %= Test to put in xip
  if ~any( xip == xind )
    xindtmp = sort( [ xind xip ] );
    Ac = do_interp( xf(xindtmp), yf(yind), zf(zind), ...
                                   Af(xindtmp,yind,zind,:), xf, yf, zf, repr );
    [e1,xip1,yip1,zip1] = get_max_dev( Af, Ac, abs_or_rel );
  else
    e1 = Inf;
  end

  %= Test to put in yip
  if ~any( yip == yind )
    yindtmp = sort( [ yind yip ] );
    Ac = do_interp( xf(xind), yf(yindtmp), zf(zind), ...
                                   Af(xind,yindtmp,zind,:), xf, yf, zf, repr );
    [e2,xip2,yip2,zip2] = get_max_dev( Af, Ac, abs_or_rel );
  else
    e2 = Inf;
  end

  %= Test to put in zip
  if ~any( zip == zind )
    zindtmp = sort( [ zind zip ] );
    Ac = do_interp( xf(xind), yf(yind), zf(zindtmp), ...
                                   Af(xind,yind,zindtmp,:), xf, yf, zf, repr );
    [e3,xip3,yip3,zip3] = get_max_dev( Af, Ac, abs_or_rel );
  else
    e3 = Inf;
  end
  
  if e1 <= e2  &  e1 <= e3
    xind = xindtmp;
    xip  = xip1;
    yip  = yip1;
    zip  = zip1;
    e    = e1;
  elseif e2 <= e3
    yind = yindtmp;
    xip  = xip2;
    yip  = yip2;
    zip  = zip2;
    e    = e2;
  else
    zind = zindtmp;
    xip  = xip3;
    yip  = yip3;
    zip  = zip3;
    e    = e3;
  end
end

xc = xf(xind);
yc = yf(yind);
zc = zf(zind);

if nargout > 3
  Ac = Af(xind,yind,zind,:);
end


return


function Ac = do_interp( xc, yc, zc, A, xf, yf, zf, repr )
  %
  for i = 1 : size(A,4)
    Ac(:,:,:,i) = interp3( yc, xc, zc, A(:,:,:,i), yf, xf, zf', repr );
  end
  %
return


function [e,xip,yip,zip] = get_max_dev( Af, Ac, abs_or_rel );
  %
  if strcmp( abs_or_rel, 'abs' )
    [e,xip] = max( max( max( max( abs( Ac - Af ), [], 4 ), [], 3 ), [], 2 ) );
    [e,yip] = max( max( max( max( abs( Ac - Af ), [], 4 ), [], 3 ), [], 1 ) );
    [e,zip] = max( max( max( max( abs( Ac - Af ), [], 4 ), [], 2 ), [], 1 ) );
  elseif strcmp( abs_or_rel, 'rel' )
    [e,xip] = max( max( max( max( abs( (Ac - Af)./Af ), [], 4 ), [], 3 ), [], 2 ) );
    [e,yip] = max( max( max( max( abs( (Ac - Af)./Af ), [], 4 ), [], 3 ), [], 1 ) );
    [e,zip] = max( max( max( max( abs( (Ac - Af)./Af ), [], 4 ), [], 2 ), [], 1 ) );
  else
    error( ...
      sprintf('Unknown error type (%s). Can only be ''abs'' or ''rel''.', ...
                                                                abs_or_rel ) );
  end
  %
return