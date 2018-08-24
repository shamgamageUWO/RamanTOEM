%=============================================================
% n = vmr2nd(vmr,p,t)
%
% Calculates number density values from VMR-values.
%
% If any of vmr, p or t is not a scalar, the otehrs must have the 
% same size or be scalars.
%
% Input: vmr    vector(s) of VMR-values [-]
%        p      vector of pressure values [Pa]
%        t      vector of temperature values [K]
%
% Output:   n   vector of number density values [1/m3]
%
% Patrick Eriksson 1993
% PE 2001-12-12, Adapted to AMI
% PE 2004-09-11, Adapted to Atmlab
%=============================================================

function n = vmr2nd(vmr,p,t)

kb = constants( 'BOLTZMANN_CONST' );

n = (vmr.*p./(kb*t)); 

