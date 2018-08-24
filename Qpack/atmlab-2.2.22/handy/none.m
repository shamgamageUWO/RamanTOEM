function B = none(X, dim)

% NONE True if all elements are zero.
%
% implemented as all(~X, dim)

% $Id$

if ~exist('dim', 'var')
    dim = [];
end

narginchk(1, 2);

switch nargin
    case 1
        B = all(~X);
    case 2
        B = all(~X, dim);
end

end
