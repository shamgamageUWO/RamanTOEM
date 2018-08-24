function out = optargs_struct(userin, defaults, varargin)

% optargs_struct  A help function to handle optional arguments in a struct
%
% This function provides a simply way to define default values for function
% inputs where this input consists of a structure. It takes two structures,
% one consisting of default values and one of user-provided values. It
% returns a structure containing the user values where provided and the
% default values otherwise.
%
% If for a given field, both the default and the user-input are a
% structure, optargs_struct recursively descends into substructures, where
% pairs of structures are passed on to optargs_struct.
%
% FORMAT
%
%   out = optargs_struct(userin, defaults[, recurse])
%
% IN
%
%   userin      structure   User provided optional settings
%   defaults    structure   Default values.
%
% OPTIONAL INPUT
%
%   recurse     bool        Recurse into substructures; defaults to true
%
% OUT
%
%   merged      structure   User's value where provided, default otherwise
%
% See also: <a href="matlab:help optargs">optargs</a>

% Author: Gerrit Holl
% $Id: optargs_struct.m 8941 2014-09-15 11:04:40Z olemke $

recurse = optargs(varargin, {true});

% If userin empty, out is simply set to default
if isempty(userin)
  out = defaults;
  return;
end
  
out = defaults;
fields_userin = fieldnames(userin);
for i = 1:length(fields_userin)
    f = fields_userin{i};
    % special case: input and default are struct, then recurse
    % as far as I'm aware, structures cannot contain themselves, so this
    % cannot lead to any infinite loop (no need for explicit recurse
    % counting)
    if recurse && isstruct(userin.(f)) && isfield(defaults, f)
        if isstruct(defaults.(f))
            out.(f) = optargs_struct(userin.(f), defaults.(f));
            continue
        end
    end
    out.(f) = userin.(f);
end

end
