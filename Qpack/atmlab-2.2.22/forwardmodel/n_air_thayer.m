% N_AIR_THAYER   Microwave refractive index for Earth's atmosphere
%
%   The parameterisation of Thayer (Radio Science, 9, 803-807, 1974).
%   See also Eq. 3 and 5 of Solheim et al. (JGR, 104, pp. 9664).
%   The expression is non-dispersive. 
%
% FORMAT: n = n_air_thayer(p,t,h2o)
%
% OUT: n   Refractive index (only real part).
% IN:  p   Pressure.
%      t   Temperature
%      e   Water vapour partial pressure

function n = n_air_thayer(p,t,e)

rqre_element_math( p, t );
rqre_element_math( p, e );
  
n = 1 + ( 77.6e-8 * ( p - e ) + ( 64.8e-8 + 3.776e-3 ./ t) .* e ) ./ t;
