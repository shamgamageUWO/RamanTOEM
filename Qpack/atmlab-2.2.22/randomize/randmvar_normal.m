% RANDMVAR_NORMAL  Random multivariate normal distributed data
%
%    Creates a set of random vectors fulfilling multivariate normal
%    statistics. The statistics to fulfill is defined by giving the
%    mean vector, standard deviations and the correlation matrix.
%
%    See also *randmvar_normal2*.
%
% FORMAT   X = randmvar_normal( x, si, C, n )
%        
% OUT   X    Random data [length(x) x n].
% IN    x    Mean vector. Vector with length matching *C* or a scalar.
%            In the scalar case, this value is applied for all positions. 
%       si   Standard deviations. Vector with length matching *C* or a scalar.
%            In the scalar case, this value is applied for all positions. 
%       C    Correlation matrix. 
%       n    Number of realisations to generate.

% 2005-05-20   Created by Patrick Eriksson.


function X = randmvar_normal(x,si,C,n)


%= Check input
%
rqre_nargin( 4, nargin );
%
if dimens(C) > 2  |  size(C,1) ~= size(C,2) 
  error('Input argument *C* must be a square matrix.');
end
%
l = size(C,1);
%
if ~( length(x) == 1  |  length(x) == l )
  error( ...
  'Input argument *x* must be a scalar or a vector with length matching *C*.');
end
%
if ~( length(si) == 1  |  length(si) == l )
  error( ...
 'Input argument *si* must be a scalar or a vector with length matching *C*.');
end
%
if ~isscalar(n)  |  ~iswhole(n)  |  n<1
  error('Input argument *n* must be a positive integer.');
end


if length(si) > 1
  si = vec2col( si );
end

S = (si*si') .* C; 

if length(x) == 1
  x = repmat( x, l, 1 );;
end


X = repmat(vec2col(x),1,n) + chol(S)'*randn(l,n);