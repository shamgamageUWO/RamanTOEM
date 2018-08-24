%converts lambda to Dme or Dmean or reverse
%
%        This function converts lambda or Dme or Dmean
%        to Dme or Dmean or lambda, for a gamma distribution
%        of the form n(D)=N*D^mu*exp(-lambda*D).
%        Dme is the median mass diameter,Dmean is the mean
%        mass diameter. 
% 
% OUT     vector of Dme[m] or Dmean[m] or lambda[m^-1] depending on input
%
% IN      f       what to convert
%                 1 = lambda to Dme
%                 2 = lambda to Dmean
%                 3 = Dme    to lambda
%                 4 = Dmean  to lambda
%         mu      the width of gamma distribution mu>-2 
%         beta    exponent in particle mass-diameter relationship
%                 m(D)=alfa*D^beta,beta=3 for spheres or ellipsoids         
%         lambda  size parameter of gamma distribution [m^-1]
%                 empty if f=3 or 4
%         Dme     mass median diameter [m]
%                 empty if f=1 or 2
%         Dmean   mass mean diameter [m]
%                 empty if f=1 or 2
function [y]=gamma_lambda2d(f,mu,beta,lambda,Dme,Dmean)
 
min_nargin( 6, nargin );

if f==1
  y=(beta+mu+0.67)./lambda;
elseif f==2
  y=gamma(beta+2+mu)./gamma(beta+1+mu)./lambda;
elseif f==3
  y=(beta+mu+0.67)./Dme;
elseif f==4
  y=gamma(beta+2+mu)./gamma(beta+1+mu)./Dmean;
else
 error('f must be equal to 1,2,3, or 4')
end
y=vec2col(y);
