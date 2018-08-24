% GF_SET_DATA   Sets the data and grid fields
%
%    To insert the matrix A in G:
%      G = gf_set_data( G, A, {grid1,grid2} );
%
%    To set G to a scalar:
%      G = gf_set_data( G, 1e3, [] );
%
% FORMAT   G = gf_set_data(data,grids,grid_names,grid_units)
%        
% OUT   G              Modified gformat structure.
% IN    G              Original gformat structure.
%       data           Data to be inserted.
%       grids          Grids corresponding to data, given as an array of 
%                      vectors.
% OPT   grid_names     Empty (default) or an array of strings with name of 
%                      each grid.
%       grid_units     Empty (default) or an array of strings with unit of 
%                      each grid.

% 2007-10-17   Created by Patrick Eriksson.

function G = gf_set_data(G,data,grids,grid_names)
%
if nargin < 4, grid_names = []; end
if nargin < 5, grid_units = []; end

dim = length( grids );

strict_assert = atmlab('STRICT_ASSERT');

if strict_assert
  rqre_nargin( 3, nargin );
  rqre_datatype( data, @isnumeric );
  rqre_datatype( grids, {@isempty,@iscell} );
  rqre_datatype( grid_names, {@isempty,@iscellstr} );
  rqre_datatype( grid_units, {@isempty,@iscellstr} );
  if length(grids) < dimens( data )
    error( 'Dimensionality of *data* > than number of grids.' );
  end
end

G.DATA = data;
G.DIM  = dim;

if isempty( grid_names )
  grid_names = cell(dim,1);
elseif strict_assert
  if length(grid_names) ~= dim 
    error('*grid_names* must be empty or have same length as *grids*');
  end
end

if isempty( grid_units )
  grid_units = cell(dim,1);
elseif strict_assert
  if length(grid_units) ~= dim
    error('*grid_units* must be empty or have same length as *grids*');
  end
end

for d = 1 : dim
  G = gf_set_grid( G, d, grids{d}, grid_names{d}, grid_units{d} );
  if strict_assert
    rqre_gridmatch( data, d, grids{d} );
  end
end

