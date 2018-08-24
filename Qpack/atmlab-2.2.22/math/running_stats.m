function stat_vectors = running_stats(x, y, binsize, stat_handles)
% running_stats Calculate running statistics
%
% FORMAT
%
%   stats = running_stat(x, y, binsize, stat_handles)
%
% IN
%
%   x [vector]
%       independent quantity, must be constantly spaced
%
%   y [vector]
%       quantity to calculate statistics for
%
%   winsize [scalar]
%       size of window.
%       if positive, interpreted as same unit as x
%       if negative but >-1, interpreted as fraction (negative is just a
%       trick here to pass a flag), then extra stat_handle appended showing
%       number of samples used for each statistic
%       
%
%   stat_handles [cell array of function handles]
%       functions to apply to each running window
%       Note that each function MUST accept a dimension as its second
%       argument, such as median(X, 2)!
%
% OUT
%
%   stat_vectors [cell array of vectors]
%       Output of all handles in stat_handles for each running window.
%       Padded with nans at begin and end where sliding stats are
%       undefined.
%
% See also: smooth, medfilt1, movingstd, filter
%
% Note: smooth is in the curve-fitting toolbox, medfilt1 is in the signal
% processing toolbox.
% * in the curve fitting toolbox, otherwise see
%   http://stackoverflow.com/a/1516168/974555
% ^ from File Exchange

% $Id: running_stats.m 7901 2012-09-27 15:38:16Z gerrit $

% convert binsize [x-unit] to binsize [n-index]

% some input checks

rqre_same_size(x, y);

% verify that x-unit is constantly spaced
% error otherwise

df = diff(x);
spacing_xunit = unique(df);
if length(spacing_xunit)>1
    error(['atmlab:' mfilename ':notunique'], ...
        ['Error in calculation of running statistics: ' ...
        'spacing in independent quantity not constant']);
end


if binsize > 0
    stat_vectors = running_stats_linear(x, y, binsize, stat_handles, spacing_xunit);
elseif binsize < 0 && binsize > -1
    % fractional binsize, e.g. 0.01 is all within 1%
    stat_vectors = running_stats_fractional(x, y, binsize, stat_handles, spacing_xunit);
else
    error(['atmlab:' mfilename], ...
        'Binsize must be >0 or <0 & >-1. Found: %.3f', binsize);
end

end

function stat_vectors = running_stats_linear(x, y, binsize_xunit, stat_handles, spacing_xunit)
    

N = round(binsize_xunit/spacing_xunit);
L = length(x);

% pre-allocate
stat_vectors = preallocate_stat_vectors(x, stat_handles);

% Yes: idea from
% http://www.mathworks.com/matlabcentral/fileexchange/29029-summarizes-data-using-a-sliding-window-without-loops/content/movingstat.m

% re-arrange data so there are columns for each window (needs memory)
data_arranged = y(repmat(0:N-1,L-N+1,1)+cumsum(ones(L-N+1,N)));
if iseven(N)
    ran = (N/2):(L-N/2);
else
    ran = (ceil(N/2)):(L-floor(N/2));
end

% TODO: do in chunks similar to medfilt1
for j = 1:length(stat_handles)
    stat_vectors{j}(ran) = stat_handles{j}(data_arranged, 2);
end

% this is the slow version:
% for i = (binsize_n/2+1):(length(x)-binsize_n/2)
%     slice = (i-(binsize_n/2)):(i+(binsize_n/2));
%     segment = y(slice);
%     for j = 1:length(stat_handles)
%         stat_vectors{j}(i) = stat_handles{j}(segment);
%     end
% end


end

function stat_vectors = running_stats_fractional(x, y, binsize_frac, stat_handles, spacing_xunit)

L = length(x);

% fraction is passed negative
binsize_frac = -binsize_frac;

% always tell the length
stat_handles = [stat_handles {@size}];

% pre-allocate
stat_vectors = preallocate_stat_vectors(x, stat_handles);

% get lower and upper edge of segments for each x

lo = x .* (1 - binsize_frac/2);
hi = x .* (1 + binsize_frac/2);

% translate this to indices

N = ceil(2 * (x * binsize_frac) / spacing_xunit);
fst = find(N > 100, 1, 'first'); % arbitrary start

% try brute-force first (POITROAE)
for i = fst:length(y)
    % search for indices corresponding to lo(i) and hi(i)
    slice = floor(i-(N(i)/2)):ceil(i+(N(i)/2));
    if (slice(1) < 1) || (slice(end) > L)
        continue
    end
    segment = y(slice);
    
    for j = 1:length(stat_handles)
        stat_vectors{j}(i) = stat_handles{j}(segment, 1);
    end
    
    if mod(i, 100000)==0
        logtext(atmlab('OUT'), '%d/%d done\n', i, length(y));
    end
end

end

function stat_vectors = preallocate_stat_vectors(x, stat_handles)

stat_vectors = cell(size(stat_handles));
for i = 1:length(stat_handles)
    stat_vectors{i} = nan(size(x));
end

end
