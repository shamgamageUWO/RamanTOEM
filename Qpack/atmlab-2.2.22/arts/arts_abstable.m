% ARTS_ABSTABLE   Creates an ARTS absorption lookup table
%
%    The function assumes that all needed fields of Q are set, and
%    calculates an absorption look-up table.
%
%    The following Qarts fields must be specified:
%       ABS_LINES
%       ABS_LINES_FORMAT
%       ABS_LINESHAPE 
%       ABS_LINESHAPE_CUTOFF
%       ABS_LINESHAPE_FACTOR
%       ABS_MODELS 
%       ABS_NLS
%       ABS_NLS_PERT
%       ABS_P
%       ABS_SPECIES
%       ABS_T
%       ABS_T_PERT 
%       ABS_VMRS 
%
%    The function *qarts_abstable* could be useful to set some of the fields
%    listed above.
%
% FORMAT   A = arts_abstable( Q [, workfolder, do_load ] )
%
% OUT   A            Absorption table structure. Can be data or file name.
% IN    Q            Qarts settings.
% OPT   workfolder   If not defined or empty, a temporary folder is created.
%                    Obtained data are then loaded into A.
%                    Otherwise this is interpreted as the path to a folder 
%                    where calculation output can be stored. These files
%                    will be left in the folder. The function output is then
%                    the name of the file holding the absorption table.
%                    Default is [].
%       do_load      Flag to force reading of data even if a work folder has 
%                    been specified.

% 2007-09-13   Created by Patrick Eriksson.


function A = arts_abstable( Q, varargin )
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


parts = qarts2cfile( 'GetAbsTable' );
S     = qarts2cfile( Q, parts, workfolder );
cfile = fullfile( workfolder, 'cfile.arts' );
strs2file( cfile, S );
arts( cfile );


fname = fullfile( workfolder, 'abs_lookup.xml' );

if ~exist( fname )                                                       %&%
  error( 'No absorption table generated. Forgot to set Q.ABSORPTION?' ); %&%
end                                                                      %&%

if folder_created  |  do_load
  A = xmlLoad( fname );
else
  A = fname;
end






