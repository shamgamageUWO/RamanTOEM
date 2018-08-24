% QARTS_GET_GFORMAT   Resolves Qarts variable of gformat type
%
%    A complement to *qarts_get* to also handle gformat data. This is needed
%    as there is no complete support for gformat in the xml part.
%
%    A file is tried to be loaded, through *gf_load*, if *a* is a
%    string. Otherwise b is just set to a.
%
% FORMAT   b = qarts_get_gformat( a )
%        
% OUT   b          Variable value.
% IN    a          Variable value or file name.

% 2004-07-10   Created by Patrick Eriksson.


function b = qarts_get_gformat( a )

if ischar( a )
  b = gf_load( a );
else
  b = a;
end