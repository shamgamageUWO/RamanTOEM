function s_new = strrep_multi(s_old, varargin)

% strrep_multi Perform multiple string replacement
%
% For an input string s, perform many string replacements at once
%
% FORMAT
%
%   s_new = strrep_multi(s_old, S)
%
% IN
%
%   s_old   string      initial string
%   s1      string      to be replaced
%   s2      string      to replace with
%   s3      ...         etc.
%
% OUT
%
%   s_new   string      final string
%
% $Id: strrep_multi.m 6543 2010-10-07 15:57:41Z gerrit $

assert(mod(nargin, 2)==1, ...
    'atmlab:strrep_multi', ...
    'Number of input arguments must be odd');
s_new = s_old;
for i = 2:2:nargin
    s_new = strrep(s_new, varargin{i-1}, varargin{i});
end