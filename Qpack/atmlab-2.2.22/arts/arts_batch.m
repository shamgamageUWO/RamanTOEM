% ARTS_BATCH   Performs ARTS batch calculations
%
%    Largely as *arts_y* but calculates several spectra in a single run,
%    batch calculations. The data to be changed between each spectrum is
%    stored in Q.BATCH, with details described in qartsBatch.
%
% FORMAT   Y = arts_batch( Q [, workfolder] )
%        
% OUT   Y            Calculated spectra.
% IN    Q            Qarts structure.
% OPT   workfolder   If not defined or empty, a temporary folder is created.
%                    Otherwise this is interpreted as the path to a folder 
%                    where calculation output can be stored.

% 2007-10-22   Created by Patrick Eriksson.

function Y = arts_batch( Q, workfolder )
%
if nargin < 2
  workfolder = [];
end
                                                                 %&%
                                                                 %&%
%= Check input                                                   %&%
%                                                                %&%
rqre_nargin(2,nargin);                                           %&%
%                                                                %&%
rqre_datatype( Q, @isstruct );                                   %&%
rqre_datatype( workfolder, {@isempty,@ischar} );                 %&%


if isempty( workfolder )
  workfolder = create_tmpfolder;
  cu = onCleanup( @()delete_tmpfolder( workfolder ) );
end


parts = qarts2cfile( 'Batch' );
S     = qarts2cfile( Q, parts, workfolder );
cfile = fullfile( workfolder, 'cfile.arts' );
strs2file( cfile, S );
arts( cfile );


Y = xmlLoad( fullfile( workfolder, 'ybatch.xml' ) );

