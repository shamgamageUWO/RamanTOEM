function [local_min, local_max, prom_min, prom_max] = find_extrema_with_prominence(x, y)
% Locate local extrema with associated prominence
%
% For a discrete set of data [x, y], locate all local maxima and minima in
% y = f(x). Additionally, for each local extremum, the one-dimensional
% topographic prominence is returned. Prominence is defined as the
% horizontal distance (delta-x) to the nearest extremum that is more
% extreme. For example, if local maxima are at (2, 8), (4, 6), (5, 7) and
% (10, 10), the prominence of (5, 7) is |5-2|=3, because it takes delta-x=3
% to go to the nearest larger maximum.
%
% WARNING: If a function is locally constant, this function will return
% wrong results! This function is still a work in progress and results
% might change dramatically in the near future (for the record: this lise
% was written 2012-09-20, if it's still there in 2013, please give Gerrit a
% kick)
%
% FORMAT
%
%   [min, max, prom_min, prom_max] = find_extrema_with_prominence(x, y)
%
% IN
% 
%   x       vector with x-data (must be monotonically increasing)
%   y       vector with y-data
%
% OUT
%
%   min         logical true at local minima
%   max         logical true at local maxima
%   prom_min    vector with prominences corresponding to min
%   prom_max    vector with prominences corresponding to max
%
% See also: plot_extrema_shaded
%
% Created by Gerrit Holl, 2012-09-20

% $Id: find_extrema_with_prominence.m 7882 2012-09-20 15:34:42Z gerrit $

errid = ['atmlab:' mfilename];

% verify that x is monotonically increasing

if all(~x(2:end) > x(1:end-1))
    error(errid, 'error in input: x is not monotonically increasing');
end

% something is a local maximum if it's larger-or-equal than the previous
% and than the next element. The or-equal will result in neighbouring
% maxima with 0 prominence; this will be checked for separately
local_max = (y(2:end-1) > y(1:end-2)) & (y(2:end-1) > y(3:end));
local_min = (y(2:end-1) < y(1:end-2)) & (y(2:end-1) < y(3:end));

prom_max = get_prominence(x, y, local_max, 'max');
prom_min = get_prominence(x, y, local_min, 'min');

% check for neighbouring local maxima/minima, saddlepoints, etc.
end

function prominence = get_prominence(x, y, local_max, order)
% for a vector of logicals, true for extrema, get the prominence for each
%
% get_prominence(x, y, local_max, order)
%
% 'order' must be 'max' or 'min' (strings)

switch order
    case 'max'
        operation = @gt;
    case 'min'
        operation = @lt;
    otherwise
        error('atmlab:BUG', ...
            'Reached impossible place, crashing violently!');
end

pos_max_all = find(local_max);
% there is probably a way to do this in a vectorised way. However,
% Premature Optimisation Is The Root Off All Evil -- Donald Knuth

prominence = zeros(size(pos_max_all));
for i = 1:length(pos_max_all)
    pos_max = pos_max_all(i);
    x_here = x(pos_max_all(i));
    % find more extreme local extrema
    worse = operation(y(pos_max_all), y(pos_max));
    
    if any(worse)
        % x-values (e.g. frequencies) for values worse
        x_worse = x(pos_max_all(worse));
        prominence(i) = min(abs(x_here-x_worse));
    else
        prominence(i) = inf;
    end
end

% no = 1:length(pos_max_all);
% maxima = [no(:) x(local_max) y(local_max)];
% dist_left = [x(pos_max_all(1))-x(1); x(pos_max_all(2:end)) - x(pos_max_all(1:end-1))];
% dist_right = [dist_left(2:end); x(end) - x(pos_max_all(end))];
% prominence = min([dist_left dist_right], [], 2);

end
