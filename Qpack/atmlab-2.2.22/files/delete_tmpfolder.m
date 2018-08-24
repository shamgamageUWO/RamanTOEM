% DELETE_TMPFOLDER   Removes folders in the work area.
%
%    The function removes a folder in the folder set as work area in
%    *atmlab*. See CONFIGURE for information about *atmlab*. A work area 
%    is a required setting. Only folders in the work area are removed for
%    safety reasons.
%
% FORMAT   delete_tmpfolder(tmpfolder)
%
% IN       tmpfolder   Full path of folder to remove. 

% 2011-05-03  Switch to Matlab's rmdir(...,'s') function. (OLE)
% 2005-03-04  WindowsXP and Windows2000 compatibility added by Hermann Berg
% 2005-01-27  Added force (-f) flag to unix remove command. Without this
%             the function does not work for users with alias rm='rm -i'.
%             Mattias Ekstrom
% 2002-12-20  Created by Patrick Eriksson, based on older version
%             in AMI (part of arts-1).

function delete_tmpfolder(tmpfolder)



%== Check that not debug
%
atmlab( 'require', {'DEBUG'} );
db = atmlab( 'DEBUG' );
%
if ~isnan(db) && db
  return                   % --->
end


%=== Require that a work area is set as a personal setting
%
atmlab( 'require', {'WORK_AREA'} );
workarea = atmlab( 'WORK_AREA' );
%
if ~ischar( workarea )
  error( 'WORKAREA must be a string' );
end 

if ispc  % Windows is not case sensitive for file/path names
  if ~strncmpi( workarea, tmpfolder, length(workarea) )
    error('The given directory is not inside the work area.');
  end
else
  if ~strncmp( workarea, tmpfolder, length(workarea) )
    error('The given directory is not inside the work area.');
  end
end

if (exist(tmpfolder,'dir'))
    [succ,msg] = rmdir(tmpfolder, 's');
    if (~succ), error('atmlab:delete_tmpfolder', msg); end
else
    logtext(1, [tmpfolder ' doesn''t exist. Moving on.\n']);
end
