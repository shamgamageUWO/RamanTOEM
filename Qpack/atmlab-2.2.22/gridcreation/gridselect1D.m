% GRIDSELECT1D   Simple selection of a 1D grid
%
%    The function needs a set of realisations of the quantity for which the
%    grid shall be selected. These realisations are given as columns of the
%    matrix *Af*, are provided on a sufficient fine grid that representation
%    errors can be neglected and shall span the possible cases that shall be
%    represented. 
%
%    The dimension of Af shall be [ xf, number of realisation ]
%
%    The grid is selected by first including the end points of *xf*. The 
%    coarse representation is transformed to the fine one, and a new grid 
%    point is included where the maximum deviation is found (where all
%    realisations are considered in parallel). This procedure is repeated
%    until the coarse and representations deviates less then *tol* (at all
%    points of *xf*).
%
%    See also GRIDSELECT2D and GRIDSELECT3D.
%
% FORMAT   xc = gridselect1D( xf, Af, tol, repr, abs_or_rel )
%        
% OUT   xc          Obtained coarse grid.
%       Ac          Af at grid points xc.
% IN    xf          Reference fine grid.
%       Af          Reference data (a matrix) on fine grid.
%       tol         Acceptable tolarance.
%       repr        String describing representation used. Possible choices
%                   are equal to allowed 'methods' for *interp1*.
% OPT   abs_or_rel  String telling if tolarance is in absolute ('abs') or
%                   relative ('rel') units. Default is 'abs'.

% 2004-09-18   Created by Patrick Eriksson.


function [xc,Ac] = gridselect1D( xf, Af, tol, repr, abs_or_rel )

if nargin < 5
  abs_or_rel = 'abs';
end

n = length( xf );


%=== Check input
%
if ~isvector( xf )
  error( 'Input argument *xf* must be a vector.' );
end
%
if ndims( Af ) ~= 2  |  ~isnumeric( Af )
  error( 'Input argument *Af* must be a matrix.' );
end
%
if size( Af, 1 ) ~= n
  error( 'Sizes of *xf* and *Af* do not match.' );
end
%
if strcmp( abs_or_rel, 'rel' )  &  any( Af == 0 )
   error( 'With *abs_or_rel* = ''rel'', *Af can not contain zeros.' );
end

xf = vec2row( xf );

ind = 1;
ip  = n;
e   = tol*2;


while e > tol

  ind = sort( [ ind ip ] );

  Ac = interp1( xf(ind), Af(ind,:), xf, repr );

  if strcmp( abs_or_rel, 'abs' )
    [e,ip] = max( max( abs( Ac - Af ), [], 2 ) );
  elseif strcmp( abs_or_rel, 'rel' )
    [e,ip] = max( max( abs( (Ac - Af)./Af ), [], 2 ) );
  else
    error( ...
      sprintf('Unknown error type (%s). Can only be ''abs'' or ''rel''.', ...
                                                                abs_or_rel ) );
  end
end


xc = xf(ind);

if nargout > 1
  Ac = Af(xind,:);
end


return

%= Some code for plotting
%

E = Ac - Af;

plot( xf, mean( E, 2 ), 'r-', xf, max( E, [], 2 ), 'b--', ...
      xf, min( E, [], 2 ), 'g--' );
ylabel( 'Absolute deviation' )
legend( 'Mean deviation', 'Highest deviation', 'Lowest deviation' );