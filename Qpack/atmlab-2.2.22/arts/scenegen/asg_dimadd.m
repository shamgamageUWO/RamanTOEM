% ASG_DIMADD   Extrapolates ASG data to match Q.ATMOSPHERE_DIM
%
%    The function ensures that atmospheric fields are defined for 
%    dimensions 1:Q.ATMOSPHERE_DIM and surface for 2:Q.ATMOSPHERE_DIM.
%    Nothing is done if the DATA field is empty. 
%
%    The data are extended following settings in G.DIMADD. The extrapolation
%    method is selected by the field METHOD. The following options exist:
%
%    FORMAT = 'expand'
%    -----------------
%    The data are simply expanded to fill missing higher dimensions. For 
%    example, a 1D pressure profile is expanded to 2D by inserting the
%    profile at each Q.LAT_GRID position.
%   
%    FORMAT = 'expand_weighting'
%    reguires the fields
%    G.DIMADD.weight    which is a weighting vector with the same length
%    as the corresponding missing data in Q.(P,LAT,LON)_GRID
%    -----------------        
%    
%    FORMAT = 'iaaft'
%    the data are expanded in longitude dimension  by an Iterative
%    Amplitude Adapted Fourier Transform algorithm   
%
%    The data are expanded to fill missing higher dimensions. For
%    example 2D pressure and latitude dependent data are
%    expanded to longitudinal dependency by applying the weights
%    in G.DIMADD.weight. So G.DATA(p1,lat1,lon1)=  
%    G.DATA(p1,lat1)*G.DIMADD.weight(1) 
%
% FORMAT   G = asg_regrid( G, Q )
%        
% OUT   G   Extrapolated ASG data.
% IN   
%       G   gformat data data.
%       Q   Qarts setting structure.

% 2007-10-19   Created by Patrick Eriksson

function G = asg_dimadd( G, Q )
  

%- Basic checks of input
%
%qcheck( @asgD, D );
%qcheck( @asgG, G );
%qcheck( @qarts, Q );
%
rqre_in_range( Q.ATMOSPHERE_DIM, 1, 3, 'Q.ATMOSPHERE_DIM' );



%- New grids for p, lat and lon . To be used with 'expand' option.
%
expandg = { [1.1e5 1e-9], [-90 90], [-180 180] };


for ig = 1 : length(G)

  %- Do nothing if DATA field is empty.
  %
  if isempty( G(ig).DATA )
    continue;
  end
  
  %- Determine new dimensions
  %
  %maxdim  = max( G(ig).DIMS( find(G(ig).DIMS <= Q.ATMOSPHERE_DIM) ) );
  maxdim=G(ig).DIM;
  %
  if isempty(maxdim)
    if G(ig).SURFACE
      maxdim = 1;
    else
      maxdim = 0;
    end
  end
  %
  newdims = maxdim+1 : Q.ATMOSPHERE_DIM;

  %- Already at Q.ATMOSPHERE_DIM?
  %
  if isempty( newdims )
    continue;
  end
  
  if ~isfield( G(ig).DIMADD, 'METHOD' )
    error( sprintf('No field ''METHOD in G(%d).DIMADD.', ig ) );
  end

  switch lower( G(ig).DIMADD.METHOD )
  
   %--- Simple expansion ---------------------------------------------------
   case 'expand'
    %
   
    G(ig) = gf_increase_dim( asgD, G(ig), newdims, {expandg{newdims}} );

   case 'expand_weighting'
    %
    if length(newdims)==1 
       if newdims~=3 
          error('only longitudinal dependency can be added with this option')
       end
    else
      error('only longitudinal dependency can be added with this option')
    end
    if length(Q.LON_GRID)~=length(G(ig).DIMADD.weights)
      error('mismatch in size between Q.LON_GRID and G.DIMADD.weights')
    end
    G(ig) = gf_increase_dim( D, G(ig), newdims, {Q.LON_GRID} );
    data=G(ig).DATA;
    if isvector(data)
       for jg=1:length(Q.LON_GRID)
           data(:,jg)=data(:,jg)*G(ig).DIMADD.weights(jg);
       end       
    else
       for jg=1:length(Q.LON_GRID)
           data(:,:,jg)=data(:,:,jg)*G(ig).DIMADD.weights(jg);
       end
    end 
    G(ig).DATA=data;
    
   case 'iaaft' 
    if length(newdims)==1 
      if newdims~=3 
          error('only longitudinal dependency can be added with this option')
      end
    else
      error('only longitudinal dependency can be added with this option')
    end  
    G(ig) = asg_2d23d( G(ig), Q );   

   otherwise
     error( sprintf( 'No recognised choice for G(%d).DIMADD.METHOD.', ig ) );
  end
end

  
% GF_INCREASE_DIM   Increase dimension of gformat data
%
%    Existing data are repeated to fill added dimensions. 
%
%    To e.g. expand 1D data to 2D, covering the range [-90 90], do
%       G = gf_increase_dim( D, G, 2, {[-90 90]} );
%
% FORMAT   G = gf_increase_dim( D, G, newdims, grids )
%        
% OUT   G         Expanded data.
% IN    D         Gformat definition structure
%       G         Original gformat data.
%       newdims   Data dimensions to be added, as a vector of integers.
%       grids     Grids for new dimensions. An array of vectors, with same
%                 length as *newdims*.

% 2007-10-17   Created by Patrick Eriksson.


function G = gf_increase_dim( D, G, newdims, grids )


%- Check input
%
%rqre_datatype( 'struct', D );
%rqre_datatype( 'struct', G );
%rqre_field( D, 'DIM', 0 );
%rqre_field( G, 'DIMS', 0 );
%rqre_datatype( 'vector', newdims );
%rqre_datatype( 'cell', grids );
%
newdims = vec2row( newdims );
%
if max(newdims) > D.DIM
  error( 'You have selected a dimension (in *newdims*) above D.DIM.' );
end
%
if any( diff(newdims) < 1 )
  error( ['Input argument *newdims* must be sorted in ascending order, ',...
          'with no dimensions repeated.'] );
end
%
if length(newdims) ~= length(grids)
  error( 'Difference in length between *newdims* and *grids*.' );
end


for ig = 1 : length(G)

  %if isempty(G(ig).DIMS)
  %  maxdim = 0;
  %else
  %  maxdim = G(ig).DIMS(end); 
  %end
  maxdim=G(ig).DIM;

  if maxdim >= newdims(1)
    continue;
  end
  
  %- Create mapdata and include grids
  %
  mapdata = ones( 1, max([ 2 newdims(end) ]) ); 
  %
  for id = 1 : length(newdims)
    mapdata(newdims(id))                  = length( grids{id} );
    G(ig).(sprintf('GRID%d',newdims(id))) = grids{id};
  end
  
  %G(ig).DIMS = [ vec2row(G(ig).DIMS), newdims ];
  G(ig).DIM=max(newdims);
  G(ig).DATA = repmat( G(ig).DATA, mapdata );

end

return