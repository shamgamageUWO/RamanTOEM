% GRIDTHINNING   Removes close grid points 
%
%    The input grid is thinned in such way that no points are closer than
%    *mindx*. This with exceptions of the two end points that are always 
%    kept, to ensure that the coverage of the grid is not decreased.
%
%    The input grid is assumed to be increasing.
%
% FORMAT   x = gridthinning(x0,mindx)
%        
% OUT   x       Thinned grid.
% IN    x0      Original grid
%       mindx   Minimum distance in thinned grid

% 2007-05-15   Created by Patrick Eriksson.


function x = gridthinning(x0,mindx)

  
x     = x0;
n     = 1;

for itest = 2:length(x0)-1
  if x0(itest) - x(n) >= mindx
    n     = n + 1;
    x(n)  = x0(itest);
  end
end

%- Include end point
%
n    = n + 1; 
x(n) = x0(end);


x = x(1:n);
