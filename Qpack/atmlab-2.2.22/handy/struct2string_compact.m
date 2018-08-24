function descr = struct2string_compact(S, varargin)

% struct2string_compact
%
% Return a compact representation of a struct. Whole numbers are represented
% as such, any others are given N digits of precision. This can be useful
% to add to a filename for storing a figure or to use in a plot title or legend.
%
% EXAMPLE
%
% >> disp(struct2string_compact(struct('A', 1, 'B', 2, 'C', pi), 4));
% A=1,B=2,C=3.1416
%
% FORMAT
%
%   descr = struct2string_compact(S, n)
%
% IN
%
%   S   scalar structure, all values should be scalar numbers
%   n   number of digits of precision. Defaults to 3.
%
% OUT
%
%   descr   compact string describing the structure
%
% $Id: struct2string_compact.m 7445 2012-03-26 10:15:27Z seliasson $

n = optargs(varargin, {3});

if isempty(fieldnames(S))
    descr = '';
    return;
end
%descr = cellfun(@(v) sprintf('%s=%.*f,', v, n*~iswhole(S.(v)), S.(v)), fieldnames(S), 'UniformOutput', false);
descr = cellfun(@(v) sprintf('%s=%s;', v, elem2str(S.(v), n)), fieldnames(S), 'UniformOutput', false);
descr = strcat(descr{:});
descr = descr(1:end-1); % take off final comma
end
function s = elem2str(v, n)
% elem2str Convert single element to string compactly
if isempty(v)
    s = '';
    return
elseif isboolean(v) || istensor0(v) % isscalar is true for cell array with 1 elem
    s = sprintf('%.*f', n*~(iswhole(v)||isboolean(v)), v);
elseif iscell(v)
    s = cellfun(@(u) [elem2str(u, n) ','], v, 'UniformOutput', false);
elseif isscalar(v)
    s = char(v);
elseif isvector(v)
    s = arrayfun(@(u) [elem2str(u, n) '-'], v, 'UniformOutput', false);
else
    error('atmlab:struct2string_compact:elem2str', ...
        'Unable to provide compact string representation of %s', ...
        evalc('disp(v)'));
end
if ~isscalar(v)
    s = strcat(s{:});
    s = s(1:end-1);
end
end
