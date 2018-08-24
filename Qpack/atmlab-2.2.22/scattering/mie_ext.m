% MIE_EXT  Mie extinction for individual particles
%
%   Basically an interface to mie.m. The function handles a single
%   combination of refractive index and wavelength, but a multiple of
%   particle sizes are allowed.
%
%   The data are returned "blown-up" to match selected Stokes dimensionality.
%   Total extinction matrix and absorption vector are obtianed by multiplying
%   with particle number densities.
%
%   K(1,1) = a(1) + S(1,1). Single scattering albedo is S(1,1)/K(1,1).
%
% FORMAT  [K,a,S]=mie_ext(m,lambda,r[,stokes_dim])
%
% OUT     K     Extinction cross-section matrix [m2]. 
%               Size(r,stokes_dim,stokes_dim).
%         a     Absorption vector [m2]. Size(r,stokes_dim).
%         S     Scattering cross-section matrix [m2]. 
%               Size(r,stokes_dim,stokes_dim).
%
% IN      m          complex refractive index (imaginary part should 
%                    be positive)   (scalar)
%         lambda     wavelength [m] (scalar)
%         r          particle radius [m] (vector)   
% OPT     stokes_dim Stokes dimension. 

% History: 2010-02-02 Created by Bengt Rydberg

function [K,a,S] = mie_ext(m,lambda,r,stokes_dim)
%
if nargin < 4
  stokes_dim = 1;
end
%                                                                           %&%
rqre_datatype( m, @istensor0 );                                             %&%
rqre_datatype( lambda, @istensor0 );                                        %&%
rqre_alltypes(r, {@isnumeric,@isvector} );                                  %&%
rqre_alltypes( stokes_dim, {@istensor0,@iswhole} );                         %&%
rqre_in_range( stokes_dim, 1 , 4 );                                         %&%
if imag( m ) < 0                                                            %&%
  error( 'Imaginary part of the refractive index must be positive.' );      %&%
end                                                                         %&%
  
x = (2*pi/lambda) * r;

K = zeros( length(r), stokes_dim, stokes_dim );
a = zeros( length(r), stokes_dim );
S = zeros( length(r), stokes_dim, stokes_dim );

%loop over particle sizes
for i=1:length(x)
  area     = pi * r(i)^2;
  result   = mie(m, x(i));
  %
  a(i,1)   = area * result(3);
  c1       = area * result(1);
  c2       = area * result(2);
  %
  for j = 1 : stokes_dim
    K(i,j,j) = c1;
    S(i,j,j) = c2;
  end
end
