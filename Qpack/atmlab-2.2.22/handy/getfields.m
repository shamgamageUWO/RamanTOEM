function S = getfields(S, varargin)
%% getfields Get multiple fields from structure
%
% This is like getfield, but accepts multiple fieldnames.
%
% IN
%
%   S       structure
%   fields  Fields to be returned
%
% OUT
%
%   S       new structure

% $Id$

if isempty(varargin)
    S = struct();
    return
end

if iscell(varargin{1})
    fields = varargin{1};
else
    fields = varargin;
end

S = cell2struct(cellfun(@(field) S.(field), vec2row(fields), 'UniformOutput', false), ...
                vec2row(fields), ...
                2);

end
