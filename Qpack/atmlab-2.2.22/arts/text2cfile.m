% TEXT2CFILE   Help function to create a small ARTS cfile
%
%    The input to the function is a string giving each row of the control
%    file to create. The initial 'Arts{' and end '}' are included
%    automaticlly (and should not be part of the function input).
%
%    All text strings are joined into an array of string *aos*.
%
% FORMAT aos = text2cfile( s1, s2, ... )
%
% OUT   aos  An array of string, see above.
% IN    s1   First input string
%       ...

% 2014-09-13 Patrick Eriksson

function aos = text2cfile( varargin )

if atmlab('STRICT_ASSERT') & ~iscellstr(varargin)
  error( 'All input arguments must be strings' );
end
  
aos{1} = 'Arts2{'; 

for i = 1 : length(varargin)
  aos{1+i} = varargin{i};
end

aos{end+1} = '}'; 
