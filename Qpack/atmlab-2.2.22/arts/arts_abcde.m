% ARTS_ABCDE   Extracting selectable variables from an ARTS run
%
%    The purpose of this function is to make it possible to extract any
%    (or at least almost all) variable created during an ARTS run.
%
%    A "normal" calculation is performed, corresponding to *arts_y*. Such
%    an ARTS run include yCalc and calculation of jacobians (pending on
%    state of Q.J). At the end of the control file, saving of the 
%    variables specified in *vnames1* is added. These files are later 
%    loaded into Matlab and the content is copied to the output argument
%    V1.
%
%    To extract y and ppath for the case in *qarts_demo*:
%
%       Q = qarts_demo;
%       vnames1 = {'y','z_field'};
%       V1 = arts_abcde(Q,vnames1);
%
%    First element of V1 (V1{1}) will then be y, and the second element
%    z_field.
%
%    The stuff below is presently not working, but will be updated later:
%
%    It is also possible to extract indexed files. That is, file stored
%    by the WSM WriteXMLIndexed. This is done with the second pair of
%    arguments. Here the saving of the files must be included by existing
%    Q fields. WriteXMLIndexed must be called with "" as keyword argument.
%    First file is assumed to have number 1.    
%
%    All this is best described by an example. To also extract the propagation
%    path for each pencil beam direction used in *qarts_demo*:
%
%       Q.PRE_RTE_WSMS{end+1} = 'IndexSet(file_index){0}';
%       Q.RTE_AGENDA{end+1}   = 'IndexStep(file_index,file_index){}';
%       Q.RTE_AGENDA{end+1}   = 'WriteXMLIndexed(ppath){""}';
%       vnames2 = {'ppath'};
%       [V1,V2] = arts_abcde(Q,vnames1,vnames2);
%    
%    V2{1}{i} will here be the propogation path for pencil beam i.
%
% FORMAT   [V1,V2] = arts_y( Q, vnames1 [,vnames2, workfolder] )
%        
% OUT   V1        Array, containing the variables specied by *vnames1*.
%       V2        Array of arrays, corresponding to *vnames2*.
% IN    Q         Qarts structure.
%       vnames1   A string array with variable names. See further above.
% OPT   vnames2   A string array with variable names. See further above.
%       workfolder   If not defined or empty, a temporary folder is created.
%                    Otherwise this is interpreted as the path to a folder 
%                    where calculation output can be stored. These files
%                    will be left in the folder. The files are not read if
%                    corresponding output argument not is considered.
%                    Default is [].

% 2005-06-14   Created by Patrick Eriksson.


function [V1,V2] = arts_abcde(Q,vnames1,vnames2,workfolder)
%
if nargin < 4
  workfolder = [];
end
                                                                 %&%
                                                                 %&%
%= Check input                                                   %&%
%                                                                %&%
rqre_nargin(2,nargin);                                           %&%
%                                                                %&%
rqre_datatype( Q, @isstruct );                                   %&%
rqre_datatype( vnames1, @iscellstr );                            %&%
if nargin >=3                                                    %&%
  rqre_datatype( vnames2, @iscellstr );                          %&%
end                                                              %&%
%                                                                %&%
rqre_datatype( workfolder, {@isempty,@ischar} );                 %&%


if isempty( workfolder )
  workfolder = create_tmpfolder;
  cu = onCleanup( @()delete_tmpfolder( workfolder ) );
end


%= Get text for control file, but remove ending '}'
%
parts = qarts2cfile( 'y' );
S     = qarts2cfile( Q, parts, workfolder );
S     = S(1:end-1);

%= Add saving of variables
%
for i = 1:length(vnames1)
  filename = fullfile( workfolder, [ vnames1{i}, '.xml' ] ); 
  S{end+1} = sprintf('WriteXML("%s",%s,"%s")', Q.OUTPUT_FILE_FORMAT, ...
                                                        vnames1{i}, filename );
end

%= Add closing 
%
S{end+1}  = '}';

%= Create control file and run 
%
cfile = fullfile( workfolder, 'cfile.arts' );
strs2file( cfile, S );
arts( cfile );


%= Read stored variables
%
for i = 1:length(vnames1)
  filename = fullfile( workfolder, [ vnames1{i}, '.xml' ] ); 
  V1{i}     = xmlLoad( filename );
end


% Read numbered variables
%
V2 = [];
%
if nargin >= 3
  for i = 1:length(vnames2)
    j     = 1;
    ready = 0;
    while ~ready 
      filename = fullfile( workfolder, 'cfile' );
      filename = sprintf( '%s.%s.%d.xml', filename, vnames2{i}, j );
      if exist( filename, 'file' )
        V2{i}{j} = xmlLoad( filename );
        j = j + 1;
      else
        ready = 1;
      end
    end
  end
end


