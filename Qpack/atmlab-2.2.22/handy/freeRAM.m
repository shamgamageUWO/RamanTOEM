function freeMB = freeRAM()
%% freeRAM
% 
% PURPOSE: 
%        Checks how much RAM is available on your computer.
% 
% OUT:    freeRAM [MB]
%
%
% Created by Salomon Eliasson
% $Id: freeRAM.m 8287 2013-03-12 10:24:14Z olemke $ 

%find how much RAM is left
if ismac
    x=regexp(exec_system_cmd('vm_stat | grep -e free -e inactive | sed s/[^0-9]//g'),'\n','split');
    freeMB = (str2double(x{1}{1})+str2double(x{1}{2}))*4096/1024/1024;
elseif isunix
    x = regexp(exec_system_cmd('free -m'),'\n','split');%MB
    [notUsed,free] = regexp(x{1}{1},'free');
    
    freeMB = str2double(x{1}{3}(free-5:free));
    if strcmp(computer,'GLNX86') %32 Bit only allows for a maximum of 3GB
        [notUsed,used] = regexp(x{1}{1},'used');
        usedMB = str2double(x{1}{3}(used-5:used));
        freeMB = 3000-usedMB; 
    end
elseif ispc
    error(['atmlab:' mfilename ':Platform'],'Function isn''t setup for pc (windows)')
end