% QTOOL   Creation of control files from a template.
%
%       The data for the control file are given by the structure Q. 
%
%       The Qtool has three mechanisms to create control files from
%       templates. See the file examples/sample.tmplt for a practical 
%       example on a template file. Such a file is read by the
%       function *file2strs* and is then passed to *qtool* as a
%       string array. The string array can also be defined inside
%       a function, or a local sub-functions, and thus a seperate
%       template file can be avoided.
%
%       1. Variable substition.
%         The Qtool tries to replace everything specified between
%         $-signs by the value of the corresponding variable in the 
%         workspace. If the variable does not exist, there will be an
%         error.
%         As the data structure given to the function will have
%         locally the name Q, this name must also be used
%         in the control file template, e.g. $Q.PLAT_ALT$.
%
%       2. If statements
%         The keywords IF, ELSE and END are valid. These keywords
%         must be in uppercase and be placed in column 1.
%         Nested if-statements are not valid.
%         All logical expressions of Matlab can be used.
%
%       3. Inline functions
%         If a @-sign is found in the first column, the rest of the
%         line is treated to be the name of a function writing text
%         to the control file.
%         This function will then be called with Q and the control 
%         file identifier as input. For example "@some_fun" will 
%         result in a function call as "some_fun(Q,fid)". 
%
%       A field with name FILESEP will be added to Q. This field is 
%       set to the file seperator for the platform (a string). A 
%       folder and a file name of Q are thus combined in the template
%	as: $Q.CALCGRIDS_DIR$$Q.FILESEP$$Q.F_MONO$
%
% FORMAT   qtool(S,outfile,Q[,dbg])
%        
% IN    S         String array containing the template file.
%       outfile   Name of control file to create.
%       Q         Structure with data to paste into the template.
% OPT   dbg       Debugging mode. Default is 0. If set to 1, the input
%                 strings are displayed on the screen. The last displayed
%                 string is the one causing problems (if there are any).

% 2002-12-20   Created by Patrick Eriksson, based on the function with same
%              name in AMI.


function qtool(S,outfile,Q,dbg)


%= Input
%
rqre_nargin( 3, nargin );
%
if nargin < 4
  dbg = 0;
end 


%=== Set file sperator for the computer platfom ===============================
%
Q.FILESEP = filesep;


%=== Open output file for writing
%
fid = fileopen( outfile, 'w' );


%=== Read from string array, replace keywords etc. and write to cfile
line    = 0;
in_if   = 0;
in_else = 0;
do      = 1;
do_this = 1;

for line = 1 : length( S )

  s    = S{line};

  if dbg
    fprintf('%s\n',s);
  end

  if ~ischar(s)
    error('The array *S* contains non-string elements.');
  end

  if length(s) & double( tail( s, 1 ) ) == 10
    error('The strings shall not include the newline character.');
  end

  do_this = 1;

  if (length(s)>=3) & strcmp(s(1:3),'IF ')

    if in_if | in_else
      error(sprintf('Nested IFs found on line %d.',line));
    end

    in_if   = 1;
    in_else = 0;
    s       = deblank( s(4:length(s)) );
    if isempty(s)
      error(sprintf('IF statement without variable found on line %d.',...
                                                                    line));
    end
    if eval(s)
      do = 1;
    else
      do = 0;
    end         
    do_this = 0;

  end %if

  if (length(s)>=4) & strcmp(s(1:4),'ELSE')

    if ~in_if | in_else
      error(sprintf('Not allowed placement of ELSE at line %d.',line));
    end

    in_if   = 0;
    in_else = 1;
    do      = ~do;
    do_this = 0;

  end %else

  if (length(s)>=3) & strcmp(s(1:3),'END')

    if ~in_if & ~in_else 
      error(sprintf('Not allowed placement of END at line %d.',line));
    end

    in_if   = 0;
    in_else = 0;
    do      = 1;
    do_this = 0;

  end %else

  if do_this & do

    %= Check first if any "inline" function shall be called
    if length(s) & s(1) == '@'
      %
      eval([ s(2:length(s)), '(Q,fid);' ])

    %= Replace variables (marked by $$) and move text to cfile
    else

      if ~isempty( s )
      	dollars = find( s == '$' );
      	if ~isempty(dollars)
      	  if isodd(length(dollars))
      	    error(sprintf(...
      		       'An odd number of $-signs was found on line %d.',line));
      	  end
      	  while ~isempty(dollars)
      	    i1 = dollars(1);
      	    i2 = dollars(2);
      	    name = s((i1+1):(i2-1));
      	    if isstr(eval(name))
      	      s = [s(1:(i1-1)),eval(name),s((i2+1):length(s))];
      	    else
      	      s = [s(1:(i1-1)),num2str(eval(name)),s((i2+1):length(s))];
      	    end
      	    dollars = find( s == '$' );
      	  end
      	end
      end

      fprintf(fid,'%s\n',s);

    end % else
  end % if do...
end



fileclose( fid );



if in_if | in_else
  error('EOF reached inside IF or ELSE statement.');
end
