function y = cur(x, varargin)
% CUR function equivalent of curly braces
%
% For a discussion on the thoughts behind this function, see <a
% href="matlab:help par">par</a>.
% CUR is the equivalent but with curly braces.
%
% FORMAT
%
%   y = c(func(), a, b, ...)
%
% IN
%
%   func()      expression to be indexed or called
%   a, b, ...   index per dimension
%
% OUT
%
%   y           result of indexing operation x{a, b, ...}
%
% By Gerrit Holl, inspired by http://is.gd/b3MkRf
%
% See also: par, getfield

% $Id: cur.m 8777 2014-02-12 12:45:13Z gerrit $
y = x{varargin{:}};
end
