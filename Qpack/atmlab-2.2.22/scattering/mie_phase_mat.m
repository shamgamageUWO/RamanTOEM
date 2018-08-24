% MIE_PHASE_MAT   Mie phase matrix
%
%   Returns the phase matrix for Mie particles. Multiple particle sizes and
%   scattering angles are handled.
%
%   The returned phase matrix is not normalised. That is, the upper left
%   element of the matrix, y(1,:,1,1), is related to the scattering
%   cross-section as:
%
%     int_{4pi}[ y(1,:,1,1) ] domega = y_sca
%
%   where the integration is performed over the complete sphere, omega is solid
%   angle and y_sca is the scattering cross-section.
%
% FORMAT  y = mie_phase_mat(m,lambda,r,theta[,stokes_dim])
%
% OUT     y          Mie phase matrix. Size(r,theta,stokes_dim,stokes_dim)
%
% IN      m          complex refractive index (imaginary part should 
%                    be positive)   (scalar)
%         lambda     wavelength [m] (scalar)
%         theta      scattering angle [deg], (vector)
%         r          particle radius [m] (vector)   
% OPT     stokes_dim Stokes dimension. 

% History: 2010-02-02 Created by Bengt Rydberg

function [y] = mie_phase_mat(m,lambda,r,theta,stokes_dim)
%
if nargin < 5
  stokes_dim = 1;
end
%                                                                           %&%
rqre_datatype( m, @istensor0 );                                             %&%
rqre_datatype( lambda, @istensor0 );                                        %&%
rqre_alltypes( r, {@isnumeric,@isvector} );                                 %&%
rqre_alltypes( theta, {@isnumeric,@isvector} );                             %&%
rqre_alltypes( stokes_dim, {@istensor0,@iswhole} );                         %&%
rqre_in_range( stokes_dim, 1 , 4 );                                         %&%
if imag( m ) < 0                                                            %&%
  error( 'Imaginary part of the refractive index must be positive.' );      %&%
end                                                                         %&%

DEG2RAD = constants( 'DEG2RAD' );

k = 2 * pi / lambda;
x = k * r;

y = zeros( length(r), length(theta), stokes_dim, stokes_dim );


%loop over particle sizes
for i=1:length(x)
  
  %loop over scattering angle
  for l=1:length(theta)
    u          = cos(DEG2RAD*theta(l));
    S          = mie_S12(m,x(i),u);
    S11        = 1/2 * ( abs(S(1))^2 + abs(S(2))^2 )/k^2;
    y(i,l,1,1) = S11;
    %
    if stokes_dim > 1        
      S12        = 1/2 * ( abs(S(2))^2 - abs(S(1))^2 )/k^2;
      y(i,l,2,2) = S11;
      y(i,l,1,2) = S12;
      y(i,l,2,1) = S12;
      %
      if stokes_dim > 2
        S33        = 1/2 * ( S(2)*conj(S(1)) + S(1)*conj(S(2)))/k^2;
        y(i,l,3,3) = S33;
        %
        if stokes_dim > 3
          S34        = -1/2 *imag(-S(2)*conj(S(1)) + S(1)*conj(S(2))) /k^2;
          y(i,l,4,4) = S33;
          y(i,l,3,4) = S34;
          y(i,l,4,3) = -S34;
        end
      end
    end
  end
end

