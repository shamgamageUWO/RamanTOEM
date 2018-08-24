% EPS_ICE_LIEBE93   Dielectric constant for pure ice according to Liebe 93
%
%    Provides the complex dielectric constant following the Liebe 1993
%    paper.
%
%    The actual limits of the parameterisation are not known. The following
%    limits are here applied:
%      f: [ 10 MHz, 1000 GHz] 
%      t: [ 20 K, 280 K ] 
%
%    Another parameterisation is provided by *epsice*.
%
% FORMAT    e = eps_ice_liebe93( f, t )
%        
% OUT   e   Complex dielectric constant
% IN    f   Frequency [Hz]
%       t   Temperature [K]

% 2004-10-22   Created by Patrick Eriksson


function e = eps_ice_liebe93( f, t )


theta = 300 ./ t;
fghz  = f/1e9;

if fghz<0.01  |  fghz>1000
  error('Valid range for frequency is 0.01-1000 GHz'); 
end
if t<20  |  t>280
  error('Valid range for temperature is 20-280 K'); 
end


a     = ( theta - 1 ) * exp( 17 - 22.1*theta );
b     = 1e-5 * ( (0.233/(1-0.993/theta)).^2 + 6.33/theta - 1.31 ); 

e     = 3.15 + i * ( a./fghz + b*fghz );
