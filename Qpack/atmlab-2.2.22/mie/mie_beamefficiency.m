function result = mie_beamefficiency(m, x, tetalim, nsteps)

% Cumulative power (corresponds to the beam efficiency in antenna theory) 
% scattered within a maximum scattering angle (variable from 0 to pi) for
% Mie Scattering (with and without diffraction peak) with
% complex refractive-index ratio m=m'+im", size parameters x=k0*a, 
% according to Bohren and Huffman (1983) BEWI:TDD122
% INPUT: 
% m, x: as usual
% tetalim: maximum angle to be considered, in radians
% nsteps: number of angles to be considered
% C. Mätzler, June 2003, revised April, 2004.

dteta=tetalim/nsteps;
xmin=dteta/pi;
m1=real(m); m2=imag(m);
nx=(1:nsteps); 
teta=(nx-0.5).*dteta;
u=cos(teta); xs=x.*sqrt(1-u.*u);
    for j = 1:nsteps, 
% Computation of diffraction pattern S according to BH, p. 110
        if abs(xs(j))<0.0001
            S(j)=x*x*0.25*(1+u(j));            % avoiding division by zero
        else
            S(j)=x*x*0.5*(1+u(j)).*besselj(1,xs(j))./xs(j);    
        end;
        a(:,j)=Mie_S12(m,x,u(j));
        b(:,j)=a(:,j)-S(j); % Subtraction of diffaction peak
        
        SL(j)= real(a(1,j)'*a(1,j))/(pi*x^2);   % with diffraction
        SR(j)= real(a(2,j)'*a(2,j))/(pi*x^2);
        SLb(j)= real(b(1,j)'*b(1,j))/(pi*x^2);  % without diffraction
        SRb(j)= real(b(2,j)'*b(2,j))/(pi*x^2);  
    end;
st=2*pi*sin(teta);
SSL=st.*SL;
SSR=st.*SR;
SSLb=st.*SLb;
SSRb=st.*SRb;
tetad=teta*180/pi;
Q=mie(m,x);
Qsca=Q(2);
z=0.5*dteta*cumsum(SSL+SSR)/Qsca;
zb=0.5*dteta*cumsum(SSLb+SSRb)/Qsca;
semilogx(tetad/180,z,'r-',tetad/180,zb,'k--'),
title(sprintf('Cumulative Fraction of Scattered Power: m=%g+%gi, x=%g',m1,m2,x)),
xlabel('Maximum Scattering Angle/180°'),
axis([xmin, tetalim/pi, 0, 1.1]);
result=[teta; SSL; SSR; SSLb; SSRb; z; zb]';
