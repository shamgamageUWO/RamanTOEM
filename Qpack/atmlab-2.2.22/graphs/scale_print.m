% SCALE_PRINT   Resizes the print out of a figure
%
% FORMAT   scale_print(scfac)
%        
% IN   scfac   Scaling factor (e.g. 0.5 to shrink with factor of 2)

% 2005-01-12  Created by Patrick Eriksson.


function scale_print(scfac)


%=== Basic check of input
%
rqre_nargin( 1, nargin );


h = gcf;

pos = get( h, 'PaperPosition' );

dx = (1-scfac) * pos(3) / 2;
dy = (1-scfac) * pos(4) / 2;

set( h, 'PaperPosition', [pos(1)+dx pos(2)+dy pos(3)*scfac pos(4)*scfac ] );