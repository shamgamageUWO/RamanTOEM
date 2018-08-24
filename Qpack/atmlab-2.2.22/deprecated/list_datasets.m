function datasets = list_datasets(only_config)

% list_datasets Returns of a list of all datasets supported by this subsystem
%
% Return a list of all datasets supported by the subsystem. By default, it
% returns all that can be configured. If passed a true value, it only
% returns those that actually are configured.
%
% FORMAT
%
%   datasets = list_datasets([only_config])
%
% IN
%
%       only_config     logical     (optional) if true, only return those
%                                   that are actually configured and thus
%                                   can be used.
%
% OUT
%
%       datasets        cellstr     Cell array of strings, those datasets
%                                   that can be or are configured.
%
% $Id: list_datasets.m 7553 2012-04-27 19:08:16Z gerrit $

warning(['atmlab:' mfilename ':deprecated'], ...
    'list_datasets is deprecated, no longer maintained, may fail, etc.. Use ''datasets'' instead');

if ~exist('only_config', 'var')
    only_config = false;
end

D = datasets_config;
fields = fieldnames(D);
has_basedir = cellfun(@(v) strcmp(v(end-6:end), 'basedir'), fields);
datasets = cellfun(@(v) v(1:end-8), fields(has_basedir), 'UniformOutput', false);
if only_config
    datasets = datasets(cellfun(@(v) any(D.([v '_basedir'])), datasets));
end
