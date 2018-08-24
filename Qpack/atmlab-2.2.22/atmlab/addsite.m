function addsite

% addsite Adds site-specific directory to path
%
% To be called as soon as site-specific info is needed, but no sooner.
%
% IN  none
% OUT none

toppath = atmlab_path;

if isnan(atmlab('SITE'))
    warning('ATMLAB:nosite', 'No site configured, site-specific functions will fail');
else
    sitedir = fullfile(toppath, 'site-specific', atmlab('SITE'));
    if exist(sitedir, 'dir')
        addpath(sitedir);
%         % execute any initialisation m-files
%         W = whichfiles('*init.m', sitedir);
%         for i = 1:length(W)
%             run(W{1});
%         end
    else
        warning('ATMLAB:unkownsite','Unknown site: %s',atmlab('SITE'));
        atmlab('SITE', NaN );
    end
end