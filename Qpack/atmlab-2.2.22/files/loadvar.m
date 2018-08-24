% LOADVAR   Loads a specific variable from a MATLAB data file
%
%    The function enables direct loading of a named variable (matlab's load
%    function puts into a struct). To load the variable x from file data.mat:
%
%        x = loadvar( 'data.mat', 'x' )
%
% FORMAT   x = loadvar( filename, varname )
%
% OUT   x          Loaded variable
% IN    filename   Name of file.
%       varname    Name of variable.

% 2008-10-27   Created by Patrick Eriksson.


function x = loadvar( filename, varname )

try
    X = load( filename, varname );
catch ME
    switch ME.identifier
        case 'MATLAB:load:numColumnsNotSame'
            % Matlab tried to load as ASCII and failed.
            % Try to load as binary MAT-file instead.
            X = load(filename, varname, '-mat');
        otherwise
            ME.rethrow();
    end
end

if ~isfield( X, varname )
    error( ['atmlab:' mfilename ':variableNotFound'],...
        lastwarn);
else
    x = X.(varname);
end

end
