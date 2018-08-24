% Internal function to check whether enough data fields were read from file.
%
%    Exits with error message if not.
%
% FORMAT   xmlCheckSize(ne, nr)
%
% IN   ne   Expected number of items
% IN   nr   Read number of items

% 2002-10-18   Created by Oliver Lemke.

function xmlCheckSize(ne, nr)

if nr(1) ~= ne
  error ('Not enough input data found in file');
end

