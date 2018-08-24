% ATMLAB_INIT   Initializes the Atmlab package
%
%    See CONFIGURE for standard usage of this function.
%
%    The following operations are performed:
%
%     1. Atmlab folders are added to the search path. The folders are put
%        at the start of the search path (prepended).
%
%     2. If *atmlab_conf* is found, it is called. Otherwise default atmlab
%        settings are created. 
%     
%     3. Default aliases are set (see *alias*).
%
% FORMAT   atmlab_init

% 2002-12-09   Created by Patrick Eriksson.


function atmlab_init


%= Determine path to Atmlab top folder
%
toppath = fileparts( fileparts( which( 'atmlab_init' ) ) );



%= Add folders to the search path
%
% If you create a new sub-folder, it should be added here.
% Please use reversed alphabetical order.
%
addpath( fullfile( toppath, 'time' ) );
addpath( fullfile( toppath, 'tests' ) );
addpath( fullfile( toppath, 'sensors', 'atovs' ) ); 
addpath( fullfile( toppath, 'sensors' ) ); 
addpath( fullfile( toppath, 'scattering' ) ); 
addpath( fullfile( toppath, 'retrieval','qpack2' ) );
addpath( fullfile( toppath, 'retrieval','ismar','hamburg' ) ); 
addpath( fullfile( toppath, 'retrieval' ) ); 
addpath( fullfile( toppath, 'randomize','iaaft' ) ); 
addpath( fullfile( toppath, 'randomize' ) ); 
addpath( fullfile( toppath, 'physics' ) );
addpath( fullfile( toppath, 'lineshape', 'faddeeva' ) ); 
addpath( fullfile( toppath, 'mie' ) ); 
addpath( fullfile( toppath, 'math' ) ); 
addpath( fullfile( toppath, 'handy' ) ); 
addpath( fullfile( toppath, 'h2o', 'parametrisations' ) ); 
addpath( fullfile( toppath, 'h2o', 'thermodynamics' ) ); 
addpath( fullfile( toppath, 'gridcreation', 'uniformsphere' ) ); 
addpath( fullfile( toppath, 'gridcreation', 'annealing' ) ); 
addpath( fullfile( toppath, 'gridcreation' ) ); 
addpath( fullfile( toppath, 'graphs' ) );
addpath( fullfile( toppath, 'gformat' ) );
addpath( fullfile( toppath, 'geoplots', 'gmt') );
addpath( fullfile( toppath, 'geoplots' ) );
addpath( fullfile( toppath, 'geophysics' ) );
addpath( fullfile( toppath, 'geographical' ) );
addpath( fullfile( toppath, 'geodetic' ) );
addpath( fullfile( toppath, 'forwardmodel' ) );
addpath( fullfile( toppath, 'files' ) ); 
addpath( fullfile( toppath, 'demos' ) );
addpath( fullfile( toppath, 'datasets' ) ); 
addpath( fullfile( toppath, 'circular' ) ); 
addpath( fullfile( toppath, 'covmat' ) );
addpath( fullfile( toppath, 'collocations' ) ); 
addpath( fullfile( toppath, 'atmlab' ) ); 
addpath( fullfile( toppath, 'arts', 'netcdf' ) ); 
%addpath( fullfile( toppath, 'arts', 'scenegen', 'amsu' ) ); 
%addpath( fullfile( toppath, 'arts', 'scenegen' ) ); 
addpath( fullfile( toppath, 'arts', 'xml' ) ); 
addpath( fullfile( toppath, 'arts_usage' ) ); 
addpath( fullfile( toppath, 'arts' ) ); 
%
if nversion < 7.04
  addpath( fullfile( toppath, 'V7-4' ) ); 
end



%=== Read Atmlab settings
%
if exist( 'atmlab_conf' ) == 2
  atmlab_conf;
else
  atmlab('defaults');  
end

if atmlab('LEGACY_MODE')
    addpath( fullfile( toppath, 'deprecated' ) ); 
end

%=== Define some aliases
%
alias('amsub', 'mhs');
