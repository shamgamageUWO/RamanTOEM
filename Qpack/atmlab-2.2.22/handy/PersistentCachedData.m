classdef PersistentCachedData < CachedData
    % like CachedData but stores data on disk
    %
    % Useful to store large results of big 'read'-commands and so.
    % Default disk-stored cache-size is 10 GiB.
    %
    % !!!WARNING!!!
    %
    % DO NOT SET A CACHE-DIRECTORY THAT YOU ARE OTHERWISE USING!
    % METHODS IN THIS CLASS MIGHT DELETE FILES FROM CACHE-DIRECTORY!
    %
    % !!!WARNING!!!
    
    % $Id: PersistentCachedData.m 8941 2014-09-15 11:04:40Z olemke $
    
    properties
        % maximum size of what's stored on disk. Default 10 GiB.
        storedsize   = 10*2^30; % maxStoredSize =  10*2^30;
        minFreeSpace = 5*2^30;  % minimun free space you want left over (5GiB)
        
        % directory to store cache-files
        %
        % !!!WARNING!!!
        %
        % DO NOT SET A CACHE-DIRECTORY THAT YOU ARE OTHERWISE USING!
        % METHODS IN THIS CLASS MIGHT DELETE FILES FROM CACHE-DIRECTORY!
        %
        % !!!WARNING!!!

        cachedir;
    end
    
    methods
        function self = PersistentCachedData(cachedir)
            % pcd = PersistentCachedData(cachedir)
            %
            % See warning!
            self = self@CachedData();
            self.cachedir = cachedir;
        end
        
        function data = get_entry(self, s)
            % get entry
            
            % first try to get it from memory
            try
                data = get_entry@CachedData(self, s);
                return
            catch ME
                switch ME.identifier
                    case 'MATLAB:nonExistentField'
                        % get from disk instead
                    otherwise
                        ME.rethrow();
                end
            end
            ldfl = fullfile(self.cachedir, [s '.mat']);
            d = dir(ldfl);
            logtext(atmlab('OUT'), 'Reading from persistent cache: %s \n(which was created %s)\n', ldfl, d.date);
            
%             % Make the user aware of the age of this file
%             [text] = exec_system_cmd(sprintf('ls -l %s',ldfl));
%             x = textscan(text{1},'%s');
%             % note: this is completely dependent on 'ls -l' being the same on
%             % all systems.
%             logtext(atmlab('OUT'),'Be aware that this read file was originally created: %s\n',sprintf('%s %s %s',x{1}{6},x{1}{7},x{1}{8}))
            data = loadvar(ldfl, 'data');
        end
        
        function v = has_entry(self, s)
            if has_entry@CachedData(self, s)
                v = 1;
            elseif exist(fullfile(self.cachedir, [s '.mat']), 'file')
                v = 2;
            else
                v = 0;
            end
        end
        
        function set_entry(self, s, data, varargin)
            set_entry@CachedData(self, s, data);
            info = optargs(varargin, {struct()});
            svfl = fullfile(self.cachedir, [s '.mat']);
            logtext(atmlab('OUT'), 'Storing cache-entry to disk: %s -> %s\n', ...
                s, svfl);
            save(svfl, '-v7.3', 'data');
            logtext(atmlab('OUT'), 'New size: %s\n', ...
                nbytes2string(self.disk_cachesize()));
            if self.disk_free() + self.disk_cachesize() < self.minFreeSpace
                error(['atmlab:' mfilename ':noSpace'],'df + du = %d + %d < minFreeCache = %d', ...
                    self.disk_free(), self.disk_cachesize(), self.minFreeSpace);
            end
            if self.disk_toolarge()
                self.del_old_disk_entry()
            end
            % store info. salomon: I'll make the name a bit more unique
            % here
            infofile = fullfile(self.cachedir, ['info' [datestr(now,'ddmmyy') '-' num2str(cputime)] '.mat']);
            if exist(infofile, 'file')
                all_info = loadvar(infofile, 'all_info');
            end
            all_info.(s) = info;
            save(infofile, 'all_info');
        end
        
        function df = disk_free(self)
            % get the free space using df (output in bytes)
            % stat -f ... %a ... gives no. of blocks available
            % stat -f ... %s ... gives block size
            if ismac
                sizes = exec_system_cmd(sprintf('df %s |tail -n1|awk ''{print $4*512;}''',self.cachedir));
                df = str2double(sizes{1});
            else
                sizes = exec_system_cmd({['stat -f --printf=''%a'' ' self.cachedir], ['stat -f --printf=''%s'' ' self.cachedir]});
                df = (str2double(sizes{1}) * str2double(sizes{2}));
            end
            %x = exec_system_cmd(sprintf('df -k %s',self.cachedir));
            %df = structfun(@str2double,regexp(x{1}(regexp(x{1},'\n'):end),'^[^ ]+ +[0-9]+ +[0-9]+ +(?<bytes>[0-9]+)','names'));
            %df = df*1024;
        end
        
        function sz = disk_cachesize(self)
            d = dir(self.cachedir);
            sz = sum(arrayfun(@(x) x.bytes, d));
        end
        
        function b = disk_toolarge(self)
            b = self.disk_cachesize() > self.storedsize || self.disk_free() < self.minFreeSpace;
        end
        
        function del_old_disk_entry(self)
            % remove oldest cache-entry on disk. Should contain only
            % MAT-files!
           
            % by default, Matlab issues warnings, not errors, if deletion
            % fails. Fortunately, this can be turned into an error with
            % this undocumented Matlab code.
            % works in 8.0.0.783 (R2012b) and many older versions.
            
            X1 = warning('error', 'MATLAB:DELETE:DirectoryDeletion');
            X2 = warning('error', 'MATLAB:DELETE:FileNotFound');
            X3 = warning('error', 'MATLAB:DELETE:Permission');

            d = dir(self.cachedir);
            % all but 2 must end in .mat
            for i = 1:length(d)
                assert(any(strcmp(d(i).name, {'.', '..'})) || ...
                      ((length(d(i).name) >= 4) && strcmp(d(i).name(end-3:end), '.mat')), ...
                      ['atmlab:' mfilename ':NotACacheDir'], ...
                      ['Not a cache directory: ' self.cachedir]);
            end
            while self.disk_toolarge()
                d = dir(self.cachedir);
                d = d(~[d.isdir]); % don't include directories
                [~, i] = min(arrayfun(@(x) x.datenum, d));
                % FIXME: 
                delete(fullfile(self.cachedir, d(i).name));
            end
            
            % reset warning-config to old state
            warning(X1);
            warning(X2);
            warning(X3);
        end
    end
end
