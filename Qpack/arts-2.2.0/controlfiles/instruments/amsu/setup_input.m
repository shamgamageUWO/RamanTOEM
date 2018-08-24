function setup_input

% These variables end with _multi in arts, but the names are here shortened
% to the names used for single mixer cases
  
% AMSU-B is a true DSB instrument, but one sideband must be assigned as 
% main band and the upper band is here selected.


% Channels to include:
%
ind = 16:20;


%--- Index of "channel 0"
%
i0 = 15;



%--- Antenna response
%
% The nominal width is the same for all channels (1.1 deg).
% Grids spanning [-1,1] degrees cover 95% of the response.
% No normalisation of R performed here. Fixed by arts (with sensor_norm=1)
%
width   = 1.1;
za_grid = -1.0 : 0.1 : 1.0;
aa_grid = za_grid;
%
si    = fwhm2si( width );
[A,Z] = meshgrid( aa_grid, za_grid );
R     = mvnpdf( [Z(:) A(:)], [0 0], (si*si)*eye(2) );
R     = reshape( R, length(za_grid), length(aa_grid) );
%
G.name      = 'Antenna response function';
G.gridnames = { 'Polarisation', 'Frequency', 'Zenith angle', 'Azimuth angle' };
G.grids     = { {'1'}, 150e9, za_grid, aa_grid };
G.dataname  = 'Response';
G.data(1,1,:,:) = R;
%
%xmlStore( 'amsub.antenna.xml', G, 'GriddedField4' );
%
clear G


%--- LO frequencies
%
lo = [ 89e9, 150e9, 183.31e9, 183.31e9, 183.31e9 ];
%
%xmlStore( 'amsub.lo.xml', lo(ind-i0), 'Vector' );


%--- Main sideband (see above)
%
sideband_mode = { 'upper', 'upper', 'upper', 'upper', 'upper' };
%
%xmlStore( 'amsub.sideband_mode.xml', {sideband_mode{ind-i0}}, 'ArrayOfString' );


%--- Sideband response
%
% Is equal everywhere but frequency grids must be adjusted to channel
% width and spacing.
%
Gtmplt.name      = 'Sideband response function';
Gtmplt.gridnames = { 'Frequency' };
Gtmplt.grids     = [];
Gtmplt.dataname  = 'Response';
Gtmplt.data      = [0.5 0.5];
%
[G{1:5}]         = deal( Gtmplt );
%
G{1}.grids = { 1400e6*[-1 1] };
G{2}.grids = G{1}.grids;
G{3}.grids = { 8000e6*[-1 1] };
G{4}.grids = G{3}.grids;
G{5}.grids = G{3}.grids;
%
xmlStore( 'amsub.sideband_response.xml', {G{ind-i0}}, 'ArrayOfGriddedField1' );


%--- Center position of backend channels
%
% Frequencies must match selection of "main band"
%
G = { [89.9e9], [150.9e9], [184.31e9], [186.31e9], [190.31e9] };
%
%xmlStore( 'amsub.f_backend.xml', {G{ind-i0}}, 'ArrayOfVector' );


%--- Backend channel response functions
%
Gtmplt.name   = 'Backend channel response function';
Gtmplt.data   = [1 1];
%
G             = [];
%
G{1}{1}       = Gtmplt;
G{1}{1}.grids = { [-500 500]*1e6 };
%
G{2}{1}       = G{1}{1};
%
G{3}{1}       = Gtmplt;
G{3}{1}.grids = { [-250 250]*1e6 };
%
G{4}{1}       = G{1}{1};
%
G{5}{1}       = Gtmplt;
G{5}{1}.grids = { [-1000 1000]*1e6 };
%
%xmlStore( 'amsub.backend_channel_response.xml', {G{ind-i0}}, 'ArrayOfArrayOfGriddedField1' );


