%  MIE_ARTS_SCAT_DATA   Creates single scattering properties for spherical 
%                       particles following the ARTS format
% 
%  As input a matrix containing the refractive indices for the
%  freqeuncies and temperatures given in f_grid and T_grid is
%  required. 
%
%  The function uses the Mie code by C. Mätzler
%     
%   FORMAT  ssp = mie_arts_scat_data(f_grid,T_grid,rfr_index,theta,r) 
%   
%   OUT     ssp      single scattering data
%   IN      f_grid   frequency grid [Hz]  (vector)
%   IN      T_grid   temperature grid [K] (vector)
%   IN      rfr_ind  refractive indices, matrix with dimension
%                    [f_grid, T_grid] 
%   IN      theta    scattering angle grid [deg]
%   IN      r        particle radius [m]

%    Created by Claudia Emde.


function ssp = mie_arts_scat_data(f_grid, T_grid, rfr_ind, theta, r) 
%                                                                           %&%
rqre_alltypes( f_grid, {@isnumeric,@isvector} );                            %&%
rqre_alltypes( T_grid, {@isnumeric,@isvector} );                            %&%
rqre_datatype( rfr_ind, @istensor2 );                                       %&%
rqre_alltypes( theta, {@isnumeric,@isvector} );                             %&%
rqre_datatype( r, @istensor0 );                                             %&%
if any( imag( rfr_ind ) < 0 )                                               %&%
  error( 'Imaginary part of the refractive index must be positive.' );      %&%
end                                                                         %&%
if (size(rfr_ind,1)~=length(f_grid) | size(rfr_ind,2)~=length(T_grid))      %&%
   error('Mismatch in size between rfr_ind and f_grid or T_grid.')          %&%
end                                                                         %&%

% Particle type is 'p20' for spherical particles
ssp.ptype = 20;

ssp.description = ['Spherical particles, generated using atmlab and ',...
		           'the Mie program from C. Mätzler, particle size', ...
		           ': ', num2str(r*1e6),' microns.']; 

ssp.f_grid = f_grid;

ssp.T_grid = T_grid;

ssp.za_grid = theta;

% Set aa grid to be empty (p20)
ssp.aa_grid = [];

% Now start Mie calculations

c = constants('SPEED_OF_LIGHT');


for i = 1:length(f_grid)
  for j = 1:length(T_grid)
    % Refractive index
    m = rfr_ind(i,j); 
    
    % Calculate scattering, absorption and extinction cross-sections
  
    [K,a] = mie_ext( m, c/f_grid(i), r, 1 );

    ssp.ext_mat_data(i, j, 1, 1, 1) = K;
    ssp.abs_vec_data(i, j, 1, 1, 1) = a;

    % Calculate the phase matrix

    y = mie_phase_mat( m, c/f_grid(i), r, theta, 4 );

    ssp.pha_mat_data(i, j, :, 1, 1, 1, 1) = y(1,:,1,1);
    ssp.pha_mat_data(i, j, :, 1, 1, 1, 2) = y(1,:,2,1);
    ssp.pha_mat_data(i, j, :, 1, 1, 1, 3) = y(1,:,1,1);
    ssp.pha_mat_data(i, j, :, 1, 1, 1, 4) = y(1,:,3,3);
    ssp.pha_mat_data(i, j, :, 1, 1, 1, 5) = y(1,:,3,4);
    ssp.pha_mat_data(i, j, :, 1, 1, 1, 6) = y(1,:,3,3);   

   end
end
