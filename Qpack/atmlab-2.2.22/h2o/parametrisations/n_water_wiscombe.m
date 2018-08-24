% N_WATER_WISCOMBE   Complex refractive index for ice
%
%    The function is a temporary interface to a Fortran routine made by
%    Wiscombe. It was tested to make a mex interface to the Wiscombe 
%    function, but the compilation did not work. Instead tabulated
%    values are so far used. The tabulated values are obtained by
%       f77 -o wiscombe wiscombe.f REFICE.f REFWAT.f
%       wiscombe > wiscombe.m
%
%    The refractive index is defined to have positive imaginary part.
%    
%    No temperature dependency of *n* is provided. Data are valid for
%    280 K (set in wiscombe.f). However, the Wiscombe function has no
%    temperature dependency below 10e-6.
%
% FORMAT   n = n_water_wiscombe( lambda )
%        
% OUT   n        Complex refractive index
% IN    lambda   Vector of wavelengths [m]

% 2004-11-02   Created by Patrick Eriksson.


function n = n_water_wiscombe(lambda)

wiscombe;

b = interp1( WATER(:,1), WATER(:,2:3), lambda );

n = b(:,1) + i*b(:,2);


