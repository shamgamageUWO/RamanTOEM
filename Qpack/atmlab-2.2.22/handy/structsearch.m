function no = structsearch(c, name)

% structsearch Search for field in each of the substructures
%
% If c is a structure whose fields contain structures (such as
% colloc_config('cols_cpr_mhs'), then structsearch(c, name)
% returns the value of the field of the first substructure that contains
% field 'name'.
%
% FORMAT
%
%     no = structsearch(c, name)
%
% IN
%
%   c       structure   structure to search in
%   name    string      fieldname to search for
%
% OUT
%
%   no      number      value of c.(foo).name where foo can be any
%
% $Id$

nm = fieldnames(c);
has = structfun(@(v) isfield(v, name), c);
if ~any(has)
    error('atmlab:structsearch:invalidfield', 'no such field: %s', name);
end
no = c.(nm{find(has, 1, 'first')}).(name);
