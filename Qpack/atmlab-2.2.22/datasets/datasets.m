function SS = datasets(varargin)

% list or add dataset
%
% Returns a magic structure with all known datasets.
%
% When called with an argument, adds a dataset. Warning! The constructor of
% SatDataset takes care of the 'registration', and there should never be a
% need to call this function with any argument directly.
%
% There's also so
%
% When called with 2 and 1st argument is 'delete', deletes 2nd entry.

% $Id: datasets.m 8354 2013-04-18 22:15:37Z gerrit $

persistent S

if isempty(S)
    S = struct();
end

narginchk(0, 2);

switch nargin
    case 2
        
        if (strcmp(varargin{1}, 'delete'))
            S = rmfield(S, varargin{2}.name);
        else
            error(['atmlab:' mfilename ':invalid'], ...
                'Invalid call sig. See help text.');
        end
        
    case 1
        
            if isequal(varargin{1}, '*')
                SS = S;
                return
            end
            if isfield(S, varargin{1}.name)
                if S.(varargin{1}.name) == varargin{1}
                    warning(['atmlab:' mfilename], ...
                        'Dataset with name %s was already defined, equally', ...
                        varargin{1}.name);
                else
                    error(['atmlab:' mfilename], ...
                        'Dataset with name %s already exists and is different', varargin{1}.name);
                end
            end
            if varargin{1}.visible
                S.(varargin{1}.name) = varargin{1};
            end
        
    case 0
        
        SS = dsmagic();
        update_dynamic_props(SS);
        
end

%SS = S;

end
