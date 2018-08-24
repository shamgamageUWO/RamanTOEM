% N_ICE_WARREN84   Complex refractive index for ice
%
%   Refractive index of ice following the Warren84 parameterization.
%
%   Calculates complex refractive index of Ice 1H for wavelengths
%   between 45 nm and 8.6 m.
%   For wavelengths above 167 microns, temperature dependence is
%   included for temperatures between 213 and 272K.
%   
%   This function requires that ARTS is at hand. For more information about
%   the ARTS workspace method that is used by this Atmlab function:
%      arts -d complex_refr_indexIceWarren84
%
% FORMAT   n = n_ice_warren84( f, t )
%        
% OUT   n   Complex refractive index, for each combination of f and t.
% IN    f   Frequency
%       t   Temperature

% 2014-05-27   Created by Patrick Eriksson.


function n = n_ice_warren84( f, t )
%  
rqre_datatype( f, @istensor1 );
rqre_datatype( t, @istensor1 );


%- Create workfolder?
%
workfolder = create_tmpfolder;
cu = onCleanup( @()delete_tmpfolder( workfolder ) );


%- Store input arguments to files
%
xmlStore( fullfile(workfolder,'f.xml'), f, 'Vector' );
xmlStore( fullfile(workfolder,'t.xml'), t, 'Vector' );


%- Define control file
%
S{1}     = 'Arts2{';
S{end+1} = 'VectorCreate( f )';
S{end+1} = 'VectorCreate( t )';
S{end+1} = 'ReadXML( f, "f.xml" )';
S{end+1} = 'ReadXML( t, "t.xml" )';
S{end+1} = 'complex_refr_indexIceWarren84( complex_refr_index, f, t )';
S{end+1} = 'WriteXML( "ascii", complex_refr_index, "n.xml" )';
S{end+1} = '}';


%- Run ARTS
%
cfile = fullfile( workfolder, 'cfile.arts' );
strs2file( cfile, S );
arts( cfile );


%- Load data
%
N = xmlLoad( fullfile( workfolder, 'n.xml' ) );
n = N.data(:,:,1) + i*N.data(:,:,2);
