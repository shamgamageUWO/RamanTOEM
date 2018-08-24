function f = safegetfield(S, field, alt)

% SAFEGETFIELD get field from structure, otherwise return alt
%
% safegetfield(S, field, alt) is short for:
%
% if isfield(S, field)
%   f = S.(field);
% else
%   f = alt;
% end

% $Id: safegetfield.m 8377 2013-04-25 16:00:02Z gerrit $

if isfield(S, field)
  f = S.(field);
else
  f = alt;
end

end
