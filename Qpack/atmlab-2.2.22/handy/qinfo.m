% QINFO   Prints Q structure information 
%
%    This function prints field information for a "Q-structure" if the
%    general format described in *qcheck* is followed. 
%
%    The information text shall be a plain string. Formatting of the output
%    is handled by the function, where position of row brakes is determined
%    by the Atmlab setting SCREEN_WIDTH. Row brakes can further be hard 
%    coded and are then indicated by the character '#'. Leave some space
%    after '#' if you want the new paragraph to be intended.
%
%    Some examples:
%    Assuming that *qdef* provides needed information, information for 
%    field DUMMY is obtained by:
%       qinfo(@qdef,'DUMMY');
%    A trailing wild character can also be used:
%       qinfo(@qdef,'NEW*');
%    To create a file qdoc.txt with information for all fields:
%       qinfo(@qdef,'all',''qdoc.txt');
%
% FORMAT   qinfo( qfun [, field, fid, lines ] )
%        
% IN    qfun   Pointer to function providing default structure.
% OPT   field  Field name, or 'all'. Default is all.
%       fid    File identifier(s) for output. Or name on file to create.
%              Default is to only print on screen.
%       lines  As the same argument for *out*.

% 2004-09-07   Created by Patrick Eriksson.

function qinfo( qfun, field, fid, lines )
%
if nargin < 2
  field = 'all';
end
if nargin < 3
  fid = 1;
end
if nargin < 4
  lines = true;
end

if ischar(fid)
  fid = fileopen( fid, 'w' );
  filetoclose = 1;
else
  filetoclose = 0;
end


[Q,INFO] = feval( qfun );


f1 = fieldnames( Q ); 
f2 = fieldnames( INFO ); 

ok = 1;

for i = 1 : length(f1)
  if ~isfield( INFO, f1{i} )
    fprintf('The Q-field %s is not found in INFO.\n', f1{i} );
    ok = 0;
  end
end


if length(f1) ~= length(f2)  | ~ok
  for i = 1 : length(f2)
    if ~isfield( Q, f2{i} )
      fprintf('The INFO-field %s is not defined in Q.\n', f1{i} );
      ok = 0;
    end
  end
end


if ~ok
  fprintf('\n');
  error('Inconsistency found when comparing Q and INFO.');
end


if strcmp( field, 'all' )  |  strcmp( tail(field,1), '*' )

  fields = fieldnames( INFO );

  if strcmp( tail(field,1), '*' )
    n   = length( field ) - 1;
    ind = find( strncmp( field(1:n), fields, n ) );
    if isempty(ind)
      fprintf('No fields match the search string.\n');
      return
    else
      fields = fields( ind );
    end
  end

  out(0,1,fid,lines);
  for i = 1 : length(fields)  
    printfield( fields{i}, getfield( INFO, fields{i} ), fid, lines );
    if i < length(fields)
      out(0,0,fid,lines);
    end
  end
  out(0,-1,fid,lines);


else

  if ~isfield( INFO, field )
    error(sprintf('The field %s is not recognised.', field));
  end

  s = getfield( INFO, field );

  if ~ischar( s )
    error(sprintf('Information for field %s is not a string.', field));
  end

  out(0,1,fid,lines);
  printfield( field, s, fid, lines );
  out(0,-1,fid,lines);

end


if  filetoclose 
  fileclose( fid );
end



%----------------------------------------------------------------------------

function printfield( field, s, fid, lines )
  %
  atmlab( 'require', {'SCREEN_WIDTH'} );
  ncols = atmlab( 'SCREEN_WIDTH' ) - 4;
  ls = length( s );
  %
  ind  = [find( s == ' ' ) ls+1 ];
  pind = find( s == '#' );
  ready = 0;
  i = 1;
  %
  out(0,sprintf('%s:',field),fid,lines);
  %out(0,'-',fid,lines);
  while ~ready
    j = ind(max(find( ind <= i+ncols )))-1;
    if j <= i + 2    % Fix to handle cases when SCREEN_WIDTH is smaller than
      j  = min( [ i+ncols-1 length(s) ] );  % maximum length of a "word"
      jj = 1;
    else
      jj = 2;
    end
    if any( pind <= j )
      j = min(pind) - 1;
      pind = tail( pind, length(pind)-1 );
    end
    out(0,s(i:j),fid,lines);
    i = j + jj;
    if i > ls
      ready = 1;
    end
  end
return


