% LAYERMEAN   Calculate means between adjacent vector elements
%
%    Returns a vector with one element less than the original
%    vector, containing the mean values between each two adjacent
%    elements. This is useful to calculate column quantities
%    according to the usual ARTS definition that profile grid
%    values represent point values and the profile behaves linearly
%    in-between.
%
%    If x is a matrix, then the layermean will be the matrix of
%    row means. In other words, size(m) = [size(x,1)-1,
%    size(x,2)]. In this sense, the functions behaves in analogy to
%    diff. To calculate a column value from given height profile z
%    and concentration profile c, do:
%   
%    col = sum( layermean(c) .* diff(z) )
%
% FORMAT   m = layermean(x)
%        
% OUT   m   Vector or matrix of mean values
% IN    x   Input vector or matrix
%
% 2006-02-28   Created by Stefan Buehler

function m = layermean(x)

if size(x,1) == 1			% Vector case.

  if length(x) < 2
    error( 'There must be at least two levels to calculate the mean.' );
  end

  m = ( x(1:end-1) + x(2:end) ) / 2.0;
  
else					% Matrix case

  m = ( x(1:end-1,:) + x(2:end,:) ) / 2.0;

end