% RQRE_GRIDMATCH   Checks that length of grid matches data
%
%    Grid lengths of both 0 and 1 are accpeted for singleton dimensions.
%
%    Issues an error if criterion not fulfilled.
%
%    The function can also be used to check if grid stricltly ascending or
%    descending.
%
% FORMAT   rqre_gridmatch( A, dim, g, [, demand_sorted,reversed] ) 
%        
% IN    A     Gridded data.
%       dim   Dimension for *g*.
%       g     Grid.
% OPT   demand_sorted   Flag to demand that grid is sorted, without 
%                       any points duplicated.
%       reversed        Flag to indicate that grid is supposed to descending
%                       (instead of ascending).

% 2010-01-04   Created by Patrick Eriksson.

function rqre_gridmatch( A, dim, g, varargin )
%
[demand_sorted,reversed] = optargs( varargin, {false,false} );

assert( iswhole( dim ) );                                                   %&%
assert( istensor1( g ) );                                                   %&%
assert( isboolean( demand_sorted ) );                                       %&%
assert( isboolean( reversed ) );                                            %&%
                                                                            
l = size(A,dim);

if (l>1 & length(g)~=l) | (l<2 & length(g)>1) 
  error( 'Length of grid does not match size of *%s* for dimension %d.', ...
                                                        inputname(1), dim );
end


if demand_sorted
  if reversed
    g = g(end:-1:1);
    if min( diff(g) <= 0 ) 
      error( 'The grid must be sorted in descending order.' );
    end
  else
    if min( diff(g) <= 0 ) 
      error( 'The grid must be sorted in ascending order.' );
    end
  end
end

 