function result = mie_phasefunasy(m, x, nsteps)
% aus mie_phasefunplot(m, x, nsteps) abgeleitet
% zur numerischen Berechnung des Asymmetriefaktors
% sowie zum Testen, wie er aus verschiedenen Streuwinkeln
% zusammengesetzt ist. Z. Bsp. Einfluss von Vorwaertspeak bei 
% Streuwinkel 0.

% INPUT: 
% m, x: as usual
% nsteps: number of angles to be considered
% C. Mätzler, July 2003.

dteta=pi/(nsteps-1);
m1=real(m); m2=imag(m);
nx=(1:nsteps);
teta=(nx-1).*dteta;
    for j = 1:nsteps, 
        u=cos(teta(j));
        a(:,j)=mie_S12(m,x,u);
        SL(j)= real(a(1,j)'*a(1,j));
        SR(j)= real(a(2,j)'*a(2,j));
    end;
tetad=teta*180/pi;
co=cos(teta);
dcos=-diff(co);
Q=mie(m,x);
Qext=Q(1); Qsca=Q(2); asy=Q(5); w=Qsca/Qext;
p=co.*(2*(SL+SR)./Qsca/x.^2);
n=length(teta);
p1=p(1:n-1); p2=p(2:n); p3=0.5*(p1+p2);
dasy=[0,cumsum(0.5*dcos.*p3)];

plot(tetad(1:n),dasy,'r-')
title(sprintf('m=%g+%gi, x=%g, w=%g, g=%g',m1,m2,x,w,asy))
xlabel('Scattering Angle (deg)'),ylabel('dasy')
