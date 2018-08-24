% GRID_WEIGHTSPACED   Creates a grid based on some response weights 
%
%    This function sets up a grid where the spacing is follows some weight.
%    The basic idea is that the grid shall be more dense where the response
%    is high. 
%
%    The end points of *g* equal the end points of *x*. The other points are
%    determined by dividing the cumulative integral of *y* in equal steps. 
%
%    This approach makes sense if *y* is some response function and the
%    representation error where *g* will be used increases linearly with
%    grid spacing.
%
% FORMAT   g = grid_weightspaced(x,y,n)
%        
% OUT   g        Created grid.
% IN    x        Grid for *y*.
%       y        Vector of weights.
%       n        Number of points in *g*.

% 2010-09-22   Created by Patrick Eriksson.

function g = grid_weightspaced(x,y,n)
%
if atmlab( 'STRICT_ASSERT' )
  rqre_datatype( x, @istensor1 );
  rqre_datatype( y, @istensor1 );
  rqre_datatype( n, @istensor0 );
end

cs = cumtrapz( x, abs(y) );

g = interp1( cs, x, linspace( cs(1), cs(end), n ) );