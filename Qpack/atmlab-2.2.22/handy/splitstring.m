% SPLITSTRING   Splits string into tokens at given separator.
%
% FORMAT   s = splitstring (p, sep)
%        
% OUT   s   Cell array of strings.

% 2011-01-26   Created by Oliver Lemke.


function s = splitstring (p, sep)

if exist('OCTAVE_VERSION','builtin')
  s = strsplit (p, sep, true);
else
  s = regexp (p, sep, 'split');
end

