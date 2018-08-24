function rows = unique2(M1, M2)

% unique2 Return rows from matrix2 not occuring in matrix1
%
% Given two matrices M1 and M2, returns a logical of those rows in M2 that
% do not occur in M1. A use case may be to concatenate subsequent granules,
% but not concatenating those rows in the second granule that already exist
% in the first one (like with AMSU/HIRS/MHS data).
%
% FORMAT
%
%   rows = unique2(M1, M2)
%
% IN
%
%   M1      matrix      primary matrix (left untouched)
%   M2      matrix      secondary matrix (shall be reduced)
%
% OUT
%
%   rows    logical     rows in M2 not occuring in M1
%
% $Id: unique2.m 6543 2010-10-07 15:57:41Z gerrit $

[~, I] = unique([M1; M2], 'rows', 'first');
rows = false(size(M2, 1), 1);
n1 = size(M1, 1);

rows(I(I>n1)-n1) = true;