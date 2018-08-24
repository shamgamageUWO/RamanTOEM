function result = mie_S12nopeak(m, x, u)

% Computation of Mie Scattering functions S1 and S2
% without the diffraction pattern to avoid the forward peak
% of the scattering phase function.
% Complex refractive index m=m'+im", 
% size parameter x=k0*a, and u=cos(scattering angle),
% where k0=vacuum wave number, a=sphere radius;
% s. p. 110-114, Bohren and Huffman (1983) BEWI:TDD122
% C. Mätzler, March 2004

nmax=round(2+x+4*x^(1/3));
ab=mie_ab(m,x);
an=ab(1,:);
bn=ab(2,:);

pt=mie_pt(u,nmax);
pin =pt(1,:);
tin =pt(2,:);

n=(1:nmax);
n2=(2*n+1)./(n.*(n+1));
pin=n2.*pin;
tin=n2.*tin;
S1=(an*pin'+bn*tin');
S2=(an*tin'+bn*pin');
xs=x.*sqrt(1-u.*u);
% Computation of diffraction pattern S according to BH, p. 110
if abs(xs)<0.0001
    S=x.*x*0.25.*(1+u);            % avoiding division by zero
else
    S=x.*x*0.5.*(1+u).*besselj(1,xs)./xs;    
end;
% Subtracting the diffraction pattern to avoid the forward peak
% of the scattering phase function.
result=[S1-S;S2-S];