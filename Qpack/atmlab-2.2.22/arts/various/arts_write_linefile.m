%------------------------------------------------------------------------
% NAME:     arts_write_linefile
%
%           Creates a line file in the ARTS format.
%
%           The line data shall be given by an array of structures. The
%           field names of the structures shall equal the label name of
%           the table in absorption.h defining the ARTS line format.
%           The field names are throughout in lower case.
%           No unit conversions are performed, thus the data shall have 
%           the same unit as in the line file.
%
% FORMAT:   arts_write_linefile( filename, L [, do_quanta, do_source, do_append ])
%
% OUT:      -
% IN:       filename   Name on file to create.
%           L          Structure array with line data (see above)
% OPTIONAL: do_quanta  Flag for writing of quantum data. Default is 1. 
%           do_source  Flag for writing of source information. Default is 1.
%           do_append  Flag for appending to an existing file instead of
%                      creating a new file. Default is 0.
%------------------------------------------------------------------------

% HISTORY:  040908  Copied to Atmlab from AMI by PE.
%           020101  Created by Patrick Eriksson (PE).


function arts_write_linefile( filename, L, do_quanta, do_source, do_append )


if ~exist('do_quanta','var'),   do_quanta = 0;   end
if ~exist('do_source','var'),   do_source = 0;   end
if ~exist('do_append','var'),   do_append = 0;   end


%=== Present version number
%
vers = 3;


%=== Open the file  
if do_append   
  fid = fopen( filename, 'a' );
else
  fid = fopen( filename, 'w' );
end
if fid < 0
  error(sprintf('The file %s could not be opened.',filename));
end


%=== Write version number
%
if ~do_append
  fprintf(fid, 'ARTSCAT-%d\n', vers );
end


%=== Write data
%
for i = 1:length(L)

  fprintf(fid, '@ %s',   L{i}.name );
  fprintf(fid, ' %.9e',  L{i}.f );
  if L{i}.psf == 0
    fprintf(fid, ' 0');
  else  
    fprintf(fid, ' %.e',  L{i}.psf );
  end
  fprintf(fid, ' %e',  L{i}.i0 );
  fprintf(fid, ' %f',  L{i}.t_i0 );
  fprintf(fid, ' %e',  L{i}.elow );
  fprintf(fid, ' %f',  L{i}.agam );
  fprintf(fid, ' %f',  L{i}.sgam );
  fprintf(fid, ' %f',  L{i}.nair );
  fprintf(fid, ' %f',  L{i}.nself );
  fprintf(fid, ' %f',  L{i}.t_gam );
  fprintf(fid, ' %d',  L{i}.n_aux );
  for j = 1:L{i}.n_aux
    fprintf(fid, ' %e',  eval(['L{i}.aux',int2str(j)]) );
  end
  if L{i}.df < 0
    fprintf(fid, ' %f',  L{i}.df );
  else
    fprintf(fid, ' %e',  L{i}.df );
  end
  if L{i}.di0 < 0
    fprintf(fid, ' %f',  L{i}.di0 );
  else
    fprintf(fid, ' %f',  L{i}.di0 );
  end
  if L{i}.dagam < 0
    fprintf(fid, ' %f',  L{i}.dagam );
  else
    fprintf(fid, ' %f',  L{i}.dagam );
  end
  if L{i}.dsgam < 0
    fprintf(fid, ' %f',  L{i}.dsgam );
  else
    fprintf(fid, ' %f',  L{i}.dsgam );
  end
  if L{i}.dnair < 0
    fprintf(fid, ' %f',  L{i}.dnair );
  else
    fprintf(fid, ' %f',  L{i}.dnair );
  end
  if L{i}.dnself < 0
    fprintf(fid, ' %f',  L{i}.dnself );
  else
    fprintf(fid, ' %f',  L{i}.dnself );
  end
  if L{i}.dpsf < 0
    fprintf(fid, ' %f',  L{i}.dpsf );
  else
    fprintf(fid, ' %f',  L{i}.dpsf );
  end

  if do_quanta  &  isfield( L{i}, 'qcode' )
    fprintf(fid, ' "%s"',  L{i}.qcode );
    fprintf(fid, ' "%s"',  L{i}.qlower );
    fprintf(fid, ' "%s"',  L{i}.qupper );

    if do_source  &  isfield( L{i}, 'if' )
      fprintf(fid, ' "%s"',  L{i}.if );
      fprintf(fid, ' "%s"',  L{i}.ii0 );
      fprintf(fid, ' "%s"',  L{i}.ilw );
      fprintf(fid, ' "%s"',  L{i}.ipsf );
      fprintf(fid, ' "%s"',  L{i}.iaux );
    end
  end

  fprintf(fid, '\n');

end


%=== Close the file
fclose( fid );
