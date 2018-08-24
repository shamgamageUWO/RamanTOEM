function rqre_subset(small, large)

% For two cell arrays, require that one is subset of other
%
% FORMAT
%
%   rqre_subset(small, large)
%
% IN
%
%   small       array that should be a subset
%   large       array that should be a superset
%
% No output arguments, but throws an error if it fails.

% $Id: rqre_subset.m 8377 2013-04-25 16:00:02Z gerrit $

errId = ['atmlab:' mfilename ':notasubset'];

for elem = small
    if ~ismember(elem{1}, large)
        error(errId, ...
            '%s must be subset of %s but is not', ...
            inputname(small), inputname(large));
    end
end

end
