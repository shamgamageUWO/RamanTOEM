% gauss_laguerre returns abscissas and weights for Laguerre Gauss quadrature
%    
%     Returns a vector with abscissas and weights for performing
%     Laguerre Gauss quadrature to represent scattering properties
%     of particle polydispersions. 
%
%     To apply the integration weights use *gauss_laguerre_apply*.
%
%     An example on usage (to generate a PSD for ice particles):
%        xnorm = 50e-6;
%        [x_i,w_i] = gauss_laguerre(0,10,xnorm);
%        y = ice_psd_gamma( ... );
%        y = gauss_laguerre_apply(y,x_i,w_i,xnorm);
%
% FORMAT   [x_i,w_i] = gauss_laguerre(alpha,N[,xnorm])     
%
% OUT      x_i is a vector with abscissas
%          w_i is a vector with weights
% 
% IN       alpha  exponent of weighting function x^alpha*exp(-x)
%          N      number of points
% OPT      xnorm  Normalisation value for length scale. Original point of 1
%                 will be mapped to this value. Default is 1.

% History: 2005-05-13  Created by Bengt Rydberg

function [x_i,w_i]=gauss_laguerre(alpha,N,varargin)
%
[xnorm] = optargs( varargin, { 1 } );


L_size=100000;
x=linspace(0,100,L_size)';
% get Laguerre polynomials
for i=0:N+1
    if i==0
       L(1:L_size,1)=1;
    elseif i==1
       L(1:L_size,2)=-x+alpha+1;
    else
      L(1:L_size,i+1)=((-x+2*(i-1)+alpha+1.0).*L(1:L_size,i)-(i-1.0+alpha)*L(1:L_size,i-1))/i;
    end
end
% find abscissas (roots of laguerre polynom of order N)
s=1;
for i=1:length(x)-1
    if L(i,N+1)*L(i+1,N+1)<=0
       x_i(s)=x(i);
       L_i(s)=L(i,N+1);
       L_i_a(s)=L(i,N+2);
       s=s+1;
    end
end
n_fak=1;
for i=1:N
    n_fak=n_fak*i;
end
% get weights
w_i=gamma(N+alpha+1)*x_i./n_fak/(N+1)^2./L_i_a.^2;



x_i = x_i * xnorm;

