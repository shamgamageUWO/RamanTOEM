classdef CachedData < handle
    % Cache data rather than re-generate every time
    %
    % Sometimes, it can be somewhat tricky to implement code in a way that
    % prevents re-reading or re-calculating the exact some thing with only
    % a short time in between. Don't despair! Here is the class you'll
    % love. Just use its methods to store and retrieve data.
    %
    % Entries are stored by string. Internally, it uses a structure, so you
    % may use <a href="matlab:help genvarname">genvarname</a> to generate valid names to use for caching.
    % 
    %
    % CachedData Properties:
    %
    %   maxsize -       Maximum permitted cache size in bytes
    %
    % CachedData Methods:
    %
    %   get_entry -     Retrieve entry
    %   has_entry -     Check whether entry exists
    %   set_entry -     Set new entry and, if needed, remove old
    %   clear -         Completely clear the cache
    %   cachesize -     Get current cache-size in bytes
    %   evaluate -      Evaluate expression and cache result, or read
    %                   result from cache
    
    % $Id: CachedData.m 8720 2013-10-21 20:41:39Z gerrit $
    properties
        % maximum permitted cache size in bytes
        %
        % default 100 MiB
        maxsize = 100*2^20;
    end
    
    properties (GetAccess = private, SetAccess = private)
        cache;
    end
    
    methods
        function self = CachedData()
            self = self@handle();
            self.cache = struct();
        end
        
        function data = get_entry(self, s)
            % Retrieve entry from cache
            %
            % FORMAT
            %
            %   data = c.get_entry(s)
            
            data = self.cache.(s);
        end
        
        function b = has_entry(self, s)
            % check whether entry exists in cache
            %
            % FORMAT
            %
            %   b = c.has_entry(s)
            
            b = isfield(self.cache, s);
        end
        
        function set_entry(self, s, d)
            % sets cache entry and removes old entry if needed
            %
            % Set a cache entry and, if the size is exceeded, remove the
            % oldest entry.
            %
            % FORMAT
            %
            %   c.set_entry(s, d)
            %
            % IN
            %
            %   s   string      string by which it is stored
            %   d   any         data to be stored
            
            logtext(atmlab('OUT'), 'Setting cache entry: %s (new size: ', s);
            self.cache.(s) = d;
            fprintf(atmlab('OUT'), '%d entries, %s)\n', length(fieldnames(self.cache)), nbytes2string(self.cachesize()));
            if self.toolarge()
                self.del_old_entry();
            end
        end        
        
        function clear(self)
            % clear the cache completely
            self.cache = struct();
        end
        
        function c = cachesize(self)
            % get size in bytes
            dummy = self.cache; %#ok<NASGU>
            X = whos('dummy');
            c = X.bytes;
        end
        
        function varargout = evaluate(self, no, func, varargin)
            % Execute func(arg1, arg2, ...) if output not already cached
            %
            % This method calculates a key from all its arguments. If no
            % value is stored in association with this key, it executes
            % func(arg1, arg2, ...) and stores the results with the key,
            % then returns the results. If there is a value already stored,
            % it returns the value(s). The first argument is a number,
            % it represents the number of output arguments taken from the
            % expression.
            %
            % FORMAT
            %
            %   out = cd.evaluate(no, @func, arg1, arg2, ...)
            %
            % IN
            %
            %   no      number of output arguments. Needed because
            %           there may be a difference between y = foo(...)
            %           and [y, z] = foo(...)
            %
            %   func    function handle to function to be evaluated
            %   arg1    1st argument passed to function
            %    ...
            %   argN    nth argument passed to function
            %   'EXTRA' literal string 'EXTRA'.  The remaining arguments
            %   WILL be used to calculate the hash, but WON'T be passed on
            %   to others.  Use this e.g. when calculating obj.meth(args)
            %   for different objects (pass obj.name or so).
            %
            % OUT
            %
            %   output is as for func(arg1, ..., argN).
            %
            % EXAMPLE
            %
            %   If you have an expensive function 'y = ackermann(m, n)', 
            %   then you can cache as follows:
            %
            %   >> c = CachedData(); % create cache object
            %   >> y = c.evaluate(1, @ackermann, 4, 4) % come back a few million years later
            %   >> y = c.evaluate(1, @ackermann, 4, 4) % get result immediately
            %

            % generate a unique (?) string
            nm = genvarname(DataHash([{no, func}, varargin]));
            
            extra = 0;
            args = varargin;
            % check if any equal to 'EXTRA'
            for i = 1:length(varargin)
                if isequal(varargin{i}, 'EXTRA')
                    extra = i;
                    args = varargin(1:extra-1);
                    break;
                end
            end
            if self.has_entry(nm)
                logtext(atmlab('OUT'), 'getting %s([%d arguments]) from cache (%s)\n', ...
                    func2str(func), length(args), nm);
                varargout = self.get_entry(nm);
            else
                logtext(atmlab('OUT'), 'executing, then caching %s([%d arguments])\n', ...
                    func2str(func), length(args));
                [varargout{1:no}] = func(args{:});
                self.set_entry(nm, varargout);
            end
        end
    end
    
    methods (Access = private)
        function del_old_entry(self)
            % Remove oldest entry in cache.
            %
            % FORMAT
            %
            %   c.del_old_entry()
            flds = fieldnames(self.cache);
            logtext(atmlab('OUT'), 'Pruning cache entry %s\n', flds{1});
            self.cache = rmfield(self.cache, flds{1});
            logtext(atmlab('OUT'), 'New size: %d entries, %d bytes\n', length(fieldnames(self.cache)), self.cachesize());
        end
        

        function b = toolarge(self)
            % whether or not to remove old entry
            %
            % Check whether the current size exceeds the total size.
            b = self.cachesize() > self.maxsize;
        end
        

    end
end
