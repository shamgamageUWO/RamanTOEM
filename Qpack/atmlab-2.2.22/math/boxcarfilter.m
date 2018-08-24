% BOXCARFILTER   Rectangular filtering of data series
%
%    A rectangular filtering is performed. For each abscissa point, the 
%    filtered value is based on all data inside +-xw/2.
%
%    The data are assumed to be equidistant, but gaps in the data series
%    are allowed. The distance between data points is taken as 
%    min( diff( x ) ).
%
%    The filter is throughout applied symmetrically. Parts of the filter
%    extending outside the complete data range, r into data gaps, 
%    are neglected.
%
% FORMAT   yf = boxcarfilter(x,y,xw)
%        
% OUT   yf   Filtered data.
% IN    x    Data abscissa.
%       y    Data values. Must be given as a column vector or a matrix.
%       xw   Width (total) of the filter. 

% 2006-04-05   Created by Patrick Eriksson.


function yf = boxcarfilter(x,y,xw)

if size(y,1) ~= length(x)
  error('Size of *y* does not match size of *x*.');
end
%
if ~issorted(x)
  error('The vector *x* must be sorted.');
end


%= Set-up output variable
%
yf = y;


%= Length of each data range
%
l  = min( diff( x ) );


%= Make sure that *x* is a column vector
%
x = vec2col(x);


for i = 1:length(x)

  % Calculate distance to closest edge of data ranges
  d       = abs( x - x(i) ) - l/2;
  d(i)    = 0;

  % What data points to consider  
  ind     = find( d < xw/2 );

  % Calculate effective length 
  %
  leff      = repmat( l, length(ind), 1 );
  %
  if d(ind(1)) + l > xw/2
    leff(1)   = d(ind(1)) + l - xw/2;
  end
  if d(ind(end)) + l > xw/2;
    leff(end) = d(ind(end)) + l - xw/2;
  end

  % Filter
  yf(i,:) = sum(y(ind,:).*repmat(leff,1,size(y,2))) / sum(leff);

end

