function new = sanitise(old, varargin)

% sanitise If you must pass something to system, do this first
%
% Often, calls to system (or exec_system_cmd) can be avoided. Avoid them if
% you can. If you must use system, and you pass on input coming from the
% user, pass your string through this function first. It will sanitise the
% input, replacing any undesired characters.
%
% Dangerous characters are: :=, ()*/<>!?%;
%
% IN
%
%   old     string to be sanitised
%   rep     character to replace with; defaults to _
%   action  relates to messages:
%           1 = print warning message if string changed (default)
%           2 = error if string changed
%           anything else: silently replace names
%   danger  dangerous characters; defaults to ':=, ()*<>!?%;'
%
% OUT
%
%   new     new sanitised string
%
% See also: exec_system_cmd

% $Id: sanitise.m 8744 2013-11-27 07:14:23Z seliasson $

WARN = 1;
ERROR = 2;

[repl, action, danger] = optargs(varargin, {'_', WARN, ':=, ()*<>!?%;&$'});

new = regexprep(old,['[' danger ']'],repl);

if ~strcmp(new, old)
    switch action
        case WARN
            logtext(atmlab('ERR'), ...
                'Warning: string changed from %s to %s.\n', ...
                old, new);
        case ERROR
            error(['atmlab:' mfilename ':wrongname'], ...
                ['Encountered dangerous string %s, should not be used with ' ...
                 'exec_system_cmd/system or similar! Maybe use %s instead?'], ...
                 old, new);
    end
end
end
