% CRUZPOL98   Water absorption according to Cruz Pol et al. 1998
%
%    A simple model for water vapour absorption below 30 GHz, taken from
%    "Improved 20- to 32-GHz atmospheric absorption model" by Cruz Pol et al.,
%    Radio Science, Vol 33, 1319-1333, 1998.
%
%    The function considers only water vapour. Oxygen is not included, 
%    in contrast to the complete Cruz Pol model.
%
%    The vectors to describe the atmospheric conditions (*p*, *t* and *e*)
%    must all have the same length. The water vapour amount is specified 
%    by the relative humidity.
%
% FORMAT   A = cruzpol98(f,p,t,e)
%        
% OUT   A   Absorption matrix [1/m] Size [length(p),length(f)]
% IN    f   Frequency vector 
%       p   Pressure vector
%       t   Temperature vector
%       e   Relative humidity (with respect to water) vector

% 2004-10-26   Created by Patrick Eriksson.


function A = cruzpol98(f,p,t,e)


Cl = 1.0639;
Cw = 1.0658;
Cc = 1.2369;


nf = length(f);
np = length(p);


if length(t) ~= np
 error('Length of pressure (*p*) and temperature (*t*) vectors must be equal.')
end
if length(e) ~= np
 error(['Length of pressure (*p*) and relative humidity (*e*) vectors ',...
                                                             'must be equal.'])
end

F     = repmat( vec2row( f/1e9 ), np, 1 );
P     = repmat( vec2col( p/100 ), 1, nf );
T     = repmat( vec2col( t ), 1, nf );
Theta = 300 ./ T;
Ph2o  = repmat( vec2col(e).*e_eq_water(vec2col(t))/100, 1, nf );
Pdry  = P - Ph2o;
Ga    = 0.002784 * Cw * ( Pdry.*Theta.^0.6 + 4.8*Ph2o.*Theta.^1.1 );
f0    = 22.235;


%= Water vapour (factor 1e-3 to go from 1/km to 1/m)
%
A = ( 1e-3 * 0.0419 ) * F.^2 .* ( ...
       0.0109*Cl*Ph2o.*Theta.^3.5.*exp(2.143*(1-Theta)) .* ...
       Ga .* ( 1./((f0-F).^2+Ga.^2) + 1./((f0+F).^2+Ga.^2) ) / f0 + ...
       Cc * ( 1.13e-8*Ph2o.*Pdry.*Theta.^3 + 3.57e-7*Ph2o.^2.*Theta.^10.5 ) );


