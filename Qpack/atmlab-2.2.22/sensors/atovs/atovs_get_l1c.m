% ATOVS_GET_L1C   Converts a file from level 1B to level 1C and reads it.
%
% This function reads ATOVS level 1c data.
%
% FORMAT   data = atovs_get_l1c( filename );
%
% IN    file_name   AMSU l1b filename.
% OUT   data        Data structure. See atovs_read_data for format
%                   description.

% 2009-11-26   Created by Oliver Lemke.

function data = atovs_get_l1c( filename )

tf = create_tmpfolder();
cleanupObject = onCleanup(@() delete_tmpfolder(tf));

atovs_file = [ tf '/atovs.l1c' ];
try
    cmd = ['zamsu2l1c.sh "' filename '" "' atovs_file '"'];
    [status,err] = system(cmd);
    if status == 6
        error('atmlab:atovs_get_l1c:zamsu2l1c','Killed')
    end
    if status ~= 0
        error('atmlab:atovs_get_l1c:zamsu2l1c', err);
    end
    data = atovs_read_data( atovs_file );
catch ME
    ME2 = MException('atmlab:atovs_get_l1c:zamsu2l1c', ME.message);
    ME2 = ME2.addCause(ME);
    ME2.throw();
end
