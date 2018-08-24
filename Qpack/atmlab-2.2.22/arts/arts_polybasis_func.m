% ARTS_POLYBASIS_FUNC   Polynomial basis functions (following arts-2)
%
%   This function matches the arts internal function polynomial_basis_func, used
%   to set up the basis functions for jacobian polynomial representations. For
%   example, arts_polybasis_func( Q.SENSOR_RESPONSE.F_BACKEND, 1 ) gives the
%   "weight" for changing the backend frequencies to match a retrieved frequency
%   stretch.
%
% FORMAT   B = arts_polybasis_func( grid, polcoeff )
%        
% OUT      B          Calculated basis function(s), stored as columns.
% IN       x          The grid 
%          polcoeff   Polynomial coefficients. Can be a single index (e.g. 1)
%                     or a range (e.g. 0:3)

% 2009-10-22   Created by Patrick Eriksson.


function B = arts_polybasis_func( grid, polcoeff )

n = length(polcoeff);
B = zeros( length(grid), n );

for i = 1 : n
  if polcoeff(i) == 0
    %
    B(:,i) = 1;
    %
  else
    %
    x1 = min( grid );
    b = ( grid - x1 ) / ( 0.5*( max(grid) - x1 ) ) - 1;
    if polcoeff > 1
      b = b.^ polcoeff(i);
    end
    %
    B(:,i) = b - mean(b);
    %
  end
end