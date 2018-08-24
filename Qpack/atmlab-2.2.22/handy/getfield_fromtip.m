% GETFIELD_FROMTIP 
%
%    As F = GETFIELD(S,'field') but using as 'field' the first 
%    field that contain the string tip. If no field containing
%    tip is found, F is returned empty.
%
% FORMAT   F = getfield_fromtip( S, tip )
%        
% IN       S    structure
%          tip  string
%
% OUT      F    contents of the field

% 2004-08-31   Created by Carlos Jimenez.

function f = getfield_fromtip( S, tip )

aux = fieldnames( S);
ind = '';
j   = 0;

while isempty( ind )

  j   = j+1;
  ind = findstr( char( aux(j) ), tip );

end

if isempty( ind )

  f = ind;

else

  f = getfield( S, char( aux(j) ) );

end


end
