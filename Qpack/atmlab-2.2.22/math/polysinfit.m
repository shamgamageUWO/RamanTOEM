% POLYSINFIT   Combined polynomial and sinusiodal fit
%
%    The function works as *polyfit*, but sinusiodal fits can be made in
%    parallel. Data and polynomial varaibles exactly as for *polyfit*. The
%    sinusiodal part is defined by specifying the period length of each
%    component. A sin and cosine term for each period length is fitted, where
%    the results is returned as s=[s1,c1,s2,c2,...] where s1 is the amplitude
%    for first sine term, c1 amplitude for first cosine term etc.
%
%    The fit of y(x) is obtained as A*[p;s].
%
%    The optional argument *w* allows to consider the uncertainty for each
%    data point. The function *lscov* is then used, and *w* fits the third
%    argument of that function. If the uncertainties are uncorrelated, *w*
%    can be set to be a vector where the standard choice is to set the
%    weights to 1/sigma^2 (the inverse variance). 
%
% FORMAT   [p,s,A] = polysinfit(x,y,n,ls)
%        
% OUT   p    As for *polyfit*.
%       s    Sine and cosine amplitudes.
%       A    Fitting matrix.
% IN    x    As for *polyfit*.
%       y    As for *polyfit*.
%       n    As for *polyfit*.
%       ls   Period length of sinusoidal components.
% OPT   w    Fitting weight for each data point in *y*. As passed on as 
%            argument three of *lscov* (there called W or V).


% 2009-11-19   Created by Patrick Eriksson.

function [p,s,A] = polysinfit(x,y,n,ls,w)

if ~isequal(size(x),size(y))
  error( 'The *x* and *y* vectors must have the same size.' );
end

x = x(:);
y = y(:);
  
A = zeros( length(y), n+1+length(ls)*2 );

for i = 1:n+1
  o = n + 1 - i;
  if o == 0
    A(:,i) = 1;
  elseif o == 1
    A(:,i) = x;
  else
    A(:,i) = x.^o;
  end
end

for i = 1 : length(ls)
  A(:,n+1+(i-1)*2+1) = sin( x*(2*pi)/ls(i) );
  A(:,n+1+(i-1)*2+2) = cos( x*(2*pi)/ls(i) );
end

if nargin == 4
  b = A \ y;
else
  p = lscov( A, y, w );
end

p = b(1:n+1);
s = b(n+2:end);
