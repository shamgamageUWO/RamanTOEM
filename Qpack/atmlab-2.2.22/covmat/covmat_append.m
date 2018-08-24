% COVMAT_APPEND   Appends a set of covariance matrices.
%
%    The covariance matrices are assembled assuming no correlation between
%    the quantities corresponding to each covariance matrix. That is, 
%    the output has the structure:
%       S = [S1  0  0 ...
%             0 S2  0 ...
%             0  0 S3 ...
%             ........... ]
%
%    All input matrices must be sparse.
%
% FORMAT   S = covmat_append( S1, S2, S3, ... )
%        
% OUT   S   Complete covariance matrix.
% IN    Si  Input covariance matrix.

% 2005-05-20   Created by Patrick Eriksson.


function S = covmat_append( varargin )

i = [];
j = [];
s = [];
n = 0;

for a = 1 : length(varargin )

  if ~( isempty( varargin{a} )  |  ...
     ( sparse( varargin{a} )  &  size(varargin{a},1) == size(varargin{a},2) ) )
    error( 'All covariance matrices must be square and sparse.' );
  end

  [ii,jj,ss] = find( varargin{a} );

  i = [ i; vec2col(n+ii) ];
  j = [ j; vec2col(n+jj) ];
  s = [ s; vec2col(ss) ];

  n = n + size( varargin{a}, 1 );

end

S = sparse(i,j,s,n,n);