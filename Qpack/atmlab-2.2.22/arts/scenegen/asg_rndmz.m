% ASG_RNDMZ   Adds random disturbances of ASG variables
%
%    All data in G having the RNDMZ field set are disturbed. This field
%    is a structure, having these general fields:
%
%       FORMAT     String giving the format used to describe the disturbances.
%                  Valid options listed below.
%       TYPE       Can either be 'abs' or 'rel'. Determines if given data 
%                  specifies an absolute or relative disturbance.  In the
%                  first case, standard deviations are given in same unit as
%                  the data, while in the second case relative values are 
%                  given (such as 0.5 for a 50% disturbance).
%       DATALIMS   Lower and upper limit for data. A vector. The first value 
%                  gives lower limit, and second value upper limit. Data 
%                  below/above a limit, is set to the limit value. 
%                  The field is not mandatory. Upper limit can be left out.
%                  If a limit is set to NaN, all values will be accepted.
%
%    The following formats are handled
%
%    FORMAT = 'param'
%    -----------------
%    The format of *covmat3d* is here used to specify the disturbances. 
%    That is, the covariance matrix for selected variability is described
%    in a parametrised way.
%
% FORMAT   G = asg_rndmz( G )
%        
% OUT   G   Modified ASG data. 
% IN    
%       G            ASG data.

% 2007-10-22   Created by Patrick Eriksson.


function G = asg_rndmz( G )

  

for ig = 1 : length( G )
  
  %Something to do?
  if isempty( G(ig).RNDMZ )
    continue;  % ---->
  end
  
  if ~isfield( G(ig).RNDMZ, 'FORMAT' )
    error( sprintf( 'The field FORMAT is missing in G(%d).RNDMZ.', ig ) );
  end
  
  
  switch lower( G(ig).RNDMZ.FORMAT )
  
   case 'param'
    %
    G(ig) = do_param( G(ig), ig );
    
   otherwise
    error( sprintf( 'Not recognised choice for G(ig).RNDMZ.FORMAT.', ig ) );
  end
  

  %- Remove too low values
  %
  if isfield( G(ig).RNDMZ, 'DATALIMS' )
    if ~isnan( G(ig).RNDMZ.DATALIMS(1) )
      ind             = find( G(ig).DATA < G(ig).RNDMZ.DATALIMS(1) );
      G(ig).DATA(ind) = G(ig).RNDMZ.DATALIMS(1);
    end
    if length(G(ig).RNDMZ.DATALIMS) > 2  &  ~isnan( G(ig).RNDMZ.DATALIMS(1) )
      ind             = find( G(ig).DATA > G(ig).RNDMZ.DATALIMS(2) );
      G(ig).DATA(ind) = G(ig).RNDMZ.DATALIMS(2);
    end
  end

end

return
%------------------------------------------------------------------------------


function G = do_param( G, ig )
  
  %- Only fields are handled (so far?)
  if G.SURFACE
    error( sprintf( ['G(%d).RNDMZ.FORMAT equals ''param'', which so far ',...
                                 'only works for atmospheric fields.'], ig ) );
  end

  %- Check G.DIM and determine dimensionality
  %
  dim = G.DIM;
  %
  if isempty(dim)
    error( sprintf('0D data not handled (found in G(%d)).', ig ) );
  end
  %if length(dim) ~= dim(end)
  %  error( sprintf('Pressure or latitude is missing in G(%d).DIMS', ig ) );
  %end 
  %
  %dim = dim(end);
  
  %- Create covariance matrix for disturbance
  %
  % Use try-ctch for more informative error message
  %
  try
    S = covmat3d( dim, G.RNDMZ, G.GRID1, G.GRID2, G.GRID3, 'atm' );
  catch 
    fprintf( '%s\n\n', lasterr );
    error( sprintf('Incorrect covariance definition for item %d.',ig) );
  end

  %- Create disturbance (loop around cases)
  %
  if strcmp( G.RNDMZ.TYPE, 'rel' )
    for ic = 1 : size( G.DATA, 4 )
      G.DATA(:,:,:,ic) = G.DATA(:,:,:,ic) .* ...
              reshape( randmvar_normal2( 1, S, 1 ), size(G.DATA(:,:,:,ic)) );
    end
  elseif strcmp( G.RNDMZ.TYPE, 'abs' )
    for ic = 1 : size( G.DATA, 4 )
      G.DATA(:,:,:,ic) = G.DATA(:,:,:,ic) + ...
              reshape( randmvar_normal2( 0, S, 1 ), size(G.DATA(:,:,:,ic)) );
    end
    
  else
    error( sprintf( 'Unknown selection in G(ig).RNDMZ.TYPE.', ig ) );
  end
  
return

