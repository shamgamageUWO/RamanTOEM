function verify_colloc_constants

% verify_colloc_constants Check colloc_constants for consistency
%
% colloc_constants defines columns more or less twice, for historical
% reasons. Once in .overlap/.data/.meandata, and once in .stored.
% This m-file checks that they are consistent.
%
% There is no input and nothing is returned, but all 'missing' entries are
% printed to stdout. A human (such as Gerrit) should then interpret whether
% this is okay.

% Gerrit Holl 2011-06-14
%
% $Id: verify_colloc_constants.m 7017 2011-06-14 16:13:46Z gerrit $

% those names are allowed to be missing in .stored
special_names = {'filter_double', 'NCOLS'};

constants = colloc_constants();
allnames = fieldnames(constants);
for f = allnames.'
    fn = f{1};
    if strcmp(fn(1:4), 'cols')
        cols = constants.(fn);
        stored_names = fieldnames(cols.stored).';
        internal_names = [fieldnames(cols.overlap).' fieldnames(cols.data).'];
        if isfield(cols, 'meandata')
            internal_names = [internal_names fieldnames(cols.meandata).'];
        end
        % verify all internal names are also in stored names
        for intrn = internal_names
            if ~(ismember(intrn{1}, stored_names) || ...
                 ismember(intrn{1}, special_names))
                logtext(1, 'internal but not stored: %s, %s\n', fn, intrn{1});
            end
        end
        for strd = stored_names
            if ~(ismember(strd{1}, internal_names))
                logtext(1, 'stored but not internal: %s, %s\n', fn, strd{1});
            end
        end
    end
end
end
