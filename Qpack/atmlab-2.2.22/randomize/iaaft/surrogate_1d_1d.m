% surrogate_1d_1d
%
% This is the main program of the (Stochastic) Iterative Amplitude Adapted Fourier
% Transform (IAAFT or SIAAFT) method to make surrogate fields. This version makes 1D
% time series based on the statistical properties of 1D time series.
%
% The IAAFT method was developped by Schreiber and Schmitz (see e.g. Phys. 
% Rev Lett. 77, pp. 635-, 1996) for statistical non-linearity tests for time series.
% This method makes fields that have a specified amplitude distribution and
% power spectral coefficients. It works by iteratively adaptation the amplitude 
% distribution and the Fourier coefficients (the phases are not changed in this 
% step). 
% The SIAAFT algorithm was developped by me (Victor Venema). The main
% difference is just one line of code, where only a fraction of the values
% is adapted in the amplitude adaptation, instead of all values. This makes
% the algorithm more accurate, i.e. the power spectra of template and
% surrogate correspond closer. For the rest the result should be identical.
% See my homepage for more details.
% 
% Do not use this program without understanding the function
% iaaft_loop_1d and siaaft_1d and tuning its variables to your needs.

% This Matlab version was written by Victor Venema,
% Victor.Venema@uni-bonn.de, http:\\www.meteo.uni-bonn.de\victor, or 
% http:\\www.meteo.uni-bonn.de\victor\themes\surrogates\iaaft\
% for the generation of surrogate cloud fields. 
% First version:  May 2003.
% IAAFT version:  November 2003.
% SIAAFT version: October 2004.

% Copyright (C) 2003 and 2004 Victor Venema
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

algorithmVersion = 2; % 1: IAAFT, 2: SIAAFT

[fourierCoeff, sortedValues, x, template, meanValue, noValues] = load_1d_data(1);

switch algorithmVersion
    case 1
        [surrogate, errorAmplitude, errorSpec] = iaaft_loop_1d(fourierCoeff, sortedValues);
        errorAmplitude
        errorSpec
    case 2
        counterThresshold = 100; % This iteration threshold is set to 100 to make the first run fast, a better value is 1000 or 10.000.
        [surrogate, spectralDiff] = siaaft_1d(fourierCoeff, sortedValues, counterThresshold);
        spectralDiff
end
        
surrogate = surrogate + meanValue;

plot_1d_surrogate(x, template,  'template')
plot_1d_surrogate(x, surrogate, 'surrogate')
