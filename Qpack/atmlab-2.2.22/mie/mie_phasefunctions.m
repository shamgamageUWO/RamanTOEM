function result = mie_phasefunctions(m, x, u)

% Computation of Mie phase functions p1 and p2
% for complex refractive index m=m'+im", 
% size parameter x=k0*a, and u=cos(scattering angle),
% where k0=vacuum wave number, a=sphere radius;
% s. p. 111-114, Bohren and Huffman (1983) BEWI:TDD122
% C. M�tzler, May 2002

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
Q=mie(m,x);
Qext=Q(1);
p1=S1'*S1./(pi*Qext.*x^2);
p2=S2'*S2./(pi*Qext.*x^2);
result=[p1;p2];