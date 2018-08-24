% RANDMVAR_ADD_UNIFORM   Random multivariate data with uniform distribution
%
%   Prepares input to *randmvar* to include data with uniform distribution.
%   The statistical properties are set by lower and upper limit for data
%   range, and the covariance matrix for the data variables to be included.
%
%   Zero correlation to already included variables is assumed.
%
% FORMAT   [P,C] = randmvar_add_uniform( P, C, Xlims, Cm )
%        
% OUT   P       Description of probability distribution function. See 
%               *randmvar* for format description.
%       C       Correlation matrix. 
% IN    P       Description of probability distribution function for already 
%               added variables.
%       C       Correlation matrix for already added variables. 
%       Xlims   Lower and upper limit for each vector element. Given as a
%               matrix with 2 columns.
%       C       Correlation matrix for variables to be added. 

% 2005-05-21   Created by Patrick Eriksson.


function [P,C] = randmvar_add_uniform(P,C,Xlims,Cm)


%= Check input
%
rqre_nargin( 4, nargin );
%
if ndims(C) > 2  |  size(C,1) ~= size(C,1) 
  error('Input argument *C* must be a square matrix.');
end
%
if length(P) ~= size(C,1)
  error('Mismatch in size between *P* and *C*.');
end
%
if ndims(Xlims) ~= 2  |  size(Xlims,2) ~= 2
  error('Input argument *Xlims* must be a matrix with two columns.');
end
%
if ndims(Cm) > 2  |  size(Cm,1) ~= size(Cm,1) 
  error('Input argument *Cm* must be a square matrix.');
end
%
if size(Xlims,1) ~= size(Cm,1) 
  error('Mismatch in size between *Xlims* and *Cm*.');
end


np = length( P );
nx = size( Xlims, 1 );

P{np+nx} = [];

for i = 1 : nx
  %
  P{np+i}.cdf     = [ Xlims(i,:)', [0;1] ];
  P{np+i}.imethod = 'linear';  
  %
end

C = covmat_append( C, Cm );


