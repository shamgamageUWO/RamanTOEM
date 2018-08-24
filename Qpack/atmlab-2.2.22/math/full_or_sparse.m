% FULL_OR_SPARSE   Selects if full or sparse data format shall be used
%
%    The function checks the density of non-zero elements, and if this
%    denisty is below the given limit, *X* is converted to sparse (if not
%    already is sparse). Otherwise, X is made sure to be full.
%
%    The default density limit is selected considering memory usage (for
%    double precision). If you want to maximise the calculation speed, a
%    considerably lower limit is likely better. 
%
% FORMAT   X = full_or_sparse(X[,density_limit])
%
% OUT   X               The input variable, maybe converted to full or 
%                       sparse.
% IN    X               Input variable.
% OPT   density_limit   Threshold density for full/sparse. Default is 0.5.

% 2014-01-04 Patrick Eriksson

function X = full_or_sparse(X,density_limit)
%
if nargin == 1, density_limit=0.5; end

density = nnz(X) / prod(size(X));

if density < density_limit
  if ~issparse(X)
    X = sparse(X);
  end
else
  if issparse(X)
    X = full(X);
  end  
end
