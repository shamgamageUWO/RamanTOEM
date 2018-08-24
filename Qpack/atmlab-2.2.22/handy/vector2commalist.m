% VECTOR2COMMALIST   Converts a vector to a comma seperated string
%
%    Creates a comma seperated string of vector elements. The vector
%    elements are converted to strings by *num2str*.
%
%    An example:
%       s = vector2commalist(0.1:0.2:1.3);
%    gives
%       s = '0.1,0.3,0.5,0.7,0.9,1.1,1.3';
%
% FORMAT   s = vector2commalist( x [,fstring] )
%        
% OUT   s         The string.
% IN    x         The vector.
% OPT   fstring   Output format. Possible choices as for sprintf.
%                 Default is '%g'.

% 2005-06-08   Created by Patrick Eriksson.


function s = vector2commalist(x,varargin)
%
[fstring] = optargs( varargin, { '%1g' } );

s = '';

for i = 1 : length(x)

  if i == 1 
    s = sprintf( '%s', num2str(x(i),fstring) );
  else
    s = sprintf( '%s,%s', s, num2str(x(i),fstring) );
  end
end

