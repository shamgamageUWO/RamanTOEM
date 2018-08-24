function z = epsice(f,TK)
% Function for calculating the relative permittivity of pure ice in the 
% microwave region, according to C. Mätzler, "Microwave properties of ice 
% and snow", in B. Schmitt et al. (eds.) Solar System Ices, Astrophys. 
% and Space Sci. Library, Vol. 227, Kluwer Academic Publishers, 
% Dordrecht, pp. 241-257 (1998). Input:
% f = frequency in GHz, range 0.01 to 3000
% TK = temperature (K), range 20 to 273.15

    a = dbstack;
    %
    if length(a)==1 | ~strncmp(a(2).file,'mie',3) | ~strncmp(a(2).file,'eps',3)
      error('This function can just be used by the Mie functions.');
    end
	
	B1 = 0.0207;
	B2 = 1.16e-11;
	b = 335;
	deltabeta = exp(-10.02 + 0.0364*(TK-273));
	betam = (B1/TK) * ( exp(b/TK) / ((exp(b/TK)-1)^2) ) + B2*f^2;
	beta = betam + deltabeta;
	theta = 300 / TK - 1;
	alfa = (0.00504 + 0.0062*theta)*exp(-22.1*theta);
	z = 3.1884 + 9.1e-4*(TK-273);
	z = z + i*(alfa/f + beta*f);
