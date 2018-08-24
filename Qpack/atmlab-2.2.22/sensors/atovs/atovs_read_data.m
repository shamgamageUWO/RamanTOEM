% ATOVS_READ_DATA   Read ATOVS level 1c data
%
% This function reads ATOVS level 1c data.
%
% FORMAT   data = atovs_read_data( file_name );
%
% IN    file_name   File name.
% OUT   data        Data structure with the following fields:
%           time    Vector of scanline time stamps in UTC [msec].
%           elev    Vector of satellite elevations [km]
%           satlat  Vector of satellite latitude* [degrees]
%           satlon  Vector of satellite longinude* [degrees]
%           lon     2D matrix (fov,scanline) of longitudes in [degrees].
%           lat     2D matrix (fov,scanline) of latitudes in [degrees].
%           lza     2D matrix (fov,scanline) of local zenith angle in
%                   [degrees].
%           laa     2D matrix (fov,scanline) of local azimuth angle in
%                   [degrees].
%           sza     2D matrix (fov,scanline) of solar zenith angle in
%                   [degrees].
%           saa     2D matrix (fov,scanline) of solar azimuth angle in
%                   [degrees].
%           tb      3D matrix (fov,channel,scanline) of brightness
%                   temperatures in [K].
%           
%       err         Error flag. 0 - no error, 1 - error.
%
% * Satellite latitude and longitude is approximated by assuming the
% average position between the two footprints closest to nadir.  L1C data
% does not contain the position explicitly.

% 2004-06-29   Created by Mashrab Kuvatov.
% 2010-11-11   Adapted by Gerrit Holl (also return angles)

function [data, err] = atovs_read_data( file_name )


% determine satellite and instrument IDs, data level,
% and number of scan lines
[sat_id, inst_id, level, nlines, err] = atovs_read_header( file_name ); %#ok<ASGLU>

if err ~= 0
  % error
  disp( 'Error. Unable to read input file.' );
  data = [];
  err = 1;
  return
end

% make sure it is level 1c data
if ~strcmp( level, 'l1c')
  % error
  disp('atmlab:atovs_read_data', 'Error. Input file must be of level 1c.' );
  data = [];
  err = 1;
  return
end

% depending on instrument, define data record format
switch inst_id
 case {'AMSU-B', 'MHS'}
  [rec_format, rec_len, nchan, nfovs] = atovs_define_amsubl1c;
 case 'AMSU-A'
  [rec_format, rec_len, nchan, nfovs] = atovs_define_amsual1c;
 case 'HIRS'
  [rec_format, rec_len, nchan, nfovs] = atovs_define_hirsl1c;
 otherwise
  error('atmlab:atovs_read_data','No known instrument: %s', inst_id)
end

% open a file
% 'b' means big-endian byte ordering
% It seems that big-endian was only necessary on Marvin (SAB 2007-12-11)
%file_id = fopen( file_name, 'r', 'b' );
file_id = fopen( file_name, 'r' );

% skip the header
fseek( file_id, rec_len * 4, -1 );

% read all records
[record, count] = fread( file_id, rec_len * nlines, 'int32' );

% close a file
fclose( file_id );

% number of scan lines read
nlines_read = count / rec_len;

% if amount of data read is less than asked
if count < rec_len * nlines
  % if some scan lines are missing, we still can go on
  if iswhole( nlines_read )
    disp( 'Warning. Some scanlines are missing.' );
  % if number of scan lines is not integer, part of a record is missing
  else
    disp( 'Error. Input file is corrupt.' );
    data = [];
    err = 1;
    return
  end
end

% Reshape read data. Result: rec_len rows and nlines_read columns
record = reshape( record, rec_len, nlines_read );

% read into the structure according to the record format
data.lon = record( rec_format.lon, : ) * .0001;
data.lat = record(  rec_format.lat, : ) * .0001;
data.time = record( rec_format.time, : );
data.lza = record(rec_format.lza, :) * .01;
data.laa = record(rec_format.laa, :) * .01;
data.sza = record(rec_format.sza, :) * .01;
data.saa = record(rec_format.saa, :) * .01;
if isfield(rec_format, 'elev')
    data.elev = record(rec_format.elev, :) * .1;
end
data.tb = reshape( record( rec_format.tb', : ) * .01, nfovs, nchan, nlines_read );

% approximate satellite position
ind = floor(size(data.lat, 1)/2);
[data.satlat, data.satlon] = geographic_mean(data.lat(ind:ind+1, :).', data.lon(ind:ind+1, :).');

end
