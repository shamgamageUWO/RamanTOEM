% COMPLEX_REFR_INFDEXFROMFUN   Sets up complex_refr_index 
%
%    The function creates a variable matching ARTS's definition of
%    complex_refr_index. That is, data of complex refractive index is
%    compiled in to a single variable, of type GriddedField3.
%
%    The function to be used for calculating refractive index is 
%    specified as a function handle (nfun). For higher flexibility, 
%    the data returned by this function can be modified further by 
%    setting *mapfun*. The standard usage of *mapfun* should be to
%    convert dielectric constant data to refractive index, by setting
%    mapfun = @sqrt. An example:
%
%    N = complex_refr_indexFromFunc(fg,tg,@eps_water_liebe93,@sqrt);
%
% FORMAT   N = complex_refr_indexFromFunc(f_grid,t_grid,nfun[,mapfun])
%        
% OUT   G        Data in GriddedField3 format.
% IN    f_grid   Frequency grid.
%       t_grid   Temperature grid.
%       nfun     Handle to function returning relevant data.
% OPT   mapfun   Mapping function, see above.

% 2013-08-18   Created by Patrick Eriksson.


function N = complex_refr_indexFromFunc(f_grid,t_grid,nfun,mapfun)

% Check input
%
rqre_datatype( f_grid, @istensor1 );
rqre_datatype( t_grid, @istensor1 );
rqre_datatype( nfun, @isfunction_handle );
if nargin > 3
  rqre_datatype( mapfun, @isfunction_handle );
end


% Set aux data
N.name = sprintf( 'Complex n data obtained in Atmlab by %s', ...
                                                func2str(nfun ) );

N.gridnames = { 'Frequency', 'Temperature', 'Complex' };
N.grids     = { f_grid, t_grid, [1 2]' };
N.dataname  = 'Complex refractive index';


% Fill data
%
N.data      = zeros( length(f_grid), length(t_grid), 2 );
%
for i = 1 : length(f_grid)
  for j = 1 : length(t_grid)

    n = nfun( f_grid(i), t_grid(j) );
    
    if nargin > 3
      n = mapfun(n);
    end
    
    N.data(i,j,:) = [ real(n) imag(n) ];
    
  end
end
