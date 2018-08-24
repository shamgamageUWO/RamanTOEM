% ARTS_AUTOSET_INCLUDES   Sets ARTS_INCLUDES to match ARTS_PATH
%
%    This function sets atmlab('ARTS_INCLUDES') based on atmlab('ARTS_PATH'),
%    to ensure consistency between arts version and include files used.
%
% FORMAT   arts_autoset_includes

% 2014-05-21   Created by Patrick Eriksson.

function arts_autoset_includes

p = atmlab( 'ARTS_PATH' );

if isnan(p) | isempty(p) 
  error( 'atmlab(''ARTS_PATH'') gives NaN or [].' );
end
if exist(p) ~= 2
  error( 'atmlab(''ARTS_PATH'') returns an invalid path.' );
end

artsdir = fileparts( fileparts( fileparts( p ) ) );

atmlab( 'ARTS_INCLUDES', fullfile( artsdir, 'controlfiles', 'general') );
