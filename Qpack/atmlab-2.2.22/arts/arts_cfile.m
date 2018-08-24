% ARTS_CFILE   Generates a complete ARTS example.
%
%    Creates a control file and corresponding input files matching the 
%    settings in a Qarts structure.
%
%    The control file is named as cfile.arts.
%
%    See *qarts2cfile* for existing choices for *runtype*. 
%
% FORMAT   arts_cfile( Q, runtype, folder )
%        
% IN    Q         Qarts structure.
%       runtype   String describing type of calculation to perform.
%       folder    The folder where to put files.

% 2004-09-23   Created by Patrick Eriksson.


function arts_cfile( Q, runtype, folder )

parts = qarts2cfile( runtype );

S = qarts2cfile( Q, parts, folder );

cfile = fullfile( folder, 'cfile.arts' );

strs2file( cfile, S );




