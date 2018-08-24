% za_grid_opt.m
%
% OPTIMIZE_ZA_GRID
%
% Optimitation of the zenith angle grid (scat_za_grid) 
% for an ARTS scattering calculation.
%
% This script optimizes the zenith angle grid, on which
% the radiation field is stored inside ARTS. Only the intensity
% is optmized (not the other Stokes components). 
% The script works only for one latitude and longitude, so 
% it can be used for 1D calculations or homogeneous 3D 
% calculations. For inhomogeneous 3D clouds one hos to 
% optimize the full intensity field (Tensor6).
% It is sufficient to take the clearsky field for optimization. 
% The optimal grid for all altitudes inside the cloudbox is 
% calculated.
%
% To represent the radiation field accurately, the grid has 
% to be very find at angles around 90 degress. For limb spectra
% simulations, the sensor look at exactly this regions. It is 
% very important to reduce the number of grid points as far as 
% possible because computation time depends strongly on this 
% number. From my experience, optimization within an accuracy
% of 0.1% leads to sufficiently good results. 

% FORMAT  [i_approx, za_opt] = optimize_za_grid(i_field, za_grid_fine, acc)
%
% OUT   i_approx Approximated i_field
%       za_opt   Optimized grid.
% IN    i_field  Clearsky radiation field (output from ARTS).
%       za_grid_fine Fine grid used for ARTS calculation.
%       acc      Accuracy limit [%]

% 24-10-2003 Created by Claudia Emde

function [i_approx, za_opt] = optimize_za_grid(i_field, za_grid_fine, acc)

% Number of grid points in the fine grid.
N_za = length(za_grid_fine);

% Number of pressure levels. 
N_p = length(squeeze(i_field(:,1,1,1,1,1)));

% "Exact" i_field, calculated on fine za_grid  
i_exact = squeeze(i_field(:,1,1,:,1,1));


% Index vector holds indicees of the optimized grid.

% Start with the end points of the grid
indx = [1 N_za];

% The maximum difference between any point of the intensity 
% on the very fine grid and the intensity on the optimized 
% grid (linearly interpolated) in %. Arbitrary set to 100.
max_diff = 100 


% This value gives the accuracy of the optimization. 
while max_diff > acc
    
    % Create reduced grid and approximated intensity vector    
    N = length(indx);
    
    % Interpolate reduced intensity field on fine za grid 
    % for all pressure levels.
    for j = 1:N_p
        for i = 1:N
            za_reduced(i) = za_grid_fine(indx(i));
            i_approx(j,i) = i_exact(j, indx(i));
        end
        i_approx_interp = interp1(za_reduced, i_approx(j,:), za_grid_fine);
        
        % Plot (just to check, whether the method works correctly)
        % plot(za_grid, i_approx_interp);
        % hold on;
                
        % Calculate the differences between approx. i-vector and
        % exact i-vector for one pressure level. 
        diff_vec = abs(i_exact(j,:)' - i_approx_interp);
        
        % Pick out maximum value.
        [max_diff_za(j), ind_za(j)] = max(diff_vec);
    end
    % Take the maximum of the maximum differences of all 
    % pressure levels
    [max_diff_p, ind_p] = max(max_diff_za);
    
    % Take relative difference [%]
    max_diff = max_diff_p/i_exact(ind_p, ind_za(ind_p))*100;
    
    % Put the index of maximum value into index vector and sort.
    indx = [indx ind_za(ind_p)];
    indx = sort(indx);
end

% The optimized za grid:
za_opt = sort(za_reduced);




