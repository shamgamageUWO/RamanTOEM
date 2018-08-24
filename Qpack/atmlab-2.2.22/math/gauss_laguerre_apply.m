% gauss_laguerre_apply performs Laguerre Gauss quadrature
%    
%     Returns a vector or matrix depending on input with for example 
%     particle number density after performing
%     Laguerre Gauss quadrature to represent scattering properties
%     of particle polydispersions. 
%     For information on Gaussian quadrature see for example
%     numerical recipies
%
%
%     An example on usage (to generate a PSD for ice particles):
%        xnorm = 50e-6;
%        [x_i,w_i] = gauss_laguerre(0,10,xnorm);
%        y = ice_psd_gamma( ... );
%        y = gauss_laguerre_apply(y,x_i,w_i,xnorm);
%
% FORMAT   [Y] = gauss_laguerre_apply(Y,x_i,w_i,xnorm])     
%
% OUT      Y      A matrix or vector with the integrated
%                 values of Y
%
% IN       x_i    is a vector with abscissas
%          w_i    is a vector with weights
%          xnorm  Normalisation value for length scale.
%          Y      The function to be integrated evaluated
%                 at x_i

% History: 2005-06-28  Created by Bengt Rydberg

function Y = gauss_laguerre_apply(Y,x_i,w_i,varargin)
%
[xnorm] = optargs( varargin, { 1 } );


%= Check input
%
if length(x_i) ~= length(w_i)
  error('Length of *x_i* and *w_i* must be identical.');
end
%
if size(Y,1) ~= length(x_i)
  error('Size of *Y* does not match length of *x_i*');
end


x_i = x_i / xnorm;

x_i = vec2col( x_i );
w_i = vec2col( w_i );

Y = Y .* repmat(xnorm*exp(x_i).*w_i,1,size(Y,2));
