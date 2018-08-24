function result = mie_phasefunplot(m, x, nsteps, peak)

% Plot of Mie phasefunction for unpolarised radiation 
% with normalisation to 'one' when integrated 
% over all directions/(4*pi), see Chandrasekhar 1960
% Eq. (28), for complex refractive-index ratio m=m'+im", 
% size parameters x=k0*a, 
% according to Bohren and Huffman (1983) BEWI:TDD122
% INPUT: 
% m, x: as usual
% nsteps: number of angles to be considered
% peak=1 for normal case, peak=0 without forward peak
% C. Mätzler, July 2003, revised March 2004 (peak).

dteta=pi/nsteps;
m1=real(m); m2=imag(m);
nx=(1:nsteps);
teta=(nx-0.5).*dteta;
u=cos(teta);
    for j = 1:nsteps, 
        if peak==1
            a(:,j)=mie_S12(m,x,u(j));
        elseif peak==0
            a(:,j)=mie_S12nopeak(m,x,u(j));
        end;
        SL(j)= real(a(1,j)'*a(1,j));
        SR(j)= real(a(2,j)'*a(2,j));
    end;
tetad=teta*180/pi;
s=sin(teta);
Q=mie(m,x); Qext=Q(1); Qsca=Q(2); Qabs=Q(3); asy=Q(5); w=Qsca/Qext;
p=(SL+SR)./Qsca/x.^2;
eta=dteta*(p*s'-(p(1)*s(1)+p(nsteps)*s(nsteps))*0.5);
asy0=dteta*(p*(u.*s)'-(p(1)*s(1)-p(nsteps)*s(nsteps))*0.5)/eta;
Qsca0=Qsca*eta;Qext0=Qabs+Qsca0;
w0=Qsca0/Qext0;
pdB=10*log10(p);
% Qsca to be exchanged by Qext=Q(1) above if normalisation
% to single-scattering albedo is required.
plot(tetad,pdB,'r-')
title(sprintf('Phase Function: m=%g+%gi, x=%g, w=%g, g=%g',m1,m2,x,w0,asy0))
xlabel('Scattering Angle (deg)'),ylabel('Phase Function (dB)')
result=[teta;p]'; % Phase function  
