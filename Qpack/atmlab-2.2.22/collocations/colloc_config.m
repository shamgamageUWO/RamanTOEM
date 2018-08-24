function value = colloc_config(varargin)

% colloc_config Handling of Cloudsat Collocation configuration settings
%
% Deprecated.
%
% $Id: colloc_config.m 8377 2013-04-25 16:00:02Z gerrit $

persistent A


[A,value] = prstnt_struct( A, @colloc_config_defs, varargin );

end

function A = colloc_config_defs

A = struct();

% % overwrite existing collocations
% 
% A.overwrite = false;
% 
% %% maximum collocation distance and time
% 
% % used as default when no dist/interval provided upon creation of
% % CollocatedDataset object
% A.distance = 15; % km
% A.interval = 900; % seconds
% 
% %% distances to be for sure to be inside the pixel
% 
% % not used anymore in the new system, here only for backward compatibility
% A.distance_for_average_MHS = 7.5; % km
% A.distance_for_average_HIRS = 5; % For HIRS/4

end
