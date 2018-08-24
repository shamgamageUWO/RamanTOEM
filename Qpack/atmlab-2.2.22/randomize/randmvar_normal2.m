% RANDMVAR_NORMAL2  Random multivariate normal distributed data
%
%    As *randmvar_normal2*, but using taking a covariance matrix as input
%    instead of standard deviations and correlations separately.
%
%    Creates a set of random vectors fulfilling multivariate normal
%    statistics. The statistics to fulfill is defined by giving the
%    mean vector and covariance matrix.
%
%    The mean state, *x*, can be given as a scalar if all values are identical.
%
% FORMAT   X = randmvar_normal2( x, Sx, n )
%        
% OUT   X    Random data [length(x) x n].
% IN    x    Mean vector. 
%       Sx   Covariance matrix. 
%       n    Number of realisations to generate.

% 2007-05-22   Created by Patrick Eriksson.


function X = randmvar_normal2(x,S,n)


%= Check input
%
rqre_nargin( 3, nargin );
%
if ~isvector(x) 
  error('Input argument *x* must be a vector.');
end
%
if dimens(S) ~= 2  |  size(S,1) ~= size(S,2) 
  error('Input argument *S* must be a square matrix.');
end
%
if ~( length(x) == 1  |  length(x) == size(S,1) )
  error( ...
  'Input argument *x* must be a scalar or a vector with length matching *S*.');
end
%
if ~isscalar(n)  |  ~iswhole(n)  |  n<1
  error('Input argument *n* must be a positive integer.');
end


if length(x) == 1
  x = repmat( x, size(S,1), 1 );;
end

X = repmat(vec2col(x),1,n) + chol(S)'*randn(length(x),n);