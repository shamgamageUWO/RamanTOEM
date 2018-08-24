function [out,retvals] = exec_system_cmd(cmd, varargin)
%
% EXEC_SYSTEM_CMD Executes one or more system commands.
%
% Executes one or more system commands.
%
% You are strongly recommended to pass each of them through sanitise first,
% as to avoid potentially destroying the universe. The safest alternative
% is usually not to use exec_system_cmd if it can be avoided (e.g. for
% deleting files).
%
% If any command returns an error code not equal to 0, this function will
% throw an error with the error identifier 'atmlab:exec_system_cmd:shell'.
%
% IN
%
%   cmd: string or cell array of strings
%
%       Command to pass to the shell. If this is a cell array of strings,
%       each string will be apssed to the shell in turn.
%
%
%   verbose: bool, optional. Defaults to false
%
%       If true, each command with be printed to the screen before it is
%       executed.
%
%   continueOnError: bool, optional. Defaults to false
%
%       
%
% OUT
%
%   out: cell array of strings
%
%       For each command passed as input, the output (stdout+stderr)
%       is collected in a string. Those strings are then collected to
%       a cell array of strings. If only one input command was given,
%       this is a cell array with one string.
%
%    retvals: boolean return value if second optional input 'report' is given
%       
% USAGE
%
%   [out,ret] = exec_system_cmd(cmd, varargin)
%
% See also: sanitise
%
% updated by: Salomon, Gerrit
% Author: Oliver Lemke

if ~iscell(cmd), cmd = {cmd}; end

cmd = cmd(:);

[verbose,continueOnError] = optargs(varargin, {false,false});

v = atmlab('VERBOSITY');  
atmlab('VERBOSITY',verbose);
vObj=onCleanup(@()(atmlab('VERBOSITY',v)));

errID = 'atmlab:exec_system_cmd:shell';
out = cell(1,length(cmd)); i = 1; % keep track of output messages
retvals = zeros(1,length(cmd)); % keep track of return messages (if report is input)
for x = cmd'
    fullcmd = char(x);
    
    if verbose>0, logtext(atmlab('OUT'),'%s\n',fullcmd); end
    
    [ret,out{i}] = system(fullcmd);
    
    if verbose>0 && ~isempty(out{i})
        logtext(atmlab('OUT'),'%s\n',out{i}(1:end-1))
    end
    
    if (ret ~= 0)
        if any(~cellfun('isempty',regexp(out{i},...
                {'symbol lookup error',...
                'dyld: Symbol not found',...
                'library version mismatched'},'start')))
            error(errID,[ [ out{i} '\n'],...
                'A shared library conflict occured while running the command.\n'...
                'This may be due to the fact that MATLAB comes with its own versions of some system libraries\n',...
                'To use the system libraries do:\n',...
                'If you are on a MAC, try setenv(''DYLD_LIBRARY_PATH'','''')\n',...
                'If you are using LINUX, try setenv(''LD_LIBRARY_PATH'','''')\n',...
                'If this solves the problem, add the corresponding line to your startup file'])
        else
            if continueOnError, retvals(i) = ret;
            else
                error(errID,'Command ''%s'' returned error %d: "%s"', fullcmd, ret, out{i})
            end
        end
    end
    i = i+1;
end

end
