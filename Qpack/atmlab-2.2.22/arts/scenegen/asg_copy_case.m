% ASG_COPY_CASE   Copying of an ASG case
%
%    Creates *ncopes* copes of the case specified by *icopy*. The copies are
%    appended to the DATA field. The function assumes that cases are numbered
%    followoing their index. The function makes further sure that *DIMS*
%    includes the case dimension (4).
%
% FORMAT   G = asg_copy_case( D, G, ncopies [, icopy ] )
%        
% OUT   G         Extended ASG data.
% IN    D         Gformat definition structure.
%       G         ASG data.
%       ncopies   Number of ciopies to create
% OPT   icopy     Index of case to copy. If set to empty, last case
%                 will be copied. Default is [].

% 2007-10-22   Created by Patrick Eriksson

function G = asg_copy_case( D, G, ncopies, icopy )
%
icopy = optargs( varargin, { [] } );

  
for ig = 1 : length(G)
  
  %- Reallocate DATA field
  %
  data          = G(ig).DATA;
  [n1,n2,n3,n4] = size( data );
  G(ig).DATA    = zeros( n1, n2, n3, n4+ncopies );
  %
  G(ig).DATA(:,:,:,1:n4) = data;

  %- Add new cases
  %
  if isempty( icopy )
    ic = n4;
  else
    ic = icopy;
  end
  %
  G(ig).DATA(:,:,:,n4+1:n4+ncopies) = ...
                                  repmat( data(:,:,:,ic), [ 1 1 1 ncopies ] );
  
  %- New case grid
  %
  G(ig).GRID4 = 1 : (n4+ncopies);  
  
  %- Ensure that "case dimension" is activated
  %
  if ~any( G(ig).DIMS == 4 )
    G(ig).DIMS(end+1) = 4;
  end
end