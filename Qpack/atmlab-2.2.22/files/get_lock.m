function fullpath = get_lock(d, f, varargin)

% getlock   Acquire lock
%
% This function creates an empty file and tries to move it to a lockfile
% destination.  If the lockfile destination already exists, it will wait
% until it does not.  However, it will not wait longer than a timeout that
% the user may specify as a 3rd option.
%
% When done, just remove the lockfile.  I mean, really!
%
% IN
%
%   d         directory where lockfile shall be created
%   f         name of the lockfile (not including directory)
%   timeout   maximum length in second to wait.  Defaults to 120 seconds.
%
% OUT
%
%   the full path to the lockfile

% $Id: get_lock.m 8516 2013-06-26 21:33:48Z gerrit $

timeout = optargs(varargin, {120});

t = tempname(d);
fp = fopen(t, 'w');
fclose(fp);
fullpath = fullfile(d, f);

interval = 0.1;
t1 = tic();
success = false;
logtext(atmlab('OUT'), 'Trying to create lockfile at %s\n', fullpath);
while toc(t1) < timeout
    exec_system_cmd(sprintf('mv -n %s %s', ...
        t, fullpath));
    % if original still exists, then mv -n (NOCLOBBER) failed
    if exist(t, 'file')
        pause(interval);
        if mod(toc(t1), 5) < 0.2
            logtext(atmlab('OUT'), 'Waiting for lockfile after %.3f seconds\n', toc(t1));
        end
    else
        logtext(atmlab('OUT'), 'Succesfully created lockfile\n');
        success = true;
        break
    end
end

if ~success
    error(['atmlab:' mfilename ':nolock'], ...
        'No lock after waiting for %d seconds', timeout);
end

end
