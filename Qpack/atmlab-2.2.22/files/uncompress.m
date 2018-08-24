function filename = uncompress(compfile,varargin)
%% uncompress
%
% Purpose: uncompress a file and return the name of the uncompressed file
%
% IN        compfile        full path to compressed file
%           tmpdir          The directory you want to uncompress it into
%                           (optional, defaults to atmlab('WORK_AREA'))
%           flags           structure with additional flags:
%               unidentified --- what to do if compressed file not recognised?
%                   'ignore'    default, do nothing
%                   'warn'      write a message
%                   'error'     issue an error
%               tool --- what to use for uncompressing?
%                   'shell'     default, use a shell call. Fastest.
%                   'builtin'   Matlab builtin. May work when shell fails.
%
% OUT       filename        The fullpath to the uncompressed filename.
%                           Empty if the file was never uncompressed.
%
% NOTE
%           - Known compression formats are .gz, .zip, and .bz2
%           - BEWARE: If the input file "compfile" is not uncompressed by this
%           function (not recognised as a compressed file), filename = compfile.
%
% Salomon Eliasson and others
% $Id: uncompress.m 8371 2013-04-23 15:42:12Z gerrit $

[tmpdir, flags] = optargs(varargin, {atmlab('WORK_AREA'), struct()});
flags = optargs_struct(flags, struct('unidentified', 'ignore', 'tool', 'shell'));

[~,tmpfile,fend] = fileparts(compfile);

switch fend
    case '.zip'
        switch flags.tool
            case 'shell'
                out = exec_system_cmd(sprintf('unzip %s -d %s',compfile,tmpdir),atmlab('DEBUG'));
                filename = strtrim(out{1}(strfind(out{1}, 'inflating:')+length('inflating:')+1:end));
            case 'builtin'
                filename = cur(unzip(compfile, tmpdir), 1);
            otherwise
                dunno(tool)
        end
    case '.gz'
        filename = fullfile(tmpdir,tmpfile);
        exec_system_cmd(sprintf('gunzip -c %s > %s',compfile,filename),atmlab('DEBUG'));
    case '.bz2'
        filename = fullfile(tmpdir,tmpfile);
        exec_system_cmd(sprintf('bunzip2 -c %s > %s',compfile,filename),atmlab('DEBUG'));
    otherwise
        switch flags.unidentified
            case 'ignore'
                % do nothing...
            case 'warn'
                logtext(atmlab('OUT'), ...
                'Did not uncompress %s because I didn''t recognise the compression', ...
                    compfile);
            case 'error'
                error(['atmlab:' mfilename ':unidentified'], ...
                    'I tried to uncompress %s, but I don''t know how!', ...
                        compfile);
            otherwise
                error(['atmlab:' mfilename], 'Unknown flag %s=%s', ...
                    'unidentified', flags.unidentified);
        end
        filename = compfile;
end

end

function dunno(tool)
% issue error
ME = MException(['atmlab:' mfilename ':unknown'], ...
    'Unknown tool: %s.  Read help.', tool);
ME.throwAsCaller();
end
