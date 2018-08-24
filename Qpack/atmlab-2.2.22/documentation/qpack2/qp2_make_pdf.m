% QP2_MAKE_PDF   Compiles the Qpack2 manual
%
%   The function extracts on-line documentation to be included on the PDF.
%   And runs pdflatex (twice) on qpack2.tex
%
% FORMAT   qp2_make_pdf( [clean_files] )
%
% OPT   clean_files   Flag to delete unnecessary files. Default is false.

% 2009-08-10   Created by Patrick Eriksson.


function qp2_make_pdf(clean_files)

  
wd = pwd;
%
if ~strcmp( wd(end+(-5:0)), 'qpack2' )
  error( 'This function must be executed from the qpack2 sub-folder.' );
end


sw = atmlab( 'SCREEN_WIDTH' );
     atmlab( 'SCREEN_WIDTH', 70 );

  
fid = fileopen( 'qarts.txt', 'w' );
qinfo( @qarts, 'all', fid, false );
fileclose( fid );

fid = fileopen( 'oem.txt', 'w' );
qinfo( @oem, 'all', fid, false );
fileclose( fid );

fid = fileopen( 'qp2_y.txt', 'w' );
qinfo( @qp2_y, 'all', fid, false );
fileclose( fid );


!pdflatex qpack2
!pdflatex qpack2


if nargin  &  clean_files
  delete('qarts.txt');
  delete('oem.txt');
  delete('qp2_y.txt');
  delete('qpack2.log');
  delete('qpack2.aux');
end

atmlab( 'SCREEN_WIDTH', sw );
