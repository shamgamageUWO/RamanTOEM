% GF_GET_GRID   Gets gformat grid data
%
%    The fields GRIDx, GRIDx_NAME and GRIDx_UNIT can be extracted with the
%    function, where x is *dim*.
%
% FORMAT   [grid,name,unit] = gf_get_grid( G, dim )
%        
% OUT   grid  Grid.
%       name  Grid name.
%       unit  Grid unit.
% IN    G     A gformat structure.
%       dim   Dimension.

% 2010-01-06   Created by Patrick Eriksson.

function [grid,name,unit] = gf_get_grid( G, dim )

strict_assert = atmlab('STRICT_ASSERT');

  
if strict_assert
  rqre_nargin( 2, nargin );
  rqre_datatype( G, @isstruct );
  rqre_alltypes( dim, {@istensor0,@iswhole} );
  rqre_in_range( dim, 1 );
end

bname = sprintf( 'GRID%d', dim );
if strict_assert
  rqre_field( G, bname );
end
grid = G.(bname);
  
if nargout >= 2
  fname = [ bname, '_NAME' ]; 
  if strict_assert
    rqre_field( G, fname );
  end
  name = G.(fname);
  if nargout >= 3
    fname = [ bname, '_UNIT' ]; 
    if strict_assert
      rqre_field( G, fname );
    end
    unit = G.(fname);
  end
end
