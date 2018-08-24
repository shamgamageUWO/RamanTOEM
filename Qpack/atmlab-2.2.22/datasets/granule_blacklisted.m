function status = granule_blacklisted(sat, sensor, datevec)

% granule_blacklisted Check whether granule is blacklisted
%
% FORMAT
%
%   status = granule_blacklisted(sat, sensor, datevec)
%
% IN
%
%   sat
%   sensor (dataset)
%   datevec (see details below)
%
% OUT
%
%   status
%       <0  could not determine (probably no blacklist-file found)
%       0   not blacklisted
%       >0  blacklisted, probably not wise to use
%
% Compares 'datevec' against all those listed in the associated 'blacklist'
% file. If the blacklist file contains less columns than datevec, the
% superfluous columns in datevec are ignored. If the blacklist file
% contains less columns than datevec, an error is thrown.
%
% Note: currently (2011-10-10), the only return values are -1, 0 and 1.
% In the future, statuses may contain more information, e.g.
% the code may indicate why the granule is blacklisted or why it could not
% be determined.

% $Id: granule_blacklisted.m 7175 2011-10-10 09:06:45Z gerrit $

errid = 'atmlab:granule_blacklisted';

assert(isvector(datevec), errid, 'datevec must be a vector, it appears not to be');

status = -1;

try
    blfile = datasets_config('blacklist');
catch ME
    if strcmp(ME.identifier, 'atmlab:input:undefined')
        return
    else
        ME.rethrow();
    end
end

if isnan(blfile)
    return;
end

blfile = strrep(blfile, '$SAT', num2str(sat));
blfile = strrep(blfile, '$SENSOR', num2str(sensor));

if ~exist(blfile, 'file')
    return;
end

M = load(blfile);
ncol = size(M, 2);
dvsize = numel(datevec);

if dvsize < ncol
    error(errid, ['datevec must contain at least as many elements as ' ...
                  'blacklistfile has columns. Found %d datevec elements ' ...
                  'and %d blacklistfile columns.'], ...
          dvsize, ncol);
end

status = any(all(bsxfun(@(a, b) a==b, M, datevec(1:ncol)), 2));

end
