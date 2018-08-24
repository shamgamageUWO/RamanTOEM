% Function for calculating the complex refractive index
% of pure ice in the submillimeter region, according to 
% Zhang ...
% (Zhang et al. do not provide a formula for real part of refractive index,
% but have measured it and showed variations from 1.787-1.793 between 250
% and 1000GHz with no significant temperature variation. Here, we fix the
% real part to the mean value of 1.790)
%
% FORMAT   n = n_ice_zhang01(f,TK)
%        
% OUT   n   Complex refractive index
% IN    f   Frequency [Hz]. 0.01-3000 GHz.
%       TK  Temperature [K]. 20-273.15 K.

% 2014-07-14   Created by J. Mendrok

function n = n_ice_zhang01(f,TK)

    f = f/1e9;

    if f<1.  |  f>1000
      error('Valid range for frequency is 1-1000 GHz'); 
    end
    if TK<100  |  TK>273.15
      error('Valid range for temperature is 100-273.15 K'); 
    end
    
    n1=1.79d0;

    h   = 6.6260693d-34;	% [Js]				; from wikipedia: h = 6,626 069 3(11) * 10^-34 Js
    c   = 2.99792458d+10;	% [cm/s]			; from wikipedia: c = 2,997 924 58 * 10^8 m/s
    k   = 1.3806504d-23;	% [J/K]				; from wikipedia: k = 1,380 650 4(24) * 10-23 J/K
    hck   = h*c/k;
    Pi4c = 4.*pi*c;

    A  = 4.044d-5;	% [GHz]         ; it's not fully clear from paper, whether A is T-dependent
    B0 = 1.391d+5;	% [cm^(-1)*K]
    v0 = 233.d0;	% [cm^(-1)]

    hckv = hck * v0;
    v02 = v0^2;
    c1 = A / (2.d0*n1);                                         % [GHz]
    expVT = exp( hckv / TK );
    c2 = 1.d9/Pi4c * B0/TK * ( expVT/(expVT-1.0d0).^2 ) / v02;  % 1e9*[1/Hz]=[1/GHz]
    
    n = n1 + i*(shiftdim(c1/f,1) + c2*f);
