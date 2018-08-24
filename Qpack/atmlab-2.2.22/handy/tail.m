% TAIL   End part of a vector.
%
%    Returns the tail of any variable that can be indexed as (1:n).
%   
%    The function will return a result if given a non-vector input (for
%    example, a matrix). No check of the type of the input is performed
%    for efficiency reasons.
%
%    The last element of a vector is obtained by
%       tail( x, 1 );
%
%    To ask for a tail with a length exceeding the vector lengths results in
%    an error.
%
% FORMAT   t = tail( x, l )
%        
% OUT   t   Tail fo the vector.
% IN    x   The full vector.
%       l   Length of tail to extract.

% 2002-12-16   Created by Patrick Eriksson.


function t = tail( x, l )

if l > length(x)
  serr = sprintf( ['You have asked for a tail of length %d, but *x* has ',...
                                          'only %d elements.'], l, length(x) );
  error( serr );
end


t = x( length(x) + ((-l+1):0) );