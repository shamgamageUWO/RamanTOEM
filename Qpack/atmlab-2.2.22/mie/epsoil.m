function result = epsoil(fGHz, TK, rob, mv, S, C)

% Dielectric permittivity soil according to Dobson et al. 1985,
% as formulated by Ulaby et al. 1986, Monograph on
% "Microwave Ramote Sensing", Vol. 3, p. 2102.
% Input: 
% fGHz: frequency, GHz 
% TK: temperature, K 
% rob: bulk density, g/cm^3
% mv: volumetric soil moisture
% S, C: Sand and Clay fractions, respectively
% Mätzler, June 2002


    a = dbstack;
    %
    if length(a)==1 | ~strncmp(a(2).file,'mie',3) | ~strncmp(a(2).file,'eps',3)
      error('This function can just be used by the Mie functions.');
    end

ess=4.7;              % permittivity of solid material
ross=2.65;            % density of solid material, g/cm^3
alfa=0.65;
beta=1.09-0.11*S+0.18*C;
po=(ross-rob)./ross;  %  Porosity
ew=epswater(fGHz, TK);
vss=1-po;
va=po-mv;
ealfa=(1-po)*ess.^alfa+po-mv+(mv.^beta).*(ew.^alfa);
eps=ealfa.^(1/alfa);
result=eps; 