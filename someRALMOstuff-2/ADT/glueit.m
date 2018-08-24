function CO = glueit(AD, PC, maxADmv, a)
%Gluing function - glueit(AD, PC, maxADmv, a)
%AD         - analog signal, converted in MHz, by the formula (aAD+b) - i.e it is offset corrected
%PC         - photon counting signal, MHz
%maxADmv    - maximum AD signal after which to take the AD signal and not PC   
%
% a       = 38.2; %MHz/mV for water vapor PMT 
% maxADmv = 1   ; % mV
%
n = 41; % moving avaerage points 
maxPC   = maxADmv * a; % it is created PC max level, due to analog which has unknown offset and background in it
%
L=length(PC);
CO = zeros(L,1);
%
indPC = (smooth(PC,n)<=maxPC);
CO = CO + PC.*indPC;
%
indAD = (smooth(PC,n)>maxPC);
CO = CO + AD.*indAD;

end
