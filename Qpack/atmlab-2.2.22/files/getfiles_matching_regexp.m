function files = getfiles_matching_regexp(datadir,regularexp)
%% getfiles_matching_regexp
%
% Purpose: List all files that match regular expression in directory and
% its subdirectories
%
% USAGE: files = getfiles_matching_regexp('directory','regexp')
%
% IN: 
%     datadir   directory to look at   e.g. '.'
%     regexp    regular expression     e.g. '.m$e4' ($ signals the end of the filename)
%
%
%
% OUT: files    cell of matching file names
%
%
% created by Salomon Eliasson
% $Id$


assert(~isempty(dir(datadir)),['atmlab:' mfilename ':BadInput'],...
    'Directory: %s\nDoes not exist',datadir)

%replace tildas as this doesn't work with the system command
datadir = [strrep(datadir(1),'~',getenv('HOME')) datadir(2:end)];

% MAKE a list of files using UNIX find (regular files only)
command = sprintf('find ''%s'' -type f',datadir);
files = exec_system_cmd(command,gmtlab('VERBOSITY'));

% use \n for one file per cell element from string output
files = regexp(files{1},'\n','split');

% Apply the regular expression rule to filter out unwanted files
files = files(~cellfun('isempty',regexp(files,regularexp)));