% ATMLAB_VERSION   Atmlab version number. 
%
%    Version number taken from the ChangeLog file.
%
%    If there is no output argument, a message is printed to the screen.
%
%    If there is a single output argument, a string is returned.
%
%    If there are three outputs, [major, minor, micro] are returned.
%
% FORMAT   s = atmlab_version
%        
% OUT (1 output argument mode)
%
%   s   Version string
%
% OUT (3 output arguments mode)
%
%   major, minor, micro   Version numbers 

% 2002-12-09   Created by Patrick Eriksson.

function varargout = atmlab_version

% Version information now taken from ChangeLog   

toppath = fileparts( fileparts( which( 'atmlab_version' ) ) );

changelog = fullfile( toppath, 'ChangeLog' );

fid = fopen( changelog, 'r' );

if fid < 0
  s = 'atmlab-?.? (could not locate ChangeLog file)';
  return
end

s = '';
%
while isempty( findstr( s, 'atmlab-' ) )
  s = fgetl( fid );
  if ~ischar(s)
    error( 'Could not find any ''atmlab-'' in ChangeLog' );
  end
end
%
fclose(fid);


s = s( findstr(s,'atmlab-') : end );

ind = find( s == '-' );

s(ind(2:end)) = '.';

if nargout==0
  
  fprintf('This is %s\n',s);
  clear s

elseif nargout == 1
    varargout{1} = s;
elseif nargout == 3
    varargout = cellfun(@str2num, strsplit(s(8:end), '.'), 'UniformOutput', false);
end

end
