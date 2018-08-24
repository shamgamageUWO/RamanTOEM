function outpath = path_replace_tilde(inpath)
% PATH_REPLACE_TILDE Replace tilde with full home directory path
%
% If inpath starts with ~/ or contains only ~, it is replaced by the full
% home directory path. If not or getenv('HOME') is empty, the
% unmodified path is returned.
%
% IN     inpath            String or cell array of strings with paths
% OUT    outpath           New path


% 20110-05-02 Created by Oliver Lemke

if (~numel(getenv('HOME')))
    outpath = inpath;
else
    outpath = regexprep( ...
        inpath, ...
        ['^(~' filesep() ')|(~$)'], ...
        [getenv('HOME') filesep], 'once');
end
