% FM_O3_111GHZ   A very simple forward model for ozone around 110.8 GHz
%
%    This function is a simple forward model, for ground-based measurements,
%    that only considers a single transition, the ozone transition at 
%    110.836 GHz. 
%
%    The function returns both spectrum and weighting function matrix, K,
%    where K corresponds to a VMR retrieval.
%
% FORMAT   [tb,K] = fm_o3_111ghz(z,p,t,o3,v,el,tb0)
%        
% OUT   tb   Brightness temperature spectrum.
%       K    Weighting functions [K/VMR].
% IN    z    Vector of vertical altitudes.
%       p    Pressures at *z*.
%       t    Temperatures at *z*.
%       o3   Ozone VMR profile.
%       v    Frequency vector.
%       el   Elevation angle of measurement (90=zenith)
%       tb0  Brightness temperature of icoming radiation at the
%            top of the atmosphere.

% 2004-11-18   Created by Patrick Eriksson 


function [tb,K] = fm_o3_111ghz(z,p,t,o3,v,el,tb0)

%=== Some constants
KB      = 1.380662e-23;         % Boltzmann constant [J/K]
P0      = 1.013e5;              % Std. ground pressure [Pa]
T0      = 296;                  % Std. ground temperature [K]
V0      = 110.83604e9;          % Centre frequency [Hz]
S0      = 0.3724e-16;           % Line strength [m2Hz]
GA0     = 2.37e9;               % Pressure broadening at ground level [Hz]
X       = 0.73;                 % Temperature exponent [-]

nz = length(z);                 % Number of altitudes


%=== Init. Tb
tb      = repmat( tb0, length(v), 1 );
if nargout > 1
  K = zeros( length(v), nz );
end


%= Ensure column vectors
%
v = vec2col( v );


%=== Loop altitudes downwards
for i = nz:-1:1

  %= Calculate the vertical distance of the present layer.
  %= The values are treated to be valid halfway to the neighbouring points
  %= Treat first and last altitude seperately
  if i == 1
    dz = z(2) - z(1);
  elseif i == nz
    dz = z(nz) - z(nz-1);
  else
    dz = ( z(i+1) - z(i-1) ) / 2;
  end

  %= The pressure broadening width
  ga = GA0 * (p(i)/P0) * (T0/t(i))^X;

  %= The number of ozone molecules
  n  = o3(i) * p(i) / KB / t(i);

  %= Calculate the absorption
  k  = n * S0 * ga ./ ((v-V0).^2+ga^2) / pi;  

  %= The transmission, considering the elevation angle
  tr = exp( -dz * k / sin(el*pi/180) );
 
  %= Do Jacobian
  if nargout > 1
    K(:,i)   = dz * k .* ( t(i) - tb ) / o3(i);
    ind      = i:nz;
    K(:,ind) = K(:,ind) .* repmat(tr,1,nz-i+1);
  end

  %= Update tb
  tb = tb.*tr + t(i).*(1-tr);
 
end

return

plot(v/1e9,tb)
xlabel('Frequency [GHz]')
ylabel('Brightness temperature [K]')
