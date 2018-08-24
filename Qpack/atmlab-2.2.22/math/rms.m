% RMS Calculate root mean square (RMS)
%
% This function squares all elements of x, sums them up, divides by
% the number of elements, and takes the root.
%
% Input x can be a vector, matrix, or higher order tensor, the
% output is always a scalar
%
% FORMAT y = rms(x)
%
% OUT    y	RMS value
% IN     x      Input vector or matrix
%
% 2008-09-02 Created by Stefan Buehler
 
function y = rms(x)

xs = x(:) .* x(:);

s  = sum(xs) / length(x(:));

y  = sqrt(s);

