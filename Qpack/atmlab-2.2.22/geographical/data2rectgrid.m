% DATA2RECTGRID   Map irregular data to a rectangular grid 
%
%    The function finds all input data points inside each grid cell and
%    performs the operation specified by *funh* to create data on a
%    rectangular grid. The grid cells are defined by the position of the edges
%    by *xedges* and *yedges*. Data outside these ranges are ignored.
%    Empty entries in *Z* are returned as *backv*.
%
%    The data values, *z*, must be given columns. If *z* has more than one 
%    column this is interpreted as different "altitudes", and the operation 
%    is performed for each altitude individually.
%
%    The mapping function must return a scalar for a vector input. Possible
%    choices for *fun* are: @sum, @mean and @max. 
%
% FORMAT   [Z,N] = data2rectgrid(xedges,yedges,x,y,z,funh[,lonrange])
%        
% OUT   Z        Data on rectangular grid. Size 
%                is [length(xedges)-1,length(yedges)-1,size(z,2)].
%       N        Number of data points found inside each grid cell.
% IN    xedges   Edges of grid cells in x-direction.
%       yedges   Edges of grid cells in y-direction.
%       x        x-position of input data points.
%       y        y-position of input data points.
%       z        Input data values.
%       funh     Handle to mapping function. 
% OPT   backv    Value for empty bins. Default is NaN

% 2005-03-27   Created by Patrick Eriksson.


function [Z,N] = data2rectgrid(xedges,yedges,x,y,z,funh,varargin)
%
backv = optargs( varargin, { NaN } );
                                                                         %&%
                                                                         %&%
%= Check input                                                           %&%
%                                                                        %&%
rqre_nargin( 6, nargin );                                                %&%
%
if length(y)~=length(x)  
  error('Vectors *x* and *y* must have same length.');
end
%
if size(z,1)~=length(x)
  error('Mismatch in size between *x* and *z*.');
end
%
if ~isa( funh, 'function_handle')
  error('Argument *funh* must be a function handle');
end


%= Size outpout
%
N = zeros( length(xedges)-1, length(yedges)-1 );
Z = repmat( backv, [length(xedges)-1,length(yedges)-1,size(z,2)] );


% Fix to simplify code below
%
yedges(end) = yedges(end)+eps;
xedges(end) = xedges(end)+eps;

for iy = 1 : length(yedges)-1
  for ix = 1 : length(xedges)-1

    ind = find( y>=yedges(iy) & y<yedges(iy+1) & ...
                x>=xedges(ix) & x<xedges(ix+1) );

    if length(ind)
      N(ix,iy) = length( ind );
      for i = 1:size(z,2)
        Z(ix,iy,i) = funh( z(ind,i) );
      end
    end
  end
end