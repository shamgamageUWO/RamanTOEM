% GRID2EDGES   Estimates grid edges for a set of grid points.
%
%    Between defined grid points, the edge is defined as the middle point. 
%    End edges are set based on the distance between the two closest points.
%
% FORMAT   e = grid2edges(g)
%        
% OUT   e   Edges of grid ranges.
% IN    g   Grid points.

% 2006-03-27   Created by Patrick Eriksson.

function e = grid2edges(g)


%= Fix to make sure that column or row vector shape is preserved
%
e        = g;
e(end+1) = 0;


e(1)       = g(1)-(g(2)-g(1))/2;
e(2:end-1) = edges2grid(g);
e(end)     = g(end)+(g(end)-g(end-1))/2;
