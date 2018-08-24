% NVERSION   Matlab version as a number.
%
%    The function returns the two most important version levels as a numer.
%    For example, revision 13 (6.5.0.180913a) is returned as 6.05, and
%    version 7.10.0.499 as 7.10.
%
% FORMAT   v = nversion
%        
% OUT   v   Version number.

% 2002-12-14   Created by Patrick Eriksson.


function v = nversion


s = version;

l = sscanf( s, '%d.%d' );

v = l(1) + l(2)/1e2;
