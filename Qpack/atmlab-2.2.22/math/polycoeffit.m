% POLYCOEFFIT   Polynomial fit for selected coefficients
%
%    Similar to *polyfit* but has some extended functionality. First of all,
%    you can here specify exactly what polynomial coefficients to involve in
%    the fit (and not just n first as for *polyfit). This is done by the vector
%    *c* where you list the coeffients to include. For example, if you want to
%    fit a straight line to some data, but want to enforce that it to pass
%    origo you set c=[1]. That is, you here enforce coefficient to be zero.
%
%    The fit of y(x) is obtained as A*[p;s].
%
%    The optional argument *w* allows to consider the uncertainty for each
%    data point. The function *lscov* is then used, and *w* fits the third
%    argument of that function. If the uncertainties are uncorrelated, *w*
%    can be set to be a vector where the standard choice is to set the
%    weights to 1/sigma^2 (the inverse variance). 
%
% FORMAT   [p,A] = polysinfit(x,y,c,[w])
%        
% OUT   p    As for *polyfit*.
%       A    Fitting matrix.
% IN    x    As for *polyfit*.
%       y    As for *polyfit*.
%       c    Polynomial coefficients to include, e.g. [1 2].
% OPT   w    Fitting weight for each data point in *y*. As passed on as 
%            argument three of *lscov* (there called W or V).


% 2009-11-19   Created by Patrick Eriksson.

function [p,A] = polycoeffit(x,y,c,w)
  
if ~isequal(size(x),size(y))
  error( 'The *x* and *y* vectors must have the same size.' );
end

x = x(:);
y = y(:);

  
A = zeros( length(y), length(c) );

for i = 1 : length(c)
  if c(i) == 0
    A(:,i) = 1;
  elseif c(i) == 1
    A(:,i) = x;
  else
    A(:,i) = x.^c(i);
  end
end

if nargin == 3
  p = A \ y;
else
  p = lscov( A, y, w );
end
