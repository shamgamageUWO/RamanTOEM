% BINNING   Simple "binning" of data
%
%  Binning means here that the original data Y will be binned
%  on a new grid in such a way that the binned data 
%  Yb(x_i,y_i) will corresponds to weighted average 
%  of Y over the intervall 
%  [ x_i-(x_i-x_{i-1})/2, x_i+(x_{i+1}-x_{i})/2 ]
%  If the original data are not defined outside
%  the ranges of the new grid, the original data
%  are extrapolated, in order to deal with
%  with the end points.
%  The binning is performed in one dimension. 
%  
% FORMAT   [Yb,dx] = binning( x_new, x, Y )
%        
% OUT   Yb      Binned data (vector or matrix).
%       dx      The size of each bin of x_new
% IN    x_new   The new grid to bin the data on.
%       x       Original x-grid.
%       Y       Data to be binned.
%
% See also: bin, binning_fast, bin_nd
%
% 2007-11-12   Created by Bengt Rydberg.

function [Yb,dx] = binning( x_new, x,Y )

if ~isvector(x_new) & ~isvector(x)
   error('x_new and x must be vectors.')
end

if isvector(Y)
  Y=vec2col(Y);
end

if length(x)~=size(Y,1)
   error('Mismatch in size between Y and x.')
end

if min(x_new)<min(x) | max(x_new)>max(x)
   %warning('x_new is outside the range of x')
end

x_new=vec2col(x_new);
x=vec2col(x);

%create a grid with end points of x_new
x_new2=zeros(length(x_new)+1,1);
x_new2(1)=x_new(1)-(x_new(2)-x_new(1))/2;
x_new2(end)=x_new(end)+(x_new(end)-x_new(end-1))/2;       
x_new2(2:end-1)=x_new(1:end-1)+(x_new(2:end)-x_new(1:end-1))/2;

%combine the end points with the centre points for each bin
x_new2=union(x_new2,x_new);
%combine the update grid with the original grid
x_new3=union(x_new2,x);

ny = size( Y, 2 );

%interpolate data onto the combined grid
Y1=zeros(length(x_new3),ny);
for i=1:ny
    Y1(:,i)=interp1( x ,Y(:,i), x_new3,'linear','extrap');
end

xlen=length(x_new);
Yb=zeros(length(x_new),ny);
dx=zeros(length(x_new),1);
for i=1:xlen
    j1=2*(i-1)+1;
    j2=2*i+1;
    ind=find(x_new3>=x_new2(j1) & x_new3<=x_new2(j2));
    %the size for matching indices
    dx3=x_new3(ind(2:end))-x_new3( ind(1:end-1));
    %the size of each bin of x_new
    dx(i)=x_new2(j2)-x_new2(j1);
    Yb(i,1:ny)=sum((( Y1(ind(1:end-1),:)+ Y1(ind(2:end),:))/2.*...
		    [dx3/dx(i)*ones(1,ny)]));
end

