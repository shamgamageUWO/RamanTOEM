function values = bin_nd(binners, bins, varargin)
% BIN_ND Bin data in arbitrary number of dimensions
%
% Generic function to bin data in any number of dimensions.
% For a vector of 2726996 elements, takes about 3 seconds (binning_fast
% takes more than 60 seconds).
% Note: still in beta, need to check corner cases. Not ready for production
% use. Results slightly different from binning_fast, probably due to
% boundary conditions and such.
% Note: (so far) only returns indices, does not actually bin data yet.
%
% FORMAT
%
%   indices = bin_nd({lat, lon, ...}, {bins_lat, bins_lon, ...})
%
% IN
%
%   - cell with axes that data is binned at, for example lat, lon.
%   - cell with bins for each of those
%
% OUT
%
%   n-dimensional cell array with binned indices
%
% EXAMPLE
%
%   indces = bin_nd({lats, lons}, {lat_bins, lon_bins})
%
% See also: bin, binning_fast
%
% Gerrit Holl, March 2013

% $Id: bin_nd.m 8259 2013-03-04 19:07:59Z gerrit $

errid = ['atmlab:' mfilename];

if length(binners) ~= length(bins)
    error(errid, 'Inconsistent lengths: %d binners, %s bins', ...
          length(binners), length(bins));
end


data = optargs(varargin, {vec2col(uint32(1:length(binners{1})))});
nd = length(binners);

if nd > 1
    innerbinned = bin(binners{end}, data, bins{end});
    values = cell(length(innerbinned), 1);
    for i = 1:length(innerbinned)
        binners_selection = cellfun(@(X)(X(innerbinned{i})), binners(1:end-1), 'UniformOutput', false);
        values{i} = bin_nd(binners_selection, bins(1:end-1), innerbinned{i});
    end
else
    values = bin(binners{1}, data, bins{1});
end

if length(bins) > 1
    values = reshape(horzcat(values{:}), cellfun(@length, bins));
end
end
