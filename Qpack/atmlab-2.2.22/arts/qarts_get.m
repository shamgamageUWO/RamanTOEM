% QARTS_GET   Resolves Qarts variable
%
%    This function handles cases where a variable either is given directly,
%    or if it shall be loaded from a XML file.
%
%    A file is tried to be loaded if *a* is a string. Otherwise b is just
%    set to a.
%
%    Use *qarts_get_gformat* for variables of gformat type.
%
% FORMAT   b = qarts_get( a )
%        
% OUT   b          Variable value.
% IN    a          Variable value or file name.

% 2004-07-10   Created by Patrick Eriksson.


function b = qarts_get( a )

if ischar( a )
  b = xmlLoad( a );
else
  b = a;
end