% MRESPA   Get measurement response from an averaging kernel matrix
%
% FORMAT   [mresp,As] = mrespA( A, ji )
%        
% OUT   mresp   Measurement response.
%       As      Array of matrices. One matrix for each retrieval quantity. 
%               As returned by *splitA*.
% IN    A       Complete averaging kernel matrix.
%       ji      Matrix of two columns, where the columns hold start and end 
%               index for each retrieval quantity.

% 2006-09-29   Created by Patrick Eriksson.


function [mresp,As] = mrespA(A,ji)

% Checks are done in *splitA*

As = splitA( A, ji );

mresp = zeros( size(A,1), 1 );

i0 = 0;

for i = 1:length(As)
  ind        = i0+1:i0+size(As{i},1);
  mresp(ind) = sum( A(ind,ind)' );
  i0         = ind(end);
end



