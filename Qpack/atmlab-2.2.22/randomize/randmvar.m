% RANDMVAR   Realisation of random multivariate data
%
%    The function returns *n* vectors fulfilling the given statistical
%    properties. The statistics are described by cumulative distribution 
%    function (CDF) for each vector element and the correlation matrix. 
%    The cumulative distribution function is the cumulative integral of 
%    the probability density function.
%
%    The statistics for each individual vector element will be fulfilled
%    completely, while the correlation structure will be somewhat distorted.
%    The correlation distortion depends on the deviation from normal 
%    statistics.
%
%    The cumulative distribution function is described by the cell array *P*, 
%    where each element must/can have the fields listed below. The only 
%    mandatory field is 'cdf'.
%
%    cdf        : The distribution function as a 2 column matrix. Column 1 is 
%                 the data abscissa. Column 2 is the distribution function. 
%                 The distribution function must start with 0 and end with 1.
%    interpmeth : Method for interpolating data in 'cdf'. See *interp1*
%                 for options. Default is 'linear'.
%    datalims   : Min and max allowed values for obtained data. The purpose of
%                 this field is to make it possible to create PDF peaks at
%                 the end points of the data range. See example below.
%
%    To create 1e6 vectors of length 2 with uniformly distributed data:
%       C = covmat1d_from_cfun(1:2,[], ... );
%       P{1}.cdf = [0 0;1 1]; 
%       P{2} = P{1};
%       X = randmvar(P,C,1e6);
%
%    To obtain PDF peaks at 0 and 1, each holding 10% of the data
%       P{1}.cdf = [-0.01 0;0 0.1;1 0.9;1.01 1];
%       P{1}.datalims = [0 1];
%
% FORMAT   X = randmvar( P, C, n )
%        
% OUT   X    Random data [length(x) x n].
% IN    P    Description of CDF. Format given above.
%       C    Correlation matrix. 
%       n    Number of vector realisations to generate.

% 2005-05-21   Created by Patrick Eriksson.


function X = randmvar(P,C,n)


%= Check input
%
rqre_nargin( 3, nargin );
%
if ~iscell(P)
  error('Input argument *P* must be a cell array.');
end
%
if ndims(C) > 2  |  size(C,1) ~= size(C,1) 
  error('Input argument *C* must be a square matrix.');
end
%
if length(P) ~= size(C,1) 
  error('Mismatch in size between *P* and *C*.');
end
%
if ~isscalar(n)  |  ~iswhole(n)  |  n<1
  error('Input argument *n* must be a positive integer.');
end
%
if nargin < 4
  interpmeth = 'linear';
end


lxm = length(P);


%= Generate cases with normal distribution and unit std dev
%
X = randmvar_normal( zeros(lxm,1), 1, C, n );


%= Transform to cumulative values
%
Xc = cdf_normal( X );


%= Map to given distribution
%
for i = 1:lxm
  %
  if isvector( P{i}.cdf )
    %
    X(i,:) = P{i}.cdf(1,1) + X(i,:) * P{i}.cdf(1,2);

  else
    %    
    if P{i}.cdf(1,2) ~= 0
      error( sprintf('CDF %d does not start with 0',i) );
    end
    if P{i}.cdf(end,2) ~= 1
      error( sprintf('CDF %d does not end with 1',i) );
    end
    %
    if isfield( P{i}, 'interpmeth' )
      imethod = P{i}.interpmeth
    else
      imethod = 'linear';
    end
    %
    X(i,:) = interp1( P{i}.cdf(:,2), P{i}.cdf(:,1), Xc(i,:), imethod );
    %
  end
end


%= Datalims
%
if isfield( P{i}, 'datalims' )
  X(i,find(X(i,:)<P{i}.datalims(1))) = P{i}.datalims(1);
  if length(P{i}.datalims) > 1
    X(i,find(X(i,:)>P{i}.datalims(2))) = P{i}.datalims(2);
  end
end
