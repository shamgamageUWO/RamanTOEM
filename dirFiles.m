function files = dirFiles(directory)
% files = dirFiles(directory)
%
% Return list of files in specified directory


dircontents=dir(directory);
files={dircontents.name};

% Remove '.' and '..'
if ~isempty(files) && strcmp(files(1),'.')
    files = files(2:end);
end
if ~isempty(files) && strcmp(files(1),'..')
    files = files(2:end);
end
