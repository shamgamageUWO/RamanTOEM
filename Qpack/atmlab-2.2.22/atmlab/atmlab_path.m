% ATMLAB_PATH   Returns path to Atmlab's top folder
%
% FORMAT   p = atmlab_path
%        
% OUT   p   String with path.

% 2011-04-29   Created by Patrick Eriksson.


function p = atmlab_path

p = fileparts( fileparts( which( 'atmlab_init' ) ) );
