function logtext(fid, text, varargin)

% logtext Log text to fid along with callers name+lineno
%
% logtext is a logging function that writes text to the indicated file
% descriptor along with the filename and the line number of the caller.
% If writing to stdout or stderr and to the java desktop, it will make the
% filename+line number clickable. If atmlab('VERBOSITY') is zero, it will
% not write anything at all.
%
% FORMAT logtext(fid, text, ...)
%
% IN
%
%   fid  number  File descriptor to write to
%   text string  Text to write
%   ...  ...     All subsequent arguments are passed to fprintf
%
% $Id$

% TODO:
%   - should this use atmlab('VERBOSITY') or atmlab('DEBUG')?
%   - when stdout or stderr, try to check if output is matlab java terminal or
%   just a console. Is this possible?

if ~atmlab('VERBOSITY')
    return
end

haspar = ~isempty(ver('distcomp')) && ~isempty(getCurrentTask());

ST = dbstack;
if length(ST) < 2
    lineno = -1;
    name = '(none)';
else
    lineno = ST(2).line;
    f = ST(2).file;
    name = ST(2).name;
end

% ugliness: try to get class/self.name in caller
try
    cl = evalin('caller', 'class(self)');
    nm = evalin('caller', 'self.name');
    showcls = true;
catch ME % never mind
    showcls = false;
end   

fprintf(fid, '%s:', datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF'));
if fid<3 && usejava('desktop') && ~strcmp(name(1), '@') && ~strcmp(name, '(none)') % assume stdout/stderr
    if showcls
        fprintf(fid, '<a href="matlab:opentoline(''%s'', %d, 1)">%s:%d:%s:%s</a>:', ...
            which(f), lineno, name, lineno, cl, nm);
    else
        fprintf(fid, '<a href="matlab:opentoline(''%s'', %d, 1)">%s:%d</a>:', ...
            which(f), lineno, name, lineno);
    end
elseif haspar % if really par, usejava-desktop is false anyway
    t = getCurrentTask();
    fprintf(fid, '%s:%d:%d:', name, lineno, t.ID);
else
    fprintf(fid, '%s:%d:', name, lineno);
end
fprintf(fid, text, varargin{:});
end
