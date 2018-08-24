% BACKEND_AMSUTYPE   Creates ARTS backend workspace variables
%
%    The function aims at setting up the ARTS workspace variables associated
%    with the backend, for sensor of AMSU type. The channels can have an
%    arbitrary number of passbands. The passbands of each channel are
%    assumed to have the same width. The response of each passband is
%    treated to be of rectangular type, but with some distance for the
%    transition between 0 and 1 response. 
%
%    A suitable f_grid is also created. The grid has equidistant points over
%    each passband.
%
%    The channels are described by a structure having the fields:
%     C(i).centre_f       : The centre frequency of the channel, such as
%                           183.31e9 for AMSU channel 18.
%     C(i).passband_dfs   : The position of the passbands, with respect to
%                           the centre frequency. Examples: [0], [-1e9 1e9]
%                           and [-20e6 -10e6 10e6 20e6]
%     C(i).passband_width : The FWHM of each passband of the channel.
%     C(i).length_0to1    : The length (in frequency) for the transition
%                           from 0 to 1 response.
%     C(i).passband_nf    : The number of frequencies in f_grid to cover
%                           each passband of the channel..
%
%    See the second FORMAT version for how to obtain pre-defined data for C.
%
% FORMAT [f_backend,B,f_grid] = backend_amsutype(C)
%
% OUT   f_backend   As the ARTS WSV with the same name
%       B           Matches ARTS' backend_channel_response
%       f_grid      As the ARTS WSV with the same name
% IN    C           Channel description structure vector
%
%   or
%
% FORMAT C = backend_amsutype( sensor )
%
% OUT   C      Channel description structure vector
% IN    sensor String with sensor name. The following options are at hand
%  'amsu': AMSU A and B (AMSU-B channels have index 16 to 20).
%          C.passband_nf set to give an approximate accuracy of about 0.1 K
%          (but only tested for a single case).

% 2014-03-20  Created, Patrick Eriksson


function [f_backend,B,f_grid] = backend_amsutype(C)

%- Only return pre-defined sensor specification?
%
if ischar(C)
  if nargout > 1
    error( 'If *C* is a string, there can only be one output argument.' );
  end
  f_backend = instrument_specs( C );
  return;
end
%---


% Init output arguments
%
f_backend = [];
f_grid    = [];


