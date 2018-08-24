% LOADSTRUCTFILES   Loads and merge mat-files with data in structures
%
%    The function is useful if you have data stored in different files,
%    where each file contains a structure. The structure can have a
%    different name in each file, but the field names shall be the
%    same throughout. By using the optional argument, unnecessary fields 
%    can be ignored.
%
%    An example, where fileds 'a' and 'b' are wanted:
%       filenames = whichfiles('*.mat');
%       O = loadstructfiles(filenames,{'a','b'});
%
% FORMAT   O = loadstructfiles(filenames[,fnames])
%        
% OUT   O           Structure array with all data.
% IN    filenames   Cell array of strings with names of files to read.
% OPT   fnames      Cell array of strings with names of fields to keep.
%                   If not specified all fields will be kept.
%       verbose     Set to 1 to get a simple file counter. Default is 0.

% 2006-02-01   Created by Patrick Eriksson.


function O = loadstructfiles(filenames,varargin)
%
[fnames,verbose] = optargs( varargin, { [], 1 } );


n = 0;

for i = 1 : length(filenames)

  if verbose
    fprintf( '%d/%d\n', i, length(filenames) );
  end
  
  %= Load data into a structure as we do not know name of variable
  %
  % We can then get the varaible name by *fieldnames* and use dynamic field
  % naming (all this to avoid using *eval*).
  %
  S = load( filenames{i} );

  %= Only one variable shall be found
  %
  vname = fieldnames(S);
  %
  if length(vname) > 1
    error(sprintf('More than 1 variable in %s',filenames{i}));
  end

  if isempty(fnames)
    for j = 1:length(S.(vname{1}))
      n = n + 1;
      O(n) = S.(vname{1})(j);
    end
  else
    for j = 1:length(S.(vname{1}))
      n = n + 1;
      for k = 1:length(fnames)
        O(n).(fnames{k}) = S.(vname{1})(j).(fnames{k});
      end
    end
  end
end