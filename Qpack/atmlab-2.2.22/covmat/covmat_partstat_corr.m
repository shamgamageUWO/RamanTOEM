% COVMAT_PARTSTAT_CORR   Covariance matrix for multidimensional data
%
%    Sets up a covariance matrix for data spanning several dimensions and with
%    partial stationary correlation. That is, it is assumed that there is no
%    dependency between the correlation in one dimension with the other data
%    dimensions. The correlation is allowed to vary along each dimension, but
%    this independently between the data dimensions. A higher degree of
%    freedom for the correlation is accepted by *covmat3d_from_cfun*.
%
%    Note that the standard deviation can vary freely.
%
%    The data are assumed to be stored with dimension 1 as innermost "loop",
%    dimension 2 next etc. For 3D case, the data order is as follows:
% 
%       [(x1,y1,z1) (x2,y1,z2) ...(xn,y1,z1) (x1,y2,z) ... (x1,y1,z2) ...]'
%
%    Correlation coefficient matrix 1 (C1) describes then the correlation
%    for x=[x1,x2,...xn]', and C2 the same thing for y, etc. The correlation
%    along dimensions 1 depends thus only on x, no dependency on y, z ...
%
% FORMAT   S = covmat_partstat_corr( si, C1 [, C2, C3 ...] )
%        
% OUT   S    Covariance matrix.
% IN    si   Standard deviations: given as 
%              1. A vector with a value for each data point. Length must
%                 then be the product of dimension sizes.
%              2. A scalar. This value is then applied for all data points.
%              3. Empty. A constant standard deviation of 1 is then applied, 
%                 and the overall correlation matrix is obtained.
%       C1   Correlation coefficients along dimension 1.
% OPT   C2   Correlation coefficients along dimension 2.
%       C3   Correlation coefficients along dimension 3.
%       ...

% 2007-05-25   Created by Patrick Eriksson.


function S = covmat_partstat_corr(si,varargin)


nc = length(varargin);
% 
if nc < 1
  error( 'At least one correlation matrix must be given.' )
end
%
n = 1;
for i = 1 : nc
  if ~( dimens(varargin{i})~=2 | size(varargin{i},1)==size(varargin{i},2) )
    error( sprintf( 'Correlation matrix %d is not a square matrix', i ) );
  end
  n = n * size(varargin{i},1);
end
%
if ~( isempty(si)  |  isscalar(si)  |  n == length(si) )
  error( ...
   'Inconsistency between length of *si* and sizes of correlation matrices.' );
end
%
clear n


S = varargin{1};


for i = 2 : nc

  nold = size( S, 1 );
  nnew = size( varargin{i}, 1 );
  
  [irow0,icol0,s0] = find( S );
  %
  ns   = length( s0 );
  irow = repmat( irow0, nnew^2, 1 );
  icol = repmat( icol0, nnew^2, 1 );
  s    = repmat( s0, nnew^2, 1 );  

  for ir = 1:nnew
    for ic = 1:nnew
      %
      ind_s   = (1:ns) + ((ic-1)*nnew+ir-1)*ns;
      %
      irow(ind_s) = irow0 + (ir-1)*nold;
      icol(ind_s) = icol0 + (ic-1)*nold;
      s(ind_s)    = varargin{i}(ir,ic) * s0;
    end
  end
  
  ind = find(s);

  if i < nc  |  isempty(si)
    S = sparse( irow(ind), icol(ind), s(ind), nold*nnew, nold*nnew );  
  else
    % If last dimension, include si
    if isscalar(si)
      S = sparse( irow(ind), icol(ind), (si*si)*s(ind), nold*nnew, nold*nnew );
    else
      si = vec2col(si);
      S = sparse( irow(ind), icol(ind), ...
                  si(irow(ind)).*si(icol(ind)).*s(ind), nold*nnew, nold*nnew );
    end
  end
end

% *si* not included if nc == 1
%
if nc == 1  &  ~isempty(si)
  if isscalar(si)
    S = (si*si) * S;
  else
    si = vec2col(si);
    S  = (si*si') .* S;
  end
end
