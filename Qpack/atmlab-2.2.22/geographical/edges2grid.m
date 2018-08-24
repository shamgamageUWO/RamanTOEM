% EDGES2GRID   Gives centre points for ranges specified by their edges
%
%    Useful for e.g. defining the plotting position if the data are specified
%    for data ranges. The data grid is assumed to be continous where *e* gives
%    the edge between the ranges.
%
% FORMAT   g = edges2grid(e)
%        
% OUT   g   Grid points.
% IN    e   Edges of grid ranges.

% 2006-03-27   Created by Patrick Eriksson.

function g = edges2grid(e)

g = e(1:end-1) + diff(e)/2;

