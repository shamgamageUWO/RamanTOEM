% Function for calculating the complex relative permittivity 
% of pure ice in the microwave region, 
% according to 
% Matzler, C., P.W. Rosenkranz, A. Battaglia and J.P. Wigneron (eds.), 
% "Thermal Microwave Radiation - Applications for Remote Sensing", 
% IEE Electromagnetic Waves Series 52, London, UK (2006), Chapter 5.
%
% FORMAT   z = eps_ice_matzler06(f,TK)
%        
% OUT   z   Complex relative permittivity
% IN    f   Frequency [Hz]. 0.01-3000 GHz.
%       TK  Temperature [K]. 20-273.15 K.

% 2006-03-07   Function provided by C. Matzler (some adaptions by PE).

function z = eps_ice_matzler06(f,TK)

    f = f/1e9;

    if f<0.01  |  f>3000
      error('Valid range for frequency is 0.01-3000 GHz'); 
    end
    if TK<20  |  TK>273.15
      error('Valid range for temperature is 20-273.15 K'); 
    end
	
	B1 = 0.0207;
	B2 = 1.16e-11;
	b = 335;
	deltabeta = exp(-9.963 + 0.0372.*(TK-273));
	betam = (B1./TK).* ( exp(b./TK)./ ((exp(b./TK)-1).^2) ) + B2*f.^2;
	beta = betam + deltabeta;
	theta = 300./TK - 1;
	alfa = (0.00504 + 0.0062*theta).*exp(-22.1*theta);
	z = 3.1884 + 9.1e-4*(TK-273);
	z = z + i*(alfa./f + beta.*f);
