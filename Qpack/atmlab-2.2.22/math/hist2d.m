function [counto,xco,yco] = hist2d(x,y,nx,ny)
% HIST2D calculates a 2-dimensional histogram
%    N = HIST2D(X,Y) bins the X and Y data into 10 equally spaced bins in
%    both dimensions
%
%    N = HIST2D(X,Y,M), where M is a scalar, bins the data into M equally
%    spaced bins in both dimensions
%
%    N = HIST2D(X,Y,B), where B is a vector, bins the data with centers
%    specified by B 
%
%    The number of bins or centers can be specified individually for either
%    dimension using N = HIST2D(X,Y,NX,NY) or N = HIST2D(X,Y,BX,BY)
%
%    [N,BX,BY] = HIST2D(...) also returns the positions of the bin centers
%    as two matrices in BX and BY
%
%    HIST2D(...) without output arguments produces a colormapped image plot
%    of the 2d histogram
%
% EXAMPLE
%   yin = randn(1,1000);
%   xin = randn(1,1000);
%   [n,x,y] = hist2d(xin,yin,11);
%   imagesc(x(1,:),y(:,1),n); hold on; plot(xin,yin,'y.'); colorbar
%
% This is a downloaded function from somewhere, but I have optimized it a
% bit
% $Id: hist2d.m 8372 2013-04-24 06:23:43Z seliasson $

if nargin < 3
   nx = 10;
end

if nargin < 4
   ny = nx;
end

assert(isequal(size(x),size(y)),['atmlab:' mfilename ':badInput'],...
    'x and y must be same size');

[~,xc] = hist(x,nx);
[~,yc] = hist(y,ny);

count = zeros(length(yc),length(xc));
for i = 1:length(yc)
   if i == 1
      lbound = -Inf;
   else
      lbound = (yc(i-1) + yc(i)) / 2;
   end
   if i == length(yc)
      ubound = inf;
   else
      ubound = (yc(i) + yc(i+1)) /2;
   end
   count(i,:) = hist(x((y >= lbound) & (y < ubound)),xc);
end

[xc, yc] = meshgrid(xc, yc);

if nargout == 0
   imagesc(xc(1,:),yc(:,1),count);
else
   counto = count;
   xco = xc;
   yco = yc;
end

end