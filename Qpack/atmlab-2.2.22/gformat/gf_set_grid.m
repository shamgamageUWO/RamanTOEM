% GF_SET_GRID   Sets gformat grid data
%
%    The fields GRIDx, GRIDx_NAME and GRIDx_UNIT can be set with the function,
%    where x is *dim*.
%
% FORMAT   G = gf_set_grid( G, dim, grid [, name, unit ] )
%
% OUT   G     Modified gformat structure (array).
% IN    G     Original gformat structure (array).
%       dim   Dimension.
%       grid  Grid to be copied.
% OPT   name  Grid name.
%       unit  Grid unit (a string).

% 2010-01-06   Created by Patrick Eriksson.

function G = gf_set_grid( G, dim, grid, name, unit )

if atmlab('STRICT_ASSERT')
  rqre_nargin( 3, nargin );
  rqre_datatype( G, @isstruct );
  rqre_alltypes( dim, {@istensor0,@iswhole} );
  rqre_in_range( dim, 1 );
  rqre_datatype( grid, {@isempty,@istensor1} );
  if nargin>=4
    rqre_datatype( name, {@isempty,@ischar} );
    if nargin>=5
      rqre_datatype( unit, {@isempty,@ischar} );
    end
  end
end


bname = sprintf( 'GRID%d', dim );


for i = 1 : length(G)
    
  G(i).(bname) = grid;
    
  if nargin >= 4
    G(i).([bname,'_NAME']) = name;
    if nargin >= 5
      G(i).([bname,'_UNIT']) = unit;
    end
  end
end


