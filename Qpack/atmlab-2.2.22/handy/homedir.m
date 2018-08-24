% HOMEDIR   Returns users home directory
%
% FORMAT   d = homedir
%        
% OUT   d   String with path of home directory.

% 2009-05-24   Created by Patrick Eriksson.


function d = homedir


d = getenv('HOME');

if isempty(d)
  error('atmlab:homedir', 'No home-directory defined');
end
