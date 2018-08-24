% CHI2   Chi2 distance
%
%    Calculates:
%      v' * inv(S) * v
%    where v is a vector and S is the associated covariance matrix.
%
% FORMAT   c = chi2(V,S)
%        
% OUT   c   Distance value
% IN    V   Data matrix, where each column corresponds to v above.
%       S   Covariance matrix

% 2005-11-23   Created by Patrick Eriksson.

function c = chi2(V,S)


if size(V,1) ~= size(S,1)
  error( 'Mismatch in size between V and S.' );
end


%= If S is diagonal, a faster expression can be used

if length(find(S)) == size(S,1)
  %
  c = sum( V.^2 .* repmat(1./diag(S),1,size(V,2) ) )';

else
  %
  Sinv = inv( S );
  c = sum( V .* ( Sinv * V ) )';

end

return

% The last calculation above is equal to:
%
%   for i = 1 : size(V,2)
%     c(i) = V(:,i)'*Sinv*V(:,i);
%   end
%
% but is much faster than this later solution.