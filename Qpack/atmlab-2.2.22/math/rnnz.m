% RNNZ   Relative amount of non-zero elements
%
%    Works as *nnz* but returns the relative value, instead of the
%    absolute number of non-zero values.
%
% FORMAT  f = rnnz(x)  
%        
% OUT   f   Fraction of non-zero elements.
% IN    x   Data vector or matrix.

% 2005-05-17   Created by Patrick Eriksson.

function f = rnnz(x)

f = length(find(x)) / prod(size(x));