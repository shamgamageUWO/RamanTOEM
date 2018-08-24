% GAUSS   The Gauss function
%
%    Calculates the scalar Gauss function:
%
%      y = 1/(s*sqrt(2*pi)) * exp(-0.5((x-m)/(s))^2)
%
%    where x is a vector.
%
% FORMAT   y = gauss(x,s,m)
%        
% OUT   y   Function values
% IN    x   Input vector
%       s   Standdard deviation
%       m   Mean

% 2006-03-02   Created by Stefan Buehler

function y = gauss(x,s,m)

y = 1.0 / ( s * sqrt(2.0*pi) ) * exp( -0.5 * ((x-m)/s).^2 );
