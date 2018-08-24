function M = combine_rows(A, B, varargin)

% combine_rows Return combinations of rows
%
% Returns every combination of rows for all arguments (matrices)
%
% FORMAT
%
%   M = combine_rows(A, B, C, ...) % any number of arguments
%
% IN
%
%   ... matrices
%
% OUT
%
%   M   matrix with each row a unique combination of the rows of A, B, ...
%
% $Id: combine_rows.m 6555 2010-10-08 14:48:16Z gerrit $

switch nargin
    case 0
        M = [];
    case 1
        M = A;
    case 2
        % pre-allocate
        M = nan(size(A, 1)*size(B, 1), size(A, 2)+size(B, 2));
        
        c = 1;
        for i = 1:size(A, 1)
            for j = 1:size(B, 1)
                M(c, 1:size(A, 2)) = A(i, :);
                M(c, (1+size(A, 2)):end) = B(j, :);
                c = c + 1;
            end
        end
    otherwise % >3; call self where A+B is combined with the rest first
        M = combine_rows(...
            combine_rows(A, B), ...
            combine_rows(varargin{:}));
end