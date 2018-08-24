% SCATMAT_AMP2STOKES   Conversion of scattering matrices
%
%    Converts amplitude scattering functions to a scattering matrix
%    for Stokes vectors.
%
%    The input specifies the matrix describing the effect of a scattering
%    event:
%       [E1b,E2b]' = [S2,S3;S4,S1]*[E1a,E2a]'
%    where E1a is one of the ortoghonal components of the incoming radiation
%    etc. This function return the corresponding matrix to use for
%    Stokes vactors:
%       Ib = F*Ia
%    where Ia is the incoming Stokes vector.
%
%    See further polarisation theory chapter in ARTS user guide.
%
% FORMAT   F = scatmat_amp2stokes(S1,S2,S3,S4)
%        
% OUT   F   Stokes scattering matrix.
% IN    S1  Amplitude scattering function.
%       S2  Amplitude scattering function.
% OPT   S3  Amplitude scattering function. Default is 0.
%       S4  Amplitude scattering function. Default is 0.

% 2004-05-20   Created by Patrick Eriksson.


function F = scatmat_amp2stokes(S1,S2,varargin)
%
[S3,S4] = optargs( varargin, { 0, 0 } );


F = [
(Mfun(S2)+Mfun(S3)+Mfun(S4)+Mfun(S1))/2, ...
(Mfun(S2)-Mfun(S3)+Mfun(S4)-Mfun(S1))/2, ...
Sfun(S2,S3)+Sfun(S4,S1), ...
-Dfun(S2,S3)-Dfun(S4,S1); ...
(Mfun(S2)+Mfun(S3)-Mfun(S4)-Mfun(S1))/2, ...
(Mfun(S2)-Mfun(S3)-Mfun(S4)+Mfun(S1))/2, ...
Sfun(S2,S3)-Sfun(S4,S1), ...
-Dfun(S2,S3)+Dfun(S4,S1); ...
Sfun(S2,S4)+Sfun(S3,S1), ...
Sfun(S2,S4)-Sfun(S3,S1), ...
Sfun(S2,S1)+Sfun(S3,S4), ...
-Dfun(S2,S1)+Dfun(S3,S4); ...
Dfun(S2,S4)+Dfun(S3,S1), ...
Dfun(S2,S4)-Dfun(S3,S1), ...
Dfun(S2,S1)+Dfun(S3,S4), ...
Sfun(S2,S1)-Sfun(S3,S4) ];



function a = Mfun(Sk)
  %
  a = abs(Sk)^2;
  %
return


function a = Sfun(Sk,Sj)
  %
  a = (Sj*conj(Sk)+Sk*conj(Sj))/2;
  %
return


function a = Dfun(Sk,Sj)
  %
  a = -j*(Sj*conj(Sk)-Sk*conj(Sj))/2;
  %
return