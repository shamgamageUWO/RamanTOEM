% EXTRA   Lists non-Matlab functions.
%
%    Lists all functions in the search path that are found in non-Matlab
%    folders. Folders with a path containing both matlab and toolbox are
%    judged to be Matlab folders.
%    
%    The working directory (PWD) is not included if it is not in the 
%    search path.
%     
% FORMAT   extra

% HISTORY: 2003-03-07  Created by Patrick Eriksson


function extra


%=== Get search path and loop folders.
%
P = path;
%
while ~isempty( P )

  i = min( [ min( find( P == pathsep ) ) - 1, length(P) ] );

  if isempty( findstr( P(1:i), 'matlab' ) )  &  ...
                                       isempty( findstr( P(1:i), 'toolbox' ) )
    fprintf('===== %s =====', P(1:i) );
    dir( [ P(1:i), filesep, '*.m' ] )
  end 

  P = P((i+2):length(P));

end