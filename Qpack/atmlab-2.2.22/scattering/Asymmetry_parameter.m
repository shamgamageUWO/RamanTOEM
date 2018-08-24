% Asymmetry_parameter   extracts the asymmetry parameter from an array of
%                       ARTS single scattering data
%
%        Returns an array of asymmetry parameters depending on the length 
%        of T-matrix's output. 
%        The output of theT-matrix (D), is the input of the Asymmetry_parameter function.
%     
%
%
% FORMAT   g = Asymmetry_parameter(D)
%  
%
% OUT      g        Array of asymmetry parameters         [-] 
%                   Its dimension is: g{length of D}(length of f_grid , length of t_grid)
%
% IN       D        Array of ARTS single scattering data(Tmatrix's output) 
%
% History: 2014-02-10      Created by Maryam Jamali



function g = Asymmetry_parameter(D)

for i = 1 : length(D)
    for j = 1 : length (D{1,i}.f_grid) 
        for k = 1 : length (D{1,i}.T_grid) 
 
          b  =  D{1,i}.pha_mat_data(j,k,1:end,1,1,1,1) ;
          norm_factor = 1/2 * trapz ( D{1,i}.za_grid , squeeze(b) .* sind(D{1,i}.za_grid) );
 
          g{i}(j,k) = 1/2 * trapz ( D{1,i}.za_grid , cosd(D{1,i}.za_grid) .* (squeeze(b) ./ norm_factor) .* sind(D{1,i}.za_grid) );
 
        end
    end
end
