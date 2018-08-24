function result = mie_phasefunction(m, x, u, peak)

% Computation of Mie Phase Function p=p1+p2 (unpolarised)
% with normalisation to 'one' when integrated 
% over all directions/(4*pi), see Chandrasekhar 1960
% Eq. (28), with complex refractive index m=m'+im", 
% size parameter x=k0*a, and u=cos(scattering angle),
% where k0=vacuum wave number, a=sphere radius;
% u=cos(teta), teta=scattering angle
% peak=0 if diffraction signal is to be subtracted
% s. p. 111-114, Bohren and Huffman (1983) BEWI:TDD122
% C. Mätzler, July 2003, revised April 2004.

nmax=round(2+x+4*x^(1/3));
ab=Mie_ab(m,x);
an=ab(1,:);
bn=ab(2,:);

pt=Mie_pt(u,nmax);
pin =pt(1,:);
tin =pt(2,:);

n=(1:nmax);
n2=(2*n+1)./(n.*(n+1));
pin=n2.*pin;
tin=n2.*tin;
S1=(an*pin'+bn*tin');
S2=(an*tin'+bn*pin');
if peak==0,
    % Computation of diffraction pattern S according to BH, p. 110
    xs=x.*sqrt(1-u.*u);
    if abs(xs)<0.0001
        S=x.*x*0.25.*(1+u);            % avoiding division by zero
    else
        S=x.*x*0.5.*(1+u).*besselj(1,xs)./xs;    
    end;
    S1=S1-S;
    S2=S2-S;
end;
Q=mie(m,x);
Qext=Q(1); Qsca=Q(2); asy=Q(5); w0=Qsca/Qext;
p=2*(S1'*S1+S2'*S2)/(Qsca*x^2);  
% Qsca to be exchanged by Qext above if normalisation to 
% single-scattering albedo, w, is required
result=[p,w0,asy];