% ASG_ATMGRIDS   Automatic selection of the atmospheric grids
%
%    The following Q fields are considered:
%       ATMOSPHERE_DIM
%       P_GRID
%       LAT_GRID
%       LON_GRID
%
%    If any of the grids are set to a scalar, a grid is created by taking the
%    union of all corresponding grids in G (by *gf_grid_union*). The given
%    scalar value is used as minimum distance between grid points (see input
%    argument *mindx* in *gridthinning*). No thinning is performed if grid
%    set to be empty or 0.
%
%    The unit for scalar P_GRID is pressure decades. Normal values should
%    accordingly be in the order of 0.01 (roughly equal to 200/16e3).
%
% FORMAT   Q = asg_atmgrids( D, G, Q )
%        
% OUT   Q   Modified qarts setting structure.
% IN    D   Gformat definition structure.
%       G   AGS data.
%       Q   Qarts setting structure.


% 2007-10-19   Created by Patrick Eriksson


function Q = asg_atmgrids( D, G, Q );

  
%- Basic checks
%
% D and G are partially checked inside gf functions.
% Full check of D, G and Q is only made in *asg_chdim* for efficiency reasons.


dims = [];


%- Check for what dimensions grid union is reuqired, and some checks
%
if isnan( Q.P_GRID )
  error( 'NaN found for Q.P_GRID' );
elseif isempty( Q.P_GRID )  |  isscalar( Q.P_GRID )
  dims = 1;
elseif isnumeric( Q.P_GRID )  &  isvector( Q.P_GRID )
  %
else
  error( 'Q.P_GRID must be empty, a scalar or a vector.' );  
end
%
if Q.ATMOSPHERE_DIM >= 2
  if isnan( Q.LAT_GRID )
    error( 'NaN found for Q.LAT_GRID' );
  elseif isempty( Q.LAT_GRID )  |  isscalar( Q.LAT_GRID )
    dims = [ dims 2 ];
  elseif isnumeric( Q.LAT_GRID )  &  isvector( Q.LAT_GRID )
    %
  else
    error( 'Q.LAT_GRID must be empty, a scalar or a vector.' );  
  end
end
%
if Q.ATMOSPHERE_DIM == 3
  if isnan( Q.LON_GRID )
    error( 'NaN found for Q.LON_GRID' );
  elseif isempty( Q.LON_GRID )  |  isscalar( Q.LON_GRID )
    dims = [ dims 3 ];
  elseif isnumeric( Q.LON_GRID )  &  isvector( Q.LON_GRID )
    %
  else
    error( 'Q.LON_GRID must be empty, a scalar or a vector.' );  
  end
end


%- Something to do?
%
if isempty( dims )
  return;           % --->
end

grids = gf_grid_union(D,G,dims);

%- Set P_GRID
%
if any( dims == 1 )
  %
  % Consider that grids{1} is sorted in ascending order, and is in Pa while
  % grid thinning is made in pressure decades.
  %
  grids{1} = flipud( vec2col( grids{1} ) );
  if isempty( Q.P_GRID )  |  Q.P_GRID == 0 
    Q.P_GRID = grids{1};
  else
    grids{1} = gridconvert( grids{1}, 0, @log10, 1 );
    grids{1} = gridthinning( grids{1}, Q.P_GRID );
    Q.P_GRID = gridconvert( grids{1}, 1, @pow10 );
  end
  %
end


%- Set LAT_GRID
%
if any( dims == 2 )
  %
  id = find( dims == 2 );
  %
  if isempty( grids{id} )
    error( 'Automatic setting of Q.LAT_GRID not possible (no input data).' );
  end
  % 
  if isempty( Q.LAT_GRID )  |  Q.LAT_GRID == 0 
    Q.LAT_GRID = grids{id};
  else 
    Q.LAT_GRID = gridthinning( grids{id}, Q.LAT_GRID );
  end
  %
end


%- Set LON_GRID
%
if any( dims == 3 )
  %
  id = find( dims == 3 );
  %
  if isempty( grids{id} )
    error( 'Automatic setting of Q.LON_GRID not possible (no input data).' );
  end
  % 
  if isempty( Q.LON_GRID )  |  Q.LON_GRID == 0 
    Q.LON_GRID = grids{id};
  else 
    Q.LON_GRID = gridthinning( grids{id}, Q.LON_GRID );
  end
  %
end






  
