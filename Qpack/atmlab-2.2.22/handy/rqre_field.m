% RQRE_FIELD   Require that a structure has a particular field
%
%    Issues an error if criterion not fulfilled.
%
% FORMAT   rqre_field( Q, fieldname [, nonstdname ] )
%        
% IN    Q             The structure.
%       fieldname     Name of field.
% OPT   nonstdname    Name of variable to use in error message. Default is
%                     to use the function *inputname* to determine the
%                     variable name.

% 2005-03-15   Created by Patrick Eriksson.


function rqre_field( Q, fieldname, nonstdname )
%
if nargin < 3, nonstdname = []; end
 
%- Handle the cellstr case in recursive manner
if iscellstr( fieldname )
  for i = 1 : length(fieldname)
    rqre_field( Q, fieldname{1}, nonstdname );
  end
  return
end
                                                                           %&%
assert( ischar( fieldname ) );                                             %&%
assert( ischar( nonstdname )  ||  isempty( nonstdname ) );                 %&%
  

if isempty(nonstdname)
  vname = sprintf( 'The variable *%s*', inputname(1) );
else
  assert( ischar( nonstdname ) );                                          %&%
  vname = sprintf( '%s', nonstdname );
end

if ~isfield( Q, fieldname )
  error(['atmlab:' mfilename ':missingfield'], ...
      '%s is required to have the field *%s*.', vname, fieldname);
end

end
