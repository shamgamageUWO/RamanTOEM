% VEC2ROW   Ensures that a variable not has less columns than rows.
%
%    The most common application of this function is to ensure that a 
%    vector is a row vector.
%
% FORMAT   v = vec2row(v)
%        
% OUT   v   A variable of any type.
% IN    v   The variable possible transposed.

% 1993        Created by Patrick Eriksson. 
% 2002-12-10  Adapted to Atmlab from arts/ami.
% 2013-03-04  Bugfix by Gerrit Holl for empty vector + do not get conj

function v = vec2row(v)

wid = ['atmlab:' mfilename ':zero'];
[rows,cols] = size(v);

if all(size(v)==0)
    warning(wid, 'Cannot convert zero-sized vector to row');
end

if (isempty(v) && ~isrow(v)) || (~isempty(v) && rows > cols)
 v = v.';
end
end
