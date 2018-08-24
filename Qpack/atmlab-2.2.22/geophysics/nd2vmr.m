%=============================================================
% vmr = nd2vmr(n,p,t)
%
% Calculates VMR-values from number density values.
%
% If any of n, p or t is not a scalar, the others must have the 
% same size or be scalars.
%
% Input:    n   vector of number density values [1/m3]
%           p   vector of pressure values [Pa]
%           t   vector of temperature values [K]
%
% Output:   vmr vector of VMR-values [ppm]
%
% Patrick Eriksson 1993
% PE 2001-12-12, Adapted to AMI
% PE 2004-09-11, Adapted to Atmlab
%=============================================================

function vmr = nd2vmr(n,p,t)
  
kb = constants( 'BOLTZMANN_CONST' );

vmr = n*kb.*t./p;