for i = 1 : length(C)
  
  % Check channel data
  if C(i).centre_f <= 0
    error( 'C(%d).centre_f is <= 0', i ); 
  end
  if max(abs(C(i).passband_dfs)) > 20e9
    error( 'Value(s) in C(i).passband_dfs appears too large (>20GHz)', i ); 
  end
  if ~issorted(C(i).passband_dfs)
    error( 'C(i).passband_dfs must be sorted', i ); 
  end
  if C(i).passband_width <= 0
    error( 'C(%d).passband_width is <= 0', i ); 
  end
  if C(i).passband_width > 10e9
    error( 'C(i).passband_dfs appears too large (>10>GHz)', i ); 
  end
  if length(C(i).passband_dfs) > 1  &  ...
                            C(i).passband_width > min(diff(C(i).passband_dfs))
    error( 'C(i).passband_dfs too large compared to C(i).passband_dfs' );
  end
  if C(i).length_0to1 < 1e3
    error( 'C(%d).length_0to1 is < 1 kHz', i ); 
  end
  if C(i).length_0to1 > C(i).passband_width
    error( 'C(%d).length_0to1 can not exceed C(%d).passband_width', i ); 
  end
  if C(i).passband_nf < 2
    error( 'C(%d).passband_nf is < 2', i ); 
  end
  
  
  f_backend = [ f_backend; C(i).centre_f ]; 
  
  B{i}.name      = 'Backend channel response function';
  B{i}.gridnames = { 'Frequency' };
  B{i}.dataname  = 'Response';
  %
  grid           = [];
  data           = [];
  df             = symgrid( C(i).passband_width / 2 + ...
                            C(i).length_0to1 * [-0.5;0.5] );
  %
  for j = 1 : length( C(i).passband_dfs )
    grid         = [ grid; C(i).passband_dfs(j)+df ];
    data         = [ data; 0; 1; 1; 0 ];
    
    f_grid       = [ f_grid; C(i).centre_f+C(i).passband_dfs(j)+...
                             linspace( min(df), max(df), C(i).passband_nf)' ];
  end
  %
  B{i}.grids   = { grid };
  B{i}.data    = data;

end


%- Final steps
%
f_grid = unique( f_grid );






%--------------------------------------------------------------------------

function C = instrument_specs( sensor )

switch upper( sensor )
 
 case 'AMSU'
  % Set dummy/default values
  [C(1:20).centre_f]       = deal( -1 );   % Dummy value
  [C(1:20).passband_dfs]   = deal( 0 );    % OK for 1 passband channels
  [C(1:20).passband_width] = deal( -1 );   % Dummy value
  [C(1:20).length_0to1]    = deal( 10e6 ); % OK, beside for narrow channels
  
  % Data (mainly) taken from
  % AMSU-A: http://mirs.nesdis.noaa.gov/amsua.php
  % AMSU-B: http://mirs.nesdis.noaa.gov/amsub.php
  % Some bandwidths set to be consistent with the arts include files.
    
  % Channel  1
  C(1).centre_f        = 23.800e9;
  C(1).passband_width  = 270e6;
  C(1).passband_nf     = 2;
  % Channel  2
  C(2).centre_f        = 31.400e9;
  C(2).passband_width  = 180e6;
  C(2).passband_nf     = 2;
  % Channel  3
  C(3).centre_f        = 50.300e9;
  C(3).passband_width  = 180e6;
  C(3).passband_nf     = 2;
  % Channel  4
  C(4).centre_f        = 52.800e9;
  C(4).passband_width  = 400e6;
  C(4).passband_nf     = 5;
  % Channel  5
  C(5).centre_f        = 53.596e9;
  C(5).passband_dfs    = symgrid( 115e6 );
  C(5).passband_width  = 170e6;
  C(5).passband_nf     = 5;
  % Channel  6
  C(6).centre_f        = 54.400e9;
  C(6).passband_width  = 400e6;
  C(6).passband_nf     = 8;
  % Channel  7
  C(7).centre_f        = 54.940e9;
  C(7).passband_width  = 400e6;
  C(7).passband_nf     = 7;
  % Channel  8
  C(8).centre_f        = 55.500e9;
  C(8).passband_width  = 330e6;
  C(8).passband_nf     = 5;
  % Channel  9
  C(9).centre_f        = 57.290344e9;
  C(9).passband_width  = 330e6;
  C(9).passband_nf     = 7;
  % Channel 10
  C(10).centre_f       = 57.290344e9;
  C(10).passband_dfs   = symgrid( 217e6 );
  C(10).passband_width = 78e6;
  C(10).length_0to1    = 7.8e6;
  C(10).passband_nf    = 5;
  % Channel 11
  C(11).centre_f       = 57.290344e9;
  C(11).passband_dfs   = symgrid( 322.2e6 + 48e6*[-1 1] );
  C(11).passband_width = 36e6;
  C(11).length_0to1    = 3.6e6;
  C(11).passband_nf    = 4;
  % Channel 12
  C(12).centre_f       = 57.290344e9;
  C(12).passband_dfs   = symgrid( 322.2e6 + 22e6*[-1 1] );
  C(12).passband_width = 16e6;
  C(12).length_0to1    = 1.6e6;
  C(12).passband_nf    = 4;
  % Channel 13
  C(13).centre_f       = 57.290344e9;
  C(13).passband_dfs   = symgrid( 322.2e6 + 10e6*[-1 1] );
  C(13).passband_width = 8e6;
  C(13).length_0to1    = 0.8e6;
  C(13).passband_nf    = 4;
  % Channel 14
  C(14).centre_f       = 57.290344e9;
  C(14).passband_dfs   = symgrid( 322.2e6 + 4.5e6*[-1 1] );
  C(14).passband_width = 3e6;
  C(14).length_0to1    = 0.3e6;
  C(14).passband_nf    = 3;
  % Channel 15
  C(15).centre_f       = 89.900e9;
  C(15).passband_width = 2000e6;
  C(15).passband_nf    = 2;

  % Channel 16
  C(16).centre_f       = 89.900e9;
  C(16).passband_dfs   = symgrid( 900e6 );
  C(16).passband_width = 1000e6;
  C(16).passband_nf    = 2;
  % Channel 17
  C(17).centre_f       = 150.000e9;
  C(17).passband_dfs   = symgrid( 900e6 );
  C(17).passband_width = 1000e6;
  C(17).passband_nf    = 2;
  % Channel 18
  C(18).centre_f       = 183.310e9;
  C(18).passband_dfs   = symgrid( 1000e6 );
  C(18).passband_width = 500e6;
  C(18).passband_nf    = 2;
  % Channel 19
  C(19).centre_f       = 183.310e9;
  C(19).passband_dfs   = symgrid( 3000e6 );
  C(19).passband_width = 1000e6;
  C(19).passband_nf    = 3;
  % Channel 20
  C(20).centre_f       = 183.310e9;
  C(20).passband_dfs   = symgrid( 7000e6 );
  C(20).passband_width = 2000e6;
  C(20).passband_nf    = 3;
  
 otherwise
  error( 'Unknown option for *C*.' )
end

  