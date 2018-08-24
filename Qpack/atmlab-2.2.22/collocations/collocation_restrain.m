function rows = collocation_restrain(data, varargin)

% collocation_restrain Find rows fulfilling restrictions
%
% Find row numbers were certain limitations in the data are met.
%
% IN
%
%   data    matrix      As produced by collocation_read
%   ranges  Nx3 matrix  Matrix containing rows [colno min max], where data
%                       rows from the data are selected if
%                       min <= data(row, col) <= max.
%                       Defaults to [] (do nothing)
%   filters cell array  FIXME DOC
%
% OUT
%
%   rows    logical     Rows where limitations are met
%
% See also: limstruct2limmat
%
% $Id$

[ranges, filters] = optargs(varargin, {[], {}});

if isempty(ranges)
    rows = true(size(data, 1), 1);
else
    rightrange = all(data(:, ranges(:, 1)) >= repmat(ranges(:, 2)', [size(data, 1) 1]), 2) & ...
        all(data(:, ranges(:, 1)) <= repmat(ranges(:, 3)', [size(data, 1) 1]), 2);
    
    rows = rightrange;
    logtext(atmlab('OUT'), 'Selecting ranges: %d -> %d\n', ...
        size(data, 1), sum(rows));
end

if ~any(rows)
    logtext(atmlab('OUT'), 'No more collocations, nothing to do\n');
    return
end
    
for k = 1:length(filters)
    % make a cell array of column vectors so that I can pass a
    % variable number of arguments to the filter
    filter = filters{k}{1};
    args = cellfun(@(v) data(:, v), ...
        filters{k}{2}, ...
        'UniformOutput', false);
    if length(filters{k}) > 2
        addargs = filters{k}{3};
    else
        addargs = {};
    end
    try
        lim = filter(args{:}, addargs{:});
    catch ME
        switch ME.identifier
            case 'atmlab:granule_first_line'
                logtext(atmlab('ERR'), ...
                    'WARNING! Could not filter %s! ERROR ''%s''!\n', ...
                    func2str(filter), ME.message);
                continue;
            otherwise
                ME.rethrow();
        end
    end
        
    logtext(atmlab('OUT'), ...
        'filter %s: %d -> %d collocations\n', func2str(filter), ...
        sum(rows), sum(rows&lim));
    rows = rows&lim;
end

end
