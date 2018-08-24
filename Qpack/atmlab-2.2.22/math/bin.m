function values = bin(x, y, xbin)
%% bin Bin y according to x in xbin
%
% Bin the contents of y in the xbins according to the values in x.
% E.g. y(i) is binned according to the value of x(i). Binning rules
% as for <a href="matlab:help histc">histc</a>.
%
% Any value for which x is not finite will not be binned at all.
%
% Also known as bucketing, see
% http://en.wikipedia.org/wiki/Bucket_%28computing%29
%
%
% FORMAT
%
%   values = bin(x, y, xbin)
%
% IN
%
%   x       numeric array
%               values determine how y is binned
%   y       numeric array
%               values to bin. Must be the same size as x.
%   xbin    numeric array, monotonously increasing
%               bin edges (as for histc)
%
% OUT
%
%   values  cell array
%               Binned values.
%
% See also: binning_fast, bin_nd
%
% $Id: bin.m 8266 2013-03-05 18:03:58Z gerrit $


% convert to column vectors, if needed
x = vec2col(x);
y = vec2col(y);
%Z = [x y];

% initialise with (0x1) arrays of type y, so that all entries have the same
% type and size
values = repmat({zeros(0, 1, class(y))}, [length(xbin), 1]);

ignore = ~isfinite(x);
x(ignore) = [];
y(ignore) = [];
% if any(~isfinite(x))
%     error(['atmlab:' mfilename ':invalid'], ...
%         ['Found nonfinite values in data to be binned against. ' ...
%          'What can I do?']);
% end

if isempty(x)
    return % values already set, nothing to do
end

% check that all x are in range of bins.
% This guarantees the last bin to be empty.
if min(x) < min(xbin) || max(x) > max(xbin)
    error(['atmlab:' mfilename ':outofrange'], ...
        'x data (%g -- %g) out of range of x bins (%g -- %g)', ...
        min(x), max(x), min(xbin), max(xbin));
end

[x_sorted, x_sorted_i] = sort(x);
[~, binsorted] = histc(x_sorted, xbin);
boundaries = [0; find(diff(binsorted)); length(x)];

for i = 1:length(boundaries)-1
    lo = boundaries(i)+1;
    hi = boundaries(i+1);
    bin_i = binsorted(lo);
    values{bin_i} = y(x_sorted_i(lo:hi));
end

end
