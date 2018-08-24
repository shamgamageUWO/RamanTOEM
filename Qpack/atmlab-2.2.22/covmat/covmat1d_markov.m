% COVMAT1D_MARKOV   Covariance matrix for a Markov process
%
%    The function creates the covariance matrix and its inverse where the
%    correlation can be described as a Markow process. For details, see
%    "Inverse methods for atmospheric sounding" by C.D. Rodgers (Eq. 2.83,
%    Sec. 10.3.2.2 and Exercise 10.2).
%
% FORMAT   [S,Sinv] = covmat1d_markov( n, sigma, dz, lc [,cco] )
%        
% OUT   S       Covariance matrix, with size n x n. A sparse matrix.
%       Sinv    The inverse of S. A sparse matrix.
% IN    n       Number of points
%       sigma   Standard devation
%       dz      Distance between grid points
%       lc      Correlation length
% OPT   cco     Correlation cut-off. All values corresponding to a 
%               correlation below this limit are set to 0 in S. This causes
%               S*Sinv to deviate from the identity matrix, but can make S
%               much more sparse.

% 2009-11-06   Created by Patrick Eriksson.


function [S,Sinv] = covmat1d_markov(n,sigma,dz,lc,cco)

if nargin < 5
  cco = 0;
end


% Constants
%
s2    = sigma * sigma;
alpha = exp( -dz/lc );
c1    = -alpha / ( 1 - alpha^2 ) / s2;
c2    = 1/(1-alpha^2)/s2;

% Seinv
%
row = [ 2:n 1:n 1:n-1 ];
col = [ 1:n-1 1:n 2:n ];
w   = [ repmat(c1,1,n-1) c2 repmat(c2*(1+alpha^2),1,n-2) c2 repmat(c1,1,n-1) ];
%
Sinv = sparse( row, col, w, n, n );


S = covmat1d_from_cfun( 0:dz:dz*(n-1)*dz, sigma, 'exp', lc, cco );

