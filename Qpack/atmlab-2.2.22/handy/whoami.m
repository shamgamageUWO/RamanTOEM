% WHOAMI   Returns user name
%
% FORMAT   user = whoami
%        
% OUT   user   String with user name.

% 2005-02-15   Created by Patrick Eriksson.


function user = whoami


[s,user] = system( 'whoami' );

if s
  error( 'System call to establish user name failed.' );
end


%= Remove domain name that can be included on Windows machines
%
if ispc
  i = find( user == '\' )
  if ~isempty(i)
    user = user((i+1):end);
  end
end


%- Remove any newline character
%
if user(end) == sprintf('\n')
  user = user(1:end-1);
end
