% ATOVS_READ_HEADER   Read header of ATOVS data file.
%
% The function reads header of ATOVS data file and determines
% satellite and instrument IDs, data level, and a number of scanlines.
%
% FORMAT   [sat_id, inst_id, level, nlines, err] = atovs_read_header( file_name );
%
% IN    file_name   Name of an ATOVS data file.
%
% OUT   sat_id      NOAA satellite ID e.g. 14, 15, 16, 17.
%       inst_id     Instrument ID e.g. 'AMSU-B', 'AMSU-A', 'HIRS'.
%       level       Data level e.g. 'l1c' or 'notl1c'
%       nlines      Number of scanlines.
%       err         Error flag. 0 - no error, 1 - error.

% 2004-06-29   Created by Mashrab Kuvatov.


function [sat_id, inst_id, level, nlines, err] = atovs_read_header( file_name )

% we want to read this many words
rec_len = 22;

sat_id = '';
inst_id = '';
level = '';
nlines = 0;
err = 0;
  
try

% open a file
% 'b' means big-endian byte ordering
% It seems that big-endian was only necessary on Marvin (SAB 2007-12-11)
%file_id = fopen( file_name, 'r', 'b' );
file_id = fopen( file_name, 'r' );

% read header
[header, count] = fread( file_id, rec_len, 'int32' );

% close a file
fclose( file_id );

if count ~= rec_len
  disp( 'Error. Input file is not valid.' );
  err = 1;
  return
end

% number of scan lines
nlines = header( 19 );

% disp( ['Number of scanlines = ', num2str( nlines ) ] );

% satellite id (e.g. 14 for NOAA-14)
sat_id = header( 7 );

% disp( ['Satellite ID = ', num2str( sat_id )] );

% instrument ID
switch  header( 8 )
 case 5
  inst_id = 'HIRS';
 case 10
  inst_id = 'AMSU-A';
 case 11
  inst_id = 'AMSU-B';
 case 12
  inst_id = 'MHS';
end

% disp( ['Instrument ID = ', inst_id] );

if( strcmp( inst_id, 'HIRS' ) )
  level_flag = header( 21 );
else
  level_flag = header( 22 );
end

% Copied from Caroline's IDL routine rdatovs_head.pro. I do
% not know what exactly it means, neither could I find a
% documentation.

if( ( level_flag <= 0 ) || ( ( level_flag & ~59) > 0 ) )
  level = 'l1c';
else
  level = 'notl1c';
end

% disp( ['Data level = ', level] );

catch
  disp( 'Error. Most probably, input file does not exist.' );
  err = 1;
end

return
