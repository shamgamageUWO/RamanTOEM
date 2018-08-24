function y = par(x, varargin)
% PAR function equivalent of parenthesis
%
% Circumvent Matlabs syntactic limitation on indexing directly on the
% result of an expression.  If an expression ends in round or curly braces,
% such as after a function call, Matlab forces you to store the result
% in a variable (or use `subsref` ugliness) to access it.  This may be
% painful.  So where you would want to write:
%
%   i = magic(3)(1, 2);
%
% and you would previously write:
%
%   M = magic(3);
%   i = M(1, 2);
%
% this function allows you to write instead:
%
%   i = par(magic(3), 1, 2);
%
% It works for either arrays or function calls, so it allows for
% arbitrarily deep function chaining if you call p recursively.
% Ranges work, e.g. p(magic(3), 1:2, 2).  Full ranges appear (a lone ':')
% appear to work under particular circumstances, but always work when you
% pass in ':' as a string.  As far as I know, there is no equivalent of
% 'end'.
%
% FORMAT
%
%   y = par(x, a, b, ...)
%
% IN
%
%   x           matrix to be indexed
%   a, b, ...   index per dimension
%
% OUT
%
%   y           result of indexing operation x(a, b, ...)
%
% By Gerrit Holl, inspired by http://is.gd/b3MkRf
%
% See also: cur, getfield

% $Id: par.m 8777 2014-02-12 12:45:13Z gerrit $
y = x(varargin{:});
end
