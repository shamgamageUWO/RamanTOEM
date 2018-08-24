% ARTS_VERSION   Reports the version of arts
%
%    The version is reported as a short string. Complete information can be
%    printed on the screen.
%
% FORMAT   s = arts_version( long_on_screen )
%        
% OUT   s              A string describing the arts version, e.g. 'arts-2.1.3'
% OPT   long_on_screen Flag to print detailed information.

% 2012-10-22   Created by Patrick Eriksson.

function s = arts_version( long_on_screen )

[notok,s] = arts( '-v', [], true );

if nargin & long_on_screen
  disp(s)
end

i1 = min( findstr( s, 'arts-' ) );
i2 = min( find( s(i1:end) == ' ' ) );

s = s( i1+[0:i2-2] );
  