% FILE2STRS   Converts a file to strings
%
%    The function reads an ASCII file and puts each row of the file into
%    a cell array of strings. That is, S{3} is row 3 of the file.
%
%    Newline characters are not included in the strings.
%
% FORMAT   S = file2strs( filename )
%        
% OUT   S          Cell array of strings. Each array element is a row of the
%                  file, without newline character.
% IN    filename   Name of file to read.

% 2002-12-20   Created by Patrick Eriksson.


function S = file2strs( filename )
                                                                           %&%
%= Check input                                                             %&%
%                                                                          %&%
rqre_nargin( 1, nargin );                                                  %&%


%= Open file for reading
%
fid = fileopen( filename, 'r' );


%= Loop and read one line at the time (not storing newlines)
%
j = 0;
%
while 1	
  
  s = fgetl( fid );

  if ~ischar(s)
    break 
  end

  j = j + 1;

  S{j} = s;

end


%= Close file
%
fid = fileclose( fid );