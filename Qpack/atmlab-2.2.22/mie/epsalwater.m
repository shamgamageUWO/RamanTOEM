function result = epsalwater(fGHz, TK, S)

% Dielectric permittivity of saline water according
% Meissner and Wentz (2004)
% Frequency range: 1 to 1000 GHz, 
% Input: fGHz: frequency in GHz, TK: temperature in K, 
% Salinity S in promille
% Program by Matzler, Aug. 2004


    a = dbstack;
    %
    if length(a)==1 | ~strncmp(a(2).file,'mie',3) | ~strncmp(a(2).file,'eps',3)
      error('This function can just be used by the Mie functions.');
    end


T=TK-273.16; % temp conversion to C

a0=5.723;
a1=0.022379;
a2=-7.1237e-04;
a3=5.0478;
a4=-7.0315e-02;
a5=6.0059e-04;
a6=3.6143;
a7=2.8841e-02;
a8=0.13652;
a9=1.4825e-03;
a10=2.4166e-04;

b0=-3.56417e-03;
b1= 4.74868e-06;
b2= 1.15574e-05;
b3= 2.39357e-03;
b4=-3.13530e-05;
b5= 2.52477e-07;
b6=-6.28908e-03;
b7= 1.76032e-04;
b8=-9.22144e-05;
b9=-1.99723e-02;
b10=1.81176e-04;
b11=-2.04265e-03;
b12=1.57883e-04;

T2=T.*T;
T3=T2.*T;
T4=T3.*T;
S2=S.*S;
alfa0=(6.9431+3.2841*S-0.099486*S2)./(84.850+69.024*S+S2);
alfa1= 49.843-0.2276*S+0.00198*S2;
RTQ=1+alfa0.*(T-15)./(alfa1+T);
R15=S.*(37.5109+5.45216*S+1.4409e-02*S2)./(1004.75+182.283*S+S2);
sigma35=2.903602+8.607e-02*T+4.738817e-04*T2-2.991e-06*T3+4.3047e-09*T4;
sigma=sigma35.*RTQ.*R15;
es0=(3.70886e04-82.168*T)./(421.854+T);
es=es0.*exp(b0.*S+b1.*S2+b2.*T.*S);
v10=(45+T)./(a3+a4.*T+a5.*T2);
v1=v10.*(1+S.*(b3+b4.*T+b5.*T2))
e10=a0+a1*T+a2*T2;
e1=e10.*exp(b6.*S+b7.*S2+b8.*T.*S);
v20=(45+T)./(a8+a9.*T+a10.*T2);
v2=v20.*(1+S.*(b9+b10.*T))
einf0=a6+a7*T;
einf=einf0.*(1+S.*(b11+b12.*T));
e0=8.85418782e-03;
eps=(es-e1)./(1-i*fGHz./v1)+(e1-einf)./(1-i*fGHz./v2)+einf+i*sigma./(2*pi*e0.*fGHz);

result=eps; 