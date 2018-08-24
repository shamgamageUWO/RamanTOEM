% COVMAT_TEST   Tests if a covariance matrix is postive definite
%
%   An error is issued if not OK.
%
% FORMAT   covmat_test( S )
%        
% IN    S     The covariance matrix

% 2005-05-23   Created by Patrick Eriksson.


function covmat_test(S)


[R,p] = chol( S );

if p
  error( 'Matrix is not positive definite.' );
end
