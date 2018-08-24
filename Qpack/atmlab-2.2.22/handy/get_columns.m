function [y, y_cols] = get_columns(dat, cols, fields)
% get columns from matrix based on structure and names
%
% Select "named" columns from a matrix.  For a pair consisting of a matrix
% and a structure describing what the columns represent (such as returned
% by <a href="matlab:help
% CollocatedDataset/read">CollocatedDataset.road</a>), return a
% sub-selection of columns with an associated new describing structure.
%
% FORMAT
%
%   [y, y_cols] = get_columns(data, cols_struct, fieldnames)
%
% IN
%
%   data        Matrix containing data
%   cols        Structure describing what's in the columns
%   fieldnames:
%           either:
%       - Cell array of strings with columns to retain
%       - Structure with fields and sub-sel of columns to retain; -1 for
%       'all'
%
% OUT
%
%   y           New matrix, subset of 'data'
%   y_cols      Structure describing columns in 'y'
%
% $Id$

i = 1;    
y_cols = struct();
if iscell(fields)
    cls = cellfun(@(X) cols.(X), fields, 'UniformOutput', false);
    for fni = 1:length(fields)
        fn = fields{fni};
        y_cols.(fn) = i:(i+length(cols.(fn))-1);
        i = i + length(cols.(fn));
    end
elseif isstruct(fields)
    fns = fieldnames(fields);
    cls = cell(length(fns), 1);
    for fni = 1:length(fns)
        fn = fns{fni};
        if fields.(fn) == -1
            cls{i} = cols.(fn);  
        else
            cls{i} = par(cols.(fn), fields.(fn));
        end
        y_cols.(fn) = i:(i+length(cls{i})-1);
        i = i + length(cls{i});
    end
else
    error(['atmlab:' mfilename ':invalid'], ...
        'Expected cell or struct, got %s, read help please', ...
        class(fields));
end
y = dat(:, horzcat(cls{:}));
end
