%------------------------------------------------------------------------
% NAME:     arts_read_linefile
%
%           Reads a line file in the ARTS format.
%
%           The output is in the format expected by ARTS_WRITE_LINEFILE.
%           See further ARTS_WRITE_LINEFILE for definition of the structure
%           field names.
%
%           The optional arguments can be used to restrict the reading.
%
% FORMAT:   L = arts_read_linefile( filename [, flims, sorted, ilim ] )
%
% OUT:      L          Structure array with line data.
% IN:       filename   Name on file to create.
% OPTIONAL: flims      Frequency limits, as [f_low,f_high], for transitions
%                      to consider. Default is [0 Inf].
%           sorted     Flag indicating if transitions are sorted in
%                      frequency. If set to true, the reading is terminated
%                      as soon as a transition above flims(2) is found.
%                      Default is false.
%           ilim       Threshold for transition intensity. Transitions with
%                      an intensity below *ilim* are ignored. Default is 0.
%------------------------------------------------------------------------

% HISTORY:  040908  Copied to Atmlab from AMI by PE.
%           020101  Created by Patrick Eriksson (PE).


function L = arts_read_linefile( filename, flims, sorted, ilim )


%=== Default values
%
flims_DEFAULT  = [0 Inf];
sorted_DEFAULT = 0;
ilim_DEFAULT   = 0;
%
set_defaults;



%=== Present version number
%
vers = 3;


%=== Open the file     
fid = fopen( filename, 'r' );
if fid < 0
  error(sprintf('The file %s could not be opened.',filename));
end


%=== Check that this is a ARTSCAT file and the version number is correct
%
s     = fgets( fid );
%
if ~strncmp( s, 'ARTSCAT-', 8 )
  error('An ARTS line file must start with "ARTSCAT-"');
end
%
stest = sprintf('ARTSCAT-%d', vers );
%
if ~strncmp( s, stest, length(stest) )
  serr = sprintf('The line file has not the correct version number\n');
  serr = sprintf('%s(it should be %d)',serr,vers);
  error( serr );
end



%=== Read lines 
%
S     = next_line( fid );
n     = 0;
%
L     = [];
%
while ~isempty(S)

  f = sscanf( S{2}, '%f' );

  if sorted  &  f >= flims(2)
    break
  end
  
  i0 = sscanf( S{4}, '%f' );
  
  if f >= flims(1)  &  f <= flims(2)  &  i0 >= ilim
    %
    n = n + 1;
    %
    for i = 1:length(S)
  
      switch i
  
       case 1
         L{n}.name = S{i};
        
       case 2
         L{n}.f = f;
     
       case 3
         L{n}.psf = sscanf( S{i}, '%f' );
     
       case 4
         L{n}.i0 = i0;
     
       case 5
         L{n}.t_i0 = sscanf( S{i}, '%f' );
     
       case 6
         L{n}.elow = sscanf( S{i}, '%f' );
     
       case 7
         L{n}.agam = sscanf( S{i}, '%f' );
     
       case 8
         L{n}.sgam = sscanf( S{i}, '%f' );
     
       case 9
         L{n}.nair = sscanf( S{i}, '%f' );
     
       case 10
         L{n}.nself = sscanf( S{i}, '%f' );
     
       case 11
         L{n}.t_gam = sscanf( S{i}, '%f' );
     
       case 12
         L{n}.n_aux = sscanf( S{i}, '%f' );
         n_aux      = L{n}.n_aux;
         %
         % Aux variables are handled below otherwise
     
       case 13 + n_aux
         L{n}.df = sscanf( S{i}, '%f' );
     
       case 14 + n_aux
         L{n}.di0 = sscanf( S{i}, '%f' );
     
       case 15 + n_aux
         L{n}.dagam = sscanf( S{i}, '%f' );
     
       case 16 + n_aux
         L{n}.dsgam = sscanf( S{i}, '%f' );
     
       case 17 + n_aux
         L{n}.dnair = sscanf( S{i}, '%f' );
     
       case 18 + n_aux
         L{n}.dnself = sscanf( S{i}, '%f' );
     
       case 19 + n_aux
         L{n}.dpsf = sscanf( S{i}, '%f' );
     
       case 20 + n_aux
         L{n}.qcode = sscanf( S{i}, '%s' );
     
       case 21 + n_aux
         L{n}.qlower = sscanf( S{i}, '%s' );
     
       case 22 + n_aux
         L{n}.qlower = sscanf( S{i}, '%s' );
     
       case 23 + n_aux
         L{n}.if = sscanf( S{i}, '%s' );
     
       case 24 + n_aux
         L{n}.ii0 = sscanf( S{i}, '%s' );
     
       case 25 + n_aux
         L{n}.ilw = sscanf( S{i}, '%s' );
     
       case 26 + n_aux
         L{n}.ipsf = sscanf( S{i}, '%s' );
     
       case 27 + n_aux
         L{n}.iaux = sscanf( S{i}, '%s' );
      
       otherwise
         %
         if i <= 12+n_aux
           eval(['L{i}.aux',int2str(i-11)]) = sscanf( S{i}, '%f' );
         else
           error(sprintf('To many fields found for line %d.',n));
         end
      end
    end 
  end
  %
  S = next_line( fid );
  %
end


fclose( fid );

return



%------------------------------------------------------------------------------

function S = next_line( fid )

  S = [];

  %= Just return if EOF
  if feof(fid)
    return
  end

  %= Read next line
  sin = fgets( fid );

  %= Return if empty line
  if length(sin) < 2
    return
  end

  %= Read until next line that starts with @ and replace line feeds 
  %= with a blank
  %
  if sin(1) ~= '@'
    serr = sprintf('Could not read linefile at:\n%s',sin);
    error( serr );
  end
  % 
  s = [ sin( 3 : (length(sin)-1) ), ' ' ];
  %
  c1 = fscanf(fid,'%c',1);
  %
  while ~isempty(c1) & c1~='@'
    %
    fseek(fid,-1,'cof');   
    %
    sin = fgets( fid );
    s   = [ s, sin( 1 : (length(sin)-1) ), ' ' ];
    %
    c1 = fscanf(fid,'%c',1);
  end

  %= Back one step in the file
  fseek(fid,-1,'cof');   

  %= Field index 
  i = 0;

  while 1

    i = i + 1;

    %= Text field inside " "
    %
    if s(1) == '"'
      %
      iprims = find( s == '"' );
      %
      if length(iprims) < 2
        error('Unmatched " found.');
      end
      %
      S{i} = s(2:(iprims(2)-1));
      %
      l = iprims(2);

    %= Other field
    %
    else

      %= Find field seperations
      iblank = find( s == ' ' );

      %= Pick out text until first blank
      l    = iblank(1) - 1;    
      S{i} = s(1:l);

    end

    %= Remove used text
    s = s( (l+1):length(s) );

    %= Remove blanks at the start of s (if no-blanks, we are ready)
    ichars = find( s ~= ' ' );
    if isempty( ichars )
      return;
    end
    s = s( ichars(1):length(s) );
 
  end
return
  
