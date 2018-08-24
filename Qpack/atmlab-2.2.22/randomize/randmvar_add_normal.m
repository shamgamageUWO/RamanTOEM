% RANDMVAR_ADD_NORMAL   Random multivariate data with normal distribution
%
%   Prepares input to *randmvar* to include data with normal (Gaussian) 
%   distribution. The statistical properties are set by mean value, standard
%   deviation and the covariance matrix for the data variables to be included.
%
%   Zero correlation to already included variables is assumed.
%
% FORMAT   [P,C] = randmvar_add_normal( P, C, xm, si, Cm )
%        
% OUT   P       Description of probability distribution function. See 
%               *randmvar* for format description.
%       C       Correlation matrix. 
% IN    P       Description of probability distribution function for already 
%               added variables.
%       C       Correlation matrix for already added variables. 
%       xm      Mean vector.
%       si      Vector of standard deviations.
%       C       Correlation matrix for variables to be added. 

% 2005-05-21   Created by Patrick Eriksson.


function [P,C] = randmvar_add_normal(P,C,xm,si,Cm)


%= Check input
%
rqre_nargin( 5, nargin );
%
if ndims(C) > 2  |  size(C,1) ~= size(C,1) 
  error('Input argument *C* must be a square matrix.');
end
%
if length(P) ~= size(C,1)
  error('Mismatch in size between *P* and *C*.');
end
%
if ~isvector(xm)
  error('Input argument *xm* must be a vector.');
end
%
if ~isvector(si)  |  length(xm) ~= length(si)
  error('Input argument *si* must be a vector with same length as *xm*.');
end
%
if any( si <= 0 )
  error('All values of *si* must be >0.');
end
%
if ndims(Cm) > 2  |  size(Cm,1) ~= size(Cm,1) 
  error('Input argument *Cm* must be a square matrix.');
end
%
if length(xm) ~= size(Cm,1) 
  error('Mismatch in size between *xm* and *Cm*.');
end


np = length( P );
nx = length( xm );

P{np+nx} = [];

for i = 1 : nx
  %
  P{np+i}.cdf = [ xm(i) si(i) ];
  %
end

C = covmat_append( C, Cm );


