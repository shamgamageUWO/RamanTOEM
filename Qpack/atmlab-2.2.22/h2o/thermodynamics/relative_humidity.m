function rh = relative_humidity(ew,T,p)
% RELATIVE_HUMIDITY     relative humidity rh
%
% FORMAT    rh = relative_humidity(ew,T,p)
%        
% OUT   rh  relative humidity [%]
% IN    ew  water vapor pressure [Pa], a scalar or a vector
%       T   air temperature [K], a scalar or a vector
%       p   air pressure [Pa], a scalar or a vector
%
% EXAMPLE:
%       rh = relative_humidity(1596, 298, 100000)
%       ew = 50.0031
%
% ACCURACY: RELATIVE_HUMIDITY calculates relative humidity according to
%           thermodynamic functions without any assumptions.
%           The accuracy is decreased if air pressure is not provided.
%
% Reference: A short course in cloud physics (Chapter II, water vapor and
%             its thermodynamic effects); 1996, By: R. R. Rogers and M. M. Yau
%             page: 17, Eq.:2.20
%
% 2009-08-15   Created by Isaac Moradi.

es = e_eq_water(T);

% use simply e/es if p isnt given
if nargin < 3
    rh = 100 .* ew ./ es;
else
    rh = 100 .* ew .* (p - es) ./ (es .* (p -ew));
end



