% RQRE_ELEMENT_MATH   Checks that element-by-element math can be used
%
%    Checks that *a* and *b* are both numeric, and have the same size or one
%    of them is a scalar. That is, that the variables can be part of an
%    expression where element-by-element math is applied (e.g. using .*).
%
%    Issues an error if criterion not fulfilled.
%
% FORMAT   rqre_element_math( a, b )
%        
% IN    a   A variable
%       b   A second variable

% 2010-01-04   Created by Patrick Eriksson.

function rqre_element_math( a, b )

rqre_datatype( a, @isnumeric, inputname(1) );
rqre_datatype( b, @isnumeric, inputname(2) );
  
if ~( isscalar(a)  ||  isscalar(b)  ||  all( size(a) == size(b) ) )
  error( ['The variables *%s* and *%s* must have the same size, or one has '...
                             'to be a scalar.' ], inputname(1), inputname(2) );
end