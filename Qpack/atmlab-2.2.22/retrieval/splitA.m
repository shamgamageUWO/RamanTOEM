% SPLITA   Splits up an averaging kernel matrix
%
% FORMAT   As = splitA( A, ji )
%        
% OUT   As   Array of matrices. One matrix for each retrieval quantity. 
% IN    A    Complete averaging kernel matrix.
%       ji   Matrix of two columns, where the columns hold start and end index
%            for each retrieval quantity.

% 2006-09-29   Created by Patrick Eriksson.


function As = splitA(A,ji)
                                                                            %&%
rqre_nargin( 2, nargin );                                                   %&%
if ~istensor2(A)  |  size(A,1)~=size(A,2)                                   %&%
  error( 'Input argument *A* must be a square matrix.' );                   %&%
end                                                                         %&%
if ~istensor2(ji)  &  size(ji,2)                                            %&%
  error( 'Input argument *ji* must be a matrix with 2 columns.' );          %&%
end                                                                         %&%
if ji(end,2) ~= size(A,1)                                                   %&%
  error( 'Inconsistency between *A* and *ji*.' );                           %&%
end                                                                         %&%

for i = 1:size(ji,1)
  ind   = ji(i,1) : ji(i,2);
  As{i} = A(ind,ind);
end
