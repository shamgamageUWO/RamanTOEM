% ARTS_SENSOR   Calculates sensor response matrix using ARTS
%
%    Takes a qarts structure and calculates corresponding sensor reponse 
%    transfer matrix. 
%
%    The result can be returned in two different ways. 
%
%    1: Data are loaded into Q if no workfolder is specified or *do_load* is
%    set.
%
%    2. The fields of Q contain the names of created xml files if a 
%    workfolder is given (and do_load=false). This option is more efficient
%    if the data shall be used for later ARTS runs (and not inside Matlab).
%
% FORMAT   Q = arts_sensor( Q [, workfolder] )
%        
% OUT   Q            Q with the following fields set:
%                        SENSOR_RESPONSE   
%                        SENSOR_RESPONSE_F
%                        SENSOR_RESPONSE_ZA
%                        SENSOR_RESPONSE_AA
%                        SENSOR_RESPONSE_POL
%                        SENSOR_RESPONSE_F_GRID
%                        SENSOR_RESPONSE_ZA_GRID
%                        SENSOR_RESPONSE_AA_GRID
%                        SENSOR_RESPONSE_POL_GRID
%                        ANTENNA_DIM        
%                        MBLOCK_ZA_GRID     
%                        MBLOCK_AA_GRIDS
%                    See further above.
% IN    Q            Qarts structure.
% OPT   workfolder   If not defined or empty, a temporary folder is created.
%                    Otherwise this is interpreted as the path to a folder 
%                    where calculation output can be stored. These files
%                    will be left in the folder. The files are not read if
%                    corresponding output argument not is considered.
%                    Default is [].
%       do_load      Flag to trigger loading even if a workfolder has been
%                    given.

% 2007-08-22   Created by Patrick Eriksson.


function Q = arts_sensor( Q, varargin )
%
[workfolder,do_load] = optargs( varargin, { [], false } );
                                                                 %&%
%= Check input                                                   %&%
%                                                                %&%
rqre_nargin(1,nargin);                                           %&%
%                                                                %&%
rqre_datatype( Q, @isstruct );                                   %&%
rqre_datatype( workfolder, {@isempty,@ischar} );                 %&%
rqre_datatype( do_load, @isboolean );                            %&%


if isempty( workfolder )
  workfolder = create_tmpfolder;
  cu = onCleanup( @()delete_tmpfolder( workfolder ) );
  folder_created = 1;
else
  folder_created = 0;  
end


%= Run ARTS
%
parts = qarts2cfile( 'GetSensor' );
S     = qarts2cfile( Q, parts, workfolder );
cfile = fullfile( workfolder, 'cfile.arts' );
strs2file( cfile, S );
arts( cfile );


if nargout
  
if folder_created  |  do_load
  Q.SENSOR_RESPONSE = ...
                 xmlLoad( fullfile( workfolder, 'sensor_response.xml' ) );
  Q.SENSOR_RESPONSE_F = ...
                 xmlLoad( fullfile( workfolder, 'sensor_response_f.xml' ) );
  Q.SENSOR_RESPONSE_ZA = ...
                 xmlLoad( fullfile( workfolder, 'sensor_response_za.xml' ) );
  Q.SENSOR_RESPONSE_AA = ...
                 xmlLoad( fullfile( workfolder, 'sensor_response_aa.xml' ) );
  Q.SENSOR_RESPONSE_POL = ...
                 xmlLoad( fullfile( workfolder, 'sensor_response_pol.xml' ) );
  Q.SENSOR_RESPONSE_F_GRID = ...
              xmlLoad( fullfile( workfolder, 'sensor_response_f_grid.xml' ) );
  Q.SENSOR_RESPONSE_ZA_GRID = ...
              xmlLoad( fullfile( workfolder, 'sensor_response_za_grid.xml' ) );
  Q.SENSOR_RESPONSE_AA_GRID = ...
              xmlLoad( fullfile( workfolder, 'sensor_response_aa_grid.xml' ) );
  Q.SENSOR_RESPONSE_POL_GRID = ...
              xmlLoad( fullfile( workfolder, 'sensor_response_pol_grid.xml' ) );
  Q.ANTENNA_DIM = ...
                 xmlLoad( fullfile( workfolder, 'antenna_dim.xml' ) );
  Q.MBLOCK_ZA_GRID = ...
                 xmlLoad( fullfile( workfolder, 'mblock_za_grid.xml' ) );
  Q.MBLOCK_AA_GRID = ...
                 xmlLoad( fullfile( workfolder, 'mblock_aa_grid.xml' ) );
else
  Q.SENSOR_RESPONSE     = fullfile( workfolder, 'sensor_response.xml' );
  Q.SENSOR_RESPONSE_F   = fullfile( workfolder, 'sensor_response_f.xml' );
  Q.SENSOR_RESPONSE_ZA  = fullfile( workfolder, 'sensor_response_za.xml' );
  Q.SENSOR_RESPONSE_AA  = fullfile( workfolder, 'sensor_response_aa.xml' );
  Q.SENSOR_RESPONSE_POL = fullfile( workfolder, 'sensor_response_pol.xml' );
  Q.SENSOR_RESPONSE_F_GRID = ...
                         fullfile( workfolder, 'sensor_response_f_grid.xml' );
  Q.SENSOR_RESPONSE_ZA_GRID = ...
                         fullfile( workfolder, 'sensor_response_za_grid.xml' );
  Q.SENSOR_RESPONSE_AA_GRID = ...
                         fullfile( workfolder, 'sensor_response_aa_grid.xml' );
  Q.SENSOR_RESPONSE_POL_GRID = ... 
                         fullfile( workfolder, 'sensor_response_pol_grid.xml' );
  Q.ANTENNA_DIM         = fullfile( workfolder, 'antenna_dim.xml' );
  Q.MBLOCK_ZA_GRID      = fullfile( workfolder, 'mblock_za_grid.xml' );
  Q.MBLOCK_AA_GRID      = fullfile( workfolder, 'mblock_aa_grid.xml' );
end

end

