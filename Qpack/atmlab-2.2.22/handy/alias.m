function A = alias(varargin)

% alias Define and use aliases
%
% Define and use aliases.
%
% FORMAT
%
%   A = alias % get struct with all defined aliases
%
%       or
%
%   A = alias(foo) % get alias
%
%       or
%
%   A = alias(foo, bar) % set alias
%
% IN
%
%   name    string
%   value   (optional)
%
% OUT
%
%   A
%
% $Id: alias.m 6543 2010-10-07 15:57:41Z gerrit $


persistent S

if ~isstruct(S)
    S = struct;
end

switch nargin
    case 0
        A = S;
    case 1
        A = S.(varargin{1});
    case 2
        S.(varargin{1}) = varargin{2};
    otherwise
        error('atmlab:alias', 'incorrect number of arguments: %d', ...
            nargin);
end
