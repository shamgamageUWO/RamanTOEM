% GF_LOAD   Loads gformat data saved by *gf_save*
%
% FORMAT   G = gf_load( file )
%        
% OUT   G       Loaded data
% IN    file    Name of file to read.

% 2010-01-07   Created by Patrick Eriksson.

function G = gf_load( file )
  

G = loadvar( file, 'G' );


if atmlab('STRICT_ASSERT') & ~isgformat( G )
  error( 'The file does not contain gformat data.' );
end