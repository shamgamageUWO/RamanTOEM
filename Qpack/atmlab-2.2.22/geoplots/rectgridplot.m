% RECTGRIDPLOT   Plots a rectangular field
%
%    A help function to plot a 2D rectangular field. The function uses *pcolor*
%    and expands and shifts grids in such way that expected result is obtained.
%    The renderer is also set to OpenGL as this has been found to give better
%    performance.
%    
%    It is recommnded to use this function. First of you do not need to bother
%    about required fixes for *pcolor*. The function *contourf* is easier to
%    use but behaves strange when it comes to color limits.
%
%    The data abscissas are defined with the edges of each grid cell. This
%    means that the length of *x* and *y* shall be +1 compared to corresponding
%    dimension of *F*. 
%
% FORMAT   rectgridplot(x,y,F[,shadtype])
%        
% IN    x          Data edges in x-direction.
%       y          Data edges in y-direction.
%       F          Data field (size(F)=[length(x)-1,length(y)-1]).
% OPT   shadtype   Shading type. Default is 'flat'. Other options are 'faceted'
%                  and 'interp'.

% 2006-03-27   Created by Patrick Eriksson.


function rectgridplot(x,y,F,varargin)
%
[shadtype] = optargs( varargin, { 'flat' } );
                                                                            %&%
                                                                            %&%
%= Check input                                                              %&%
%                                                                           %&%
rqre_nargin( 3, nargin );                                                   %&%
if length(x)-1 ~= size(F,1)                                                 %&%
  error( 'Length of *x* does not match size of *F*.' );                     %&%
end                                                                         %&%
if length(y)-1 ~= size(F,2)                                                 %&%
  error( 'Length of *y* does not match size of *F*.' );                     %&%
end                                                                         %&%


if strcmp(shadtype,'flat')  |  strcmp(shadtype,'faceted')
  %
  pcolor( x, y, [ F F(:,end); F(end,:) F(end,end) ]' );

elseif strcmp(shadtype,'interp')
  %
  pcolor( [x(1) vec2row(edges2grid(x)) x(end)], ...
          [y(1) vec2row(edges2grid(y)) y(end)], ... 
      [ F(1,1)   F(1,:)   F(1,end); 
        F(:,1)   F        F(:,end); 
        F(end,1) F(end,:) F(end,end) ]' );

else                                                                        %&%
  error('Valid shading types are ''flat'', ''faceted'' and ''interp''');    %&%
end

shading( shadtype )

set( gcf, 'Renderer', 'zbuffer' );
