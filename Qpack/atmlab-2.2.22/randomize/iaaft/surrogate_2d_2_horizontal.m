% surrogate_2d_2d_horizontal
%
% This is the main program of the Iterative Amplitude Adapted Fourier
% Transform  (IAAFT) method to make surrogate fields. This version makes 2D
% fields based on the statistical properties of 2D fields. The amplitude distribution
% is supposed to be valid for the entire field (no 'vertical' profile).
%
% The IAAFT method was developped by Schreiber and Schmitz (see e.g. Phys. 
% Rev Lett. 77, pp. 635-, 1996) for statistical non-linearity tests for time series.
% This method makes fields that have a specified amplitude distribution and
% power spectral coefficients. It works by iteratively adaptation the amplitude 
% distribution and the Fourier coefficients (the phases are not changed in this 
% step). Do not use this program without understanding the function
% iaaft_loop_2d_horizontal and tuning its variables to your needs.

% This Matlab version was written by Victor Venema,
% Victor.Venema@uni-bonn.de, http:\\www.meteo.uni-bonn.de\victor, or 
% http:\\www.meteo.uni-bonn.de\victor\themes\surrogates\
% for the generation of surrogate cloud fields. 
% First version: May 2003.
% This version:  November 2003.

% Copyright (C) 2003 Victor Venema
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; version 2
% of the License.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% To get a copy of the GNU General Public License look on internet 
% or write to the Free Software Foundation, Inc., 59 Temple Place - 
% Suite 330, Boston, MA  02111-1307, USA.

% Load data.
[fourier_coeff_2d, sorted_values, x, y, template, meanValue, no_values_x, no_values_y] = load_2d_data_horizontal(1);

% Main iterative loop for 2d-surrogates
[surrogate, error_amplitude, error_spec] = iaaft_loop_2d_horizontal(fourier_coeff_2d, sorted_values);
surrogate = surrogate + meanValue;

% plot results
plot_2d_surrogate(x, y, template,  'template')
plot_2d_surrogate(x, y, surrogate, 'surrogate')