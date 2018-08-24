% eps_ice_Jiang_04   Dielectric constant for pure ice according to Jiang 2004
%
%    Provides the complex dielectric constant following the Jiang 2004
%    paper.
%
%    Frequency limit is:
%      f: [ 1  MHz, 3000 GHz] 
%    The actual limits of temperature is not known. The following limit 
%    is applied here
%      t: [ 20 K, 280 K ] 
%
%
% FORMAT    e = eps_ice_Jiang_04( f, t )
%        
% OUT   e   Complex dielectric constant
% IN    f   Frequency                     [Hz]
%       t   Temperature                   [K]

% 2014-06-19   Created by Maryam Jamali


function e = eps_ice_Jiang_04( f, t )

if t<20  |  t>280
  error('Valid range for temperature is 20-280 K'); 
end

t = t - 273.15;

theta = ( 300 ./ (273.15 + t) ) - 1;
fghz  = f/1e9;

if fghz<0.001  |  fghz>3000
  error('Valid range for frequency is 0.001-3000 GHz'); 
end


a     = 1e-4 .* (50.4 + 62 .* theta) .* exp(-22.1 .* theta);
b     = 1e-4 .* ((0.502 - 0.131.*theta) ./ (1 + theta)) + 0.542e-6 .* ((1+theta) ./ (theta+0.0073)).^2;

e     = 3.15 + i * ( a./fghz + b*fghz + 1.16e-11*fghz.^3);