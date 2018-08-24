function s = replace_aliases(s)

% replace_aliases String-replaces all aliases occuring in s
%
% For an input string s, substitutes all aliases with their respective
% value. The aliases are taken from <a href="matlab:open(which('alias'))">alias</a>

C = [fieldnames(alias) struct2cell(alias)].';
C = C(:);
s = strrep_multi(s, C{:});