function limmat = limstruct2limmat(limits, name_struct)

% limstruct2limmat Convert limits-struct to limits-matrix
%
% This function converts a limits-structure (as input to the user to, for
% example, collocation_read) to a limits-matrix (as wanted by, for example,
% collocation_restrain.
%
% FORMAT
%
%   limmat = limstruct2limmat(limits, name_struct)
%
% IN
%
%   limits      structure       Each field is a string with the name of a
%                               column. The values are 2x1-arrays
%                               describing the range of values the user
%                               wants to restrain the data to.
%   name_struct structure       Describes the mapping of column names to
%                               column numbers.
%
% OUT
%
%   limmat      Nx3 matrix      First row column numbers; 2nd and 3rd row
%                               the ranges as mentioned.
%
% See also: collocation_restrain
% 
% $Id: limstruct2limmat.m 7619 2012-05-24 15:22:54Z gerrit $

if isempty(fieldnames(limits))
    limmat = zeros(0, 3);
    return
end

fields = fieldnames(limits);
C = cell(1, length(fields));
for i = 1:length(fields)
    c = fields{i};
    if iscell(limits.(c))
        C{i} = [name_struct.(c)(limits.(c){1})' repmat(limits.(c){2}, [length(limits.(c){1}) 1])];
    else
        C{i} = [name_struct.(c)' repmat(limits.(c), [size(name_struct.(c), 2) 1])];
    end
end
% C = cellfun(@(c) ...
%     [name_struct.(c)' ...
%     repmat(limits.(c), [size(name_struct.(c), 2) 1])], ...
%     fieldnames(limits), 'UniformOutput', false);
limmat = vertcat(C{:});
end
