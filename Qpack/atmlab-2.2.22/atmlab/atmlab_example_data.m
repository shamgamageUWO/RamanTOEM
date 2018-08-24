% ATMLAB_EXAMPLE_DATA   Returns path to Atmlab example data folder
%
%    The example data folder is found at atmlab/demos/data.
%    
% FORMAT   p = atmlab_example_data
%        
% OUT   p   String with path.

% 2004-09-26   Created by Patrick Eriksson.


function p = atmlab_example_data

p = fullfile( atmlab_path, 'demos', 'data' );
