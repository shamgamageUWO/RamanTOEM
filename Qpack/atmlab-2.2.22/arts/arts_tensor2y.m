% ARTS_tensor2Y   Rearrange a tensor to a measurement vector
%
%    Reverses the rearrangement made by *arts_y2tensor*.
%
% FORMAT   y = arts_tensor2y(Y)
%        
% OUT   y    A measurement vector, sorted as by arts.
% IN    Y    Measurement data, as returned by *arts_y2tensor*.

% 2011-08-29   Created by Patrick Eriksson.

function y = arts_tensor2y(Y)
  
[nf,npol,nlos,nblock] = size( Y );

y = zeros( nf*npol*nlos*nblock, 1 );

for i = 1 : npol
  y(i:npol:end) = reshape( Y(:,i,:,:), [ nf*nlos*nblock, 1 ] );
end
